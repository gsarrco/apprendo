import { addRxPlugin } from 'rxdb';
import { RxDBDevModePlugin } from 'rxdb/plugins/dev-mode';
import { createAppDatabase, type AppDatabase } from './database';
import { PLATFORM } from '../platform/env';
import { createAndroidStorage, createE2EStorage, createWebStorage } from './storage';
import type { CardDoc, Deck, ReviewLogDoc, StudyTag } from '../types';

export * from './database';

type E2ESeeds = {
  decks: Deck[];
  cards: CardDoc[];
  reviewlogs: ReviewLogDoc[];
  studyTags?: StudyTag[];
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
    const db = await createAppDatabase({
      name: 'test-db',
      storage: await createE2EStorage()
    });
    await db.decks.bulkInsert(seeds.decks);
    await db.cards.bulkInsert(seeds.cards);
    await db.reviewlogs.bulkInsert(seeds.reviewlogs);
    if (seeds.studyTags) await db.studytags.bulkInsert(seeds.studyTags);
    return db;
  }
  if (import.meta.env.DEV) addRxPlugin(RxDBDevModePlugin);
  return createAppDatabase({
    name: 'apprendodb',
    storage: PLATFORM === 'android' ? createAndroidStorage() : createWebStorage(),
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
