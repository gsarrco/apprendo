import { test, expect } from '@playwright/test';

test('adds a new deck and it persists', async ({ page }) => {
  const deckName = `E2E Deck ${Date.now()}`;

  await page.goto('/');

  const input = page.getByPlaceholder('New deck name…');
  await input.fill(deckName);

  const addButton = page.getByRole('button', { name: 'Add deck' });
  await expect(addButton).toBeInViewport();
  await addButton.click();

  const deckLink = page.getByRole('link', { name: new RegExp(deckName) });
  await expect(deckLink).toBeVisible();
  await expect(input).toHaveValue('');

  await page.reload();
  await expect(page.getByRole('link', { name: new RegExp(deckName) })).toBeVisible();
});
