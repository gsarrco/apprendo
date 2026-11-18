import 'dart:async';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../domain/models.dart';
import '../services/media_download.dart';
import 'tables.dart';

part 'database.g.dart';

const String kSideFront = 'front';
const String kSideBack = 'back';

/// Generates a nanoid-style id, matching the ids the original app used.
String newId() {
  const chars =
      'useandom26T198340PX75pxJACKVERYLIBDOMARYSTEALTHWHATEFTYQUICKBROWNFOXJUMPOVERTHEDOG';
  final rand = Random.secure();
  return List.generate(21, (_) => chars[rand.nextInt(chars.length)]).join();
}

@DriftDatabase(
  tables: [Decks, Cards, CardAttachments, ReviewLogs, StudyTags, StudyTagDecks],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Opens the on-disk database used by the app.
  factory AppDatabase.open() => AppDatabase(driftDatabase(name: 'apprendo'));

  @override
  int get schemaVersion => 2;

  /// Migrations run automatically when the database is opened:
  /// - `onCreate` builds the schema for fresh installs.
  /// - `onUpgrade` walks existing installs forward, one schemaVersion at a
  ///   time (1→2, 2→3, …), so any user on any older app version is brought
  ///   up to date automatically.
  ///
  /// To change the schema in a future release:
  ///   1. Bump [schemaVersion] (1 -> 2).
  ///   2. Add a `from1To2: (m, schema) async { ... }` step below
  ///      (m.createTable / m.addColumn / customStatement …).
  /// Older installs then upgrade automatically the next time the app
  /// opens the database.
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_cards_deck_due ON cards (deck_id, due)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_reviewlogs_card ON review_logs (card_id)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_attachments_card ON card_attachments (card_id)',
      );
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // Attachments became raw file bytes stored in the database: the
        // url and blob_content columns were replaced by content (BLOB)
        // and mime_type. Rows that only had a remote url are dropped.
        await m.alterTable(TableMigration(decks));
        final oldRows = await customSelect(
          'SELECT id, card_id, side, position, type, caption, attribution, '
          'language_qid, blob_content, created_at FROM card_attachments',
        ).get();
        final keep = <CardAttachmentsCompanion>[];
        for (final row in oldRows) {
          final dataUrl = row.read<String?>('blob_content');
          final parsed = dataUrl == null ? null : parseDataUrl(dataUrl);
          if (parsed == null) continue;
          keep.add(CardAttachmentsCompanion.insert(
            cardId: row.read<String>('card_id'),
            side: row.read<String>('side'),
            position: row.read<int>('position'),
            type: row.read<String>('type'),
            caption: Value(row.read<String>('caption')),
            attribution: Value(row.read<String?>('attribution')),
            languageQid: Value(row.read<String?>('language_qid')),
            content: parsed.bytes,
            mimeType: parsed.mimeType,
            createdAt: row.read<int>('created_at'),
          ));
        }
        await m.deleteTable('card_attachments');
        await m.createTable(cardAttachments);
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_attachments_card ON card_attachments (card_id)',
        );
        await batch((b) {
          if (keep.isNotEmpty) b.insertAll(cardAttachments, keep);
        });
      }
    },
    beforeOpen: (details) async {
      // Enforce the relational foreign keys (deck/card/tag cascades).
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  // ---------------------------------------------------------------- decks

  /// Streams are cached as broadcast streams so widgets can subscribe from
  /// `build()` without creating a fresh (and immediately re-emitting)
  /// database watch on every rebuild.
  Stream<List<Deck>>? _decksStream;
  Stream<List<Deck>> watchDecks() {
    if (_decksStream != null) return _decksStream!;
    final query = select(decks)
      ..orderBy([(d) => OrderingTerm.asc(d.createdAt)]);
    return _decksStream = _LatestStream(
      query.watch().map((rows) => rows.map(_deckFromRow).toList()),
    );
  }

  Future<Deck?> getDeck(String id) async {
    final row = await (select(
      decks,
    )..where((d) => d.id.equals(id))).getSingleOrNull();
    return row == null ? null : _deckFromRow(row);
  }

  /// One-shot query (no stream) — for tests and non-reactive reads.
  Future<List<Deck>> getDecksAll() async {
    final rows = await (select(
      decks,
    )..orderBy([(d) => OrderingTerm.asc(d.createdAt)])).get();
    return rows.map(_deckFromRow).toList();
  }

  Deck _deckFromRow(DeckRow row) => Deck(
    id: row.id,
    name: row.name,
    createdAt: row.createdAt,
  );

  Future<void> insertDeck(Deck deck) => into(decks).insertOnConflictUpdate(
    DecksCompanion.insert(
      id: deck.id,
      name: deck.name,
      createdAt: deck.createdAt,
    ),
  );

  Future<void> renameDeck(String id, String name) async {
    await (update(
      decks,
    )..where((d) => d.id.equals(id))).write(DecksCompanion(name: Value(name)));
  }

  /// Deletes the given decks. Cards and their attachments cascade; review
  /// logs are kept (matching the original app); study tag membership rows
  /// cascade as well.
  Future<void> deleteDecks(List<String> ids) async {
    for (final id in ids) {
      await (delete(decks)..where((d) => d.id.equals(id))).go();
    }
  }

  // ---------------------------------------------------------------- cards

  final Map<String, Stream<List<CardDoc>>> _cardsStreams = {};

  Stream<List<CardDoc>> watchCards(String deckId) {
    return _cardsStreams.putIfAbsent(deckId, () {
      final query = select(cards)
        ..where((c) => c.deckId.equals(deckId))
        ..orderBy([(c) => OrderingTerm.asc(c.createdAt)]);
      return _LatestStream(query.watch().asyncMap(_attachToRows));
    });
  }

  Stream<List<CardDoc>> watchDueCards(List<String> deckIds, {String? nowIso}) {
    if (deckIds.isEmpty) {
      return Stream.value(const <CardDoc>[]);
    }
    final now = nowIso ?? DateTime.now().toIso8601String();
    final query = select(cards)
      ..where((c) => c.deckId.isIn(deckIds) & c.due.isSmallerOrEqualValue(now))
      ..orderBy([(c) => OrderingTerm.asc(c.due)]);
    return query.watch().asyncMap(_attachToRows);
  }

  Future<List<CardDoc>> getCardsOfDecks(List<String> deckIds) async {
    if (deckIds.isEmpty) return const [];
    final query = select(cards)..where((c) => c.deckId.isIn(deckIds));
    final rows = await query.get();
    return _attachToRows(rows);
  }

  Future<CardDoc?> getCard(String id) async {
    final row = await (select(
      cards,
    )..where((c) => c.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return (await _attachToRows([row])).single;
  }

  Future<List<CardDoc>> _attachToRows(List<CardRow> rows) async {
    if (rows.isEmpty) return const [];
    final ids = rows.map((r) => r.id).toList();
    final attRows = await (select(
      cardAttachments,
    )..where((a) => a.cardId.isIn(ids))).get();
    final byCard = <String, List<CardAttachmentRow>>{};
    for (final a in attRows) {
      byCard.putIfAbsent(a.cardId, () => []).add(a);
    }
    return rows.map((r) {
      final atts = byCard[r.id] ?? const <CardAttachmentRow>[];
      return _cardFromRow(r, atts);
    }).toList();
  }

  CardDoc _cardFromRow(CardRow row, List<CardAttachmentRow> attachments) {
    int compare(a, b) => a.position.compareTo(b.position);
    final front = attachments.where((a) => a.side == kSideFront).toList()
      ..sort(compare);
    final back = attachments.where((a) => a.side == kSideBack).toList()
      ..sort(compare);
    return CardDoc(
      id: row.id,
      deckId: row.deckId,
      front: row.front,
      back: row.back,
      frontAttachments: front.map(_attachmentFromRow).toList(),
      backAttachments: back.map(_attachmentFromRow).toList(),
      due: row.due,
      stability: row.stability,
      difficulty: row.difficulty,
      elapsedDays: row.elapsedDays,
      scheduledDays: row.scheduledDays,
      learningSteps: row.learningSteps,
      reps: row.reps,
      lapses: row.lapses,
      state: row.state,
      lastReview: row.lastReview,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  CardAttachment _attachmentFromRow(CardAttachmentRow a) => CardAttachment(
    rowId: a.id,
    type: a.type == 'audio' ? AttachmentType.audio : AttachmentType.image,
    mimeType: a.mimeType,
    content: a.content,
    caption: a.caption,
    attribution: a.attribution,
    languageQid: a.languageQid,
    createdAt: a.createdAt,
  );

  /// Inserts a brand new card together with its attachments.
  Future<void> insertCard(CardDoc card) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(cards, [_cardCompanion(card)]);
    });
    await _writeAttachments(card);
  }

  /// Updates card content (front/back/attachments) without touching the
  /// scheduling columns.
  Future<void> updateCardContent(CardDoc card) async {
    await (update(cards)..where((c) => c.id.equals(card.id))).write(
      CardsCompanion(
        front: Value(card.front),
        back: Value(card.back),
        updatedAt: Value(card.updatedAt),
      ),
    );
    await _writeAttachments(card);
  }

  Future<void> _writeAttachments(CardDoc card) async {
    await (delete(
      cardAttachments,
    )..where((a) => a.cardId.equals(card.id))).go();
    await batch((b) {
      final rows = <CardAttachmentsCompanion>[];
      for (final (i, a) in card.frontAttachments.indexed) {
        rows.add(_attachmentCompanion(card.id, kSideFront, i, a));
      }
      for (final (i, a) in card.backAttachments.indexed) {
        rows.add(_attachmentCompanion(card.id, kSideBack, i, a));
      }
      if (rows.isNotEmpty) b.insertAll(cardAttachments, rows);
    });
  }

  CardsCompanion _cardCompanion(CardDoc card) => CardsCompanion.insert(
    id: card.id,
    deckId: card.deckId,
    front: card.front,
    back: card.back,
    due: card.due,
    stability: Value(card.stability),
    difficulty: Value(card.difficulty),
    elapsedDays: Value(card.elapsedDays),
    scheduledDays: Value(card.scheduledDays),
    learningSteps: Value(card.learningSteps),
    reps: Value(card.reps),
    lapses: Value(card.lapses),
    state: Value(card.state),
    lastReview: Value(card.lastReview),
    createdAt: card.createdAt,
    updatedAt: card.updatedAt,
  );

  CardAttachmentsCompanion _attachmentCompanion(
    String cardId,
    String side,
    int position,
    CardAttachment a,
  ) => CardAttachmentsCompanion.insert(
    cardId: cardId,
    side: side,
    position: position,
    type: a.type == AttachmentType.audio ? 'audio' : 'image',
    caption: Value(a.caption),
    attribution: Value(a.attribution),
    languageQid: Value(a.languageQid),
    content: a.content,
    mimeType: a.mimeType,
    createdAt: a.createdAt,
  );

  /// Persists the FSRS scheduling columns after a review.
  Future<void> applyReview(CardDoc card) async {
    await (update(cards)..where((c) => c.id.equals(card.id))).write(
      CardsCompanion(
        due: Value(card.due),
        stability: Value(card.stability),
        difficulty: Value(card.difficulty),
        elapsedDays: Value(card.elapsedDays),
        scheduledDays: Value(card.scheduledDays),
        learningSteps: Value(card.learningSteps),
        reps: Value(card.reps),
        lapses: Value(card.lapses),
        state: Value(card.state),
        lastReview: Value(card.lastReview),
        updatedAt: Value(card.updatedAt),
      ),
    );
  }

  Future<void> deleteCard(String id) async {
    await (delete(cards)..where((c) => c.id.equals(id))).go();
  }

  // -------------------------------------------------------- review logs

  Future<void> insertReviewLog(ReviewLog log) =>
      into(reviewLogs).insertOnConflictUpdate(
        ReviewLogsCompanion.insert(
          id: log.id,
          cardId: log.cardId,
          rating: log.rating,
          state: log.state,
          due: log.due,
          stability: log.stability,
          difficulty: log.difficulty,
          elapsedDays: log.elapsedDays,
          lastElapsedDays: log.lastElapsedDays,
          scheduledDays: log.scheduledDays,
          learningSteps: log.learningSteps,
          review: log.review,
        ),
      );

  Future<List<ReviewLog>> getReviewLogsOfCards(List<String> cardIds) async {
    if (cardIds.isEmpty) return const [];
    final rows = await (select(
      reviewLogs,
    )..where((r) => r.cardId.isIn(cardIds))).get();
    return rows.map(_logFromRow).toList();
  }

  ReviewLog _logFromRow(ReviewLogRow r) => ReviewLog(
    id: r.id,
    cardId: r.cardId,
    rating: r.rating,
    state: r.state,
    due: r.due,
    stability: r.stability,
    difficulty: r.difficulty,
    elapsedDays: r.elapsedDays,
    lastElapsedDays: r.lastElapsedDays,
    scheduledDays: r.scheduledDays,
    learningSteps: r.learningSteps,
    review: r.review,
  );

  // ------------------------------------------------------------ study tags

  Stream<List<StudyTag>>? _studyTagsStream;
  Stream<List<StudyTag>> watchStudyTags() {
    if (_studyTagsStream != null) return _studyTagsStream!;
    return _studyTagsStream = _watchStudyTagsUncached().asBroadcastStream();
  }

  Stream<List<StudyTag>> _watchStudyTagsUncached() async* {
    final query = select(studyTags)
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    await for (final rows in query.watch()) {
      final out = <StudyTag>[];
      for (final row in rows) {
        final deckRows = await (select(
          studyTagDecks,
        )..where((s) => s.studyTagId.equals(row.id))).get();
        out.add(
          StudyTag(
            id: row.id,
            name: row.name,
            deckIds: deckRows.map((d) => d.deckId).toList(),
            createdAt: row.createdAt,
          ),
        );
      }
      yield out;
    }
  }

  Future<StudyTag?> getStudyTag(String id) async {
    final row = await (select(
      studyTags,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    final deckRows = await (select(
      studyTagDecks,
    )..where((s) => s.studyTagId.equals(id))).get();
    return StudyTag(
      id: row.id,
      name: row.name,
      deckIds: deckRows.map((d) => d.deckId).toList(),
      createdAt: row.createdAt,
    );
  }

  Future<List<StudyTag>> getStudyTagsAll() async {
    final rows = await (select(
      studyTags,
    )..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).get();
    final out = <StudyTag>[];
    for (final row in rows) {
      final deckRows = await (select(
        studyTagDecks,
      )..where((s) => s.studyTagId.equals(row.id))).get();
      out.add(
        StudyTag(
          id: row.id,
          name: row.name,
          deckIds: deckRows.map((d) => d.deckId).toList(),
          createdAt: row.createdAt,
        ),
      );
    }
    return out;
  }

  Future<void> insertStudyTag(StudyTag tag) async {
    await into(studyTags).insertOnConflictUpdate(
      StudyTagsCompanion.insert(
        id: tag.id,
        name: Value(tag.name),
        createdAt: tag.createdAt,
      ),
    );
    await _writeTagDecks(tag);
  }

  Future<void> renameStudyTag(String id, String name) async {
    await (update(studyTags)..where((t) => t.id.equals(id))).write(
      StudyTagsCompanion(name: Value(name)),
    );
  }

  Future<void> setStudyTagDecks(String id, List<String> deckIds) async {
    final tag = await getStudyTag(id);
    if (tag == null) return;
    await _writeTagDecks(
      StudyTag(
        id: id,
        name: tag.name,
        deckIds: deckIds,
        createdAt: tag.createdAt,
      ),
    );
  }

  Future<void> _writeTagDecks(StudyTag tag) async {
    await (delete(
      studyTagDecks,
    )..where((s) => s.studyTagId.equals(tag.id))).go();
    await batch((b) {
      b.insertAll(studyTagDecks, [
        for (final deckId in tag.deckIds)
          StudyTagDecksCompanion.insert(studyTagId: tag.id, deckId: deckId),
      ]);
    });
  }
}

/// Broadcast wrapper around a database watch that re-emits the latest
/// value to every new subscriber, so pages opened later (e.g. the deck
/// detail page joining the deck stream already listened to by the deck
/// index) immediately see the current data instead of waiting for the
/// next table change.
class _LatestStream<T> extends Stream<T> {
  _LatestStream(Stream<T> source) {
    source.listen(
      (v) {
        _last = v;
        _hasLast = true;
        _controller.add(v);
      },
      onError: _controller.addError,
      onDone: _controller.close,
    );
  }

  final _controller = StreamController<T>.broadcast();
  T? _last;
  bool _hasLast = false;

  @override
  bool get isBroadcast => true;

  @override
  StreamSubscription<T> listen(
    void Function(T)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    late StreamSubscription<T> sourceSub;
    final bridge = StreamController<T>(
      onCancel: () => sourceSub.cancel(),
    );
    if (_hasLast) {
      Future<void>.delayed(Duration.zero, () {
        final last = _last;
        if (last != null && bridge.hasListener) bridge.add(last);
      });
    }
    sourceSub = _controller.stream.listen(
      bridge.add,
      onError: bridge.addError,
      onDone: bridge.close,
    );
    return bridge.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}
