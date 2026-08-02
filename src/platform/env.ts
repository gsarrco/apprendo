export type AppPlatform = 'web' | 'android';

export const PLATFORM: AppPlatform = import.meta.env.VITE_PLATFORM ?? 'web';

// Which RxDB storage each platform uses. Swap a value here (and its
// factory in src/db/storage.ts) to change a platform's database.
// - web:     Dexie (IndexedDB), AJV-validated — current production web/PWA
// - android: Dexie (IndexedDB inside the Capacitor WebView).
// - e2e tests: memory storage (selected at runtime via __APPRENDO_E2E_SEEDS__,
//   independent of platform)
export const PLATFORM_DATABASE: Record<AppPlatform, 'dexie'> = {
  web: 'dexie',
  android: 'dexie'
};
