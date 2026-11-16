import '../domain/models.dart';
import 'fsrs.dart';

/// Serializes a [DateTime] exactly like JavaScript's `toISOString()`
/// (UTC, millisecond precision).
String toIsoUtc(DateTime dt) {
  final utc = dt.toUtc();
  return DateTime.utc(utc.year, utc.month, utc.day, utc.hour, utc.minute,
          utc.second, utc.millisecond)
      .toIso8601String();
}

DateTime parseIso(String s) => DateTime.parse(s).toUtc();

/// Converts between the persisted card shape and the FSRS scheduler types.
class FsrsMappers {
  static FsrsCard toFsrsCard(CardDoc doc) => FsrsCard(
        due: parseIso(doc.due),
        stability: doc.stability,
        difficulty: doc.difficulty,
        elapsedDays: doc.elapsedDays,
        scheduledDays: doc.scheduledDays,
        learningSteps: doc.learningSteps,
        reps: doc.reps,
        lapses: doc.lapses,
        state: FsrsState.values[doc.state],
        lastReview: doc.lastReview == null ? null : parseIso(doc.lastReview!),
      );

  static CardDoc fromFsrsCard(
    FsrsCard card,
    CardDoc base,
    int updatedAt,
  ) =>
      CardDoc(
        id: base.id,
        deckId: base.deckId,
        front: base.front,
        back: base.back,
        frontAttachments: base.frontAttachments,
        backAttachments: base.backAttachments,
        due: toIsoUtc(card.due),
        stability: card.stability,
        difficulty: card.difficulty,
        elapsedDays: card.elapsedDays,
        scheduledDays: card.scheduledDays,
        learningSteps: card.learningSteps,
        reps: card.reps,
        lapses: card.lapses,
        state: card.state.value,
        lastReview: card.lastReview == null ? null : toIsoUtc(card.lastReview!),
        createdAt: base.createdAt,
        updatedAt: updatedAt,
      );

  static ReviewLog fromFsrsLog(
    FsrsReviewLog log,
    String id,
    String cardId,
  ) =>
      ReviewLog(
        id: id,
        cardId: cardId,
        rating: log.rating.value,
        state: log.state.value,
        due: toIsoUtc(log.due),
        stability: log.stability,
        difficulty: log.difficulty,
        elapsedDays: log.elapsedDays,
        lastElapsedDays: log.lastElapsedDays,
        scheduledDays: log.scheduledDays,
        learningSteps: log.learningSteps,
        review: toIsoUtc(log.review),
      );
}
