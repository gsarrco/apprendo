import { getRxStorageDexie } from 'rxdb/plugins/storage-dexie';
import { wrappedValidateAjvStorage } from 'rxdb/plugins/validate-ajv';
import { PLATFORM_DATABASE } from '../platform/env';
import type { CreateAppDatabaseOptions } from './database';

type AppStorage = CreateAppDatabaseOptions['storage'];

function dexieStorage(): AppStorage {
  return wrappedValidateAjvStorage({ storage: getRxStorageDexie() });
}

export function createWebStorage(): AppStorage {
  return dexieStorage();
}

export function createAndroidStorage(): AppStorage {
  const kind = PLATFORM_DATABASE.android;
  switch (kind) {
    case 'dexie':
      return dexieStorage();
    default:
      return kind satisfies never;
  }
}

export async function createE2EStorage(): Promise<AppStorage> {
  const { getRxStorageMemory } = await import('rxdb/plugins/storage-memory');
  return getRxStorageMemory();
}
