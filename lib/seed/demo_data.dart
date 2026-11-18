import 'dart:convert';

import '../data/database.dart';
import '../domain/models.dart';
import '../fsrs/fsrs.dart';
import '../fsrs/mappers.dart';

/// Populates an empty database with realistic fake data so the app can be
/// explored on an emulator or a fresh install. Only used when the app is
/// started with `--dart-define=SEED_DEMO=true` and the database is empty.
Future<void> seedDemoData(AppDatabase db) async {
  if (await db.getDeck('demo-it') != null) return;

  final fsrs = Fsrs();
  final now = DateTime.now();

  final decks = [
    Deck(id: 'demo-it', name: 'Italian Vocabulary', createdAt: now.subtract(const Duration(days: 30)).millisecondsSinceEpoch),
    Deck(id: 'demo-nl', name: 'Dutch Nouns', createdAt: now.subtract(const Duration(days: 21)).millisecondsSinceEpoch),
    Deck(id: 'demo-es', name: 'Spanish Verbs', createdAt: now.subtract(const Duration(days: 10)).millisecondsSinceEpoch),
  ];
  for (final d in decks) {
    await db.insertDeck(d);
  }

  // A card that has been reviewed a few times and is due now.
  CardDoc reviewedCard({
    required String id,
    required String deckId,
    required String front,
    required String back,
    required List<Rating> ratings,
    required Duration lastReviewedAgo,
    List<CardAttachment> frontAttachments = const [],
    List<CardAttachment> backAttachments = const [],
  }) {
    var card = CardDoc(
      id: id,
      deckId: deckId,
      front: front,
      back: back,
      frontAttachments: frontAttachments,
      backAttachments: backAttachments,
      due: toIsoUtc(now),
      createdAt: now.subtract(const Duration(days: 30)).millisecondsSinceEpoch,
      updatedAt: now.subtract(const Duration(days: 30)).millisecondsSinceEpoch,
    );
    var fsrsCard = fsrs.createEmptyCard(now);
    var reviewAt = now.subtract(lastReviewedAgo + const Duration(days: 20));
    var elapsed = const Duration(days: 20);
    for (final rating in ratings) {
      final result = fsrs.next(fsrsCard, reviewAt, rating);
      fsrsCard = result.card;
      final log = FsrsMappers.fromFsrsLog(result.log, newId(), id);
      // Simulate the log being stored at review time.
      card = CardDoc(
        id: card.id,
        deckId: card.deckId,
        front: card.front,
        back: card.back,
        frontAttachments: card.frontAttachments,
        backAttachments: card.backAttachments,
        due: toIsoUtc(fsrsCard.due),
        stability: fsrsCard.stability,
        difficulty: fsrsCard.difficulty,
        elapsedDays: fsrsCard.elapsedDays,
        scheduledDays: fsrsCard.scheduledDays,
        learningSteps: fsrsCard.learningSteps,
        reps: fsrsCard.reps,
        lapses: fsrsCard.lapses,
        state: fsrsCard.state.value,
        lastReview: fsrsCard.lastReview == null ? null : toIsoUtc(fsrsCard.lastReview!),
        createdAt: card.createdAt,
        updatedAt: reviewAt.millisecondsSinceEpoch,
      );
      db.insertReviewLog(ReviewLog(
        id: '$id-log${fsrsCard.reps}',
        cardId: id,
        rating: log.rating,
        state: log.state,
        due: log.due,
        stability: log.stability,
        difficulty: log.difficulty,
        elapsedDays: log.elapsedDays,
        lastElapsedDays: log.lastElapsedDays,
        scheduledDays: log.scheduledDays,
        learningSteps: log.learningSteps,
        review: toIsoUtc(reviewAt),
      ));
      reviewAt = reviewAt.add(elapsed);
      elapsed = const Duration(days: 7);
    }
    return card;
  }

  final commonImages = <CardAttachment>[
    CardAttachment(
      type: AttachmentType.image,
      mimeType: 'image/png',
      content: base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg=='),
      caption: 'yellow tomato',
      attribution: 'Wikipedia: File:Yellow tomato.jpg',
      createdAt: 0,
    ),
  ];

  final cards = <CardDoc>[
    // Italian deck: a mix of due, learning and future cards.
    reviewedCard(
      id: 'demo-it-1',
      deckId: 'demo-it',
      front: 'ciao',
      back: 'hello',
      ratings: [Rating.good, Rating.good, Rating.good],
      lastReviewedAgo: const Duration(days: 9),
    ),
    reviewedCard(
      id: 'demo-it-2',
      deckId: 'demo-it',
      front: 'grazie',
      back: 'thank you',
      ratings: [Rating.good, Rating.hard, Rating.good],
      lastReviewedAgo: const Duration(days: 4),
    ),
    reviewedCard(
      id: 'demo-it-3',
      deckId: 'demo-it',
      front: 'pomodoro',
      back: 'tomato',
      ratings: [Rating.good, Rating.again, Rating.good, Rating.easy],
      lastReviewedAgo: const Duration(days: 12),
      frontAttachments: commonImages,
    ),
    CardDoc(
      id: 'demo-it-4',
      deckId: 'demo-it',
      front: 'buongiorno',
      back: 'good morning',
      due: toIsoUtc(now),
      createdAt: now.subtract(const Duration(days: 2)).millisecondsSinceEpoch,
      updatedAt: now.subtract(const Duration(days: 2)).millisecondsSinceEpoch,
    ),
    CardDoc(
      id: 'demo-it-5',
      deckId: 'demo-it',
      front: 'a presto',
      back: 'see you soon',
      due: toIsoUtc(now.add(const Duration(days: 5))),
      createdAt: now.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
      updatedAt: now.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
      reps: 1,
      state: 2,
      scheduledDays: 5,
      stability: 3.2,
      difficulty: 5.4,
      lastReview: toIsoUtc(now),
    ),
    // Dutch deck.
    reviewedCard(
      id: 'demo-nl-1',
      deckId: 'demo-nl',
      front: 'hallo',
      back: 'hello',
      ratings: [Rating.good, Rating.good],
      lastReviewedAgo: const Duration(days: 3),
    ),
    reviewedCard(
      id: 'demo-nl-2',
      deckId: 'demo-nl',
      front: 'dank je',
      back: 'thank you',
      ratings: [Rating.easy, Rating.easy],
      lastReviewedAgo: const Duration(days: 1),
    ),
    CardDoc(
      id: 'demo-nl-3',
      deckId: 'demo-nl',
      front: 'goede morgen',
      back: 'good morning',
      due: toIsoUtc(now),
      createdAt: now.subtract(const Duration(hours: 5)).millisecondsSinceEpoch,
      updatedAt: now.subtract(const Duration(hours: 5)).millisecondsSinceEpoch,
    ),
    // Spanish deck.
    reviewedCard(
      id: 'demo-es-1',
      deckId: 'demo-es',
      front: 'hola',
      back: 'hello',
      ratings: [Rating.good, Rating.good, Rating.hard],
      lastReviewedAgo: const Duration(days: 6),
    ),
    CardDoc(
      id: 'demo-es-2',
      deckId: 'demo-es',
      front: 'buenos días',
      back: 'good morning',
      due: toIsoUtc(now),
      createdAt: now.subtract(const Duration(hours: 3)).millisecondsSinceEpoch,
      updatedAt: now.subtract(const Duration(hours: 3)).millisecondsSinceEpoch,
    ),
  ];
  for (final card in cards) {
    await db.insertCard(card);
  }

  await db.insertStudyTag(StudyTag(
    id: 'demo-tag-1',
    name: 'Daily mix',
    deckIds: const ['demo-it', 'demo-nl'],
    createdAt: now.subtract(const Duration(days: 7)).millisecondsSinceEpoch,
  ));
  await db.insertStudyTag(StudyTag(
    id: 'demo-tag-2',
    name: 'Weekend boost',
    deckIds: const ['demo-es'],
    createdAt: now.subtract(const Duration(days: 5)).millisecondsSinceEpoch,
  ));
}
