import { addRxPlugin } from 'rxdb';
import { getRxStorageDexie } from 'rxdb/plugins/storage-dexie';
import { wrappedValidateAjvStorage } from 'rxdb/plugins/validate-ajv';
import { RxDBDevModePlugin } from 'rxdb/plugins/dev-mode';
import { createAppDatabase, type AppDatabase } from './database';
import type { CardDoc, Deck, ReviewLogDoc } from '../types';

export * from './database';

type E2ESeeds = {
  decks: Deck[];
  cards: CardDoc[];
  reviewlogs: ReviewLogDoc[];
};

function readE2ESeeds(): E2ESeeds | null {
  if (typeof window === 'undefined') return null;
  return (
    (window as unknown as { __APPRENDO_E2E_SEEDS__?: E2ESeeds })
      .__APPRENDO_E2E_SEEDS__ ?? null
  );
}

async function initDb(): Promise<AppDatabase> {
  const seeds = readE2ESeeds();
  if (seeds) {
    const { getRxStorageMemory } = await import('rxdb/plugins/storage-memory');
    const db = await createAppDatabase({
      name: 'test-db',
      storage: getRxStorageMemory()
    });
    await db.decks.bulkInsert(seeds.decks);
    await db.cards.bulkInsert(seeds.cards);
    await db.reviewlogs.bulkInsert(seeds.reviewlogs);
    return db;
  }
  if (import.meta.env.DEV) addRxPlugin(RxDBDevModePlugin);
  return createAppDatabase({
    name: 'apprendodb',
    storage: wrappedValidateAjvStorage({ storage: getRxStorageDexie() }),
    ignoreDuplicate: import.meta.env.DEV
  });
}

let dbPromise: Promise<AppDatabase> | null = null;

export function getDb(): Promise<AppDatabase> {
  if (!dbPromise) {
    dbPromise = initDb();
    dbPromise.catch(() => {
      dbPromise = null;
    });
  }
  return dbPromise;
}
