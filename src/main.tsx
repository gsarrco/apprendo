import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import './styles.css';
import App from './App.tsx';
import { getDb } from './db';

if (import.meta.env.DEV) {
  getDb()
    .then(async (db) => {
      const [decks, cards, reviewlogs] = await Promise.all([
        db.decks.find().exec(),
        db.cards.find().exec(),
        db.reviewlogs.find().exec()
      ]);
      console.log(
        '%c[DB] decks',
        'color:#6366f1;font-weight:bold',
        JSON.stringify(decks.map((d) => d.toMutableJSON()), null, 2)
      );
      console.log(
        '%c[DB] cards',
        'color:#6366f1;font-weight:bold',
        JSON.stringify(cards.map((c) => c.toMutableJSON()), null, 2)
      );
      console.log(
        '%c[DB] reviewlogs',
        'color:#6366f1;font-weight:bold',
        JSON.stringify(reviewlogs.map((r) => r.toMutableJSON()), null, 2)
      );
    })
    .catch((err) => console.error('[DB] failed to dump', err));
}

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>
);
