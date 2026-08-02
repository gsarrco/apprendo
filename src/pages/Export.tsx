import { useMemo, useState } from 'react';
import { Checkbox } from 'flowbite-react';
import { Download } from 'lucide-react';
import { useDecks } from '../hooks/useDecks';
import { useToast } from '../hooks/useToast';
import { btnPrimary } from '../components/ui';
import { buildExport, downloadExport } from '../lib/export';

export default function Export() {
  const decks = useDecks();
  const [selectedIds, setSelectedIds] = useState<Set<string>>(new Set());
  const [includeReviewLogs, setIncludeReviewLogs] = useState(true);
  const [exporting, setExporting] = useState(false);
  const { notify } = useToast();

  const sorted = useMemo(
    () => [...decks].sort((a, b) => a.createdAt - b.createdAt),
    [decks]
  );
  const allSelected = sorted.length > 0 && selectedIds.size === sorted.length;

  function toggle(id: string) {
    setSelectedIds((prev) => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
  }

  function toggleAll() {
    setSelectedIds(allSelected ? new Set() : new Set(sorted.map((d) => d.id)));
  }

  async function handleExport() {
    if (selectedIds.size === 0) return;
    setExporting(true);
    try {
      const exportFile = await buildExport([...selectedIds], { includeReviewLogs });
      downloadExport(exportFile);
      notify('Export ready', 'success');
    } catch (err) {
      notify(`Could not export: ${err instanceof Error ? err.message : String(err)}`);
    } finally {
      setExporting(false);
    }
  }

  return (
    <section className="space-y-6">
      <div>
        <h2 className="text-xl font-bold tracking-tight">Export</h2>
        <p className="mt-1 text-sm text-zinc-500 dark:text-zinc-400">
          Select the decks you want to export. The export includes their cards,
          attachments, and any study tags that reference them.
        </p>
      </div>

      {sorted.length === 0 ? (
        <div className="rounded-2xl border border-dashed border-zinc-300 px-6 py-12 text-center dark:border-zinc-700">
          <p className="text-sm font-medium text-zinc-600 dark:text-zinc-300">
            No decks yet
          </p>
        </div>
      ) : (
        <div className="space-y-3">
          <label className="flex cursor-pointer items-center gap-2 text-sm font-medium text-zinc-700 dark:text-zinc-200">
            <Checkbox checked={allSelected} onChange={toggleAll} />
            Select all
          </label>
          <ul className="divide-y divide-zinc-200 rounded-2xl border border-zinc-200 bg-white dark:divide-zinc-800 dark:border-zinc-800 dark:bg-zinc-900">
            {sorted.map((deck) => (
              <li key={deck.id}>
                <label className="flex cursor-pointer items-center gap-3 px-4 py-3">
                  <Checkbox
                    checked={selectedIds.has(deck.id)}
                    onChange={() => toggle(deck.id)}
                  />
                  <span className="truncate text-sm text-zinc-900 dark:text-zinc-100">
                    {deck.name}
                  </span>
                </label>
              </li>
            ))}
          </ul>
          <label className="flex cursor-pointer items-center gap-2 text-sm text-zinc-700 dark:text-zinc-200">
            <Checkbox
              checked={includeReviewLogs}
              onChange={() => setIncludeReviewLogs((prev) => !prev)}
            />
            Include review history
          </label>
          <p className="text-xs text-zinc-400 dark:text-zinc-500">
            Turn off to share a deck with other learners without your personal
            study progress.
          </p>
          <button
            type="button"
            className={btnPrimary}
            disabled={selectedIds.size === 0 || exporting}
            onClick={handleExport}
          >
            <Download className="mr-1.5 h-4 w-4" aria-hidden="true" />
            {exporting
              ? 'Exporting…'
              : `Export ${selectedIds.size || ''} deck${selectedIds.size === 1 ? '' : 's'}`.trim()}
          </button>
        </div>
      )}
    </section>
  );
}