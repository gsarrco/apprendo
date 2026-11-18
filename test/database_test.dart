import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:apprendo/data/database.dart';
import 'package:apprendo/domain/models.dart';
import 'package:apprendo/export/export_file.dart';
import 'package:drift/native.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  CardDoc newCard(String id, String deckId, {String? due, int state = 0}) =>
      CardDoc(
        id: id,
        deckId: deckId,
        front: 'front $id',
        back: 'back $id',
        due: due ?? DateTime.now().toIso8601String(),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        state: state,
      );

  test('deck insert, watch and rename', () async {
    await db.insertDeck(Deck(
      id: 'd1',
      name: 'Deck One',
      keepAttachmentsOffline: false,
      createdAt: 100,
    ));
    final decks = await db.watchDecks().first;
    expect(decks.single.name, 'Deck One');
    await db.renameDeck('d1', 'Renamed');
    expect((await db.watchDecks().first).single.name, 'Renamed');
  });

  test('cached watch streams replay the latest value to late subscribers',
      () async {
    await db.insertDeck(Deck(
        id: 'd1', name: 'D', keepAttachmentsOffline: false, createdAt: 1));
    await db.insertCard(CardDoc(
      id: 'c1',
      deckId: 'd1',
      front: 'f',
      back: 'b',
      frontAttachments: const [],
      backAttachments: const [],
      due: '2026-01-01T00:00:00.000Z',
      createdAt: 1,
      updatedAt: 1,
    ));
    await db.watchDecks().first;
    expect((await db.watchDecks().first).single.id, 'd1');
    await db.watchCards('d1').first;
    expect((await db.watchCards('d1').first).single.id, 'c1');
  });

  test('card insert with attachments round-trips', () async {
    await db.insertDeck(Deck(
        id: 'd1', name: 'D', keepAttachmentsOffline: false, createdAt: 1));
    final card = CardDoc(
      id: 'c1',
      deckId: 'd1',
      front: 'front',
      back: 'back',
      frontAttachments: [
        CardAttachment(
          type: AttachmentType.image,
          url: 'https://example.com/a.png',
          caption: 'a',
          attribution: 'Author — CC',
          createdAt: 5,
        ),
        CardAttachment(
          type: AttachmentType.audio,
          url: null,
          caption: 'clip',
          blobContent: 'data:audio/ogg;base64,AAA',
          createdAt: 6,
        ),
      ],
      backAttachments: const [],
      due: '2026-01-01T00:00:00.000Z',
      createdAt: 1,
      updatedAt: 1,
    );
    await db.insertCard(card);
    final loaded = (await db.getCardsOfDecks(['d1'])).single;
    expect(loaded.front, 'front');
    expect(loaded.frontAttachments.length, 2);
    expect(loaded.frontAttachments[0].type, AttachmentType.image);
    expect(loaded.frontAttachments[0].attribution, 'Author — CC');
    expect(loaded.frontAttachments[1].blobContent, 'data:audio/ogg;base64,AAA');
    expect(loaded.frontAttachments[1].type, AttachmentType.audio);
    // ordering preserved
    expect(loaded.frontAttachments[0].caption, 'a');
  });

  test('deleting a deck cascades to cards and attachments but keeps logs',
      () async {
    await db.insertDeck(Deck(
        id: 'd1', name: 'D', keepAttachmentsOffline: false, createdAt: 1));
    await db.insertCard(newCard('c1', 'd1'));
    await db.insertReviewLog(ReviewLog(
      id: 'l1',
      cardId: 'c1',
      rating: 3,
      state: 1,
      due: '2026-01-01T00:00:00.000Z',
      stability: 1,
      difficulty: 5,
      elapsedDays: 0,
      lastElapsedDays: 0,
      scheduledDays: 0,
      learningSteps: 1,
      review: '2026-01-01T00:00:00.000Z',
    ));
    await db.deleteDecks(['d1']);
    expect(await db.getCardsOfDecks(['d1']), isEmpty);
    // logs survive card deletion (web parity)
    expect((await db.getReviewLogsOfCards(['c1'])).length, 1);
  });

  test('watchDueCards filters by due date and deck', () async {
    await db.insertDeck(Deck(
        id: 'd1', name: 'D', keepAttachmentsOffline: false, createdAt: 1));
    await db.insertDeck(Deck(
        id: 'd2', name: 'D2', keepAttachmentsOffline: false, createdAt: 2));
    final now = DateTime.now();
    await db.insertCard(newCard('c1', 'd1',
        due: now.toIso8601String()));
    await db.insertCard(newCard('c2', 'd1',
        due: now.add(const Duration(days: 3)).toIso8601String()));
    await db.insertCard(newCard('c3', 'd2',
        due: now.toIso8601String()));
    final due = await db
        .watchDueCards(['d1'], nowIso: now.toIso8601String())
        .first;
    expect(due.map((c) => c.id).toList(), ['c1']);
  });

  test('study tag deck membership updates', () async {
    await db.insertDeck(Deck(
        id: 'd1', name: 'D', keepAttachmentsOffline: false, createdAt: 1));
    await db.insertDeck(Deck(
        id: 'd2', name: 'D2', keepAttachmentsOffline: false, createdAt: 2));
    await db.insertStudyTag(StudyTag(
        id: 't1', name: 'Tag', deckIds: ['d1'], createdAt: 3));
    await db.setStudyTagDecks('t1', ['d1', 'd2']);
    final tag = await db.getStudyTag('t1');
    expect(tag!.deckIds, containsAll(['d1', 'd2']));
    await db.setStudyTagDecks('t1', ['d2']);
    expect((await db.getStudyTag('t1'))!.deckIds, ['d2']);
  });

  test('offline attachment download bookkeeping', () async {
    await db.insertDeck(Deck(
        id: 'd1', name: 'D', keepAttachmentsOffline: false, createdAt: 1));
    await db.insertCard(CardDoc(
      id: 'c1',
      deckId: 'd1',
      front: 'f',
      back: 'b',
      frontAttachments: [
        CardAttachment(
            type: AttachmentType.image,
            url: 'https://example.com/a.png',
            caption: 'a',
            createdAt: 5),
        CardAttachment(
            type: AttachmentType.image,
            url: null,
            caption: 'b',
            blobContent: 'data:image/png;base64,AAA',
            createdAt: 6),
      ],
      due: DateTime.now().toIso8601String(),
      createdAt: 1,
      updatedAt: 1,
    ));
    expect(await db.countPendingAttachments('d1'), 1);
    final card = (await db.getCardsOfDecks(['d1'])).single;
    final pendingRow = card.frontAttachments
        .firstWhere((a) => a.blobContent == null);
    await db.setAttachmentBlob(pendingRow.rowId!, 'data:image/png;base64,BBB');
    expect(await db.countPendingAttachments('d1'), 0);
    await db.removeDeckBlobContent('d1');
    final stripped = (await db.getCardsOfDecks(['d1'])).single;
    expect(stripped.frontAttachments[0].blobContent, isNull);
    // the local upload (url == null) keeps its blob
    expect(stripped.frontAttachments[1].blobContent,
        'data:image/png;base64,AAA');
  });

  test('export round-trips through JSON', () async {
    await db.insertDeck(Deck(
        id: 'd1', name: 'D', keepAttachmentsOffline: true, createdAt: 1));
    await db.insertCard(CardDoc(
      id: 'c1',
      deckId: 'd1',
      front: 'f',
      back: 'b',
      frontAttachments: [
        CardAttachment(
            type: AttachmentType.audio,
            url: 'https://example.com/a.ogg',
            caption: 'a',
            attribution: 'X — CC',
            languageQid: 'Q1860',
            createdAt: 5),
      ],
      due: '2026-01-01T00:00:00.000Z',
      stability: 1.5,
      difficulty: 5.5,
      reps: 2,
      lapses: 1,
      state: 2,
      scheduledDays: 3,
      lastReview: '2025-12-29T00:00:00.000Z',
      createdAt: 10,
      updatedAt: 20,
    ));
    await db.insertReviewLog(ReviewLog(
      id: 'l1',
      cardId: 'c1',
      rating: 3,
      state: 2,
      due: '2025-12-29T00:00:00.000Z',
      stability: 1.5,
      difficulty: 5.5,
      elapsedDays: 3,
      lastElapsedDays: 0,
      scheduledDays: 3,
      learningSteps: 0,
      review: '2026-01-01T00:00:00.000Z',
    ));
    await db.insertStudyTag(StudyTag(
        id: 't1', name: 'Tag', deckIds: ['d1'], createdAt: 2));

    final export = await buildExport(db, ['d1']);
    final json = export.encode();

    // Restore into a fresh database and compare.
    final db2 = AppDatabase(NativeDatabase.memory());
    addTearDown(db2.close);
    await restoreExport(db2, parseExport(json));

    final restored = await buildExport(db2, ['d1']);
    expect(restored.decks.single.name, 'D');
    final card = restored.cards.single;
    expect(card.frontAttachments.single.languageQid, 'Q1860');
    expect(card.stability, 1.5);
    expect(card.state, 2);
    expect(restored.reviewlogs.single.rating, 3);
    expect(restored.studytags.single.deckIds, ['d1']);

    // Excluding review logs omits them.
    final noLogs = await buildExport(db, ['d1'], includeReviewLogs: false);
    expect(noLogs.reviewlogs, isEmpty);
  });

  test('imports the original web app fixtures', () async {
    final decksJson =
        await File('test/fixtures/web_decks.json').readAsString();
    final cardsJson =
        await File('test/fixtures/web_cards.json').readAsString();
    final logsJson =
        await File('test/fixtures/web_reviewlogs.json').readAsString();
    final envelope = {
      'format': 'apprendo-export',
      'version': 1,
      'exportedAt': 1784369956908,
      'decks': jsonDecode(decksJson),
      'cards': jsonDecode(cardsJson),
      'reviewlogs': jsonDecode(logsJson),
      'studytags': [],
    };
    final file = parseExport(jsonEncode(envelope));
    expect(file.decks.length, 2);
    await restoreExport(db, file);
    final restored = await db.getCardsOfDecks(file.decks.map((d) => d.id).toList());
    expect(restored.length, file.cards.length);
    final withAttachments =
        restored.where((c) => c.frontAttachments.isNotEmpty).toList();
    expect(withAttachments, isNotEmpty);
    // Logs referencing cards that no longer exist (deleted on the web app)
    // are still imported — history is append-only.
    final allLogs = await db.select(db.reviewLogs).get();
    expect(allLogs.length, file.reviewlogs.length);
    final logs = await db.getReviewLogsOfCards(file.cards.map((c) => c.id).toList());
    expect(logs.length, 2);
  });

  test('parseExport rejects invalid files with the original messages',
      () async {
    expect(() => parseExport('not json'),
        throwsA(isA<FormatException>()));
    try {
      parseExport('{"format":"other","decks":[],"cards":[],"reviewlogs":[],"studytags":[]}');
      fail('should have thrown');
    } on FormatException catch (e) {
      expect(e.message, 'File is not a valid Apprendo export');
    }
    try {
      parseEncodeBadJson();
      fail('should have thrown');
    } on FormatException catch (e) {
      expect(e.message, 'File is not valid JSON');
    }
  });
}

void parseEncodeBadJson() {
  parseExport('{broken');
}
