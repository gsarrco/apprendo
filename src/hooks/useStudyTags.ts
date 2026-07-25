import { useEffect, useState } from 'react';
import type { Subscription } from 'rxjs';
import { getDb } from '../db';
import type { StudyTag } from '../types';

export function useStudyTags(): StudyTag[] {
  const [studyTags, setStudyTags] = useState<StudyTag[]>([]);
  useEffect(() => {
    let sub: Subscription | undefined;
    let active = true;
    getDb().then((db) => {
      if (!active) return;
      sub = db.studytags.find().$.subscribe((docs) => {
        setStudyTags(docs.map((d) => d.toJSON(true) as unknown as StudyTag));
      });
    });
    return () => {
      active = false;
      sub?.unsubscribe();
    };
  }, []);
  return studyTags;
}

export function useStudyTag(studyTagId: string | undefined): {
  studyTag: StudyTag | undefined;
  loaded: boolean;
} {
  const [studyTag, setStudyTag] = useState<StudyTag | undefined>(undefined);
  const [loaded, setLoaded] = useState(false);
  useEffect(() => {
    if (!studyTagId) {
      setStudyTag(undefined);
      setLoaded(true);
      return;
    }
    let sub: Subscription | undefined;
    let active = true;
    setLoaded(false);
    getDb().then((db) => {
      if (!active) return;
      sub = db.studytags
        .findOne({
          selector: { id: studyTagId }
        })
        .$.subscribe((doc) => {
          setStudyTag(doc ? (doc.toJSON(true) as unknown as StudyTag) : undefined);
          setLoaded(true);
        });
    });
    return () => {
      active = false;
      sub?.unsubscribe();
    };
  }, [studyTagId]);
  return { studyTag, loaded };
}
