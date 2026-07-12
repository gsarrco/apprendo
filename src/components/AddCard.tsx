import { useState } from 'react';
import { nanoid } from 'nanoid';
import { getDb } from '../db';
import { createEmptyCard } from '../fsrs/scheduler';
import { fromFsrsCard } from '../fsrs/mappers';
import type { CardAttachment, CardDoc, Language } from '../types';
import { useToast } from '../hooks/useToast';
import { MediaSearch } from './MediaSearch';
import { btnPrimary, inputClass } from './ui';
import { TextAlignStart, AudioLines, Image as ImageIcon } from 'lucide-react';

type SideTab = 'text' | 'pronunciation' | 'image';

const TABS: { id: SideTab; label: string; Icon: typeof TextAlignStart }[] = [
  { id: 'text', label: 'Text', Icon: TextAlignStart },
  { id: 'pronunciation', label: 'Pronunciation', Icon: AudioLines },
  { id: 'image', label: 'Image', Icon: ImageIcon }
];

function CardSideEditor({
  heading,
  text,
  onTextChange,
  attachments,
  onAttachmentsChange,
  defaultLanguage
}: {
  heading: string;
  text: string;
  onTextChange: (v: string) => void;
  attachments: CardAttachment[];
  onAttachmentsChange: (next: CardAttachment[]) => void;
  defaultLanguage: Language | null;
}) {
  const [tab, setTab] = useState<SideTab>('text');

  return (
    <section className="grid gap-2">
      <h2 className="text-sm font-semibold leading-6 text-zinc-900 dark:text-zinc-100">
        {heading}
      </h2>

      <div className="sm:hidden">
        <select
          value={tab}
          onChange={(e) => setTab(e.target.value as SideTab)}
          className={inputClass}
        >
          {TABS.map((t) => (
            <option key={t.id} value={t.id}>{t.label}</option>
          ))}
        </select>
      </div>

      <ul className="hidden text-sm font-medium text-center text-zinc-500 dark:text-zinc-400 sm:flex -space-x-px">
        {TABS.map((t, i) => (
          <li key={t.id} className="w-full">
            <button
              type="button"
              onClick={() => setTab(t.id)}
              aria-current={tab === t.id ? 'page' : undefined}
              className={`inline-flex w-full items-center justify-center gap-1 border px-3 py-2 text-[0.8125rem] font-medium ${
                i === 0 ? 'rounded-s-xl' : ''
              } ${i === TABS.length - 1 ? 'rounded-e-xl' : ''} ${
                tab === t.id
                  ? 'z-10 border-indigo-500 bg-indigo-50 text-indigo-600 dark:border-indigo-500 dark:bg-indigo-500/10 dark:text-indigo-400'
                  : 'border-zinc-200 bg-white text-zinc-500 hover:bg-zinc-50 hover:text-zinc-800 dark:border-zinc-700 dark:bg-zinc-900 dark:text-zinc-400 dark:hover:bg-zinc-800 dark:hover:text-zinc-100'
              }`}
            >
              <t.Icon className="h-3.5 w-3.5" aria-hidden="true" />
              {t.label}
            </button>
          </li>
        ))}
      </ul>

      {tab === 'text' ? (
        <textarea
          placeholder={heading}
          value={text}
          onChange={(e) => onTextChange(e.target.value)}
          rows={2}
          className={`${inputClass} resize-y`}
        />
      ) : null}
      {tab === 'pronunciation' ? (
        <MediaSearch
          type="audio"
          defaultLanguage={defaultLanguage}
          selected={attachments}
          onChange={onAttachmentsChange}
        />
      ) : null}
      {tab === 'image' ? (
        <MediaSearch
          type="image"
          defaultLanguage={null}
          selected={attachments}
          onChange={onAttachmentsChange}
        />
      ) : null}
    </section>
  );
}

export function CardForm({
  deckId,
  language
}: {
  deckId: string;
  language: Language | null;
}) {
  const [front, setFront] = useState('');
  const [back, setBack] = useState('');
  const [frontAttachments, setFrontAttachments] = useState<CardAttachment[]>([]);
  const [backAttachments, setBackAttachments] = useState<CardAttachment[]>([]);
  const { notify } = useToast();

  async function submit(e: React.FormEvent) {
    e.preventDefault();
    const f = front.trim();
    const b = back.trim();
    const hasFront = f.length > 0 || frontAttachments.length > 0;
    const hasBack = b.length > 0 || backAttachments.length > 0;
    if (!hasFront || !hasBack) {
      notify(
        !hasFront && !hasBack
          ? 'Add at least one of text, pronunciation, or image on each side'
          : !hasFront
            ? 'Add at least one of text, pronunciation, or image on the front'
            : 'Add at least one of text, pronunciation, or image on the back',
        'info'
      );
      return;
    }
    const db = await getDb();
    const empty = createEmptyCard(new Date());
    const doc: CardDoc = fromFsrsCard(empty, {
      id: nanoid(),
      deckId,
      front: f,
      back: b,
      front_attachments: frontAttachments,
      back_attachments: backAttachments,
      createdAt: Date.now()
    });
    try {
      await db.cards.insert(doc);
      setFront('');
      setBack('');
      setFrontAttachments([]);
      setBackAttachments([]);
    } catch (err) {
      notify(`Could not save card: ${err instanceof Error ? err.message : String(err)}`);
    }
  }

  return (
    <form className="grid gap-3" onSubmit={submit}>
      <CardSideEditor
        heading="Front"
        text={front}
        onTextChange={setFront}
        attachments={frontAttachments}
        onAttachmentsChange={setFrontAttachments}
        defaultLanguage={null}
      />
      <CardSideEditor
        heading="Back"
        text={back}
        onTextChange={setBack}
        attachments={backAttachments}
        onAttachmentsChange={setBackAttachments}
        defaultLanguage={language}
      />
      <div className="flex items-center gap-2 justify-self-start">
        <button type="submit" className={btnPrimary}>
          Add card
        </button>
      </div>
    </form>
  );
}
