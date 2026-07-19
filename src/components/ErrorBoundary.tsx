import { Component, type ErrorInfo, type ReactNode } from 'react';
import { RefreshCw } from 'lucide-react';
import { btnPrimary } from './ui';
import { reloadOnce } from '../lib/reloadOnce';

interface Props {
  children: ReactNode;
}

interface State {
  hasError: boolean;
}

export class ErrorBoundary extends Component<Props, State> {
  state: State = { hasError: false };

  static getDerivedStateFromError(): State {
    return { hasError: true };
  }

  componentDidCatch(error: Error, info: ErrorInfo) {
    console.error('[ErrorBoundary] caught render error', error, info);

    const isChunkLoadError = /Failed to fetch dynamically imported module|Importing a module script failed|Loading chunk|Loading CSS chunk/i.test(
      error.message
    );
    if (isChunkLoadError) {
      reloadOnce();
    }
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="flex min-h-[280px] flex-col items-center justify-center gap-4 text-center">
          <p className="text-zinc-600 dark:text-zinc-400">
            Something went wrong loading this page.
          </p>
          <button
            className={`${btnPrimary} gap-2`}
            onClick={() => window.location.reload()}
          >
            <RefreshCw className="h-4 w-4" aria-hidden="true" />
            Reload
          </button>
        </div>
      );
    }
    return this.props.children;
  }
}
