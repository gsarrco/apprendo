import type { Language } from '../types';

export const LANGUAGES: Language[] = [
  { qid: 'Q1860', code: 'eng', label: 'English' },
  { qid: 'Q150', code: 'fra', label: 'French' },
  { qid: 'Q1321', code: 'spa', label: 'Spanish' },
  { qid: 'Q188', code: 'deu', label: 'German' },
  { qid: 'Q652', code: 'ita', label: 'Italian' },
  { qid: 'Q5146', code: 'por', label: 'Portuguese' },
  { qid: 'Q7411', code: 'nld', label: 'Dutch' },
  { qid: 'Q7026', code: 'cat', label: 'Catalan' },
  { qid: 'Q7737', code: 'rus', label: 'Russian' },
  { qid: 'Q809', code: 'pol', label: 'Polish' },
  { qid: 'Q9027', code: 'swe', label: 'Swedish' },
  { qid: 'Q143', code: 'epo', label: 'Esperanto' }
];

export const LANG_BY_QID: Record<string, Language> = Object.fromEntries(
  LANGUAGES.map((l) => [l.qid, l])
);

export const CATEGORY_BY_CODE: Record<string, string> = Object.fromEntries(
  LANGUAGES.map((l) => [l.code, `${l.label} pronunciation`])
);
