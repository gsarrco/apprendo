import type { AppDatabase } from '../db';
import type { CardAttachment, CardDoc } from '../types';
import { blobToDataUrl } from './attachments';

const SIDES = ['front_attachments', 'back_attachments'] as const;

function needsDownload(a: CardAttachment): boolean {
  return a.url != null && a.blob_content == null;
}

export function countPendingAttachments(cards: CardDoc[]): number {
  return cards.reduce(
    (sum, card) =>
      sum +
      SIDES.reduce(
        (s, side) => s + card[side].filter(needsDownload).length,
        0
      ),
    0
  );
}

export async function downloadUrlAsDataUrl(url: string): Promise<string> {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`Download failed (${res.status})`);
  return blobToDataUrl(await res.blob());
}

export async function downloadDeckAttachments(
  db: AppDatabase,
  deckId: string,
  onDownloaded: () => void,
  isCancelled: () => boolean
): Promise<void> {
  const docs = await db.cards.find({ selector: { deckId } }).exec();
  for (const doc of docs) {
    for (const side of SIDES) {
      const list = doc.get(side) as CardAttachment[];
      for (const attachment of list) {
        if (isCancelled()) return;
        if (!needsDownload(attachment)) continue;
        const blob = await downloadUrlAsDataUrl(attachment.url!);
        await doc.incrementalModify((data) => {
          data[side] = data[side].map((a) =>
            a.url === attachment.url ? { ...a, blob_content: a.blob_content ?? blob } : a
          );
          return data;
        });
        onDownloaded();
      }
    }
  }
}

export async function removeDeckBlobContent(
  db: AppDatabase,
  deckId: string
): Promise<void> {
  const docs = await db.cards.find({ selector: { deckId } }).exec();
  for (const doc of docs) {
    const hasLinkedBlob = SIDES.some((side) =>
      (doc.get(side) as CardAttachment[]).some(
        (a) => a.url != null && a.blob_content != null
      )
    );
    if (!hasLinkedBlob) continue;
    await doc.incrementalModify((data) => {
      for (const side of SIDES) {
        data[side] = data[side].map((a) =>
          a.url != null && a.blob_content != null
            ? { ...a, blob_content: null }
            : a
        );
      }
      return data;
    });
  }
}
