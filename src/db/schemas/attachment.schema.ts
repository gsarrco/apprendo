export const attachmentItemProperty = {
  type: 'object',
  properties: {
    type: { type: 'string', enum: ['image', 'audio'] },
    url: { type: 'string' },
    attribution: { type: ['string', 'null'] },
    createdAt: { type: 'number' }
  },
  required: ['type', 'url', 'attribution', 'createdAt']
} as const;

export const attachmentListProperty = {
  type: 'array',
  items: attachmentItemProperty
} as const;
