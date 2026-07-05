import { attachmentProperty } from './attachment.schema';

export const cardSchema = {
  version: 3,
  primaryKey: 'id',
  type: 'object',
  properties: {
    id: { type: 'string', maxLength: 100 },
    deckId: { type: 'string', maxLength: 100 },
    front: { type: 'string' },
    back: { type: 'string' },
    front_attachment: attachmentProperty,
    back_attachment: attachmentProperty,
    due: { type: 'string', maxLength: 40 },
    stability: { type: 'number' },
    difficulty: { type: 'number' },
    elapsed_days: { type: 'number' },
    scheduled_days: { type: 'number' },
    learning_steps: { type: 'number' },
    reps: { type: 'number' },
    lapses: { type: 'number' },
    state: { type: 'number' },
    last_review: { type: ['string', 'null'], maxLength: 40 },
    createdAt: { type: 'number' },
    updatedAt: { type: 'number' }
  },
  required: [
    'id',
    'deckId',
    'front',
    'back',
    'due',
    'stability',
    'difficulty',
    'elapsed_days',
    'scheduled_days',
    'learning_steps',
    'reps',
    'lapses',
    'state',
    'last_review',
    'createdAt',
    'updatedAt'
  ],
  indexes: ['deckId', 'due', ['deckId', 'due']]
} as const;
