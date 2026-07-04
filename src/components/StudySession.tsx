import { useMemo, useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { Check } from 'lucide-react';
import { nanoid } from 'nanoid';
import { Rating, type Grade } from 'ts-fsrs';
import { getDb } from '../db';
import { scheduler } from '../fsrs/scheduler';
import { toFsrsCard, fromFsrsCard, fromFsrsLog } from '../fsrs/mappers';
import { useDueCards } from '../hooks/useDueCards';
import type { CardDoc } from '../types';
import { RatingButtons } from './RatingButtons';
import { btnPrimary, btnSecondary } from './ui';

function formatInterval(ms: number): string {
  if (ms < 60_000) return `${Math.max(1, Math.round(ms / 1000))}s`;
  const minutes = Math.round(ms / 60_000);
  if (minutes < 60) return `${minutes}m`;
  const hours = Math.round(ms / 3_600_000);
  if (hours < 24) return `${hours}h`;
  const days = Math.round(ms / 86_400_000);
  if (days < 30) return `${days}d`;
  const months = Math.round(days / 30);
  if (months < 12) return `${months}mo`;
  return `${(days / 365).toFixed(1)}y`;
}

const STATE_LABELS = ['New', 'Learning', 'Review', 'Relearning'];

const STATE_STYLES: Record<number, string> = {
  0: 'border-zinc-300 text-zinc-500 dark:border-zinc-600 dark:text-zinc-400',
  1: 'border-amber-400/60 text-amber-500',
  2: 'border-emerald-400/60 text-emerald-500',
  3: 'border-red-400/60 text-red-500'
};

export function StudySession() {
  const { deckId } = useParams();
  const due = useDueCards(deckId);

  const [seenIds, setSeenIds] = useState<string[]>([]);
  const [showBack, setShowBack] = useState(false);
  const [busy, setBusy] = useState(false);

  const queue = useMemo(
    () => due.filter((c) => !seenIds.includes(c.id)),
    [due, seenIds]
  );

  const current = queue[0];

  const previews = useMemo(() => {
    if (!current) return {};
    const card = toFsrsCard(current);
    const now = new Date();
    const out: Record<number, string> = {};
    for (const r of [
      Rating.Again,
      Rating.Hard,
      Rating.Good,
      Rating.Easy
    ] as Grade[]) {
      try {
        const res = scheduler.next(card, now, r);
        out[r] = formatInterval(res.card.due.getTime() - now.getTime());
      } catch {
        out[r] = '';
      }
    }
    return out;
  }, [current]);

  const total = due.length || 1;
  const remaining = queue.length;
  const progress = Math.round(((total - remaining) / total) * 100);

  async function rate(rating: Grade) {
    if (!current || busy) return;
    setBusy(true);
    const cardDoc: CardDoc = current;
    const fsrsCard = toFsrsCard(cardDoc);
    const now = new Date();
    const result = scheduler.next(fsrsCard, now, rating);
    const updated = fromFsrsCard(result.card, {
      id: cardDoc.id,
      deckId: cardDoc.deckId,
      front: cardDoc.front,
      back: cardDoc.back,
      createdAt: cardDoc.createdAt
    });
    const db = await getDb();
    const rxDoc = await db.cards.findOne(cardDoc.id).exec();
    if (rxDoc) {
      await rxDoc.patch({
        due: updated.due,
        stability: updated.stability,
        difficulty: updated.difficulty,
        elapsed_days: updated.elapsed_days,
        scheduled_days: updated.scheduled_days,
        learning_steps: updated.learning_steps,
        reps: updated.reps,
        lapses: updated.lapses,
        state: updated.state,
        last_review: updated.last_review,
        updatedAt: updated.updatedAt
      });
    }
    await db.reviewlogs.insert(
      fromFsrsLog(result.log, nanoid(), cardDoc.id)
    );

    setSeenIds((prev) => [...prev, cardDoc.id]);
    setShowBack(false);
    setBusy(false);
  }

  if (!deckId) return <p>Missing deck.</p>;

  if (!current) {
    return (
      <div className="space-y-8">
        <div className="rounded-2xl border border-emerald-200 bg-emerald-50 px-8 py-12 text-center dark:border-emerald-500/20 dark:bg-emerald-500/10">
          <div className="mx-auto mb-4 flex h-12 w-12 items-center justify-center rounded-full bg-emerald-500 text-white">
            <Check className="h-6 w-6" strokeWidth={2.5} aria-hidden="true" />
          </div>
          <h2 className="text-lg font-bold">All done!</h2>
          <p className="mt-1 text-sm text-zinc-600 dark:text-zinc-300">
            No more due cards in this deck.
          </p>
        </div>
        <div className="flex justify-center gap-2">
          <Link to={`/deck/${deckId}`} className={btnSecondary}>
            Back to deck
          </Link>
          <Link to="/" className={btnSecondary}>
            Decks
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between gap-4">
        <span className="text-sm text-zinc-500 dark:text-zinc-400">
          {remaining} card{remaining === 1 ? '' : 's'} remaining
        </span>
        <Link
          to={`/deck/${deckId}`}
          className="text-sm text-zinc-500 transition hover:text-indigo-600 dark:text-zinc-400 dark:hover:text-indigo-400"
        >
          Exit
        </Link>
      </div>

      <div className="h-1.5 w-full overflow-hidden rounded-full bg-zinc-200 dark:bg-zinc-800">
        <div
          className="h-full rounded-full bg-indigo-600 transition-all duration-300"
          style={{ width: `${progress}%` }}
        />
      </div>

      <div className="flex min-h-[280px] flex-col gap-5 rounded-2xl border border-zinc-200 bg-white p-8 shadow-sm dark:border-zinc-800 dark:bg-zinc-900">
        <span
          className={`self-start rounded-full border px-2.5 py-0.5 text-[0.7rem] font-medium uppercase tracking-wider ${STATE_STYLES[current.state] ?? STATE_STYLES[0]}`}
        >
          {STATE_LABELS[current.state] ?? current.state}
        </span>
        <div className="text-xl font-semibold leading-relaxed whitespace-pre-wrap">
          {current.front}
        </div>
        {showBack ? (
          <>
            <hr className="border-zinc-200 dark:border-zinc-800" />
            <div className="text-lg leading-relaxed whitespace-pre-wrap text-zinc-700 dark:text-zinc-300">
              {current.back}
            </div>
          </>
        ) : null}
      </div>

      <div className="flex justify-center">
        {showBack ? (
          <RatingButtons
            previews={previews}
            onRate={rate}
            disabled={busy}
          />
        ) : (
          <button
            type="button"
            className={`${btnPrimary} px-6 py-3`}
            onClick={() => setShowBack(true)}
            disabled={busy}
          >
            Show answer
          </button>
        )}
      </div>
    </div>
  );
}
