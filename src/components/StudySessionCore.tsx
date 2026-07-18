import { useEffect, useMemo, useRef, useState } from 'react';
import { Link } from 'react-router-dom';
import { Check, Clock, Loader2 } from 'lucide-react';
import { nanoid } from 'nanoid';
import { Rating, State, type Grade } from 'ts-fsrs';
import { getDb } from '../db';
import { scheduler } from '../fsrs/scheduler';
import { toFsrsCard, fromFsrsCard, fromFsrsLog } from '../fsrs/mappers';
import { formatInterval } from '../lib/format';
import { useDueCards } from '../hooks/useDueCards';
import { useDecks } from '../hooks/useDecks';
import type { CardDoc, Deck } from '../types';
import { RatingButtons } from './RatingButtons';
import { CardStateBadge } from './CardStateBadge';
import {
  AttachmentAttributions,
  AttachmentAudioButtons,
  AttachmentImageGrid
} from './Attachments';
import { btnPrimary, btnSecondary } from './ui';
import { useToast } from '../hooks/useToast';

const LEARN_AHEAD_MS = 30_000;

type SessionEntry = { card: CardDoc; due: number };

export function StudySessionCore({
  deckIds,
  exitTo,
  doneLinks
}: {
  deckIds: string[];
  exitTo: string;
  doneLinks: { label: string; to: string }[];
}) {
  const { cards, loaded } = useDueCards(deckIds);
  const decks = useDecks();
  const deckById = useMemo(
    () => new Map<string, Deck>(decks.map((d) => [d.id, d])),
    [decks]
  );

  const [session, setSession] = useState<SessionEntry[]>([]);
  const [initialCount, setInitialCount] = useState(0);
  const seededRef = useRef(false);
  const [showBack, setShowBack] = useState(false);
  const [busy, setBusy] = useState(false);
  const [playIndex, setPlayIndex] = useState(0);
  const [nowTick, setNowTick] = useState(() => Date.now());
  const { notify } = useToast();
  const audioRef = useRef<HTMLAudioElement | null>(null);

  useEffect(() => {
    if (seededRef.current || !loaded) return;
    seededRef.current = true;
    const entries = cards.map((c) => ({ card: c, due: Date.parse(c.due) }));
    setSession(entries);
    setInitialCount(entries.length);
  }, [loaded, cards]);

  useEffect(() => {
    if (session.length === 0) return;
    const id = setInterval(() => setNowTick(Date.now()), 1000);
    return () => clearInterval(id);
  }, [session.length]);

  const ready = useMemo(
    () =>
      session
        .filter((e) => e.due <= nowTick + LEARN_AHEAD_MS)
        .sort((a, b) => a.due - b.due),
    [session, nowTick]
  );
  const pending = useMemo(
    () =>
      session
        .filter((e) => e.due > nowTick + LEARN_AHEAD_MS)
        .sort((a, b) => a.due - b.due),
    [session, nowTick]
  );

  const current = ready[0]?.card;
  const nextDueAt = pending[0]?.due;

  useEffect(() => {
    const audios = showBack
      ? current?.back_attachments.filter((a) => a.type === 'audio') ?? []
      : current?.front_attachments.filter((a) => a.type === 'audio') ?? [];
    if (audios.length === 0) return;
    if (playIndex >= audios.length) return;
    if (audioRef.current) {
      audioRef.current.pause();
      audioRef.current = null;
    }
    const audio = new Audio(audios[playIndex].url);
    audioRef.current = audio;
    audio.addEventListener('ended', () => {
      if (playIndex + 1 < audios.length) setPlayIndex(playIndex + 1);
    });
    void audio.play().catch(() => {});
    return () => {
      audio.pause();
      if (audioRef.current === audio) audioRef.current = null;
    };
  }, [showBack, current?.id, current?.front_attachments, current?.back_attachments, playIndex]);

  useEffect(() => {
    setPlayIndex(0);
  }, [current?.id, showBack]);

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

  const total = initialCount || 1;
  const remaining = session.length;
  const graduated = initialCount - remaining;
  const progress = Math.round((graduated / total) * 100);

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
      front_attachments: cardDoc.front_attachments,
      back_attachments: cardDoc.back_attachments,
      createdAt: cardDoc.createdAt
    });
    try {
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
      setSession((prev) => {
        const idx = prev.findIndex((e) => e.card.id === cardDoc.id);
        if (idx === -1) return prev;
        if (updated.state === State.Review) {
          return [...prev.slice(0, idx), ...prev.slice(idx + 1)];
        }
        const next = [...prev];
        next[idx] = { card: updated, due: Date.parse(updated.due) };
        return next;
      });
      setShowBack(false);
      setNowTick(Date.now());
    } catch (err) {
      notify(`Could not save review: ${err instanceof Error ? err.message : String(err)}`);
    } finally {
      setBusy(false);
    }
  }

  if (!loaded && !seededRef.current) {
    return (
      <div className="flex min-h-[280px] items-center justify-center">
        <Loader2
          className="h-6 w-6 animate-spin text-zinc-400"
          aria-hidden="true"
        />
      </div>
    );
  }

  if (!current && pending.length > 0) {
    const waitMs = Math.max(0, (nextDueAt ?? nowTick) - nowTick);
    return (
      <div className="space-y-8">
        <div className="rounded-2xl border border-amber-200 bg-amber-50 px-8 py-12 text-center dark:border-amber-500/20 dark:bg-amber-500/10">
          <div className="mx-auto mb-4 flex h-12 w-12 items-center justify-center rounded-full bg-amber-500 text-white">
            <Clock className="h-6 w-6" strokeWidth={2.5} aria-hidden="true" />
          </div>
          <h2 className="text-lg font-bold">Come back in {formatInterval(waitMs)}</h2>
          <p className="mt-1 text-sm text-zinc-600 dark:text-zinc-300">
            {pending.length} card{pending.length === 1 ? '' : 's'} still learning.
          </p>
        </div>
        <div className="flex justify-center gap-2">
          {doneLinks.map((l) => (
            <Link key={l.to} to={l.to} className={btnSecondary}>
              {l.label}
            </Link>
          ))}
        </div>
      </div>
    );
  }

  if (!current) {
    return (
      <div className="space-y-8">
        <div className="rounded-2xl border border-emerald-200 bg-emerald-50 px-8 py-12 text-center dark:border-emerald-500/20 dark:bg-emerald-500/10">
          <div className="mx-auto mb-4 flex h-12 w-12 items-center justify-center rounded-full bg-emerald-500 text-white">
            <Check className="h-6 w-6" strokeWidth={2.5} aria-hidden="true" />
          </div>
          <h2 className="text-lg font-bold">All done!</h2>
          <p className="mt-1 text-sm text-zinc-600 dark:text-zinc-300">
            No more due cards.
          </p>
        </div>
        <div className="flex justify-center gap-2">
          {doneLinks.map((l) => (
            <Link key={l.to} to={l.to} className={btnSecondary}>
              {l.label}
            </Link>
          ))}
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
          to={exitTo}
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
        <div className="flex flex-wrap gap-2 self-start">
          <CardStateBadge state={current.state} size="md" />
          {(() => {
            const deckName = deckById.get(current.deckId)?.name;
            if (!deckName) return null;
            return (
              <span className="rounded-full border border-indigo-400/60 px-2.5 py-0.5 text-[0.7rem] font-medium uppercase tracking-wider text-indigo-500">
                <strong>{deckName}</strong>
              </span>
            );
          })()}
        </div>
        <AttachmentImageGrid attachments={current.front_attachments} />
        <div className="flex items-start gap-2">
          <div className="text-xl font-semibold leading-relaxed whitespace-pre-wrap">
            {current.front}
          </div>
          <AttachmentAudioButtons
            attachments={current.front_attachments}
            size="md"
            onPlay={(i) => {
              if (showBack) return;
              setPlayIndex(i);
            }}
          />
        </div>
        <AttachmentAttributions attachments={current.front_attachments} />
        {showBack ? (
          <>
            <hr className="border-zinc-200 dark:border-zinc-800" />
            <AttachmentImageGrid attachments={current.back_attachments} />
            <div className="flex items-start gap-2">
              <div className="text-lg leading-relaxed whitespace-pre-wrap text-zinc-700 dark:text-zinc-300">
                {current.back}
              </div>
              <AttachmentAudioButtons
                attachments={current.back_attachments}
                size="md"
                onPlay={setPlayIndex}
              />
            </div>
            <AttachmentAttributions attachments={current.back_attachments} />
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
