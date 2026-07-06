import { Share, X } from 'lucide-react';
import { useIosInstallHint } from '../hooks/useIosInstallHint';

export function IosInstallHint() {
  const { show, dismiss } = useIosInstallHint();

  if (!show) return null;

  return (
    <div
      className="pointer-events-none fixed inset-x-0 bottom-4 z-50 flex justify-center px-4"
      role="status"
    >
      <div className="pointer-events-auto flex w-full max-w-sm items-start gap-2.5 rounded-xl border border-zinc-200 bg-white px-4 py-3 text-sm text-zinc-700 shadow-lg shadow-zinc-900/5 dark:border-zinc-700 dark:bg-zinc-900 dark:text-zinc-300">
        <Share className="mt-0.5 h-4 w-4 shrink-0" aria-hidden="true" />
        <p className="flex-1">
          Install Apprendo: tap Share, then "Add to Home Screen".
        </p>
        <button
          type="button"
          onClick={dismiss}
          aria-label="Dismiss"
          className="shrink-0 opacity-50 transition hover:opacity-100"
        >
          <X className="h-4 w-4" aria-hidden="true" />
        </button>
      </div>
    </div>
  );
}
