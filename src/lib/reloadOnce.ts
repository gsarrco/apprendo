const RELOAD_GUARD_KEY = 'apprendo:chunk-error-reload';

export function reloadOnce() {
  if (sessionStorage.getItem(RELOAD_GUARD_KEY)) return;
  sessionStorage.setItem(RELOAD_GUARD_KEY, '1');
  window.location.reload();
}

export function clearReloadGuardAfter(delayMs: number) {
  setTimeout(() => sessionStorage.removeItem(RELOAD_GUARD_KEY), delayMs);
}
