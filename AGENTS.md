# AGENTS.md

## Tech stack

Vite + React 19 + TypeScript. Styling is **Tailwind CSS v4** (via the
`@tailwindcss/vite` plugin in `vite.config.ts`). Linting with oxlint.
Data layer: RxDB + RxJS; spaced repetition via `ts-fsrs`.

## Required checks

Always run the following before considering work done. Fix any errors.

```bash
npm run lint        # oxlint (config in .oxlintrc.json)
npx tsc -b          # TypeScript typecheck (config in tsconfig.json / tsconfig.app.json)
npm run build       # tsc -b && vite build (production build)
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

## Project layout

- `src/components/` — UI components (one feature per file).
- `src/hooks/` — React hooks; data hooks subscribe to RxDB via RxJS.
- `src/db/` — RxDB database setup; `getDb()` is the async entry point.
- `src/fsrs/` — scheduler + mappers for `ts-fsrs`.
- `src/types.ts` — shared document types (`Deck`, `CardDoc`).
