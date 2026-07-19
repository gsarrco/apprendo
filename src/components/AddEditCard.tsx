import { useEffect, useState } from 'react';
import { nanoid } from 'nanoid';
import { getDb } from '../db';
import { createEmptyCard } from '../fsrs/scheduler';
import { fromFsrsCard } from '../fsrs/mappers';
import type { CardAttachment, CardDoc, Language } from '../types';
import { useToast } from '../hooks/useToast';
import { MediaSearch } from './MediaSearch';
import { btnPrimary, btnSecondary, inputClass } from './ui';
import { TextAlignStart, AudioLines, Image as ImageIcon } from 'lucide-react';

type SideTab = 'text' | 'pronunciation' | 'image';

const TABS: { id: SideTab; label: string; Icon: typeof TextAlignStart }[] = [
  { id: 'text', label: 'Text', Icon: TextAlignStart },
  { id: 'pronunciation', label: 'Pronunciation', Icon: AudioLines },
  { id: 'image', label: 'Image', Icon: ImageIcon }
];

function sideDefaultTab(a: CardAttachment[]): SideTab {
  if (a.some((x) => x.type === 'image')) return 'image';
  if (a.some((x) => x.type === 'audio')) return 'pronunciation';
  return 'text';
}

function sideAudioLanguage(a: CardAttachment[]): Language | null {
  return a.find((x) => x.type === 'audio')?.language ?? null;
}

function CardSideEditor({
  heading,
  text,
  onTextChange,
  attachments,
  onAttachmentsChange,
  defaultTab,
  defaultLanguage
}: {
  heading: string;
  text: string;
  onTextChange: (v: string) => void;
  attachments: CardAttachment[];
  onAttachmentsChange: (next: CardAttachment[]) => void;
  defaultTab: SideTab;
  defaultLanguage: Language | null;
}) {
  const [tab, setTab] = useState<SideTab>(defaultTab);

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
  latestCard,
  editingCard,
  onDone
}: {
  deckId: string;
  latestCard?: CardDoc | null;
  editingCard?: CardDoc | null;
  onDone?: () => void;
}) {
  const isEditing = Boolean(editingCard);
  const [front, setFront] = useState('');
  const [back, setBack] = useState('');
  const [frontAttachments, setFrontAttachments] = useState<CardAttachment[]>([]);
  const [backAttachments, setBackAttachments] = useState<CardAttachment[]>([]);
  const [formKey, setFormKey] = useState(0);
  const { notify } = useToast();

  const template = editingCard ?? latestCard ?? null;
  const frontDefaultTab: SideTab = template
    ? sideDefaultTab(template.front_attachments)
    : 'text';
  const frontDefaultLanguage: Language | null = template
    ? sideAudioLanguage(template.front_attachments)
    : null;
  const backDefaultTab: SideTab = template
    ? sideDefaultTab(template.back_attachments)
    : 'text';
  const backDefaultLanguage: Language | null = template
    ? sideAudioLanguage(template.back_attachments)
    : null;

  useEffect(() => {
    if (editingCard) {
      setFront(editingCard.front);
      setBack(editingCard.back);
      setFrontAttachments(editingCard.front_attachments);
      setBackAttachments(editingCard.back_attachments);
    }
  }, [editingCard]);

  function resetForm() {
    setFront('');
    setBack('');
    setFrontAttachments([]);
    setBackAttachments([]);
    setFormKey((k) => k + 1);
  }

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
    try {
      if (editingCard) {
        const rxDoc = await db.cards.findOne(editingCard.id).exec();
        if (!rxDoc) throw new Error('Card no longer exists');
        await rxDoc.patch({
          front: f,
          back: b,
          front_attachments: frontAttachments,
          back_attachments: backAttachments,
          updatedAt: Date.now()
        });
        resetForm();
        onDone?.();
      } else {
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
        await db.cards.insert(doc);
        resetForm();
      }
    } catch (err) {
      notify(
        `Could not ${isEditing ? 'edit' : 'save'} card: ${
          err instanceof Error ? err.message : String(err)
        }`
      );
    }
  }

  return (
    <form className="grid gap-3" onSubmit={submit}>
      <CardSideEditor
        key={`front-${editingCard?.id ?? 'new'}-${latestCard?.id ?? 'none'}-${formKey}`}
        heading="Front"
        text={front}
        onTextChange={setFront}
        attachments={frontAttachments}
        onAttachmentsChange={setFrontAttachments}
        defaultTab={frontDefaultTab}
        defaultLanguage={frontDefaultLanguage}
      />
      <CardSideEditor
        key={`back-${editingCard?.id ?? 'new'}-${latestCard?.id ?? 'none'}-${formKey}`}
        heading="Back"
        text={back}
        onTextChange={setBack}
        attachments={backAttachments}
        onAttachmentsChange={setBackAttachments}
        defaultTab={backDefaultTab}
        defaultLanguage={backDefaultLanguage}
      />
      <div className="flex items-center gap-2 justify-self-start">
        <button type="submit" className={btnPrimary}>
          {isEditing ? 'Edit card' : 'Add card'}
        </button>
        {isEditing ? (
          <button
            type="button"
            onClick={() => {
              resetForm();
              onDone?.();
            }}
            className={btnSecondary}
          >
            Cancel
          </button>
        ) : null}
      </div>
    </form>
  );
}
