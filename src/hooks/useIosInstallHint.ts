import { useState } from 'react';

const DISMISSED_KEY = 'ios-install-hint-dismissed';

function isIosSafariNotInstalled(): boolean {
  if (typeof window === 'undefined') return false;
  const isIos = /iphone|ipad|ipod/i.test(navigator.userAgent);
  const isStandalone =
    (navigator as { standalone?: boolean }).standalone === true ||
    window.matchMedia('(display-mode: standalone)').matches;
  return isIos && !isStandalone;
}

export function useIosInstallHint() {
  const [dismissed, setDismissed] = useState(
    () => localStorage.getItem(DISMISSED_KEY) === '1'
  );

  const dismiss = () => {
    localStorage.setItem(DISMISSED_KEY, '1');
    setDismissed(true);
  };

  return { show: !dismissed && isIosSafariNotInstalled(), dismiss };
}
