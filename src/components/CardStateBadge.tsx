const STATE_LABELS = ['New', 'Learning', 'Review', 'Relearning'];

const STATE_STYLES: Record<number, string> = {
  0: 'border-zinc-300 text-zinc-500 dark:border-zinc-600 dark:text-zinc-400',
  1: 'border-amber-400/60 text-amber-500',
  2: 'border-emerald-400/60 text-emerald-500',
  3: 'border-red-400/60 text-red-500'
};

export function CardStateBadge({
  state,
  size = 'sm'
}: {
  state: number;
  size?: 'sm' | 'md';
}) {
  const sizeClasses =
    size === 'md'
      ? 'px-2.5 py-0.5 text-[0.7rem] font-medium uppercase tracking-wider'
      : 'px-2 py-0.5 text-[0.7rem] capitalize';
  return (
    <span
      className={`rounded-full border ${sizeClasses} ${STATE_STYLES[state] ?? STATE_STYLES[0]}`}
    >
      {STATE_LABELS[state] ?? state}
    </span>
  );
}
