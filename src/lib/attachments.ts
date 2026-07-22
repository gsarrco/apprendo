import type { CardAttachment } from '../types';

export function attachmentSrc(a: CardAttachment): string {
  return a.blob_content ?? a.url ?? '';
}

export function blobToDataUrl(blob: Blob): Promise<string> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => resolve(reader.result as string);
    reader.onerror = () => reject(reader.error ?? new Error('Could not read file'));
    reader.readAsDataURL(blob);
  });
}
