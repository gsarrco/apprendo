import { useState } from 'react';
import { Trash2, Loader2 } from 'lucide-react';
import { btnGhost } from './ui';
import { useToast } from '../hooks/useToast';

interface DeleteButtonProps {
  onDelete: () => Promise<void>;
  label?: string;
  confirmMessage?: string;
  className?: string;
}

export function DeleteButton({
  onDelete,
  label = 'Delete',
  confirmMessage,
  className = btnGhost
}: DeleteButtonProps) {
  const { notify } = useToast();
  const [busy, setBusy] = useState(false);

  async function handleClick() {
    if (confirmMessage) {
      const ok = window.confirm(confirmMessage);
      if (!ok) return;
    }
    setBusy(true);
    try {
      await onDelete();
    } catch (err) {
      notify(
        `Could not delete: ${err instanceof Error ? err.message : String(err)}`
      );
    } finally {
      setBusy(false);
    }
  }

  return (
    <button
      type="button"
      aria-label={label}
      title={label}
      disabled={busy}
      onClick={handleClick}
      className={className}
    >
      {busy ? (
        <Loader2 className="h-4 w-4 animate-spin" aria-hidden="true" />
      ) : (
        <Trash2 className="h-4 w-4" aria-hidden="true" />
      )}
    </button>
  );
}
