import type { Language } from '../types';
import { CATEGORY_BY_CODE } from './languages';

const API_URL = 'https://commons.wikimedia.org/w/api.php';

export interface CommonsMedium {
  title: string;
  url: string;
  artist: string | null;
  license: string | null;
  credit: string | null;
}

export type CommonsImage = CommonsMedium;
export type CommonsAudio = CommonsMedium;

interface RawImageInfo {
  url?: string;
  mime?: string;
  extmetadata?: {
    Artist?: { value: string };
    LicenseShortName?: { value: string };
    Credit?: { value: string };
  };
}

interface RawPage {
  title: string;
  imageinfo?: RawImageInfo[];
}

interface QueryResponse {
  query?: { pages: Record<string, RawPage> };
}

const IMAGE_MIME = /^image\//;
const AUDIO_MIME = /^audio\//;

function extractMedium(p: RawPage, mimeFilter: RegExp): CommonsMedium | null {
  const info = p.imageinfo?.[0];
  const url = info?.url;
  const mime = info?.mime;
  if (!url || !mime || !mimeFilter.test(mime)) return null;
  const meta = info?.extmetadata;
  return {
    title: p.title,
    url,
    artist: meta?.Artist?.value ?? null,
    license: meta?.LicenseShortName?.value ?? null,
    credit: meta?.Credit?.value ?? null
  };
}

async function searchCommons(
  srsearch: string,
  mimeFilter: RegExp,
  limit: number
): Promise<CommonsMedium[]> {
  const params = new URLSearchParams({
    action: 'query',
    generator: 'search',
    gsrsearch: srsearch,
    gsrnamespace: '6',
    gsrlimit: String(limit * 2),
    prop: 'imageinfo',
    iiprop: 'url|mime|extmetadata',
    format: 'json',
    origin: '*'
  });
  const res = await fetch(`${API_URL}?${params.toString()}`);
  if (!res.ok) throw new Error(`MediaWiki request failed: ${res.status}`);
  const data = (await res.json()) as QueryResponse;
  const pages = data.query?.pages;
  if (!pages) return [];
  return Object.values(pages)
    .map((p) => extractMedium(p, mimeFilter))
    .filter((m): m is CommonsMedium => m !== null)
    .slice(0, limit);
}

export function searchCommonsImages(
  query: string,
  limit = 3
): Promise<CommonsImage[]> {
  return searchCommons(`filetype:bitmap ${query}`, IMAGE_MIME, limit);
}

function normalizeTitle(title: string): string {
  const noExt = title.replace(/\.[^.]+$/, '');
  return noExt.toLowerCase();
}

function dedupeAudios(media: CommonsAudio[], limit: number): CommonsAudio[] {
  const byKey = new Map<string, CommonsAudio>();
  for (const m of media) {
    const key = normalizeTitle(m.title);
    const existing = byKey.get(key);
    if (!existing) {
      byKey.set(key, m);
      continue;
    }
    const isLinguaLibre = (t: string) => t.includes('LL-Q');
    if (isLinguaLibre(m.title) && !isLinguaLibre(existing.title)) {
      byKey.set(key, m);
    }
  }
  return Array.from(byKey.values()).slice(0, limit);
}

export async function searchCommonsAudio(
  query: string,
  language: Language,
  limit = 3
): Promise<CommonsAudio[]> {
  const cat = CATEGORY_BY_CODE[language.code];
  const llQuery = `intitle:"${query}" filetype:audio intitle:"LL-${language.qid}"`;
  const catQuery = `intitle:"${query}" filetype:audio incategory:"${cat}"`;
  const [ll, byCat] = await Promise.all([
    searchCommons(llQuery, AUDIO_MIME, limit).catch(() => []),
    searchCommons(catQuery, AUDIO_MIME, limit).catch(() => [])
  ]);
  return dedupeAudios([...ll, ...byCat], limit);
}
