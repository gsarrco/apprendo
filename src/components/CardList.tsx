import { Link, useParams } from 'react-router-dom';
import { nanoid } from 'nanoid';
import { useState } from 'react';
import { getDb } from '../db';
import { createEmptyCard } from '../fsrs/scheduler';
import { fromFsrsCard } from '../fsrs/mappers';
import type { CardDoc } from '../types';
import { fetchImages, type WikiImage } from '../wiki';
import { useCards } from '../hooks/useCards';
import { useDeck } from '../hooks/useDecks';
import { btnPrimary, btnGhost, inputClass } from './ui';
import { Check } from 'lucide-react';
import { useToast } from '../hooks/useToast';
import { DeleteButton } from './DeleteButton';

const STATE_LABELS = ['New', 'Learning', 'Review', 'Relearning'];

const STATE_STYLES: Record<number, string> = {
  0: 'border-zinc-300 text-zinc-500 dark:border-zinc-600 dark:text-zinc-400',
  1: 'border-amber-400/60 text-amber-500',
  2: 'border-emerald-400/60 text-emerald-500',
  3: 'border-red-400/60 text-red-500'
};

interface Thumb {
  url: string;
  attribution: string;
}

function stripHtml(s: string): string {
  return new DOMParser()
    .parseFromString(s, 'text/html')
    .body.textContent?.trim() ?? '';
}

function toThumb(img: WikiImage): Thumb {
  const artist = img.artist ? stripHtml(img.artist) : '';
  const license = img.license ? stripHtml(img.license) : '';
  const credit = img.credit ? stripHtml(img.credit) : '';
  let attribution: string;
  if (artist && license) attribution = `${artist} — ${license}`;
  else if (artist) attribution = artist;
  else if (credit) attribution = credit;
  else attribution = `Wikipedia: ${img.title}`;
  return { url: img.url, attribution };
}

export function CardForm({ deckId }: { deckId: string }) {
  const [word, setWord] = useState('');
  const [front, setFront] = useState('');
  const [back, setBack] = useState('');
  const [phase, setPhase] = useState<'word' | 'form'>('word');
  const [loading, setLoading] = useState(false);
  const [thumbs, setThumbs] = useState<Thumb[]>([]);
  const [selected, setSelected] = useState<number | null>(null);
  const { notify } = useToast();

  async function populate(e: React.FormEvent) {
    e.preventDefault();
    const w = word.trim();
    if (!w) return;
    setBack(w);
    setLoading(true);
    setThumbs([]);
    setSelected(null);
    try {
      const images = await fetchImages(w, 3);
      setThumbs(images.map(toThumb));
    } catch (err) {
      setThumbs([]);
      notify(
        `Could not load images: ${err instanceof Error ? err.message : String(err)}`,
        'info'
      );
    } finally {
      setLoading(false);
      setPhase('form');
    }
  }

  function changeWord() {
    setPhase('word');
    setThumbs([]);
    setSelected(null);
    setFront('');
    setBack('');
  }

  async function submit(e: React.FormEvent) {
    e.preventDefault();
    const f = front.trim();
    const b = back.trim();
    if (!b) {
      notify('Back is required', 'info');
      return;
    }
    const thumb = selected !== null ? thumbs[selected] : null;
    const db = await getDb();
    const empty = createEmptyCard(new Date());
    const doc: CardDoc = fromFsrsCard(empty, {
      id: nanoid(),
      deckId,
      front: f,
      back: b,
      image_url: thumb?.url ?? null,
      image_attribution: thumb?.attribution ?? null,
      createdAt: Date.now()
    });
    try {
      await db.cards.insert(doc);
      setFront('');
      setBack('');
      setWord('');
      setThumbs([]);
      setSelected(null);
      setPhase('word');
    } catch (err) {
      notify(`Could not save card: ${err instanceof Error ? err.message : String(err)}`);
    }
  }

  if (phase === 'word') {
    return (
      <form className="grid gap-2" onSubmit={populate}>
        <input
          placeholder="Word to memorise"
          value={word}
          onChange={(e) => setWord(e.target.value)}
          className={inputClass}
          autoFocus
        />
        <button type="submit" className={`${btnPrimary} justify-self-start`}>
          Populate
        </button>
      </form>
    );
  }

  return (
    <form className="grid gap-2" onSubmit={submit}>
      {loading ? (
        <div className="h-1 w-full overflow-hidden rounded-full bg-zinc-200 dark:bg-zinc-800">
          <div className="h-full w-1/3 animate-pulse rounded-full bg-indigo-500" />
        </div>
      ) : null}
      {!loading && thumbs.length > 0 ? (
        <div className="flex gap-2">
          {thumbs.map((t, i) => (
            <button
              key={t.url}
              type="button"
              onClick={() => setSelected(selected === i ? null : i)}
              className={`relative aspect-square flex-1 overflow-hidden rounded-xl border-2 transition ${
                selected === i
                  ? 'border-indigo-500 ring-2 ring-indigo-500/30'
                  : 'border-zinc-200 hover:border-zinc-300 dark:border-zinc-700 dark:hover:border-zinc-600'
              }`}
            >
              <img
                src={t.url}
                alt=""
                className="h-full w-full object-cover"
              />
              {selected === i ? (
                <span className="absolute right-1 top-1 flex h-5 w-5 items-center justify-center rounded-full bg-indigo-600 text-white">
                  <Check className="h-3.5 w-3.5" strokeWidth={3} aria-hidden="true" />
                </span>
              ) : null}
            </button>
          ))}
        </div>
      ) : null}
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
      <div className="flex items-center gap-2 justify-self-start">
        <button type="submit" className={btnPrimary}>
          Add card
        </button>
        <button type="button" onClick={changeWord} className={btnGhost}>
          Change word
        </button>
      </div>
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
                {card.image_url ? (
                  <img
                    src={card.image_url}
                    alt=""
                    className="h-12 w-12 shrink-0 rounded-lg object-cover"
                  />
                ) : null}
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
                <DeleteButton
                  label="Delete card"
                  onDelete={async () => {
                    const db = await getDb();
                    const doc = await db.cards
                      .findOne({ selector: { id: card.id } })
                      .exec();
                    await doc?.remove();
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
