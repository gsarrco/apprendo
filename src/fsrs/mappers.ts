import type { Card as FsrsCard, ReviewLog as FsrsReviewLog } from 'ts-fsrs';
import type { CardDoc, ReviewLogDoc } from '../types';

export function toFsrsCard(doc: CardDoc): FsrsCard {
  return {
    due: new Date(doc.due),
    stability: doc.stability,
    difficulty: doc.difficulty,
    elapsed_days: doc.elapsed_days,
    scheduled_days: doc.scheduled_days,
    learning_steps: doc.learning_steps,
    reps: doc.reps,
    lapses: doc.lapses,
    state: doc.state,
    last_review: doc.last_review ? new Date(doc.last_review) : undefined
  };
}

export function fromFsrsCard(
  card: FsrsCard,
  base: Pick<CardDoc, 'id' | 'deckId' | 'front' | 'back' | 'image_url' | 'image_attribution' | 'createdAt'>
): CardDoc {
  return {
    ...base,
    due: card.due.toISOString(),
    stability: card.stability,
    difficulty: card.difficulty,
    elapsed_days: card.elapsed_days,
    scheduled_days: card.scheduled_days,
    learning_steps: card.learning_steps,
    reps: card.reps,
    lapses: card.lapses,
    state: card.state,
    last_review: card.last_review ? card.last_review.toISOString() : null,
    updatedAt: Date.now()
  };
}

export function fromFsrsLog(
  log: FsrsReviewLog,
  id: string,
  cardId: string
): ReviewLogDoc {
  return {
    id,
    cardId,
    rating: log.rating,
    state: log.state,
    due: log.due.toISOString(),
    stability: log.stability,
    difficulty: log.difficulty,
    elapsed_days: log.elapsed_days,
    last_elapsed_days: log.last_elapsed_days,
    scheduled_days: log.scheduled_days,
    learning_steps: log.learning_steps,
    review: log.review.toISOString()
  };
}
