import { useEffect, useState } from 'react';
import type { Subscription } from 'rxjs';
import { getDb } from '../db';
import type { CardDoc } from '../types';

export function useCards(deckId: string | undefined): CardDoc[] {
  const [cards, setCards] = useState<CardDoc[]>([]);
  useEffect(() => {
    if (!deckId) {
      setCards([]);
      return;
    }
    let sub: Subscription | undefined;
    let active = true;
    getDb().then((db) => {
      if (!active) return;
      sub = db.cards
        .find({
          selector: { deckId },
          sort: [{ createdAt: 'asc' }]
        })
        .$.subscribe((docs) => {
          setCards(docs.map((d) => d.toJSON(true) as unknown as CardDoc));
        });
    });
    return () => {
      active = false;
      sub?.unsubscribe();
    };
  }, [deckId]);
  return cards;
}
