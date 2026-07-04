import { useEffect, useState } from 'react';
import type { Subscription } from 'rxjs';
import { getDb } from '../db';
import type { Deck } from '../types';

export function useDecks(): Deck[] {
  const [decks, setDecks] = useState<Deck[]>([]);
  useEffect(() => {
    let sub: Subscription | undefined;
    let active = true;
    getDb().then((db) => {
      if (!active) return;
      sub = db.decks.find().$.subscribe((docs) => {
        setDecks(docs.map((d) => d.toJSON(true) as unknown as Deck));
      });
    });
    return () => {
      active = false;
      sub?.unsubscribe();
    };
  }, []);
  return decks;
}

export function useDeck(deckId: string): Deck | undefined {
  const [deck, setDeck] = useState<Deck | undefined>(undefined);
  useEffect(() => {
    let sub: Subscription | undefined;
    let active = true;
    getDb().then((db) => {
      if (!active) return;
      sub = db.decks
        .findOne({
          selector: { id: deckId }
        })
        .$.subscribe((doc) => {
          setDeck(doc ? (doc.toJSON(true) as unknown as Deck) : undefined);
        });
    });
    return () => {
      active = false;
      sub?.unsubscribe();
    };
  }, [deckId]);
  return deck;
}
