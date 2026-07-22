import { Volume2 } from 'lucide-react';
import type { CardAttachment } from '../types';
import { attachmentSrc } from '../lib/attachments';

export function AttachmentThumbnails({
  attachments
}: {
  attachments: CardAttachment[];
}) {
  const images = attachments.filter((a) => a.type === 'image');
  if (images.length === 0) return null;
  return (
    <div className="grid w-fit grid-cols-2 gap-1">
      {images.slice(0, 4).map((a, i) => (
        <img
          key={`${i}-${attachmentSrc(a)}`}
          src={attachmentSrc(a)}
          alt=""
          onClick={(e) => e.stopPropagation()}
          className="h-12 w-12 rounded-lg object-cover"
        />
      ))}
      {images.length > 4 ? (
        <span className="flex h-12 w-12 items-center justify-center rounded-lg bg-zinc-100 text-xs font-medium text-zinc-500 dark:bg-zinc-800 dark:text-zinc-400">
          +{images.length - 4}
        </span>
      ) : null}
    </div>
  );
}

export function AttachmentImageGrid({
  attachments
}: {
  attachments: CardAttachment[];
}) {
  const images = attachments.filter((a) => a.type === 'image');
  if (images.length === 0) return null;
  return (
    <div
      className={`grid gap-2 ${images.length >= 3 ? 'grid-cols-3' : 'grid-cols-2'}`}
    >
      {images.map((a, i) => (
        <img
          key={`${i}-${attachmentSrc(a)}`}
          src={attachmentSrc(a)}
          alt=""
          className="max-h-[200px] w-full rounded-xl object-contain"
        />
      ))}
    </div>
  );
}

export function AttachmentAudioButtons({
  attachments,
  onPlay,
  size = 'sm'
}: {
  attachments: CardAttachment[];
  onPlay: (index: number) => void;
  size?: 'sm' | 'md';
}) {
  const audio = attachments.filter((a) => a.type === 'audio');
  if (audio.length === 0) return null;
  const iconClass = size === 'md' ? 'h-5 w-5' : 'h-4 w-4';
  return audio.map((a, i) => (
    <button
      key={`${i}-${attachmentSrc(a)}`}
      type="button"
      aria-label={`Play audio ${i + 1}`}
      onClick={(e) => {
        e.stopPropagation();
        onPlay(i);
      }}
      className="text-zinc-400 transition hover:text-indigo-600 dark:hover:text-indigo-400"
    >
      <Volume2 className={iconClass} aria-hidden="true" />
    </button>
  ));
}

export function AttachmentAttributions({
  attachments
}: {
  attachments: CardAttachment[];
}) {
  const withAttr = attachments.filter((a) => a.attribution);
  if (withAttr.length === 0) return null;
  return (
    <div className="space-y-0.5 text-[0.65rem] text-zinc-400 dark:text-zinc-500">
      {withAttr.map((a, i) => (
        <div key={`${i}-${attachmentSrc(a)}`}>{a.attribution}</div>
      ))}
    </div>
  );
}
