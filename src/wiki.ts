const API_URL = 'https://commons.wikimedia.org/w/api.php';

export interface WikiImage {
  title: string;
  url: string;
  artist: string | null;
  license: string | null;
  credit: string | null;
}

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

export async function fetchImages(query: string, limit = 3): Promise<WikiImage[]> {
  const params = new URLSearchParams({
    action: 'query',
    generator: 'search',
    gsrsearch: `filetype:bitmap ${query}`,
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
    .map((p): WikiImage | null => {
      const info = p.imageinfo?.[0];
      const url = info?.url;
      const mime = info?.mime;
      if (!url || !mime || !IMAGE_MIME.test(mime)) return null;
      const meta = info?.extmetadata;
      return {
        title: p.title,
        url,
        artist: meta?.Artist?.value ?? null,
        license: meta?.LicenseShortName?.value ?? null,
        credit: meta?.Credit?.value ?? null
      };
    })
    .filter((img): img is WikiImage => img !== null)
    .slice(0, limit);
}
