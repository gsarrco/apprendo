import { useSearchParams } from 'react-router-dom';
import { Loader2 } from 'lucide-react';
import { StudySessionCore } from '../components/StudySessionCore';
import { useTag } from '../hooks/useTags';

export default function MultiDeckStudySession() {
  const [params] = useSearchParams();
  const deckId = params.get('deck') ?? undefined;
  const tagId = params.get('tag') ?? undefined;
  const { tag, loaded } = useTag(deckId ? undefined : tagId);

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

  if (!tagId) return <p>No decks selected.</p>;

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

  if (!tag) return <p>Tag not found.</p>;
  if (tag.deckIds.length === 0) return <p>This tag has no decks yet.</p>;

  return (
    <StudySessionCore
      source={{ tag }}
      exitTo="/"
      doneLinks={[{ label: 'Decks', to: '/' }]}
    />
  );
}
