import { useEffect, useRef } from 'react';
import { registerSW } from 'virtual:pwa-register';
import { useToast } from '../hooks/useToast';

export function PwaUpdatePrompt() {
  const { notify } = useToast();
  const updateSWRef = useRef<
    ((reloadPage?: boolean) => Promise<void>) | null
  >(null);

  useEffect(() => {
    updateSWRef.current = registerSW({
      immediate: true,
      onNeedRefresh() {
        notify('An update is available.', 'info', {
          persist: true,
          action: {
            label: 'Reload',
            onClick: () => {
              void updateSWRef.current?.(true);
            }
          }
        });
      },
      onRegisteredSW(_url, registration) {
        if (!registration) return;
        setInterval(
          () => {
            void registration.update();
          },
          60 * 60 * 1000
        );
      }
    });
  }, [notify]);

  return null;
}
