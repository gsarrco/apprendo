import { test, expect } from '@playwright/test';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';
import type { CardDoc, Deck, ReviewLogDoc } from '../../src/types';

const fixturesDir = join(dirname(fileURLToPath(import.meta.url)), '..', 'fixtures');
const read = (name: string) => JSON.parse(readFileSync(join(fixturesDir, name), 'utf8'));

const decks: Deck[] = read('decks.json');
const cards: CardDoc[] = read('cards.json');
const reviewlogs: ReviewLogDoc[] = read('reviewlogs.json');

test.describe('Add/edit card side defaults', () => {
  test.beforeEach(async ({ page }) => {
    await page.addInitScript((seeds) => {
      (window as unknown as { __APPRENDO_E2E_SEEDS__?: unknown }).__APPRENDO_E2E_SEEDS__ = seeds;
    }, { decks, cards, reviewlogs });
  });

  test('new card defaults front=image and back=audio with Dutch selected', async ({ page }) => {
    test.skip(
      !test.info().project.name.includes('Desktop'),
      'tab assertions rely on the desktop tab bar markup'
    );

    const deckId = decks.find((d) => d.name === 'Dutch Nouns')!.id;
    await page.goto(`/deck/${deckId}`);

    const dutch = { qid: 'Q7411', code: 'nld', label: 'Dutch' } as const;

    const front = page.locator('section', { has: page.getByRole('heading', { name: 'Front', level: 2 }) });
    const back = page.locator('section', { has: page.getByRole('heading', { name: 'Back', level: 2 }) });

    await expect(front.getByRole('button', { name: 'Image', exact: true })).toHaveAttribute('aria-current', 'page');
    await expect(back.getByRole('button', { name: 'Pronunciation' })).toHaveAttribute('aria-current', 'page');

    const languageSelect = back.getByRole('combobox');
    await expect(languageSelect).toHaveValue(dutch.qid);
    await expect(languageSelect).toContainText(dutch.label);
  });

  test('uploads an own image stored as blob_content', async ({ page }) => {
    test.skip(
      !test.info().project.name.includes('Desktop'),
      'tab interactions rely on the desktop tab bar markup'
    );

    const deckId = decks.find((d) => d.name === 'Dutch Nouns')!.id;
    await page.goto(`/deck/${deckId}`);

    const front = page.locator('section', { has: page.getByRole('heading', { name: 'Front', level: 2 }) });
    await expect(front.getByRole('button', { name: 'Image', exact: true })).toHaveAttribute('aria-current', 'page');

    const png = Buffer.from(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
      'base64'
    );
    await front
      .locator('input[type="file"]')
      .setInputFiles({ name: 'my-photo.png', mimeType: 'image/png', buffer: png });

    await expect(front.locator('img[src^="data:image/png"]')).toBeVisible();
    await expect(front.getByText('my-photo')).toBeVisible();
  });
});
