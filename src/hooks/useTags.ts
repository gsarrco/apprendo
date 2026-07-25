import { useEffect, useState } from 'react';
import type { Subscription } from 'rxjs';
import { getDb } from '../db';
import type { Tag } from '../types';

export function useTags(): Tag[] {
  const [tags, setTags] = useState<Tag[]>([]);
  useEffect(() => {
    let sub: Subscription | undefined;
    let active = true;
    getDb().then((db) => {
      if (!active) return;
      sub = db.tags.find().$.subscribe((docs) => {
        setTags(docs.map((d) => d.toJSON(true) as unknown as Tag));
      });
    });
    return () => {
      active = false;
      sub?.unsubscribe();
    };
  }, []);
  return tags;
}

export function useTag(tagId: string | undefined): {
  tag: Tag | undefined;
  loaded: boolean;
} {
  const [tag, setTag] = useState<Tag | undefined>(undefined);
  const [loaded, setLoaded] = useState(false);
  useEffect(() => {
    if (!tagId) {
      setTag(undefined);
      setLoaded(true);
      return;
    }
    let sub: Subscription | undefined;
    let active = true;
    setLoaded(false);
    getDb().then((db) => {
      if (!active) return;
      sub = db.tags
        .findOne({
          selector: { id: tagId }
        })
        .$.subscribe((doc) => {
          setTag(doc ? (doc.toJSON(true) as unknown as Tag) : undefined);
          setLoaded(true);
        });
    });
    return () => {
      active = false;
      sub?.unsubscribe();
    };
  }, [tagId]);
  return { tag, loaded };
}
