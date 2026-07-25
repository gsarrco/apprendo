import {
  createRxDatabase,
  addRxPlugin,
  type RxDatabase,
  type RxCollection,
  type RxStorage
} from 'rxdb';
import { RxDBMigrationSchemaPlugin } from 'rxdb/plugins/migration-schema';
import { deckSchema } from './schemas/deck.schema';
import { cardSchema } from './schemas/card.schema';
import { reviewLogSchema } from './schemas/reviewLog.schema';
import { studyTagSchema } from './schemas/studyTag.schema';
import type { Deck, CardDoc, ReviewLogDoc, StudyTag, AttachmentType, CardAttachment } from '../types';

export type DeckCollection = RxCollection<Deck>;
export type CardCollection = RxCollection<CardDoc>;
export type ReviewLogCollection = RxCollection<ReviewLogDoc>;
export type StudyTagCollection = RxCollection<StudyTag>;

export type AppCollections = {
  decks: DeckCollection;
  cards: CardCollection;
  reviewlogs: ReviewLogCollection;
  studytags: StudyTagCollection;
};

export type AppDatabase = RxDatabase<AppCollections>;

export const appCollections = {
  decks: {
    schema: deckSchema,
    migrationStrategies: {
      1: (oldDoc: Record<string, unknown>) => ({
        ...oldDoc,
        language: null
      }),
      2: (oldDoc: Record<string, unknown>) => {
        const rest = { ...oldDoc };
        delete rest.language;
        return rest;
      },
      3: (oldDoc: Record<string, unknown>) => ({
        ...oldDoc,
        keep_attachments_offline: false
      })
    }
  },
  cards: {
    schema: cardSchema,
    migrationStrategies: {
      1: (oldDoc: Record<string, unknown>) => ({
        ...oldDoc,
        image_url: null,
        image_attribution: null
      }),
      2: (oldDoc: Record<string, unknown>) => ({
        ...oldDoc,
        audio_url: null,
        audio_attribution: null
      }),
      3: (old: Record<string, unknown>) => {
        const build = (
          urlKey: string,
          attrKey: string,
          type: AttachmentType
        ): Record<string, unknown> | null =>
          old[urlKey] != null
            ? {
                type,
                url: old[urlKey] as string,
                caption: '',
                attribution: (old[attrKey] as string | null) ?? null,
                language: null,
                createdAt: old.createdAt as number
              }
            : null;
        const rest = { ...old };
        delete rest.image_url;
        delete rest.image_attribution;
        delete rest.audio_url;
        delete rest.audio_attribution;
        return {
          ...rest,
          front_attachment: build('image_url', 'image_attribution', 'image'),
          back_attachment: build('audio_url', 'audio_attribution', 'audio')
        };
      },
      4: (old: Record<string, unknown>) => {
        const toList = (single: unknown): CardAttachment[] =>
          single ? [single as CardAttachment] : [];
        const rest = { ...old };
        delete rest.front_attachment;
        delete rest.back_attachment;
        return {
          ...rest,
          front_attachments: toList(old.front_attachment),
          back_attachments: toList(old.back_attachment)
        };
      },
      5: (old: Record<string, unknown>) => {
        const addCaption = (list: unknown): CardAttachment[] =>
          Array.isArray(list)
            ? list.map((item) => ({
                ...(item as CardAttachment),
                caption: (item as CardAttachment).caption ?? ''
              }))
            : [];
        return {
          ...old,
          front_attachments: addCaption(old.front_attachments),
          back_attachments: addCaption(old.back_attachments)
        };
      },
      6: (old: Record<string, unknown>) => {
        const addLanguage = (list: unknown): Record<string, unknown>[] =>
          Array.isArray(list)
            ? list.map((item) => ({
                ...(item as Record<string, unknown>),
                language: (item as Record<string, unknown>).language ?? null
              }))
            : [];
        return {
          ...old,
          front_attachments: addLanguage(old.front_attachments),
          back_attachments: addLanguage(old.back_attachments)
        };
      },
      7: (old: Record<string, unknown>) => {
        const toLanguageQid = (list: unknown): CardAttachment[] =>
          Array.isArray(list)
            ? list.map((item) => {
                const { language, ...rest } = item as CardAttachment & {
                  language?: { qid: string } | null;
                };
                return {
                  ...rest,
                  language_qid: language?.qid ?? null
                } as CardAttachment;
              })
            : [];
        return {
          ...old,
          front_attachments: toLanguageQid(old.front_attachments),
          back_attachments: toLanguageQid(old.back_attachments)
        };
      },
      8: (old: Record<string, unknown>) => {
        const addBlobContent = (list: unknown): CardAttachment[] =>
          Array.isArray(list)
            ? list.map((item) => ({
                ...(item as CardAttachment),
                blob_content: (item as CardAttachment).blob_content ?? null
              }))
            : [];
        return {
          ...old,
          front_attachments: addBlobContent(old.front_attachments),
          back_attachments: addBlobContent(old.back_attachments)
        };
      },
      9: (old: Record<string, unknown>) => old
    }
  },
  reviewlogs: { schema: reviewLogSchema },
  studytags: { schema: studyTagSchema }
};

export type CreateAppDatabaseOptions = {
  name: string;
  storage: RxStorage<unknown, unknown>;
  ignoreDuplicate?: boolean;
};

export async function createAppDatabase(
  opts: CreateAppDatabaseOptions
): Promise<AppDatabase> {
  addRxPlugin(RxDBMigrationSchemaPlugin);
  const db = await createRxDatabase<AppCollections>({
    name: opts.name,
    storage: opts.storage,
    ignoreDuplicate: opts.ignoreDuplicate ?? false
  });
  await db.addCollections(appCollections);
  return db;
}
