export const attachmentItemProperty = {
  type: 'object',
  properties: {
    type: { type: 'string', enum: ['image', 'audio'] },
    url: { type: 'string' },
    caption: { type: 'string' },
    attribution: { type: ['string', 'null'] },
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
  required: ['type', 'url', 'caption', 'attribution', 'language', 'createdAt']
} as const;

export const attachmentListProperty = {
  type: 'array',
  items: attachmentItemProperty
} as const;
