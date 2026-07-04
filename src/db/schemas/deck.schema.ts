export const deckSchema = {
  version: 0,
  primaryKey: 'id',
  type: 'object',
  properties: {
    id: { type: 'string', maxLength: 100 },
    name: { type: 'string' },
    createdAt: { type: 'number' }
  },
  required: ['id', 'name', 'createdAt']
} as const;
