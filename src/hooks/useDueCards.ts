import { useEffect, useState } from 'react';
import type { Subscription } from 'rxjs';
import { getDb } from '../db';
import type { CardDoc } from '../types';

export function useDueCards(deckIds: string[]): {
  cards: CardDoc[];
  loaded: boolean;
} {
  const [cards, setCards] = useState<CardDoc[]>([]);
  const [loaded, setLoaded] = useState(false);
  useEffect(() => {
    if (deckIds.length === 0) {
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
            selector: { deckId: { $in: deckIds }, due: { $lte: now } },
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
  }, [deckIds]);
  return { cards, loaded };
}
