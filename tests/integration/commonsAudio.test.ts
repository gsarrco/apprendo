import { describe, it, expect } from "vitest";
import { searchCommonsAudio } from "../../src/integrations/commonsApi";
import { captionFromTitle } from "../../src/lib/commonsThumb";
import type { Language } from "../../src/types";

const ENGLISH: Language = { qid: "Q1860", code: "eng", label: "English" };
const FRENCH: Language = { qid: "Q150", code: "fra", label: "French" };
const GERMAN: Language = { qid: "Q188", code: "deu", label: "German" };

const CASES: Array<[query: string, language: Language]> = [
  ["hello", ENGLISH],
  ["house", ENGLISH],
  ["bonjour", FRENCH],
  ["maison", FRENCH],
  ["hallo", GERMAN],
];

describe("searchCommonsAudio", () => {
  it("returns results with clean captions for all queries", async () => {
    for (const [query, language] of CASES) {
      const results = await searchCommonsAudio(query, language, 3);
      console.log(`\n"${query}" in ${language.label}: ${results.length} results`);
      expect(results.length).toBeGreaterThan(0);
      for (const r of results) {
        const caption = captionFromTitle(r.title, "audio");
        expect(caption.length).toBeGreaterThan(0);
        expect(caption).not.toMatch(/^LL-Q/);
        expect(caption).not.toMatch(/-/);
        expect(caption).not.toMatch(/\.wav$/);
        expect(caption).not.toMatch(/\.ogg$/);
      }
    }
  });
});
