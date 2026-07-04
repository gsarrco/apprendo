import { Link, useParams } from 'react-router-dom';
import { nanoid } from 'nanoid';
import { useState } from 'react';
import { getDb } from '../db';
import { createEmptyCard } from '../fsrs/scheduler';
import { fromFsrsCard } from '../fsrs/mappers';
import type { CardDoc } from '../types';
import { useCards } from '../hooks/useCards';
import { useDeck } from '../hooks/useDecks';
import { btnPrimary, btnGhost, inputClass } from './ui';
import { Trash2 } from 'lucide-react';

const STATE_LABELS = ['New', 'Learning', 'Review', 'Relearning'];

const STATE_STYLES: Record<number, string> = {
  0: 'border-zinc-300 text-zinc-500 dark:border-zinc-600 dark:text-zinc-400',
  1: 'border-amber-400/60 text-amber-500',
  2: 'border-emerald-400/60 text-emerald-500',
  3: 'border-red-400/60 text-red-500'
};

export function CardForm({ deckId }: { deckId: string }) {
  const [front, setFront] = useState('');
  const [back, setBack] = useState('');

  async function submit(e: React.FormEvent) {
    e.preventDefault();
    const f = front.trim();
    const b = back.trim();
    if (!f || !b) return;
    const db = await getDb();
    const empty = createEmptyCard(new Date());
    const doc: CardDoc = fromFsrsCard(empty, {
      id: nanoid(),
      deckId,
      front: f,
      back: b,
      createdAt: Date.now()
    });
    await db.cards.insert(doc);
    setFront('');
    setBack('');
  }

  return (
    <form className="grid gap-2" onSubmit={submit}>
      <textarea
        placeholder="Front"
        value={front}
        onChange={(e) => setFront(e.target.value)}
        rows={2}
        className={`${inputClass} resize-y`}
      />
      <textarea
        placeholder="Back"
        value={back}
        onChange={(e) => setBack(e.target.value)}
        rows={2}
        className={`${inputClass} resize-y`}
      />
      <button type="submit" className={`${btnPrimary} justify-self-start`}>
        Add card
      </button>
    </form>
  );
}

export function CardList({ deckId }: { deckId: string }) {
  const cards = useCards(deckId);
  return (
    <div className="space-y-4">
      <h3 className="text-sm font-semibold text-zinc-500 dark:text-zinc-400">
        Cards{' '}
        <span className="text-zinc-400 dark:text-zinc-500">
          ({cards.length})
        </span>
      </h3>
      <CardForm deckId={deckId} />
      {cards.length === 0 ? (
        <p className="rounded-xl border border-dashed border-zinc-300 px-4 py-6 text-center text-sm text-zinc-400 dark:border-zinc-700 dark:text-zinc-500">
          No cards yet. Add one above.
        </p>
      ) : (
        <ul className="grid gap-2">
          {cards.map((card) => (
            <li
              key={card.id}
              className="flex items-start justify-between gap-4 rounded-xl border border-zinc-200 bg-white px-4 py-3 shadow-sm dark:border-zinc-800 dark:bg-zinc-900"
            >
              <div className="grid flex-1 gap-0.5">
                <div className="font-semibold text-zinc-900 dark:text-zinc-100">
                  {card.front}
                </div>
                <div className="text-sm text-zinc-500 dark:text-zinc-400">
                  {card.back}
                </div>
              </div>
              <div className="flex shrink-0 items-center gap-2">
                <div className="flex flex-col items-end gap-1 text-xs text-zinc-400 dark:text-zinc-500">
                  <span
                    className={`rounded-full border px-2 py-0.5 text-[0.7rem] capitalize ${STATE_STYLES[card.state] ?? STATE_STYLES[0]}`}
                  >
                    {STATE_LABELS[card.state] ?? card.state}
                  </span>
                  <span className="whitespace-nowrap">
                    due {new Date(card.due).toLocaleString()}
                  </span>
                </div>
                <button
                  type="button"
                  aria-label="Delete card"
                  onClick={async () => {
                    const db = await getDb();
                    const doc = await db.cards
                      .findOne({
                        selector: { id: card.id }
                      })
                      .exec();
                    await doc?.remove();
                  }}
                  className={btnGhost}
                >
                  <Trash2 className="h-4 w-4" aria-hidden="true" />
                </button>
              </div>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}

export function DeckDetail() {
  const { deckId } = useParams();
  const deck = useDeck(deckId ?? '');
  if (!deckId) return <p>Missing deck.</p>;
  return (
    <div className="space-y-6">
      <nav className="flex items-center gap-1.5 text-sm text-zinc-500 dark:text-zinc-400">
        <Link
          to="/"
          className="transition hover:text-indigo-600 dark:hover:text-indigo-400"
        >
          Decks
        </Link>
        <span className="text-zinc-300 dark:text-zinc-600">/</span>
        <span className="font-medium text-zinc-700 dark:text-zinc-300">
          {deck?.name ?? deckId.slice(0, 8)}
        </span>
      </nav>
      <div>
        <Link
          to={`/deck/${deckId}/study`}
          className={btnPrimary}
        >
          Study now
        </Link>
      </div>
      <CardList deckId={deckId} />
    </div>
  );
}
