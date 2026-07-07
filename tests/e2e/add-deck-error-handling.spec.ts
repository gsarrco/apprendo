import { test, expect } from '@playwright/test';

test('shows an error toast when the database fails to initialize', async ({ page }) => {
  await page.addInitScript(() => {
    Object.defineProperty(window, 'indexedDB', {
      value: undefined,
      configurable: true
    });
  });

  await page.goto('/');

  const input = page.getByPlaceholder('New deck name…');
  await input.fill('Deck that will fail');
  await page.getByRole('button', { name: 'Add deck' }).click();

  await expect(page.getByRole('alert')).toBeVisible();
});
