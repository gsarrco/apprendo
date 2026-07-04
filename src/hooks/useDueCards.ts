import { useEffect, useState } from 'react';
import type { Subscription } from 'rxjs';
import { getDb } from '../db';
import type { CardDoc } from '../types';

export function useDueCards(deckId: string | undefined): CardDoc[] {
  const [cards, setCards] = useState<CardDoc[]>([]);
  useEffect(() => {
    if (!deckId) {
      setCards([]);
      return;
    }
    let sub: Subscription | undefined;
    let active = true;
    const now = new Date().toISOString();
    const run = () =>
      getDb().then((db) => {
        if (!active) return;
        sub = db.cards
          .find({
            selector: { deckId, due: { $lte: now } },
            sort: [{ due: 'asc' }]
          })
          .$.subscribe((docs) => {
            setCards(docs.map((d) => d.toJSON(true) as unknown as CardDoc));
          });
      });
    run();
    return () => {
      active = false;
      sub?.unsubscribe();
    };
  }, [deckId]);
  return cards;
}
