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

test.describe('Deck detail view', () => {
  test.beforeEach(async ({ page }) => {
    await page.addInitScript((seeds) => {
      (window as unknown as { __APPRENDO_E2E_SEEDS__?: unknown }).__APPRENDO_E2E_SEEDS__ = seeds;
    }, { decks, cards, reviewlogs });
  });

  test('shows the counted cards from the mock data', async ({ page }) => {
    const dutchDeck = decks.find((d) => d.name === 'Dutch Nouns')!;
    await page.goto(`/deck/${dutchDeck.id}`);
    await expect(page.getByText('Cards · 5')).toBeVisible();
    await page.reload();
    await expect(page.getByText('Cards · 5')).toBeVisible();
  });
});
