import {
  useCallback,
  useState,
  type ReactNode
} from 'react';
import { CheckCircle2, AlertCircle, Info, X } from 'lucide-react';
import {
  ToastContext,
  type Toast,
  type ToastType
} from '../hooks/useToast';

const STYLES: Record<ToastType, string> = {
  success:
    'border-emerald-200 bg-white text-emerald-700 dark:border-emerald-500/30 dark:bg-zinc-900 dark:text-emerald-400',
  error:
    'border-red-200 bg-white text-red-700 dark:border-red-500/30 dark:bg-zinc-900 dark:text-red-400',
  info: 'border-zinc-200 bg-white text-zinc-700 dark:border-zinc-700 dark:bg-zinc-900 dark:text-zinc-300'
};

const ICONS: Record<ToastType, typeof CheckCircle2> = {
  success: CheckCircle2,
  error: AlertCircle,
  info: Info
};

let counter = 0;

export function ToastProvider({ children }: { children: ReactNode }) {
  const [toasts, setToasts] = useState<Toast[]>([]);

  const dismiss = useCallback((id: number) => {
    setToasts((prev) => prev.filter((t) => t.id !== id));
  }, []);

  const notify = useCallback(
    (message: string, type: ToastType = 'error') => {
      const id = ++counter;
      setToasts((prev) => [...prev, { id, message, type }]);
      setTimeout(() => dismiss(id), 5000);
    },
    [dismiss]
  );

  return (
    <ToastContext.Provider value={{ notify }}>
      {children}
      <div className="pointer-events-none fixed inset-x-0 bottom-4 z-50 flex flex-col items-center gap-2 px-4">
        {toasts.map((t) => {
          const Icon = ICONS[t.type];
          return (
            <ToastItem
              key={t.id}
              toast={t}
              icon={Icon}
              onDismiss={() => dismiss(t.id)}
            />
          );
        })}
      </div>
    </ToastContext.Provider>
  );
}

function ToastItem({
  toast,
  icon: Icon,
  onDismiss
}: {
  toast: Toast;
  icon: typeof CheckCircle2;
  onDismiss: () => void;
}) {
  return (
    <div
      className={`pointer-events-auto flex w-full max-w-sm items-start gap-2.5 rounded-xl border px-4 py-3 shadow-lg shadow-zinc-900/5 ${STYLES[toast.type]}`}
      role="alert"
    >
      <Icon className="mt-0.5 h-4 w-4 shrink-0" aria-hidden="true" />
      <p className="flex-1 text-sm">{toast.message}</p>
      <button
        type="button"
        onClick={onDismiss}
        aria-label="Dismiss"
        className="shrink-0 opacity-50 transition hover:opacity-100"
      >
        <X className="h-4 w-4" aria-hidden="true" />
      </button>
    </div>
  );
}
