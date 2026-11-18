import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:apprendo/data/database.dart';
import 'package:apprendo/domain/models.dart';
import 'package:apprendo/export/export_file.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart';

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
        id: 'd1', name: 'D', createdAt: 1));
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
        id: 'd1', name: 'D', createdAt: 1));
    final card = CardDoc(
      id: 'c1',
      deckId: 'd1',
      front: 'front',
      back: 'back',
      frontAttachments: [
        CardAttachment(
          type: AttachmentType.image,
          mimeType: 'image/png',
          content: Uint8List.fromList([1, 2, 3]),
          caption: 'a',
          attribution: 'Author — CC',
          createdAt: 5,
        ),
        CardAttachment(
          type: AttachmentType.audio,
          mimeType: 'audio/ogg',
          content: Uint8List.fromList([4, 5]),
          caption: 'clip',
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
    expect(loaded.frontAttachments[1].type, AttachmentType.audio);
    expect(loaded.frontAttachments[1].mimeType, 'audio/ogg');
    expect(loaded.frontAttachments[1].content, [4, 5]);
    expect(loaded.frontAttachments[0].mimeType, 'image/png');
    expect(loaded.frontAttachments[0].content, [1, 2, 3]);
    // ordering preserved
    expect(loaded.frontAttachments[0].caption, 'a');
  });

  test('deleting a deck cascades to cards and attachments but keeps logs',
      () async {
    await db.insertDeck(Deck(
        id: 'd1', name: 'D', createdAt: 1));
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
        id: 'd1', name: 'D', createdAt: 1));
    await db.insertDeck(Deck(
        id: 'd2', name: 'D2', createdAt: 2));
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
        id: 'd1', name: 'D', createdAt: 1));
    await db.insertDeck(Deck(
        id: 'd2', name: 'D2', createdAt: 2));
    await db.insertStudyTag(StudyTag(
        id: 't1', name: 'Tag', deckIds: ['d1'], createdAt: 3));
    await db.setStudyTagDecks('t1', ['d1', 'd2']);
    final tag = await db.getStudyTag('t1');
    expect(tag!.deckIds, containsAll(['d1', 'd2']));
    await db.setStudyTagDecks('t1', ['d2']);
    expect((await db.getStudyTag('t1'))!.deckIds, ['d2']);
  });

  test('v1 databases migrate attachments to raw bytes', () async {
    final dir = await Directory.systemTemp.createTemp('apprendo-mig');
    addTearDown(() => dir.delete(recursive: true));
    final dbPath = '${dir.path}${Platform.pathSeparator}mig.sqlite';

    final raw = sqlite3.open(dbPath);
    raw
      ..execute(
        'CREATE TABLE decks (id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL, '
        'keep_attachments_offline INTEGER NOT NULL DEFAULT 0, '
        'created_at INTEGER NOT NULL)',
      )
      ..execute(
        'CREATE TABLE cards (id TEXT NOT NULL PRIMARY KEY, deck_id TEXT NOT NULL, '
        'front TEXT NOT NULL, back TEXT NOT NULL, due TEXT NOT NULL, '
        'stability REAL NOT NULL DEFAULT 0, difficulty REAL NOT NULL DEFAULT 0, '
        'elapsed_days INTEGER NOT NULL DEFAULT 0, scheduled_days INTEGER NOT NULL DEFAULT 0, '
        'learning_steps INTEGER NOT NULL DEFAULT 0, reps INTEGER NOT NULL DEFAULT 0, '
        'lapses INTEGER NOT NULL DEFAULT 0, state INTEGER NOT NULL DEFAULT 0, '
        'last_review TEXT NULL, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL)',
      )
      ..execute(
        'CREATE TABLE card_attachments (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
        'card_id TEXT NOT NULL, side TEXT NOT NULL, position INTEGER NOT NULL, '
        'type TEXT NOT NULL, url TEXT NULL, caption TEXT NOT NULL DEFAULT \'\', '
        'attribution TEXT NULL, language_qid TEXT NULL, blob_content TEXT NULL, '
        'created_at INTEGER NOT NULL)',
      )
      ..execute("INSERT INTO decks VALUES ('d1', 'D', 1, 100)")
      ..execute(
        "INSERT INTO cards (id, deck_id, front, back, due, last_review, "
        "created_at, updated_at) VALUES "
        "('c1', 'd1', 'f', 'b', '2026-01-01T00:00:00.000Z', NULL, 1, 1)",
      )
      ..execute(
        "INSERT INTO card_attachments (card_id, side, position, type, url, caption, "
        "attribution, language_qid, blob_content, created_at) VALUES "
        "('c1', 'front', 0, 'image', 'https://example.com/a.png', 'a', NULL, NULL, "
        "'data:image/png;base64,AAECAw==', 5)",
      )
      ..execute(
        "INSERT INTO card_attachments (card_id, side, position, type, url, caption, "
        "attribution, language_qid, blob_content, created_at) VALUES "
        "('c1', 'front', 1, 'image', 'https://example.com/b.png', 'b', NULL, NULL, "
        "NULL, 6)",
      )
      ..execute('PRAGMA user_version = 1')
      ..close();

    final dbMig = AppDatabase(NativeDatabase(File(dbPath)));
    addTearDown(dbMig.close);

    final decks = await dbMig.getDecksAll();
    expect(decks.single.id, 'd1');
    final card = (await dbMig.getCardsOfDecks(['d1'])).single;
    // the url-only row is dropped, the base64 blob becomes raw bytes
    expect(card.frontAttachments, hasLength(1));
    final migrated = card.frontAttachments.single;
    expect(migrated.caption, 'a');
    expect(migrated.mimeType, 'image/png');
    expect(migrated.content, [0, 1, 2, 3]);
  });

  test('export round-trips through JSON', () async {
    await db.insertDeck(Deck(
        id: 'd1', name: 'D', createdAt: 1));
    await db.insertCard(CardDoc(
      id: 'c1',
      deckId: 'd1',
      front: 'f',
      back: 'b',
      frontAttachments: [
        CardAttachment(
            type: AttachmentType.audio,
            mimeType: 'audio/ogg',
            content: Uint8List.fromList([1, 2, 3]),
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
    expect(card.frontAttachments.single.mimeType, 'audio/ogg');
    expect(card.frontAttachments.single.content, [1, 2, 3]);
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
    // Only the pre-v2 attachment that embedded real bytes survives the
    // bytes-only import; the url-only ones are dropped.
    final withAttachments =
        restored.where((c) => c.frontAttachments.isNotEmpty).toList();
    expect(withAttachments, hasLength(1));
    final migrated = withAttachments.single.frontAttachments.single;
    expect(migrated.mimeType, 'image/png');
    expect(migrated.content, isNotEmpty);
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
