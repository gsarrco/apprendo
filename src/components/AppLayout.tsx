import { Link, Outlet } from 'react-router-dom';
import { useDecks } from '../hooks/useDecks';
import { DeckForm, DeckList } from './DeckList';

export function DeckIndex() {
  const decks = useDecks();
  return (
    <div className="deck-index">
      <h2>Decks</h2>
      <DeckForm />
      <DeckList decks={decks} />
    </div>
  );
}

export function Layout() {
  return (
    <div className="app">
      <header className="app-header">
        <Link to="/" className="app-title">
          Apprendo
        </Link>
      </header>
      <main className="app-main">
        <Outlet />
      </main>
    </div>
  );
}
