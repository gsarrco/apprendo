export const attachmentProperty = {
  type: ['object', 'null'],
  properties: {
    type: { type: 'string', enum: ['image', 'audio'] },
    url: { type: 'string' },
    attribution: { type: ['string', 'null'] },
    createdAt: { type: 'number' }
  },
  required: ['type', 'url', 'attribution', 'createdAt']
} as const;
