import { Rating, type Grade } from 'ts-fsrs';
import { btnBase } from './ui';

const LABELS: Record<number, string> = {
  [Rating.Again]: 'Again',
  [Rating.Hard]: 'Hard',
  [Rating.Good]: 'Good',
  [Rating.Easy]: 'Easy'
};

const STYLES: Record<number, string> = {
  [Rating.Again]:
    'border-red-400/60 text-red-500 hover:border-red-500 hover:bg-red-50 dark:hover:bg-red-500/10',
  [Rating.Hard]:
    'border-amber-400/60 text-amber-500 hover:border-amber-500 hover:bg-amber-50 dark:hover:bg-amber-500/10',
  [Rating.Good]:
    'border-emerald-400/60 text-emerald-500 hover:border-emerald-500 hover:bg-emerald-50 dark:hover:bg-emerald-500/10',
  [Rating.Easy]:
    'border-indigo-400/60 text-indigo-500 hover:border-indigo-500 hover:bg-indigo-50 dark:hover:bg-indigo-500/10'
};

interface Props {
  previews: Record<number, string>;
  onRate: (r: Grade) => void;
  disabled?: boolean;
}

const ORDER: Grade[] = [Rating.Again, Rating.Hard, Rating.Good, Rating.Easy];

export function RatingButtons({ previews, onRate, disabled }: Props) {
  return (
    <div className="grid grid-cols-2 gap-2 sm:grid-cols-4">
      {ORDER.map((r) => (
        <button
          key={r}
          type="button"
          className={`${btnBase} flex-col gap-1 border bg-white py-3 shadow-sm dark:bg-zinc-800 ${STYLES[r]}`}
          onClick={() => onRate(r)}
          disabled={disabled}
        >
          <span className="font-semibold">{LABELS[r]}</span>
          {previews[r] ? (
            <span className="text-xs opacity-70">{previews[r]}</span>
          ) : null}
        </button>
      ))}
    </div>
  );
}
