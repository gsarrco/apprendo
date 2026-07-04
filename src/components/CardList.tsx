import { Link, useParams } from 'react-router-dom';
import { nanoid } from 'nanoid';
import { useState } from 'react';
import { getDb } from '../db';
import { createEmptyCard } from '../fsrs/scheduler';
import { fromFsrsCard } from '../fsrs/mappers';
import type { CardDoc } from '../types';
import { useCards } from '../hooks/useCards';

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
    <form className="card-form" onSubmit={submit}>
      <textarea
        placeholder="Front"
        value={front}
        onChange={(e) => setFront(e.target.value)}
        rows={2}
      />
      <textarea
        placeholder="Back"
        value={back}
        onChange={(e) => setBack(e.target.value)}
        rows={2}
      />
      <button type="submit">Add card</button>
    </form>
  );
}

const STATE_LABELS = ['New', 'Learning', 'Review', 'Relearning'];

export function CardList({ deckId }: { deckId: string }) {
  const cards = useCards(deckId);
  return (
    <div className="card-section">
      <h3>Cards ({cards.length})</h3>
      <CardForm deckId={deckId} />
      {cards.length === 0 ? (
        <p className="empty">No cards yet. Add one above.</p>
      ) : (
        <ul className="card-list">
          {cards.map((card) => (
            <li key={card.id} className="card-row">
              <div className="card-row-main">
                <div className="card-front">{card.front}</div>
                <div className="card-back">{card.back}</div>
              </div>
              <div className="card-row-meta">
                <span className={`badge state-${card.state}`}>
                  {STATE_LABELS[card.state] ?? card.state}
                </span>
                <span className="due">
                  due {new Date(card.due).toLocaleString()}
                </span>
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
  if (!deckId) return <p>Missing deck.</p>;
  return (
    <div className="deck-detail">
      <nav className="breadcrumb">
        <Link to="/">Decks</Link> / <span>{deckId.slice(0, 8)}</span>
      </nav>
      <div className="deck-actions">
        <Link to={`/deck/${deckId}/study`} className="btn btn-primary">
          Study now
        </Link>
      </div>
      <CardList deckId={deckId} />
    </div>
  );
}
