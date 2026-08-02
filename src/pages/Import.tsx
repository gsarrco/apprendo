import { useRef, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Upload } from 'lucide-react';
import { useToast } from '../hooks/useToast';
import { btnPrimary } from '../components/ui';
import { parseBackup, restoreBackup } from '../lib/backup';

export default function Import() {
  const [importing, setImporting] = useState(false);
  const [fileName, setFileName] = useState<string | null>(null);
  const inputRef = useRef<HTMLInputElement>(null);
  const { notify } = useToast();
  const navigate = useNavigate();

  async function handleFile(file: File) {
    setImporting(true);
    setFileName(file.name);
    try {
      const text = await file.text();
      const backup = parseBackup(text);
      await restoreBackup(backup);
      notify(
        `Imported ${backup.decks.length} deck${backup.decks.length === 1 ? '' : 's'}`,
        'success'
      );
      navigate('/');
    } catch (err) {
      notify(`Could not import: ${err instanceof Error ? err.message : String(err)}`);
    } finally {
      setImporting(false);
      if (inputRef.current) inputRef.current.value = '';
    }
  }

  return (
    <section className="space-y-6">
      <div>
        <h2 className="text-xl font-bold tracking-tight">Import</h2>
        <p className="mt-1 text-sm text-zinc-500 dark:text-zinc-400">
          Select an Apprendo backup file (.json) to restore its decks, cards,
          review history, and study tags. Existing data with the same IDs will
          be overwritten.
        </p>
      </div>

      <div className="rounded-2xl border border-dashed border-zinc-300 px-6 py-12 text-center dark:border-zinc-700">
        <input
          ref={inputRef}
          type="file"
          accept="application/json,.json"
          className="hidden"
          onChange={(e) => {
            const file = e.target.files?.[0];
            if (file) void handleFile(file);
          }}
        />
        <button
          type="button"
          className={btnPrimary}
          disabled={importing}
          onClick={() => inputRef.current?.click()}
        >
          <Upload className="mr-1.5 h-4 w-4" aria-hidden="true" />
          {importing ? 'Importing…' : 'Choose backup file'}
        </button>
        {fileName && (
          <p className="mt-3 text-xs text-zinc-400 dark:text-zinc-500">
            {fileName}
          </p>
        )}
      </div>
    </section>
  );
}
