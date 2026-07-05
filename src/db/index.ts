import {
  createRxDatabase,
  addRxPlugin,
  type RxDatabase,
  type RxCollection
} from 'rxdb';
import { getRxStorageDexie } from 'rxdb/plugins/storage-dexie';
import { wrappedValidateAjvStorage } from 'rxdb/plugins/validate-ajv';
import { RxDBDevModePlugin } from 'rxdb/plugins/dev-mode';
import { RxDBMigrationSchemaPlugin } from 'rxdb/plugins/migration-schema';
import { deckSchema } from './schemas/deck.schema';
import { cardSchema } from './schemas/card.schema';
import { reviewLogSchema } from './schemas/reviewLog.schema';
import type { Deck, CardDoc, ReviewLogDoc, AttachmentType, CardAttachment } from '../types';

export type DeckCollection = RxCollection<Deck>;
export type CardCollection = RxCollection<CardDoc>;
export type ReviewLogCollection = RxCollection<ReviewLogDoc>;

export type AppCollections = {
  decks: DeckCollection;
  cards: CardCollection;
  reviewlogs: ReviewLogCollection;
};

export type AppDatabase = RxDatabase<AppCollections>;

let dbPromise: Promise<AppDatabase> | null = null;

export function getDb(): Promise<AppDatabase> {
  if (!dbPromise) {
    if (import.meta.env.DEV) {
      addRxPlugin(RxDBDevModePlugin);
    }
    addRxPlugin(RxDBMigrationSchemaPlugin);
    dbPromise = createRxDatabase<AppCollections>({
      name: 'apprendodb',
      storage: wrappedValidateAjvStorage({ storage: getRxStorageDexie() }),
      ignoreDuplicate: true
    }).then(async (db: AppDatabase) => {
      await db.addCollections({
        decks: {
          schema: deckSchema,
          migrationStrategies: {
            1: (oldDoc: Record<string, unknown>) => ({
              ...oldDoc,
              language: null
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
              ): CardAttachment | null =>
                old[urlKey] != null
                  ? {
                      type,
                      url: old[urlKey] as string,
                      attribution: (old[attrKey] as string | null) ?? null,
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
                front_attachment: build(
                  'image_url',
                  'image_attribution',
                  'image'
                ),
                back_attachment: build(
                  'audio_url',
                  'audio_attribution',
                  'audio'
                )
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
            }
          }
        },
        reviewlogs: { schema: reviewLogSchema }
      });
      return db;
    });
  }
  return dbPromise as Promise<AppDatabase>;
}
