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
import type { Deck, CardDoc, ReviewLogDoc } from '../types';

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
        decks: { schema: deckSchema },
        cards: {
          schema: cardSchema,
          migrationStrategies: {
            1: (oldDoc: Record<string, unknown>) => ({
              ...oldDoc,
              image_url: null,
              image_attribution: null
            })
          }
        },
        reviewlogs: { schema: reviewLogSchema }
      });
      return db;
    });
  }
  return dbPromise as Promise<AppDatabase>;
}
