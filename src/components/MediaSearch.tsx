import { useState } from 'react';
import { Check, Volume2 } from 'lucide-react';
import {
  searchCommonsImages,
  searchCommonsAudio,
  type CommonsMedium
} from '../integrations/commonsApi';
import { toThumb } from '../lib/commonsThumb';
import type { AttachmentType, CardAttachment, Language } from '../types';
import { AttachmentTray } from './AttachmentTray';
import { btnPrimary, inputClass } from './ui';
import { useToast } from '../hooks/useToast';

interface MediaSearchProps {
  type: AttachmentType;
  language: Language | null;
  selected: CardAttachment[];
  onChange: (next: CardAttachment[]) => void;
}

export function MediaSearch({
  type,
  language,
  selected,
  onChange
}: MediaSearchProps) {
  const [query, setQuery] = useState('');
  const [loading, setLoading] = useState(false);
  const [results, setResults] = useState<CommonsMedium[]>([]);
  const { notify } = useToast();

  async function runSearch() {
    const q = query.trim();
    if (!q) return;
    setLoading(true);
    setResults([]);
    try {
      const media =
        type === 'image'
          ? await searchCommonsImages(q, 3)
          : language
            ? await searchCommonsAudio(q, language, 3)
            : [];
      setResults(media);
    } catch (err) {
      setResults([]);
      notify(
        `Could not load ${type}: ${err instanceof Error ? err.message : String(err)}`,
        'info'
      );
    } finally {
      setLoading(false);
    }
  }

  function toggle(m: CommonsMedium) {
    if (selected.some((s) => s.url === m.url)) {
      onChange(selected.filter((s) => s.url !== m.url));
      return;
    }
    onChange([
      ...selected,
      {
        type,
        url: m.url,
        attribution: toThumb(m).attribution ?? null,
        createdAt: Date.now()
      }
    ]);
  }

  return (
    <div className="grid gap-2">
      <div className="flex gap-2">
        <input
          placeholder={`Search ${type}`}
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          onKeyDown={(e) => {
            if (e.key === 'Enter') {
              e.preventDefault();
              e.stopPropagation();
              runSearch();
            }
          }}
          className={inputClass}
        />
        <button type="button" onClick={runSearch} className={btnPrimary}>
          Search
        </button>
      </div>
      {loading ? (
        <div className="h-1 w-full overflow-hidden rounded-full bg-zinc-200 dark:bg-zinc-800">
          <div className="h-full w-1/3 animate-pulse rounded-full bg-indigo-500" />
        </div>
      ) : null}
      {!loading && results.length > 0 ? (
        <div className="grid grid-cols-3 gap-2">
          {results.map((t) => {
            const isSelected = selected.some((s) => s.url === t.url);
            return (
              <button
                key={t.url}
                type="button"
                onClick={() => toggle(t)}
                className={`relative flex aspect-square flex-col items-center justify-center gap-1 overflow-hidden rounded-xl border-2 p-2 text-center transition ${
                  isSelected
                    ? 'border-indigo-500 ring-2 ring-indigo-500/30'
                    : 'border-zinc-200 hover:border-zinc-300 dark:border-zinc-700 dark:hover:border-zinc-600'
                }`}
              >
                {type === 'image' ? (
                  <img
                    src={t.url}
                    alt=""
                    className="absolute inset-0 h-full w-full object-cover"
                  />
                ) : (
                  <Volume2
                    className="h-5 w-5 text-zinc-500 dark:text-zinc-400"
                    aria-hidden="true"
                  />
                )}
                <span className="relative line-clamp-3 text-[0.65rem] leading-tight text-zinc-600 dark:text-zinc-300">
                  {toThumb(t).attribution}
                </span>
                {isSelected ? (
                  <span className="absolute right-1 top-1 flex h-5 w-5 items-center justify-center rounded-full bg-indigo-600 text-white">
                    <Check className="h-3.5 w-3.5" strokeWidth={3} aria-hidden="true" />
                  </span>
                ) : null}
              </button>
            );
          })}
        </div>
      ) : null}
      <AttachmentTray items={selected} onChange={onChange} />
    </div>
  );
}
