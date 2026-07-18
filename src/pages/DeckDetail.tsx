import { useEffect, useMemo, useRef, useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { getDb } from '../db';
import type { CardDoc, Language } from '../types';
import { LANGUAGES, LANG_BY_QID } from '../integrations/languages';
import { useCards } from '../hooks/useCards';
import { useDeck } from '../hooks/useDecks';
import { btnPrimary, inputClass } from '../components/ui';
import { Check } from 'lucide-react';
import { DeleteButton } from '../components/DeleteButton';
import { CardStateBadge } from '../components/CardStateBadge';
import { AttachmentAudioButtons, AttachmentThumbnails } from '../components/Attachments';
import { playAudio } from '../lib/commonsThumb';
import { CardForm } from '../components/AddEditCard';

function CardList({
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
      <div className="mt-6 mb-2 flex items-center gap-3" role="separator">
        <span className="h-px flex-1 bg-zinc-200 dark:bg-zinc-800" />
        <span className="text-xs font-medium tracking-wide text-zinc-400 dark:text-zinc-500">
          {cards.length === 0 ? 'Cards' : `Cards · ${cards.length}`}
        </span>
        <span className="h-px flex-1 bg-zinc-200 dark:bg-zinc-800" />
      </div>
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
                <AttachmentThumbnails attachments={card.front_attachments} />
                <div className="flex items-center gap-1.5 font-semibold text-zinc-900 dark:text-zinc-100">
                  {card.front}
                  <AttachmentAudioButtons
                    attachments={card.front_attachments}
                    onPlay={(i) => playAudio(card.front_attachments.filter((a) => a.type === 'audio')[i].url)}
                  />
                </div>
                <AttachmentThumbnails attachments={card.back_attachments} />
                <div className="flex items-center gap-1.5 text-sm text-zinc-500 dark:text-zinc-400">
                  <span>{card.back}</span>
                  <AttachmentAudioButtons
                    attachments={card.back_attachments}
                    onPlay={(i) => playAudio(card.back_attachments.filter((a) => a.type === 'audio')[i].url)}
                  />
                </div>
              </div>
              <div
                className="flex shrink-0 items-center gap-2"
                onClick={(e) => e.stopPropagation()}
              >
                <div className="flex flex-col items-end gap-1 text-xs text-zinc-400 dark:text-zinc-500">
                  <CardStateBadge state={card.state} />
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

export default function DeckDetail() {
  const { deckId } = useParams();
  const deck = useDeck(deckId ?? '');
  const [editingName, setEditingName] = useState(false);
  const [nameValue, setNameValue] = useState('');
  const inputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    if (editingName) {
      setNameValue(deck?.name ?? '');
      inputRef.current?.focus();
    }
  }, [editingName, deck?.name]);

  if (!deckId) return <p>Missing deck.</p>;

  async function saveName() {
    const trimmed = nameValue.trim();
    if (!trimmed || !deck) {
      setEditingName(false);
      return;
    }
    const db = await getDb();
    const doc = await db.decks
      .findOne({ selector: { id: deckId } })
      .exec();
    if (doc && trimmed !== deck.name) {
      await doc.patch({ name: trimmed });
    }
    setEditingName(false);
  }

  return (
    <div className="space-y-6">
      <nav className="flex items-center gap-1.5 text-sm text-zinc-500 dark:text-zinc-400">
        <Link
          to="/"
          onClick={(e) => {
            if (editingName) e.preventDefault();
          }}
          className="transition hover:text-indigo-600 dark:hover:text-indigo-400"
        >
          Decks
        </Link>
        <span className="text-zinc-300 dark:text-zinc-600">/</span>
        {editingName ? (
          <div className="flex items-center gap-1">
            <input
              ref={inputRef}
              value={nameValue}
              onChange={(e) => setNameValue(e.target.value)}
              onKeyDown={(e) => {
                if (e.key === 'Enter') saveName();
                if (e.key === 'Escape') setEditingName(false);
              }}
              className={`${inputClass} py-1`}
            />
            <button
              type="button"
              aria-label="Save name"
              onClick={saveName}
              className="text-zinc-400 transition hover:text-emerald-600 dark:hover:text-emerald-400"
            >
              <Check className="h-4 w-4" aria-hidden="true" />
            </button>
          </div>
        ) : (
          <button
            type="button"
            title="Edit deck name"
            onClick={() => setEditingName(true)}
            className="rounded font-medium text-zinc-700 transition hover:text-indigo-600 dark:text-zinc-300 dark:hover:text-indigo-400"
          >
            {deck?.name ?? deckId.slice(0, 8)}
          </button>
        )}
      </nav>
      <div className="flex flex-wrap items-center gap-4">
        <Link to={`/study?decks=${deckId}`} className={btnPrimary}>
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
