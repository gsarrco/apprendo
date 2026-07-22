export const attachmentItemProperty = {
  type: 'object',
  properties: {
    type: { type: 'string', enum: ['image', 'audio'] },
    url: { type: 'string' },
    caption: { type: 'string' },
    attribution: { type: ['string', 'null'] },
    language_qid: { type: ['string', 'null'], maxLength: 12 },
    blob_content: { type: ['string', 'null'] },
    createdAt: { type: 'number' }
  },
  required: ['type', 'url', 'caption', 'attribution', 'language_qid', 'blob_content', 'createdAt']
} as const;

export const attachmentListProperty = {
  type: 'array',
  items: attachmentItemProperty
} as const;
