const API_URL = 'https://en.wikipedia.org/w/api.php';

export interface WikiImage {
  title: string;
  url: string;
  artist: string | null;
  license: string | null;
  credit: string | null;
}

interface RawImageInfo {
  url?: string;
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

export async function fetchImages(title: string, limit = 3): Promise<WikiImage[]> {
  const params = new URLSearchParams({
    action: 'query',
    generator: 'images',
    prop: 'imageinfo',
    iiprop: 'url|extmetadata',
    gimlimit: String(limit),
    format: 'json',
    redirects: '1',
    origin: '*',
    titles: title
  });
  const res = await fetch(`${API_URL}?${params.toString()}`);
  if (!res.ok) throw new Error(`MediaWiki request failed: ${res.status}`);
  const data = (await res.json()) as QueryResponse;
  const pages = data.query?.pages;
  if (!pages) return [];
  return Object.values(pages)
    .map((p): WikiImage | null => {
      const info = p.imageinfo?.[0];
      const url = info?.url;
      if (!url) return null;
      const meta = info?.extmetadata;
      return {
        title: p.title,
        url,
        artist: meta?.Artist?.value ?? null,
        license: meta?.LicenseShortName?.value ?? null,
        credit: meta?.Credit?.value ?? null
      };
    })
    .filter((img): img is WikiImage => img !== null);
}
