import { describe, it, expect } from "vitest";
import { searchCommonsAudio } from "../../src/integrations/commonsApi";
import type { Language } from "../../src/types";

const GERMAN: Language = { qid: "Q188", code: "deu", label: "German" };

const CASES: Array<[query: string, language: Language]> = [
  ["hallo", GERMAN],
  ["guten morgen", GERMAN],
];

describe("searchCommonsAudio", () => {
  for (const [query, language] of CASES) {
    it(`returns more than one result for "${query}" in ${language.label}`, async () => {
      const results = await searchCommonsAudio(query, language, 3);
      console.log(`"${query}" in ${language.label}: ${results.length} results`);
      expect(results.length).toBeGreaterThan(0);
      for (const r of results) {
        expect(r.url).toMatch(/^https:\/\//);
        expect(r.title).toContain("File:");
      }
    });
  }
});
