import { Download } from 'lucide-react';
import { useInstallPrompt } from '../hooks/useInstallPrompt';

export function InstallButton() {
  const { canInstall, promptInstall } = useInstallPrompt();

  if (!canInstall) return null;

  return (
    <button
      type="button"
      onClick={promptInstall}
      aria-label="Install app"
      title="Install app"
      className="relative inline-flex h-9 w-9 items-center justify-center rounded-full text-zinc-500 transition hover:bg-zinc-100 hover:text-zinc-900 dark:text-zinc-400 dark:hover:bg-zinc-800 dark:hover:text-zinc-100"
    >
      <Download className="h-5 w-5" aria-hidden="true" />
    </button>
  );
}
