# AGENTS.md

## Tech stack

Vite + React 19 + TypeScript. Styling is **Tailwind CSS v4** (via the
`@tailwindcss/vite` plugin in `vite.config.ts`), with **Flowbite React**
available for prebuilt components (via the `flowbiteReact()` Vite plugin;
import components with `import { Button } from 'flowbite-react'`). Linting
with oxlint. Data layer: RxDB + RxJS; spaced repetition via `ts-fsrs`.

## Required checks

Always run the following before considering work done. Fix any errors.

```bash
npm run lint && npx tsc -b && npm run build
```

If wiring up the dev server to sanity-check, start and stop it
(`npm run dev` serves on http://localhost:5173).

## E2E tests

Playwright, in `tests/e2e/`. Run with:

```bash
npm run test:e2e
```

This builds against `npm run preview` (port 4173) via the `webServer`
block in `playwright.config.ts`, so a production build is exercised,
not the dev server — rebuild first (`npm run build`) if source has
changed since the last build. Runs across three device projects:
Desktop Chrome, Mobile Android (Pixel 9), and Mobile Safari (iPhone
16).

## Android build (Capacitor)

The same web codebase ships as a signed Android APK via **Capacitor**
(the generated native project lives in `android/`). The web deployment is
untouched: `npm run build` still emits the PWA with its service worker.

- **Platform switch**: `src/platform/env.ts` is the single source of
  truth mapping each platform (`web` | `android`) to its RxDB storage
  (see `PLATFORM_DATABASE`). `PLATFORM` is stamped at build time from
  `VITE_PLATFORM`; `.env.android` sets it to `android` under
  `vite build --mode android`. Android currently uses the same Dexie
  (IndexedDB) storage as web, inside the Capacitor WebView; swapping to
  another storage library later touches only `createAndroidStorage()` in
  `src/db/storage.ts`.
- In `--mode android` the service worker is disabled (VitePWA `disable`)
  so no SW runs inside the WebView.

Prerequisites: Android Studio / Android SDK and a JDK.

```bash
# one-time: create the release keystore (isolated in ~/.apprendo/signing,
# never committed). Back that folder up encrypted.
scripts/setup-android-signing.sh

# build + sign the APK -> dist-android/apprendo-release.apk
npm run apk
```

`npm run build:android` (web build with `VITE_PLATFORM=android` + PWA
disabled, then `cap sync android`) is run for you by `npm run apk`.
Signing config is loaded by `android/app/build.gradle` from
`~/.apprendo/signing/keystore.properties` only if it exists — nothing
secret ever enters the repo.

## Styling conventions

- Use Tailwind utility classes directly in JSX. Do not add custom CSS.
- Dark mode is class-based: the `dark` class is toggled on
  `<html>` (see `src/hooks/useTheme.ts` and the no-flash script in
  `index.html`). Use `dark:` variants.
- Shared button/input class strings live in `src/components/ui.ts`
  (`btnPrimary`, `btnSecondary`, `btnGhost`, `inputClass`). Prefer them
  over repeating long utility strings.
- Color palette: indigo accent + zinc neutrals. State colors:
  amber (learning), emerald (review/ok), red (relearning/again).
- Do not add comments unless explicitly requested.
- `.flowbite-react/class-list.json` is generated (scanned by Tailwind's
  `@source` in `src/styles.css`) — do not hand-edit it.

## Icons

- Icons come from **`lucide-react`**. Use PascalCase **named imports**
  (e.g. `import { Check, Sun, Moon } from 'lucide-react'`). Do not use
  default imports.
- Pass styling via standard SVG props: `className` (Tailwind sizing
  like `h-5 w-5`), `strokeWidth` (number), `color`/`fill`. Use
  `aria-hidden="true"` for decorative icons.
- When you need an icon for a new concept, search the catalog via
  Context7 before inventing an inline SVG or guessing a name:

  ```text
  query-docs: libraryId="/lucide-icons/lucide",
     query="<concept e.g. 'check sun moon'> icon named import props"
  ```

  Pick the shortest matching PascalCase name from the documented list
  (e.g. `Check`, not `CheckIcon`). Fall back to inline `<svg>` only if
  no Lucide icon matches.

## Project layout

- `src/components/` — UI components (one feature per file).
- `src/hooks/` — React hooks; data hooks subscribe to RxDB via RxJS.
- `src/db/` — RxDB database setup; `getDb()` is the async entry point.
  Per-platform storage factories live in `src/db/storage.ts`.
- `src/platform/` — build-time platform/env mapping (`env.ts`).
- `src/fsrs/` — scheduler + mappers for `ts-fsrs`.
- `src/types.ts` — shared document types (`Deck`, `CardDoc`).
