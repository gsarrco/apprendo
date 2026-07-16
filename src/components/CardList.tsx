import { useMemo, useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { getDb } from '../db';
import type { CardAttachment, CardDoc, Language } from '../types';
import { LANGUAGES, LANG_BY_QID } from '../integrations/languages';
import { useCards } from '../hooks/useCards';
import { useDeck } from '../hooks/useDecks';
import { btnPrimary, inputClass } from './ui';
import { Volume2 } from 'lucide-react';
import { DeleteButton } from './DeleteButton';
import { playAudio } from '../lib/commonsThumb';
import { CardForm } from './AddEditCard';

const STATE_LABELS = ['New', 'Learning', 'Review', 'Relearning'];

const STATE_STYLES: Record<number, string> = {
  0: 'border-zinc-300 text-zinc-500 dark:border-zinc-600 dark:text-zinc-400',
  1: 'border-amber-400/60 text-amber-500',
  2: 'border-emerald-400/60 text-emerald-500',
  3: 'border-red-400/60 text-red-500'
};

function Thumbnails({ attachments }: { attachments: CardAttachment[] }) {
  const images = attachments.filter((a) => a.type === 'image');
  if (images.length === 0) return null;
  return (
    <div className="grid w-fit grid-cols-2 gap-1">
      {images.slice(0, 4).map((a) => (
        <img
          key={a.url}
          src={a.url}
          alt=""
          onClick={(e) => e.stopPropagation()}
          className="h-12 w-12 rounded-lg object-cover"
        />
      ))}
      {images.length > 4 ? (
        <span className="flex h-12 w-12 items-center justify-center rounded-lg bg-zinc-100 text-xs font-medium text-zinc-500 dark:bg-zinc-800 dark:text-zinc-400">
          +{images.length - 4}
        </span>
      ) : null}
    </div>
  );
}

function AudioButtons({ attachments }: { attachments: CardAttachment[] }) {
  const audio = attachments.filter((a) => a.type === 'audio');
  if (audio.length === 0) return null;
  return audio.map((a) => (
    <button
      key={a.url}
      type="button"
      aria-label="Play audio"
      onClick={(e) => {
        e.stopPropagation();
        playAudio(a.url);
      }}
      className="text-zinc-400 transition hover:text-indigo-600 dark:hover:text-indigo-400"
    >
      <Volume2 className="h-4 w-4" aria-hidden="true" />
    </button>
  ));
}

export function CardList({
  deckId,
  language
}: {
  deckId: string;
  language: Language | null;
}) {
  const cards = useCards(deckId);
  const [editingCardId, setEditingCardId] = useState<string | null>(null);
  const editingCard: CardDoc | null = useMemo(
    () => cards.find((c) => c.id === editingCardId) ?? null,
    [cards, editingCardId]
  );
  return (
    <div className="space-y-4">
      {editingCard ? (
        <h3 className="text-sm font-semibold text-zinc-500 dark:text-zinc-400">
          {`Edit card #${editingCard.id.slice(-4)}`}
        </h3>
      ) : null}
      <CardForm
        deckId={deckId}
        language={language}
        editingCard={editingCard}
        onDone={() => setEditingCardId(null)}
      />
      {cards.length === 0 ? (
        <p className="rounded-xl border border-dashed border-zinc-300 px-4 py-6 text-center text-sm text-zinc-400 dark:border-zinc-700 dark:text-zinc-500">
          No cards yet. Add one above.
        </p>
      ) : (
        <ul className="grid gap-2">
          {cards.map((card) => (
            <li
              key={card.id}
              onClick={() => setEditingCardId(card.id)}
              className={`flex cursor-pointer items-start justify-between gap-4 rounded-xl border bg-white px-4 py-3 shadow-sm transition dark:bg-zinc-900 ${
                editingCardId === card.id
                  ? 'border-indigo-500 ring-2 ring-indigo-500/30'
                  : 'border-zinc-200 hover:border-zinc-300 dark:border-zinc-800 dark:hover:border-zinc-700'
              }`}
            >
              <div className="grid flex-1 gap-0.5">
                <Thumbnails attachments={card.front_attachments} />
                <div className="flex items-center gap-1.5 font-semibold text-zinc-900 dark:text-zinc-100">
                  {card.front}
                  <AudioButtons attachments={card.front_attachments} />
                </div>
                <Thumbnails attachments={card.back_attachments} />
                <div className="flex items-center gap-1.5 text-sm text-zinc-500 dark:text-zinc-400">
                  <span>{card.back}</span>
                  <AudioButtons attachments={card.back_attachments} />
                </div>
              </div>
              <div
                className="flex shrink-0 items-center gap-2"
                onClick={(e) => e.stopPropagation()}
              >
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
                <DeleteButton
                  label="Delete card"
                  onDelete={async () => {
                    const db = await getDb();
                    const doc = await db.cards
                      .findOne({ selector: { id: card.id } })
                      .exec();
                    await doc?.remove();
                    if (editingCardId === card.id) setEditingCardId(null);
                  }}
                />
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
      <div className="flex flex-wrap items-center gap-4">
        <Link to={`/deck/${deckId}/study`} className={btnPrimary}>
          Study now
        </Link>
        <label className="flex items-center gap-2 text-sm text-zinc-600 dark:text-zinc-300">
          Language
          <select
            value={deck?.language?.qid ?? ''}
            onChange={async (e) => {
              const value = e.target.value;
              const newLang: Language | null = value
                ? LANG_BY_QID[value] ?? null
                : null;
              const db = await getDb();
              const doc = await db.decks
                .findOne({ selector: { id: deckId } })
                .exec();
              await doc?.patch({ language: newLang });
            }}
            className={inputClass}
          >
            <option value="">No language</option>
            {LANGUAGES.map((l) => (
              <option key={l.qid} value={l.qid}>
                {l.label}
              </option>
            ))}
          </select>
        </label>
      </div>
      <CardList deckId={deckId} language={deck?.language ?? null} />
    </div>
  );
}
