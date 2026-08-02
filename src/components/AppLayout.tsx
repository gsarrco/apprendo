import { Suspense } from 'react';
import { Link, Outlet } from 'react-router-dom';
import { Dropdown, DropdownItem } from 'flowbite-react';
import { Download, Loader2, Upload } from 'lucide-react';
import { InstallButton } from './InstallButton';
import { IosInstallHint } from './IosInstallHint';
import { ThemeToggle } from './ThemeToggle';
import { ErrorBoundary } from './ErrorBoundary';

function RouteFallback() {
  return (
    <div className="flex min-h-[280px] items-center justify-center">
      <Loader2 className="h-6 w-6 animate-spin text-zinc-400" aria-hidden="true" />
    </div>
  );
}

export function Layout() {
  return (
    <div className="min-h-full">
      <header className="sticky top-0 z-10 border-b border-zinc-200 bg-white/80 backdrop-blur dark:border-zinc-800 dark:bg-zinc-950/80">
        <div className="mx-auto flex h-14 max-w-3xl items-center justify-between px-5">
          <Link
            to="/"
            className="text-base font-bold tracking-tight transition hover:text-indigo-600 dark:hover:text-indigo-400"
          >
            Apprendo
          </Link>
          <div className="flex items-center gap-1">
            <Dropdown
              inline
              arrowIcon={false}
              label={
                <span className="relative inline-flex h-9 w-9 items-center justify-center rounded-full text-zinc-500 transition hover:bg-zinc-100 hover:text-zinc-900 dark:text-zinc-400 dark:hover:bg-zinc-800 dark:hover:text-zinc-100">
                  <Download className="h-5 w-5" aria-hidden="true" />
                </span>
              }
            >
              <DropdownItem as={Link} to="/export" icon={Download}>
                Export
              </DropdownItem>
              <DropdownItem as={Link} to="/import" icon={Upload}>
                Import
              </DropdownItem>
            </Dropdown>
            <InstallButton />
            <ThemeToggle />
          </div>
        </div>
      </header>
      <main className="mx-auto max-w-3xl px-5 py-10">
        <ErrorBoundary>
          <Suspense fallback={<RouteFallback />}>
            <Outlet />
          </Suspense>
        </ErrorBoundary>
      </main>
      <IosInstallHint />
    </div>
  );
}
