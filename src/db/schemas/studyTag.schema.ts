export const studyTagSchema = {
  version: 0,
  primaryKey: 'id',
  type: 'object',
  properties: {
    id: { type: 'string', maxLength: 100 },
    name: { type: 'string' },
    deckIds: { type: 'array', items: { type: 'string' } },
    createdAt: { type: 'number' }
  },
  required: ['id', 'name', 'deckIds', 'createdAt']
} as const;
