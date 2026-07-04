import { Rating, type Grade } from 'ts-fsrs';

const LABELS: Record<number, string> = {
  [Rating.Again]: 'Again',
  [Rating.Hard]: 'Hard',
  [Rating.Good]: 'Good',
  [Rating.Easy]: 'Easy'
};

interface Props {
  previews: Record<number, string>;
  onRate: (r: Grade) => void;
  disabled?: boolean;
}

const ORDER: Grade[] = [Rating.Again, Rating.Hard, Rating.Good, Rating.Easy];

export function RatingButtons({ previews, onRate, disabled }: Props) {
  return (
    <div className="rating-buttons">
      {ORDER.map((r) => (
        <button
          key={r}
          type="button"
          className={`rating-btn rating-${r}`}
          onClick={() => onRate(r)}
          disabled={disabled}
        >
          <span className="rating-label">{LABELS[r]}</span>
          {previews[r] ? (
            <span className="rating-preview">{previews[r]}</span>
          ) : null}
        </button>
      ))}
    </div>
  );
}
