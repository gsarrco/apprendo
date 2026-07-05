export const deckSchema = {
  version: 1,
  primaryKey: 'id',
  type: 'object',
  properties: {
    id: { type: 'string', maxLength: 100 },
    name: { type: 'string' },
    language: {
      type: ['object', 'null'],
      properties: {
        qid: { type: 'string', maxLength: 12 },
        code: { type: 'string', maxLength: 3 },
        label: { type: 'string', maxLength: 40 }
      },
      required: ['qid', 'code', 'label']
    },
    createdAt: { type: 'number' }
  },
  required: ['id', 'name', 'language', 'createdAt']
} as const;
