import { getDb } from '../db';
import type { CardDoc, Deck, ReviewLogDoc, StudyTag } from '../types';

export const EXPORT_FORMAT_VERSION = 1;

export interface ExportFile {
  format: 'apprendo-export';
  version: number;
  exportedAt: number;
  decks: Deck[];
  cards: CardDoc[];
  reviewlogs: ReviewLogDoc[];
  studytags: StudyTag[];
}

export interface BuildExportOptions {
  includeReviewLogs?: boolean;
}

export async function buildExport(
  deckIds: string[],
  options: BuildExportOptions = {}
): Promise<ExportFile> {
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
    format: 'apprendo-export',
    version: EXPORT_FORMAT_VERSION,
    exportedAt: Date.now(),
    decks,
    cards,
    reviewlogs,
    studytags
  };
}

export function downloadExport(exportFile: ExportFile): void {
  const blob = new Blob([JSON.stringify(exportFile)], {
    type: 'application/json'
  });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  const date = new Date(exportFile.exportedAt).toISOString().slice(0, 10);
  a.href = url;
  a.download = `apprendo-export-${date}.json`;
  document.body.appendChild(a);
  a.click();
  a.remove();
  URL.revokeObjectURL(url);
}

export function parseExport(text: string): ExportFile {
  let data: unknown;
  try {
    data = JSON.parse(text);
  } catch {
    throw new Error('File is not valid JSON');
  }
  if (
    typeof data !== 'object' ||
    data === null ||
    (data as Record<string, unknown>).format !== 'apprendo-export' ||
    !Array.isArray((data as Record<string, unknown>).decks) ||
    !Array.isArray((data as Record<string, unknown>).cards) ||
    !Array.isArray((data as Record<string, unknown>).reviewlogs) ||
    !Array.isArray((data as Record<string, unknown>).studytags)
  ) {
    throw new Error('File is not a valid Apprendo export');
  }
  return data as ExportFile;
}

export async function restoreExport(exportFile: ExportFile): Promise<void> {
  const db = await getDb();
  if (exportFile.decks.length) await db.decks.bulkUpsert(exportFile.decks);
  if (exportFile.cards.length) await db.cards.bulkUpsert(exportFile.cards);
  if (exportFile.reviewlogs.length) await db.reviewlogs.bulkUpsert(exportFile.reviewlogs);
  if (exportFile.studytags.length) await db.studytags.bulkUpsert(exportFile.studytags);
}
