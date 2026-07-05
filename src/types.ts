import type { Rating, State } from 'ts-fsrs';

export interface Language {
  qid: string;
  code: string;
  label: string;
}

export interface Deck {
  id: string;
  name: string;
  language: Language | null;
  createdAt: number;
}

export interface CardDoc {
  id: string;
  deckId: string;
  front: string;
  back: string;
  image_url: string | null;
  image_attribution: string | null;
  audio_url: string | null;
  audio_attribution: string | null;

  due: string;
  stability: number;
  difficulty: number;
  elapsed_days: number;
  scheduled_days: number;
  learning_steps: number;
  reps: number;
  lapses: number;
  state: State;
  last_review: string | null;

  createdAt: number;
  updatedAt: number;
}

export interface ReviewLogDoc {
  id: string;
  cardId: string;
  rating: Rating;
  state: State;
  due: string;
  stability: number;
  difficulty: number;
  elapsed_days: number;
  last_elapsed_days: number;
  scheduled_days: number;
  learning_steps: number;
  review: string;
}

export type { Rating, State };
