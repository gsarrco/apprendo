import { useState } from 'react';
import { nanoid } from 'nanoid';
import { Link } from 'react-router-dom';
import { getDb } from '../db';
import type { Deck } from '../types';

export function DeckForm() {
  const [name, setName] = useState('');

  async function submit(e: React.FormEvent) {
    e.preventDefault();
    const trimmed = name.trim();
    if (!trimmed) return;
    const db = await getDb();
    const deck: Deck = {
      id: nanoid(),
      name: trimmed,
      createdAt: Date.now()
    };
    await db.decks.insert(deck);
    setName('');
  }

  return (
    <form className="deck-form" onSubmit={submit}>
      <input
        type="text"
        placeholder="New deck name"
        value={name}
        onChange={(e) => setName(e.target.value)}
        autoFocus
      />
      <button type="submit">Add deck</button>
    </form>
  );
}

export function DeckList({ decks }: { decks: Deck[] }) {
  if (decks.length === 0) {
    return <p className="empty">No decks yet. Create one above.</p>;
  }
  return (
    <ul className="deck-list">
      {decks.map((deck) => (
        <li key={deck.id} className="deck-item">
          <Link to={`/deck/${deck.id}`} className="deck-link">
            <span className="deck-name">{deck.name}</span>
            <span className="deck-meta">
              {new Date(deck.createdAt).toLocaleDateString()}
            </span>
          </Link>
        </li>
      ))}
    </ul>
  );
}
