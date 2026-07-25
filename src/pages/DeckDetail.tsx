import { useEffect, useMemo, useRef, useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { Popover } from 'flowbite-react';
import { getDb } from '../db';
import type { CardDoc } from '../types';
import { useCards } from '../hooks/useCards';
import { useDeck } from '../hooks/useDecks';
import { useToast } from '../hooks/useToast';
import { btnPrimary, inputClass } from '../components/ui';
import {
  countPendingAttachments,
  downloadDeckAttachments,
  removeDeckBlobContent
} from '../lib/offlineAttachments';
import { Check, Info } from 'lucide-react';
import { DeleteButton } from '../components/DeleteButton';
import { CardStateBadge } from '../components/CardStateBadge';
import { AttachmentAudioButtons, AttachmentThumbnails } from '../components/Attachments';
import { playAudio } from '../lib/commonsThumb';
import { attachmentSrc } from '../lib/attachments';
import { CardForm } from '../components/AddEditCard';

function CardList({ deckId, cards }: { deckId: string; cards: CardDoc[] }) {
  const [editingCardId, setEditingCardId] = useState<string | null>(null);
  const editingCard: CardDoc | null = useMemo(
    () => cards.find((c) => c.id === editingCardId) ?? null,
    [cards, editingCardId]
  );
  const latestCard: CardDoc | null = useMemo(
    () =>
      cards.reduce<CardDoc | null>(
        (acc, c) => (acc === null || c.updatedAt > acc.updatedAt ? c : acc),
        null
      ),
    [cards]
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
        latestCard={latestCard}
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
                    onPlay={(i) => playAudio(attachmentSrc(card.front_attachments.filter((a) => a.type === 'audio')[i]))}
                  />
                </div>
                <AttachmentThumbnails attachments={card.back_attachments} />
                <div className="flex items-center gap-1.5 text-sm text-zinc-500 dark:text-zinc-400">
                  <span>{card.back}</span>
                  <AttachmentAudioButtons
                    attachments={card.back_attachments}
                    onPlay={(i) => playAudio(attachmentSrc(card.back_attachments.filter((a) => a.type === 'audio')[i]))}
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
  const cards = useCards(deckId);
  const [editingName, setEditingName] = useState(false);
  const [nameValue, setNameValue] = useState('');
  const inputRef = useRef<HTMLInputElement>(null);
  const { notify } = useToast();

  const [progress, setProgress] = useState<{ done: number; total: number } | null>(null);
  const downloadingRef = useRef(false);
  const downloadRunRef = useRef<Promise<void> | null>(null);
  const cancelCurrentRef = useRef<(() => void) | null>(null);
  const unmountedRef = useRef(false);

  const offlineEnabled = deck?.keep_attachments_offline ?? false;
  const pendingCount = useMemo(() => countPendingAttachments(cards), [cards]);

  useEffect(() => {
    unmountedRef.current = false;
    return () => {
      unmountedRef.current = true;
    };
  }, []);

  useEffect(() => {
    if (editingName) {
      setNameValue(deck?.name ?? '');
      inputRef.current?.focus();
    }
  }, [editingName, deck?.name]);

  useEffect(() => {
    if (!deckId || !offlineEnabled || pendingCount === 0 || downloadingRef.current) {
      return;
    }
    downloadingRef.current = true;
    let cancelled = false;
    cancelCurrentRef.current = () => {
      cancelled = true;
    };
    const total = pendingCount;
    let done = 0;
    downloadRunRef.current = (async () => {
      const db = await getDb();
      const deckDoc = await db.decks
        .findOne({ selector: { id: deckId } })
        .exec();
      if (!deckDoc?.get('keep_attachments_offline')) return;
      setProgress({ done, total });
      await downloadDeckAttachments(
        db,
        deckId,
        () => {
          done += 1;
          if (!unmountedRef.current) setProgress({ done, total });
        },
        () => cancelled || unmountedRef.current
      );
    })();
    downloadRunRef.current
      .catch((err) => {
        if (!unmountedRef.current) {
          notify(
            `Could not download attachments: ${err instanceof Error ? err.message : String(err)}`
          );
        }
      })
      .finally(() => {
        downloadingRef.current = false;
        if (!unmountedRef.current) setProgress(null);
      });
  }, [deckId, offlineEnabled, pendingCount, notify]);

  if (!deckId) return <p>Missing deck.</p>;

  async function toggleOffline() {
    const db = await getDb();
    const doc = await db.decks
      .findOne({ selector: { id: deckId } })
      .exec();
    if (!doc) return;
    const next = !doc.get('keep_attachments_offline');
    await doc.patch({ keep_attachments_offline: next });
    if (!next) {
      cancelCurrentRef.current?.();
      await downloadRunRef.current?.catch(() => {});
      await removeDeckBlobContent(db, deckId!);
    }
  }

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
      {progress ? (
        <div
          role="progressbar"
          aria-valuemin={0}
          aria-valuemax={progress.total}
          aria-valuenow={progress.done}
          aria-label="Downloading attachments"
          className="h-2 w-full rounded-full bg-zinc-200 dark:bg-zinc-800"
        >
          <div
            className="h-2 rounded-full bg-indigo-600 transition-all duration-300"
            style={{ width: `${Math.round((progress.done / progress.total) * 100)}%` }}
          />
        </div>
      ) : null}
      <nav className="flex flex-wrap items-center gap-x-4 gap-y-2 text-sm text-zinc-500 dark:text-zinc-400">
        <div className="flex items-center gap-1.5">
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
        </div>
        <div className="ms-auto flex items-center gap-2">
          <label className="inline-flex cursor-pointer items-center">
            <input
              type="checkbox"
              checked={offlineEnabled}
              onChange={toggleOffline}
              className="peer sr-only"
            />
            <div className="peer relative h-5 w-9 rounded-full bg-zinc-300 after:absolute after:start-[2px] after:top-[2px] after:h-4 after:w-4 after:rounded-full after:bg-white after:transition-all after:content-[''] peer-checked:bg-indigo-600 peer-checked:after:translate-x-full peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-indigo-500/30 dark:bg-zinc-700 rtl:peer-checked:after:-translate-x-full" />
            <span className="ms-3 select-none text-sm font-medium text-zinc-700 dark:text-zinc-300">
              Save attachments
            </span>
          </label>
          <Popover
            trigger="click"
            placement="bottom-end"
            content={
              <div className="w-72 p-3 text-sm text-zinc-600 dark:text-zinc-300">
                Downloads all Commons attachments, current and future, so you
                can study without an internet connection.
              </div>
            }
          >
            <button type="button" aria-label="Show information">
              <Info
                className="h-4 w-4 text-zinc-400 transition hover:text-zinc-600 dark:hover:text-zinc-200"
                aria-hidden="true"
              />
            </button>
          </Popover>
        </div>
      </nav>
      <div className="flex flex-wrap items-center gap-4">
        <Link to={`/study?deck=${deckId}`} className={btnPrimary}>
          Study now
        </Link>
      </div>
      <CardList deckId={deckId} cards={cards} />
    </div>
  );
}
