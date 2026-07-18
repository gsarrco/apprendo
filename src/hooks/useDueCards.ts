import { useEffect, useState } from 'react';
import type { Subscription } from 'rxjs';
import { getDb } from '../db';
import type { CardDoc } from '../types';

export function useDueCards(deckId: string | undefined): {
  cards: CardDoc[];
  loaded: boolean;
} {
  const [cards, setCards] = useState<CardDoc[]>([]);
  const [loaded, setLoaded] = useState(false);
  useEffect(() => {
    if (!deckId) {
      setCards([]);
      setLoaded(false);
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
            setLoaded(true);
          });
      });
    run();
    return () => {
      active = false;
      sub?.unsubscribe();
    };
  }, [deckId]);
  return { cards, loaded };
}
