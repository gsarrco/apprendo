import { useState } from 'react';
import { nanoid } from 'nanoid';
import { Link, useNavigate } from 'react-router-dom';
import { Checkbox, Dropdown, DropdownItem } from 'flowbite-react';
import { Trash2 } from 'lucide-react';
import { getDb } from '../db';
import type { Deck, Language } from '../types';
import { LANGUAGES, LANG_BY_QID } from '../integrations/languages';
import { btnPrimary, inputClass } from './ui';
import { useToast } from '../hooks/useToast';

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
    const deck: Deck = {
      id: nanoid(),
      name: trimmed,
      language,
      createdAt: Date.now()
    };
    try {
      const db = await getDb();
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
  const navigate = useNavigate();
  const { notify } = useToast();
  const [selectedIds, setSelectedIds] = useState<Set<string>>(new Set());

  function toggle(id: string) {
    setSelectedIds((prev) => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
  }

  async function deleteSelected() {
    const ids = [...selectedIds];
    if (ids.length === 0) return;
    const ok = window.confirm(
      `Delete ${ids.length} deck${ids.length === 1 ? '' : 's'} and all their cards?`
    );
    if (!ok) return;
    try {
      const db = await getDb();
      const cards = await db.cards
        .find({ selector: { deckId: { $in: ids } } })
        .exec();
      await Promise.all(cards.map((c) => c.remove()));
      const deckDocs = await db.decks
        .find({ selector: { id: { $in: ids } } })
        .exec();
      await Promise.all(deckDocs.map((d) => d.remove()));
      setSelectedIds(new Set());
    } catch (err) {
      notify(
        `Could not delete: ${err instanceof Error ? err.message : String(err)}`
      );
    }
  }

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

  const selectedCount = selectedIds.size;

  return (
    <div className="space-y-3">
      {selectedCount > 0 && (
        <div className="flex items-center justify-between gap-3 rounded-xl border border-zinc-200 bg-white px-4 py-3 shadow-sm dark:border-zinc-800 dark:bg-zinc-900">
          <span className="text-sm font-medium text-zinc-700 dark:text-zinc-200">
            {selectedCount} selected
          </span>
          <div className="flex items-center gap-2">
            <button
              type="button"
              className={btnPrimary}
              onClick={() =>
                navigate(`/study?decks=${[...selectedIds].join(',')}`)
              }
            >
              Study now
            </button>
            <Dropdown
              color="gray"
              label="Action"
              dismissOnClick
            >
              <DropdownItem
                icon={Trash2}
                className="text-red-600 dark:text-red-500"
                onClick={deleteSelected}
              >
                Delete
              </DropdownItem>
            </Dropdown>
          </div>
        </div>
      )}
      <ul className="grid gap-3 sm:grid-cols-2">
        {decks.map((deck) => {
          const checked = selectedIds.has(deck.id);
          return (
            <li key={deck.id} className="relative">
              <Checkbox
                checked={checked}
                onChange={() => toggle(deck.id)}
                aria-label={`Select ${deck.name}`}
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
          );
        })}
      </ul>
    </div>
  );
}
