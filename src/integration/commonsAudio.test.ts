import { describe, it, expect } from 'vitest';
import { searchCommonsAudio } from '../integrations/commonsApi';
import type { Language } from '../types';

const GERMAN: Language = { qid: 'Q188', code: 'deu', label: 'German' };

describe('searchCommonsAudio — German "hallo"', () => {
  it('returns more than one result', async () => {
    const results = await searchCommonsAudio('hallo', GERMAN, 3);
    expect(results.length).toBeGreaterThan(1);
    for (const r of results) {
      expect(r.url).toMatch(/^https:\/\//);
      expect(r.title).toContain('File:');
    }
  });
});
