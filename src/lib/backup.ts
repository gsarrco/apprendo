import { getDb } from '../db';
import type { CardDoc, Deck, ReviewLogDoc, StudyTag } from '../types';

export const BACKUP_FORMAT_VERSION = 1;

export interface BackupFile {
  format: 'apprendo-backup';
  version: number;
  exportedAt: number;
  decks: Deck[];
  cards: CardDoc[];
  reviewlogs: ReviewLogDoc[];
  studytags: StudyTag[];
}

export interface BuildBackupOptions {
  includeReviewLogs?: boolean;
}

export async function buildBackup(
  deckIds: string[],
  options: BuildBackupOptions = {}
): Promise<BackupFile> {
  const { includeReviewLogs = true } = options;
  const db = await getDb();
  const decks = (
    await db.decks.find({ selector: { id: { $in: deckIds } } }).exec()
  ).map((d) => d.toJSON() as unknown as Deck);

  const cards = (
    await db.cards.find({ selector: { deckId: { $in: deckIds } } }).exec()
  ).map((c) => c.toJSON() as unknown as CardDoc);

  const cardIds = cards.map((c) => c.id);
  const reviewlogs =
    includeReviewLogs && cardIds.length
      ? (
          await db.reviewlogs
            .find({ selector: { cardId: { $in: cardIds } } })
            .exec()
        ).map((r) => r.toJSON() as unknown as ReviewLogDoc)
      : [];

  const studytags = (
    await db.studytags.find().exec()
  )
    .map((t) => t.toJSON() as unknown as StudyTag)
    .filter((t) => t.deckIds.some((id) => deckIds.includes(id)));

  return {
    format: 'apprendo-backup',
    version: BACKUP_FORMAT_VERSION,
    exportedAt: Date.now(),
    decks,
    cards,
    reviewlogs,
    studytags
  };
}

export function downloadBackup(backup: BackupFile): void {
  const blob = new Blob([JSON.stringify(backup)], {
    type: 'application/json'
  });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  const date = new Date(backup.exportedAt).toISOString().slice(0, 10);
  a.href = url;
  a.download = `apprendo-backup-${date}.json`;
  document.body.appendChild(a);
  a.click();
  a.remove();
  URL.revokeObjectURL(url);
}

export function parseBackup(text: string): BackupFile {
  let data: unknown;
  try {
    data = JSON.parse(text);
  } catch {
    throw new Error('File is not valid JSON');
  }
  if (
    typeof data !== 'object' ||
    data === null ||
    (data as Record<string, unknown>).format !== 'apprendo-backup' ||
    !Array.isArray((data as Record<string, unknown>).decks) ||
    !Array.isArray((data as Record<string, unknown>).cards) ||
    !Array.isArray((data as Record<string, unknown>).reviewlogs) ||
    !Array.isArray((data as Record<string, unknown>).studytags)
  ) {
    throw new Error('File is not a valid Apprendo backup');
  }
  return data as BackupFile;
}

export async function restoreBackup(backup: BackupFile): Promise<void> {
  const db = await getDb();
  if (backup.decks.length) await db.decks.bulkUpsert(backup.decks);
  if (backup.cards.length) await db.cards.bulkUpsert(backup.cards);
  if (backup.reviewlogs.length) await db.reviewlogs.bulkUpsert(backup.reviewlogs);
  if (backup.studytags.length) await db.studytags.bulkUpsert(backup.studytags);
}
