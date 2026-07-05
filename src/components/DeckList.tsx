import { useState } from 'react';
import { nanoid } from 'nanoid';
import { Link } from 'react-router-dom';
import { getDb } from '../db';
import type { Deck, Language } from '../types';
import { LANGUAGES, LANG_BY_QID } from '../integrations/languages';
import { btnPrimary, inputClass } from './ui';
import { useToast } from '../hooks/useToast';
import { DeleteButton } from './DeleteButton';

export function DeckForm() {
  const [name, setName] = useState('');
  const [languageQid, setLanguageQid] = useState('');
  const { notify } = useToast();

  async function submit(e: React.FormEvent) {
    e.preventDefault();
    const trimmed = name.trim();
    if (!trimmed) return;
    const language: Language | null = languageQid
      ? LANG_BY_QID[languageQid] ?? null
      : null;
    const db = await getDb();
    const deck: Deck = {
      id: nanoid(),
      name: trimmed,
      language,
      createdAt: Date.now()
    };
    try {
      await db.decks.insert(deck);
      setName('');
      setLanguageQid('');
    } catch (err) {
      notify(`Could not create deck: ${err instanceof Error ? err.message : String(err)}`);
    }
  }

  return (
    <form className="flex gap-2" onSubmit={submit}>
      <input
        type="text"
        placeholder="New deck name…"
        value={name}
        onChange={(e) => setName(e.target.value)}
        autoFocus
        className={inputClass}
      />
      <select
        value={languageQid}
        onChange={(e) => setLanguageQid(e.target.value)}
        className={inputClass}
        aria-label="Deck language"
      >
        <option value="">No language</option>
        {LANGUAGES.map((l) => (
          <option key={l.qid} value={l.qid}>
            {l.label}
          </option>
        ))}
      </select>
      <button type="submit" className={btnPrimary}>
        Add deck
      </button>
    </form>
  );
}

export function DeckList({ decks }: { decks: Deck[] }) {
  if (decks.length === 0) {
    return (
      <div className="rounded-2xl border border-dashed border-zinc-300 px-6 py-12 text-center dark:border-zinc-700">
        <p className="text-sm font-medium text-zinc-600 dark:text-zinc-300">
          No decks yet
        </p>
        <p className="mt-1 text-xs text-zinc-400 dark:text-zinc-500">
          Create one above to get started.
        </p>
      </div>
    );
  }
  return (
    <ul className="grid gap-3 sm:grid-cols-2">
      {decks.map((deck) => (
        <li key={deck.id} className="relative">
          <DeleteButton
            label="Delete deck"
            confirmMessage={`Delete "${deck.name}" and all its cards?`}
            onDelete={async () => {
              const db = await getDb();
              const cards = await db.cards
                .find({ selector: { deckId: deck.id } })
                .exec();
              await Promise.all(cards.map((c) => c.remove()));
              const doc = await db.decks
                .findOne({ selector: { id: deck.id } })
                .exec();
              await doc?.remove();
            }}
            className="absolute right-2 top-2 z-10"
          />
          <Link
            to={`/deck/${deck.id}`}
            className="group flex flex-col rounded-2xl border border-zinc-200 bg-white p-5 shadow-sm transition hover:-translate-y-0.5 hover:border-indigo-400 hover:shadow-md dark:border-zinc-800 dark:bg-zinc-900 dark:hover:border-indigo-500"
          >
            <span className="truncate font-semibold text-zinc-900 transition group-hover:text-indigo-600 dark:text-zinc-100 dark:group-hover:text-indigo-400">
              {deck.name}
            </span>
            <span className="mt-2 text-xs text-zinc-500 dark:text-zinc-400">
              {new Date(deck.createdAt).toLocaleDateString()}
            </span>
          </Link>
        </li>
      ))}
    </ul>
  );
}
