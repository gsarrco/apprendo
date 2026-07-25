import { useSearchParams } from 'react-router-dom';
import { Loader2 } from 'lucide-react';
import { StudySessionCore } from '../components/StudySessionCore';
import { useStudyTag } from '../hooks/useStudyTags';

export default function MultiDeckStudySession() {
  const [params] = useSearchParams();
  const deckId = params.get('deck') ?? undefined;
  const studyTagId = params.get('studyTag') ?? undefined;
  const { studyTag, loaded } = useStudyTag(deckId ? undefined : studyTagId);

  if (deckId) {
    return (
      <StudySessionCore
        source={{ deckId }}
        exitTo="/"
        doneLinks={[
          { label: 'Back to deck', to: `/deck/${deckId}` },
          { label: 'Decks', to: '/' }
        ]}
      />
    );
  }

  if (!studyTagId) return <p>No decks selected.</p>;

  if (!loaded) {
    return (
      <div className="flex min-h-[280px] items-center justify-center">
        <Loader2
          className="h-6 w-6 animate-spin text-zinc-400"
          aria-hidden="true"
        />
      </div>
    );
  }

  if (!studyTag) return <p>Study tag not found.</p>;
  if (studyTag.deckIds.length === 0)
    return <p>This study tag has no decks yet.</p>;

  return (
    <StudySessionCore
      source={{ studyTag }}
      exitTo="/"
      doneLinks={[{ label: 'Decks', to: '/' }]}
    />
  );
}
