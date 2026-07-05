import {
  DndContext,
  closestCenter,
  PointerSensor,
  useSensor,
  useSensors,
  type DragEndEvent
} from '@dnd-kit/core';
import {
  SortableContext,
  useSortable,
  arrayMove,
  rectSortingStrategy
} from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';
import { Trash2, Volume2 } from 'lucide-react';
import type { CardAttachment } from '../types';
import { playAudio } from '../lib/commonsThumb';

interface AttachmentTrayProps {
  items: CardAttachment[];
  onChange: (next: CardAttachment[]) => void;
}

interface TrayTileProps {
  item: CardAttachment;
  onRemove: () => void;
}

function TrayTile({ item, onRemove }: TrayTileProps) {
  const {
    attributes,
    listeners,
    setNodeRef,
    transform,
    transition,
    isDragging
  } = useSortable({ id: item.url });

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
    opacity: isDragging ? 0.6 : 1
  };

  return (
    <div
      ref={setNodeRef}
      style={style}
      {...attributes}
      {...listeners}
      title={item.attribution ?? undefined}
      className="group relative flex cursor-grab items-center gap-2 overflow-hidden rounded-lg border-2 border-zinc-200 bg-white p-1 pr-2 transition active:cursor-grabbing dark:border-zinc-700 dark:bg-zinc-900"
    >
      <button
        type="button"
        aria-label={item.type === 'audio' ? 'Play audio' : 'View attachment'}
        onClick={(e) => {
          e.stopPropagation();
          if (item.type === 'audio') playAudio(item.url);
        }}
        className="relative h-12 w-12 shrink-0 overflow-hidden rounded-md"
      >
        {item.type === 'image' ? (
          <img
            src={item.url}
            alt=""
            className="h-full w-full object-cover"
          />
        ) : (
          <div className="flex h-full w-full items-center justify-center bg-zinc-100 dark:bg-zinc-800">
            <Volume2
              className="h-5 w-5 text-zinc-500 dark:text-zinc-400"
              aria-hidden="true"
            />
          </div>
        )}
      </button>
      <span className="line-clamp-2 max-w-[8rem] text-xs leading-tight text-zinc-700 dark:text-zinc-200">
        {item.caption}
      </span>
      <button
        type="button"
        aria-label="Remove attachment"
        onClick={(e) => {
          e.stopPropagation();
          onRemove();
        }}
        className="absolute right-0 top-0 flex h-4 w-4 items-center justify-center bg-zinc-900/70 text-white opacity-0 transition hover:bg-red-600 group-hover:opacity-100"
      >
        <Trash2 className="h-2.5 w-2.5" aria-hidden="true" />
      </button>
    </div>
  );
}

export function AttachmentTray({ items, onChange }: AttachmentTrayProps) {
  const sensors = useSensors(
    useSensor(PointerSensor, { activationConstraint: { distance: 5 } })
  );

  if (items.length === 0) return null;

  function handleDragEnd(event: DragEndEvent) {
    const { active, over } = event;
    if (!over || active.id === over.id) return;
    const oldIndex = items.findIndex((i) => i.url === active.id);
    const newIndex = items.findIndex((i) => i.url === over.id);
    if (oldIndex === -1 || newIndex === -1) return;
    onChange(arrayMove(items, oldIndex, newIndex));
  }

  return (
    <DndContext
      sensors={sensors}
      collisionDetection={closestCenter}
      onDragEnd={handleDragEnd}
    >
      <SortableContext items={items.map((i) => i.url)} strategy={rectSortingStrategy}>
        <div className="flex flex-wrap gap-1">
          {items.map((item) => (
            <TrayTile
              key={item.url}
              item={item}
              onRemove={() =>
                onChange(items.filter((x) => x.url !== item.url))
              }
            />
          ))}
        </div>
      </SortableContext>
    </DndContext>
  );
}
