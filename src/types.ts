import type { Rating, State } from 'ts-fsrs';

export interface Language {
  qid: string;
  code: string;
  label: string;
}

export interface Deck {
  id: string;
  name: string;
  createdAt: number;
}

export type AttachmentType = 'image' | 'audio';

export interface CardAttachment {
  type: AttachmentType;
  url: string;
  caption: string;
  attribution: string | null;
  language_qid: string | null;
  createdAt: number;
}

export interface CardDoc {
  id: string;
  deckId: string;
  front: string;
  back: string;
  front_attachments: CardAttachment[];
  back_attachments: CardAttachment[];

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
