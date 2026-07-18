import { Suspense } from 'react';
import { Link, Outlet } from 'react-router-dom';
import { Loader2 } from 'lucide-react';
import { InstallButton } from './InstallButton';
import { IosInstallHint } from './IosInstallHint';
import { ThemeToggle } from './ThemeToggle';

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
            <InstallButton />
            <ThemeToggle />
          </div>
        </div>
      </header>
      <main className="mx-auto max-w-3xl px-5 py-10">
        <Suspense fallback={<RouteFallback />}>
          <Outlet />
        </Suspense>
      </main>
      <IosInstallHint />
    </div>
  );
}
