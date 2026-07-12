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
- `src/fsrs/` — scheduler + mappers for `ts-fsrs`.
- `src/types.ts` — shared document types (`Deck`, `CardDoc`).
