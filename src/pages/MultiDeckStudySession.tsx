import { useMemo } from 'react';
import { useSearchParams } from 'react-router-dom';
import { StudySessionCore } from '../components/StudySessionCore';

export default function MultiDeckStudySession() {
  const [params] = useSearchParams();
  const deckIds = useMemo(
    () => params.get('decks')?.split(',').filter(Boolean) ?? [],
    [params]
  );
  if (deckIds.length === 0) return <p>No decks selected.</p>;
  const singleDeckId = deckIds.length === 1 ? deckIds[0] : undefined;
  const doneLinks =
    singleDeckId !== undefined
      ? [
          { label: 'Back to deck', to: `/deck/${singleDeckId}` },
          { label: 'Decks', to: '/' }
        ]
      : [{ label: 'Decks', to: '/' }];
  return <StudySessionCore deckIds={deckIds} exitTo="/" doneLinks={doneLinks} />;
}
