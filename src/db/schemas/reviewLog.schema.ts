export const reviewLogSchema = {
  version: 0,
  primaryKey: 'id',
  type: 'object',
  properties: {
    id: { type: 'string', maxLength: 100 },
    cardId: { type: 'string', maxLength: 100 },
    rating: { type: 'number' },
    state: { type: 'number' },
    due: { type: 'string', maxLength: 40 },
    stability: { type: 'number' },
    difficulty: { type: 'number' },
    elapsed_days: { type: 'number' },
    last_elapsed_days: { type: 'number' },
    scheduled_days: { type: 'number' },
    learning_steps: { type: 'number' },
    review: { type: 'string', maxLength: 40 }
  },
  required: [
    'id',
    'cardId',
    'rating',
    'state',
    'due',
    'stability',
    'difficulty',
    'elapsed_days',
    'last_elapsed_days',
    'scheduled_days',
    'learning_steps',
    'review'
  ],
  indexes: ['cardId']
} as const;
