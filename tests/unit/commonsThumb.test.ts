import { describe, it, expect } from "vitest";
import { captionFromTitle } from "../../src/lib/commonsThumb";

const CAT_TITLES = [
  "File:Good Morning.wav",
  "File:Bonjour.wav",
  "File:En-Hello.oga",
  "File:Fr-bonjour-2.ogg",
  "File:Wikibooksfr-anglias-bonjour.ogg",
];

const LL_TITLES = [
  "File:LL-Q1860 (eng)-Wodencafe-hello.wav",
  "File:LL-Q150 (fra)-Jules78120-bonjour.wav",
  "File:LL-Q188 (deu)-Trypeds-Hallo.wav",
  "File:LL-Q7411 (nld)-Robin van der Vliet-hallo.wav",
  "File:LL-Q7411 (nld)-Procrastineur49-begraafplaats Huis te Vraag.wav",
];

describe("captionFromTitle", () => {
  it("produces clean captions for LinguaLibre-style titles", () => {
    for (const title of LL_TITLES) {
      const caption = captionFromTitle(title, "audio");
      console.log(`  ${title}  =>  ${caption}`);
      expect(caption.length).toBeGreaterThan(0);
      expect(caption).not.toMatch(/^LL-Q/);
      expect(caption).not.toMatch(/^\d+$/);
      expect(caption).not.toMatch(/\.wav$/);
      expect(caption).not.toMatch(/\.oga$/);
      expect(caption).not.toMatch(/\.ogg$/);
    }
  });

  it("produces clean captions for known category-source titles", () => {
    for (const title of CAT_TITLES) {
      const caption = captionFromTitle(title, "audio");
      console.log(`  ${title}  =>  ${caption}`);
      expect(caption.length).toBeGreaterThan(0);
      expect(caption).not.toMatch(/^LL-Q/);
      expect(caption).not.toMatch(/^\d+$/);
      expect(caption).not.toMatch(/\.wav$/);
      expect(caption).not.toMatch(/\.oga$/);
      expect(caption).not.toMatch(/\.ogg$/);
    }
  });

  it("strips LL-Q speaker prefix to the pronounced word", () => {
    expect(captionFromTitle("File:LL-Q1860 (eng)-Wodencafe-hello.wav", "audio")).toBe("hello");
    expect(captionFromTitle("File:LL-Q150 (fra)-Jules78120-bonjour.wav", "audio")).toBe("bonjour");
    expect(captionFromTitle("File:LL-Q188 (deu)-Trypeds-Hallo.wav", "audio")).toBe("Hallo");
    expect(captionFromTitle("File:LL-Q188 (deu)-Lifebeginner-Hallo.wav", "audio")).toBe("Hallo");
    expect(captionFromTitle("File:LL-Q1860 (eng)-Flame, not lame-compliments of the house.wav", "audio")).toBe("compliments of the house");
  });
});
