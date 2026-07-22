import { useState } from 'react';
import { Check, Volume2 } from 'lucide-react';
import {
  searchCommonsImages,
  searchCommonsAudio,
  type CommonsMedium
} from '../integrations/commonsApi';
import { toThumb, captionFromTitle, playAudio } from '../lib/commonsThumb';
import type { AttachmentType, CardAttachment, Language } from '../types';
import { AttachmentTray } from './AttachmentTray';
import { btnPrimary, inputClass } from './ui';
import { useToast } from '../hooks/useToast';
import { LANGUAGES, LANG_BY_QID } from '../integrations/languages';

interface MediaSearchProps {
  type: AttachmentType;
  defaultLanguage: Language | null;
  selected: CardAttachment[];
  onChange: (next: CardAttachment[]) => void;
}

export function MediaSearch({
  type,
  defaultLanguage,
  selected,
  onChange
}: MediaSearchProps) {
  const [language, setLanguage] = useState<Language | null>(defaultLanguage);
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
          ? await searchCommonsImages(q, 10)
          : language
            ? await searchCommonsAudio(q, language, 10)
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
    if (type === 'audio') playAudio(m.url);
    if (selected.some((s) => s.url === m.url)) {
      onChange(selected.filter((s) => s.url !== m.url));
      return;
    }
    onChange([
      ...selected,
      {
        type,
        url: m.url,
        caption: captionFromTitle(m.title, type),
        attribution: toThumb(m).attribution ?? null,
        language_qid: type === 'audio' ? language?.qid ?? null : null,
        blob_content: null,
        createdAt: Date.now()
      }
    ]);
  }

  return (
    <div className="grid gap-2">
      {type === 'audio' ? (
        <select
          value={language?.qid ?? ''}
          onChange={(e) =>
            setLanguage(e.target.value ? LANG_BY_QID[e.target.value] ?? null : null)
          }
          className={inputClass}
        >
          <option value="">No language</option>
          {LANGUAGES.map((l) => (
            <option key={l.qid} value={l.qid}>{l.label}</option>
          ))}
        </select>
      ) : null}
      <div className="flex gap-2">
        <input
          placeholder={`Search ${type}`}
          value={query}
          disabled={type === 'audio' && !language}
          onChange={(e) => setQuery(e.target.value)}
          onKeyDown={(e) => {
            if (e.key === 'Enter') {
              e.preventDefault();
              e.stopPropagation();
              runSearch();
            }
          }}
          className={`${inputClass} disabled:cursor-not-allowed disabled:opacity-50`}
        />
        <button
          type="button"
          onClick={runSearch}
          disabled={type === 'audio' && !language}
          className={`${btnPrimary} disabled:cursor-not-allowed disabled:opacity-50`}
        >
          Search
        </button>
      </div>
      {loading ? (
        <div className="h-1 w-full overflow-hidden rounded-full bg-zinc-200 dark:bg-zinc-800">
          <div className="h-full w-1/3 animate-pulse rounded-full bg-indigo-500" />
        </div>
      ) : null}
      {!loading && results.length > 0 ? (
        <div className="flex gap-2 overflow-x-auto">
          {results.map((t) => {
            const isSelected = selected.some((s) => s.url === t.url);
            return (
              <button
                key={t.url}
                type="button"
                onClick={() => toggle(t)}
                className={`relative flex aspect-square w-[calc((100%-1rem)/3)] shrink-0 flex-col items-center justify-center gap-1 overflow-hidden rounded-xl border-2 p-2 text-center transition ${
                  isSelected
                    ? 'border-indigo-500 ring-2 ring-indigo-500/30'
                    : 'border-zinc-200 hover:border-zinc-300 dark:border-zinc-700 dark:hover:border-zinc-600'
                }`}
              >
                {type === 'image' ? (
                  <img
                    src={t.url}
                    alt=""
                    loading="lazy"
                    className="absolute inset-0 h-full w-full object-cover"
                  />
                ) : (
                  <Volume2
                    className="h-5 w-5 text-zinc-500 dark:text-zinc-400"
                    aria-hidden="true"
                  />
                )}
                <span className="relative line-clamp-1 text-xs font-medium leading-tight text-zinc-700 dark:text-zinc-200">
                  {captionFromTitle(t.title, type)}
                </span>
                <span className="relative line-clamp-2 text-[0.6rem] leading-tight text-zinc-400 dark:text-zinc-500">
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
