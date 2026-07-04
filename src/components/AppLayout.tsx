import { Link, Outlet } from 'react-router-dom';
import { useDecks } from '../hooks/useDecks';
import { DeckForm, DeckList } from './DeckList';
import { ThemeToggle } from './ThemeToggle';

export function DeckIndex() {
  const decks = useDecks();
  return (
    <section className="space-y-6">
      <div>
        <h2 className="text-xl font-bold tracking-tight">Decks</h2>
        <p className="mt-1 text-sm text-zinc-500 dark:text-zinc-400">
          Create decks of flashcards and study them on a spaced-repetition schedule.
        </p>
      </div>
      <DeckForm />
      <DeckList decks={decks} />
    </section>
  );
}

export function Layout() {
  return (
    <div className="min-h-full">
      <header className="sticky top-0 z-10 border-b border-zinc-200 bg-white/80 backdrop-blur dark:border-zinc-800 dark:bg-zinc-950/80">
        <div className="mx-auto flex h-14 max-w-3xl items-center justify-between px-5">
          <Link
            to="/"
            className="text-base font-bold tracking-tight transition hover:text-indigo-600 dark:hover:text-indigo-400"
          >
            Apprendo
          </Link>
          <ThemeToggle />
        </div>
      </header>
      <main className="mx-auto max-w-3xl px-5 py-10">
        <Outlet />
      </main>
    </div>
  );
}
