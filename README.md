# Apprendo

Apprendo is an offline-first language-learning flashcard app. It pulls
images and native-speaker pronunciation straight from Wikimedia Commons
to build the front and back of your cards, schedules reviews with
spaced repetition, and lets you study multiple decks in a single
session.

<p>
  <a href="https://apprendo.study">
    <img alt="apprendo.study" src="https://img.shields.io/website?url=https%3A%2F%2Fapprendo.study&up_message=Open%20Apprendo&up_color=4f46e5&down_message=Site%20down&down_color=red&style=for-the-badge">
  </a>
</p>

## Features

- 🖼️ **Auto-illustrated cards** — fetches images and audio pronunciation
  from Wikimedia Commons.
- 📴 **Fully offline** — installable as a PWA, data lives locally via
  RxDB.
- 🧠 **FSRS scheduling** — reviews are timed by [FSRS](https://github.com/open-spaced-repetition/ts-fsrs)
  (Free Spaced Repetition Scheduler), a modern algorithm that models
  each card's difficulty and memory stability to predict the exact
  moment you're about to forget it. It's the same algorithm available
  as an official (opt-in) scheduler option in Anki.
- 📚 **Multi-deck sessions** — study several decks together in one
  sitting.

## Architecture

- **Stack**: [Vite](https://vitejs.dev) + React 19 + TypeScript.
- **Styling**: Tailwind CSS v4 (via `@tailwindcss/vite`), with
  [Flowbite React](https://flowbite-react.com) for prebuilt components
  and [`lucide-react`](https://lucide.dev) for icons.
- **Data layer**: [RxDB](https://rxdb.info) + RxJS for local-first,
  reactive storage.
- **Scheduling**: [`ts-fsrs`](https://github.com/open-spaced-repetition/ts-fsrs)
  implements the FSRS spaced-repetition algorithm.
- **Linting**: [oxlint](https://oxc.rs/docs/guide/usage/linter.html).

Project layout:

```
src/components/    UI components (one feature per file)
src/hooks/         React hooks; data hooks subscribe to RxDB via RxJS
src/db/            RxDB database setup (getDb() is the async entry point)
src/fsrs/          Scheduler + mappers for ts-fsrs
src/integrations/  Wikimedia Commons API client and language data
src/lib/           Small shared utilities (e.g. Commons thumbnail URLs)
src/types.ts       Shared document types (Deck, CardDoc)
```

## Getting started

Install dependencies:

```bash
npm install
```

Run the app in development mode:

```bash
npm run dev
```

The dev server serves the app at http://localhost:5173.

## Building

Create a production build:

```bash
npm run build
```
