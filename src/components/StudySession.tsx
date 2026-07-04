import { useMemo, useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { nanoid } from 'nanoid';
import { Rating, type Grade } from 'ts-fsrs';
import { getDb } from '../db';
import { scheduler } from '../fsrs/scheduler';
import { toFsrsCard, fromFsrsCard, fromFsrsLog } from '../fsrs/mappers';
import { useDueCards } from '../hooks/useDueCards';
import type { CardDoc } from '../types';
import { RatingButtons } from './RatingButtons';

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

export function StudySession() {
  const { deckId } = useParams();
  const due = useDueCards(deckId);

  // Track moved-off card ids so reactive updates don't snap the next card
  // from underneath us mid-rating.
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
    for (const r of [Rating.Again, Rating.Hard, Rating.Good, Rating.Easy] as Grade[]) {
      try {
        const res = scheduler.next(card, now, r);
        out[r] = formatInterval(
          res.card.due.getTime() - now.getTime()
        );
      } catch {
        out[r] = '';
      }
    }
    return out;
  }, [current]);

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
      <div className="study study-done">
        <div className="study-inner">
          <h2>All done!</h2>
          <p>No more due cards in this deck.</p>
        </div>
        <div className="study-nav">
          <Link to={`/deck/${deckId}`} className="btn">
            Back to deck
          </Link>
          <Link to="/" className="btn">
            Decks
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="study">
      <div className="study-progress">
        <span>
          {queue.length} card{queue.length === 1 ? '' : 's'} remaining
        </span>
        <Link to={`/deck/${deckId}`} className="btn btn-link">
          Exit
        </Link>
      </div>

      <div className="study-card">
        <div className="study-state">
          {STATE_LABELS[current.state] ?? current.state}
        </div>
        <div className="study-front">{current.front}</div>
        {showBack ? (
          <>
            <hr className="divider" />
            <div className="study-back">{current.back}</div>
          </>
        ) : null}
      </div>

      <div className="study-controls">
        {showBack ? (
          <RatingButtons
            previews={previews}
            onRate={rate}
            disabled={busy}
          />
        ) : (
          <button
            type="button"
            className="btn btn-primary btn-reveal"
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
