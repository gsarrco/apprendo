import 'dart:convert';
import 'dart:typed_data';

import '../data/database.dart';
import '../domain/models.dart';
import '../services/media_download.dart';

const int exportFormatVersion = 2;

/// The `apprendo-export` JSON envelope (version 2). Attachments carry
/// raw file bytes (base64 `content` + `mime_type`); remote urls are no
/// longer part of the format.
class ExportFile {
  final int exportedAt;
  final List<Deck> decks;
  final List<CardDoc> cards;
  final List<ReviewLog> reviewlogs;
  final List<StudyTag> studytags;

  const ExportFile({
    required this.exportedAt,
    this.decks = const [],
    this.cards = const [],
    this.reviewlogs = const [],
    this.studytags = const [],
  });

  Map<String, dynamic> toJson() => {
        'format': 'apprendo-export',
        'version': exportFormatVersion,
        'exportedAt': exportedAt,
        'decks': decks.map(_deckToJson).toList(),
        'cards': cards.map(_cardToJson).toList(),
        'reviewlogs': reviewlogs.map(_logToJson).toList(),
        'studytags': studytags.map(_tagToJson).toList(),
      };

  String encode() => const JsonEncoder.withIndent('  ').convert(toJson());

  Map<String, dynamic> _deckToJson(Deck d) => {
        'id': d.id,
        'name': d.name,
        'createdAt': d.createdAt,
      };

  Map<String, dynamic> _cardToJson(CardDoc c) => {
        'id': c.id,
        'deckId': c.deckId,
        'front': c.front,
        'back': c.back,
        'front_attachments': c.frontAttachments.map(_attachmentToJson).toList(),
        'back_attachments': c.backAttachments.map(_attachmentToJson).toList(),
        'due': c.due,
        'stability': c.stability,
        'difficulty': c.difficulty,
        'elapsed_days': c.elapsedDays,
        'scheduled_days': c.scheduledDays,
        'learning_steps': c.learningSteps,
        'reps': c.reps,
        'lapses': c.lapses,
        'state': c.state,
        'last_review': c.lastReview,
        'createdAt': c.createdAt,
        'updatedAt': c.updatedAt,
      };

  Map<String, dynamic> _attachmentToJson(CardAttachment a) => {
        'type': a.type == AttachmentType.audio ? 'audio' : 'image',
        'mime_type': a.mimeType,
        'content': base64Encode(a.content),
        'caption': a.caption,
        'attribution': a.attribution,
        'language_qid': a.languageQid,
        'createdAt': a.createdAt,
      };

  Map<String, dynamic> _logToJson(ReviewLog r) => {
        'id': r.id,
        'cardId': r.cardId,
        'rating': r.rating,
        'state': r.state,
        'due': r.due,
        'stability': r.stability,
        'difficulty': r.difficulty,
        'elapsed_days': r.elapsedDays,
        'last_elapsed_days': r.lastElapsedDays,
        'scheduled_days': r.scheduledDays,
        'learning_steps': r.learningSteps,
        'review': r.review,
      };

  Map<String, dynamic> _tagToJson(StudyTag t) => {
        'id': t.id,
        'name': t.name,
        'deckIds': t.deckIds,
        'createdAt': t.createdAt,
      };
}

/// Builds an export of the given decks, including their cards and
/// attachments, optionally the review history, and every study tag that
/// references at least one of the decks.
Future<ExportFile> buildExport(
  AppDatabase db,
  List<String> deckIds, {
  bool includeReviewLogs = true,
}) async {
  final decks = <Deck>[];
  for (final id in deckIds) {
    final deck = await db.getDeck(id);
    if (deck != null) decks.add(deck);
  }
  final cards = await db.getCardsOfDecks(deckIds);
  final reviewlogs =
      includeReviewLogs ? await db.getReviewLogsOfCards(cards.map((c) => c.id).toList()) : const <ReviewLog>[];
  final allTags = await db.getStudyTagsAll();
  final studytags =
      allTags.where((t) => t.deckIds.any(deckIds.contains)).toList();
  return ExportFile(
    exportedAt: DateTime.now().millisecondsSinceEpoch,
    decks: decks,
    cards: cards,
    reviewlogs: reviewlogs,
    studytags: studytags,
  );
}

/// Parses and validates an export file, throwing the same error messages
/// the original app used.
ExportFile parseExport(String text) {
  dynamic data;
  try {
    data = jsonDecode(text);
  } catch (_) {
    throw const FormatException('File is not valid JSON');
  }
  final isValid = data is Map<String, dynamic> &&
      data['format'] == 'apprendo-export' &&
      data['decks'] is List &&
      data['cards'] is List &&
      data['reviewlogs'] is List &&
      data['studytags'] is List;
  if (!isValid) {
    throw const FormatException('File is not a valid Apprendo export');
  }
  final map = data;
  return ExportFile(
    exportedAt: (map['exportedAt'] as num?)?.toInt() ??
        DateTime.now().millisecondsSinceEpoch,
    decks: [
      for (final d in (map['decks'] as List).cast<Map<String, dynamic>>())
        Deck(
          id: d['id'] as String,
          name: d['name'] as String? ?? '',
          createdAt: (d['createdAt'] as num?)?.toInt() ?? 0,
        ),
    ],
    cards: [
      for (final c in (map['cards'] as List).cast<Map<String, dynamic>>())
        CardDoc(
          id: c['id'] as String,
          deckId: c['deckId'] as String,
          front: c['front'] as String? ?? '',
          back: c['back'] as String? ?? '',
          frontAttachments: _attachmentsFromJson(c['front_attachments']),
          backAttachments: _attachmentsFromJson(c['back_attachments']),
          due: c['due'] as String? ?? '',
          stability: (c['stability'] as num?)?.toDouble() ?? 0,
          difficulty: (c['difficulty'] as num?)?.toDouble() ?? 0,
          elapsedDays: (c['elapsed_days'] as num?)?.toInt() ?? 0,
          scheduledDays: (c['scheduled_days'] as num?)?.toInt() ?? 0,
          learningSteps: (c['learning_steps'] as num?)?.toInt() ?? 0,
          reps: (c['reps'] as num?)?.toInt() ?? 0,
          lapses: (c['lapses'] as num?)?.toInt() ?? 0,
          state: (c['state'] as num?)?.toInt() ?? 0,
          lastReview: c['last_review'] as String?,
          createdAt: (c['createdAt'] as num?)?.toInt() ?? 0,
          updatedAt: (c['updatedAt'] as num?)?.toInt() ?? 0,
        ),
    ],
    reviewlogs: [
      for (final r in (map['reviewlogs'] as List).cast<Map<String, dynamic>>())
        ReviewLog(
          id: r['id'] as String,
          cardId: r['cardId'] as String,
          rating: (r['rating'] as num?)?.toInt() ?? 0,
          state: (r['state'] as num?)?.toInt() ?? 0,
          due: r['due'] as String? ?? '',
          stability: (r['stability'] as num?)?.toDouble() ?? 0,
          difficulty: (r['difficulty'] as num?)?.toDouble() ?? 0,
          elapsedDays: (r['elapsed_days'] as num?)?.toInt() ?? 0,
          lastElapsedDays: (r['last_elapsed_days'] as num?)?.toInt() ?? 0,
          scheduledDays: (r['scheduled_days'] as num?)?.toInt() ?? 0,
          learningSteps: (r['learning_steps'] as num?)?.toInt() ?? 0,
          review: r['review'] as String? ?? '',
        ),
    ],
    studytags: [
      for (final t in (map['studytags'] as List).cast<Map<String, dynamic>>())
        StudyTag(
          id: t['id'] as String,
          name: t['name'] as String? ?? '',
          deckIds: (t['deckIds'] as List?)?.cast<String>() ?? const [],
          createdAt: (t['createdAt'] as num?)?.toInt() ?? 0,
        ),
    ],
  );
}

/// Attachments carry raw file bytes (base64 `content` + `mime_type`).
/// A pre-v2 `blob_content` data URL still embeds real bytes, so those are
/// harvested too; everything without recoverable bytes (old url-only
/// attachments, malformed content) is skipped.
List<CardAttachment> _attachmentsFromJson(dynamic json) {
  if (json is! List) return const [];
  final out = <CardAttachment>[];
  for (final raw in json.cast<Map<String, dynamic>>()) {
    Uint8List? content;
    var mimeType = raw['mime_type'] as String? ?? 'application/octet-stream';
    if (raw['content'] is String) {
      content = _decodeBase64(raw['content']);
    } else if (raw['blob_content'] is String) {
      final parsed = parseDataUrl(raw['blob_content'] as String);
      if (parsed != null) {
        if (raw['mime_type'] == null) mimeType = parsed.mimeType;
        content = parsed.bytes;
      }
    }
    if (content == null) continue;
    out.add(CardAttachment(
      type: raw['type'] == 'audio'
          ? AttachmentType.audio
          : AttachmentType.image,
      mimeType: mimeType,
      content: content,
      caption: raw['caption'] as String? ?? '',
      attribution: raw['attribution'] as String?,
      languageQid: raw['language_qid'] as String?,
      createdAt: (raw['createdAt'] as num?)?.toInt() ?? 0,
    ));
  }
  return out;
}

Uint8List? _decodeBase64(dynamic value) {
  if (value is! String) return null;
  try {
    return base64Decode(value);
  } catch (_) {
    return null;
  }
}

/// Restores an export into the database. Same ids are overwritten.
Future<void> restoreExport(AppDatabase db, ExportFile file) async {
  for (final deck in file.decks) {
    await db.insertDeck(deck);
  }
  for (final card in file.cards) {
    await db.insertCard(card);
  }
  for (final log in file.reviewlogs) {
    await db.insertReviewLog(log);
  }
  for (final tag in file.studytags) {
    await db.insertStudyTag(tag);
  }
}
