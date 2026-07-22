import type { CardAttachment } from '../types';

export function attachmentSrc(a: CardAttachment): string {
  return a.blob_content ?? a.url;
}
