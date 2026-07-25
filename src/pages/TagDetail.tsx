import { useEffect, useRef, useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { Checkbox } from 'flowbite-react';
import { ArrowLeft, Loader2 } from 'lucide-react';
import { getDb } from '../db';
import { inputClass } from '../components/ui';
import { useToast } from '../hooks/useToast';
import { useTag } from '../hooks/useTags';
import { useDecks } from '../hooks/useDecks';

export default function TagDetail() {
  const { tagId } = useParams<{ tagId: string }>();
  const { tag, loaded } = useTag(tagId);
  const decks = useDecks();
  const { notify } = useToast();
  const [name, setName] = useState('');
  const initializedRef = useRef(false);

  useEffect(() => {
    if (initializedRef.current || !tag) return;
    initializedRef.current = true;
    setName(tag.name);
  }, [tag]);

  async function patchTag(patch: { name?: string; deckIds?: string[] }) {
    if (!tagId) return;
    try {
      const db = await getDb();
      const doc = await db.tags.findOne(tagId).exec();
      if (doc) await doc.patch(patch);
    } catch (err) {
      notify(`Could not save tag: ${err instanceof Error ? err.message : String(err)}`);
    }
  }

  function rename(value: string) {
    setName(value);
    void patchTag({ name: value.trim() });
  }

  function toggleDeck(deckId: string) {
    if (!tag) return;
    const next = tag.deckIds.includes(deckId)
      ? tag.deckIds.filter((id) => id !== deckId)
      : [...tag.deckIds, deckId];
    void patchTag({ deckIds: next });
  }

  if (!loaded) {
    return (
      <div className="flex min-h-[280px] items-center justify-center">
        <Loader2
          className="h-6 w-6 animate-spin text-zinc-400"
          aria-hidden="true"
        />
      </div>
    );
  }

  if (!tag) {
    return (
      <div className="space-y-4">
        <p className="text-sm text-zinc-500 dark:text-zinc-400">Tag not found.</p>
        <Link
          to="/"
          className="inline-flex items-center gap-1.5 text-sm text-zinc-500 transition hover:text-indigo-600 dark:text-zinc-400 dark:hover:text-indigo-400"
        >
          <ArrowLeft className="h-4 w-4" aria-hidden="true" />
          Decks
        </Link>
      </div>
    );
  }

  return (
    <section className="space-y-6">
      <Link
        to="/"
        className="inline-flex items-center gap-1.5 text-sm text-zinc-500 transition hover:text-indigo-600 dark:text-zinc-400 dark:hover:text-indigo-400"
      >
        <ArrowLeft className="h-4 w-4" aria-hidden="true" />
        Decks
      </Link>
      <div>
        <h2 className="text-xl font-bold tracking-tight">Tag</h2>
        <p className="mt-1 text-sm text-zinc-500 dark:text-zinc-400">
          Changes are saved automatically.
        </p>
      </div>
      <div className="space-y-1.5">
        <label
          htmlFor="tag-name"
          className="text-sm font-medium text-zinc-700 dark:text-zinc-200"
        >
          Name
        </label>
        <input
          id="tag-name"
          type="text"
          placeholder="Tag name…"
          value={name}
          onChange={(e) => rename(e.target.value)}
          autoFocus
          className={inputClass}
        />
      </div>
      <div className="space-y-2">
        <h3 className="text-sm font-medium text-zinc-700 dark:text-zinc-200">
          Decks
        </h3>
        {decks.length === 0 ? (
          <p className="rounded-xl border border-dashed border-zinc-300 px-4 py-6 text-center text-sm text-zinc-400 dark:border-zinc-700 dark:text-zinc-500">
            No decks yet. Create one first.
          </p>
        ) : (
          <ul className="grid gap-2 sm:grid-cols-2">
            {decks.map((deck) => (
              <li key={deck.id}>
                <label className="flex cursor-pointer items-center gap-3 rounded-xl border border-zinc-200 bg-white px-4 py-3 shadow-sm transition hover:border-indigo-400 dark:border-zinc-800 dark:bg-zinc-900 dark:hover:border-indigo-500">
                  <Checkbox
                    checked={tag.deckIds.includes(deck.id)}
                    onChange={() => toggleDeck(deck.id)}
                  />
                  <span className="truncate text-sm font-medium text-zinc-900 dark:text-zinc-100">
                    {deck.name}
                  </span>
                </label>
              </li>
            ))}
          </ul>
        )}
      </div>
    </section>
  );
}
