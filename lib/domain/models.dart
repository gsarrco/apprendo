/// Plain domain models used by the UI and the export format. These mirror
/// the document shapes the original app persisted and exchanged.
library;

enum AttachmentType { image, audio }

class Language {
  final String qid;
  final String code;
  final String label;
  const Language({required this.qid, required this.code, required this.label});
}

class Deck {
  final String id;
  final String name;
  final bool keepAttachmentsOffline;
  final int createdAt;

  const Deck({
    required this.id,
    required this.name,
    required this.keepAttachmentsOffline,
    required this.createdAt,
  });
}

class CardAttachment {
  final AttachmentType type;
  final String? url;
  final String caption;
  final String? attribution;
  final String? languageQid;

  /// Base64 data URL of the media (either an uploaded file or a downloaded
  /// offline copy of [url]).
  final String? blobContent;
  final int createdAt;

  /// Local database row id, when the attachment was loaded from storage.
  final int? rowId;

  const CardAttachment({
    required this.type,
    this.url,
    this.caption = '',
    this.attribution,
    this.languageQid,
    this.blobContent,
    required this.createdAt,
    this.rowId,
  });

  CardAttachment copyWith({int? rowId}) => CardAttachment(
        type: type,
        url: url,
        caption: caption,
        attribution: attribution,
        languageQid: languageQid,
        blobContent: blobContent,
        createdAt: createdAt,
        rowId: rowId ?? this.rowId,
      );

  /// The single resolution rule for rendering any attachment.
  String get src => blobContent ?? url ?? '';
}

class CardDoc {
  final String id;
  final String deckId;
  final String front;
  final String back;
  final List<CardAttachment> frontAttachments;
  final List<CardAttachment> backAttachments;

  /// ISO-8601 timestamp.
  final String due;
  final double stability;
  final double difficulty;
  final int elapsedDays;
  final int scheduledDays;
  final int learningSteps;
  final int reps;
  final int lapses;

  /// 0 = new, 1 = learning, 2 = review, 3 = relearning.
  final int state;
  final String? lastReview;

  /// Epoch milliseconds.
  final int createdAt;
  final int updatedAt;

  const CardDoc({
    required this.id,
    required this.deckId,
    required this.front,
    required this.back,
    this.frontAttachments = const [],
    this.backAttachments = const [],
    required this.due,
    this.stability = 0,
    this.difficulty = 0,
    this.elapsedDays = 0,
    this.scheduledDays = 0,
    this.learningSteps = 0,
    this.reps = 0,
    this.lapses = 0,
    this.state = 0,
    this.lastReview,
    required this.createdAt,
    required this.updatedAt,
  });

  DateTime get dueDate => DateTime.parse(due);
  DateTime? get lastReviewDate =>
      lastReview == null ? null : DateTime.parse(lastReview!);
}

class ReviewLog {
  final String id;
  final String cardId;

  /// 1 = again, 2 = hard, 3 = good, 4 = easy.
  final int rating;
  final int state;
  final String due;
  final double stability;
  final double difficulty;
  final int elapsedDays;
  final int lastElapsedDays;
  final int scheduledDays;
  final int learningSteps;

  /// ISO-8601 timestamp of the review.
  final String review;

  const ReviewLog({
    required this.id,
    required this.cardId,
    required this.rating,
    required this.state,
    required this.due,
    required this.stability,
    required this.difficulty,
    required this.elapsedDays,
    required this.lastElapsedDays,
    required this.scheduledDays,
    required this.learningSteps,
    required this.review,
  });
}

class StudyTag {
  final String id;
  final String name;
  final List<String> deckIds;
  final int createdAt;

  const StudyTag({
    required this.id,
    required this.name,
    required this.deckIds,
    required this.createdAt,
  });

  StudyTag copyWith({String? name, List<String>? deckIds}) => StudyTag(
        id: id,
        name: name ?? this.name,
        deckIds: deckIds ?? this.deckIds,
        createdAt: createdAt,
      );
}
