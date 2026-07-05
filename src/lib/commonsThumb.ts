import type { CommonsMedium } from '../integrations/commonsApi';
import type { AttachmentType } from '../types';

export interface Thumb {
  url: string;
  attribution: string;
}

export function stripHtml(s: string): string {
  return new DOMParser()
    .parseFromString(s, 'text/html')
    .body.textContent?.trim() ?? '';
}

export function captionFromTitle(title: string, type: AttachmentType): string {
  let s = title.replace(/^File:/, '').replace(/_/g, ' ').trim();
  s = s.replace(/\.[^.]+$/, '').trim();
  if (type === 'audio' && s.startsWith('LL-Q')) {
    return s.split('-').pop() ?? s;
  }
  return s;
}

export function toThumb(m: CommonsMedium): Thumb {
  const artist = m.artist ? stripHtml(m.artist) : '';
  const license = m.license ? stripHtml(m.license) : '';
  const credit = m.credit ? stripHtml(m.credit) : '';
  let attribution: string;
  if (artist && license) attribution = `${artist} — ${license}`;
  else if (artist) attribution = artist;
  else if (credit) attribution = credit;
  else attribution = `Wikipedia: ${m.title}`;
  return { url: m.url, attribution };
}

let currentAudio: HTMLAudioElement | null = null;

export function playAudio(url: string | null) {
  if (!url) return;
  try {
    if (currentAudio) {
      currentAudio.pause();
      currentAudio.currentTime = 0;
    }
    const audio = new Audio(url);
    currentAudio = audio;
    void audio.play().catch(() => {});
  } catch {
    /* ignore */
  }
}
