export const deckSchema = {
  version: 3,
  primaryKey: 'id',
  type: 'object',
  properties: {
    id: { type: 'string', maxLength: 100 },
    name: { type: 'string' },
    keep_attachments_offline: { type: 'boolean' },
    createdAt: { type: 'number' }
  },
  required: ['id', 'name', 'keep_attachments_offline', 'createdAt']
} as const;
