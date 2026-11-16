import '../domain/models.dart';

const List<Language> kLanguages = [
  Language(qid: 'Q1860', code: 'eng', label: 'English'),
  Language(qid: 'Q150', code: 'fra', label: 'French'),
  Language(qid: 'Q1321', code: 'spa', label: 'Spanish'),
  Language(qid: 'Q188', code: 'deu', label: 'German'),
  Language(qid: 'Q652', code: 'ita', label: 'Italian'),
  Language(qid: 'Q5146', code: 'por', label: 'Portuguese'),
  Language(qid: 'Q7411', code: 'nld', label: 'Dutch'),
  Language(qid: 'Q7026', code: 'cat', label: 'Catalan'),
  Language(qid: 'Q7737', code: 'rus', label: 'Russian'),
  Language(qid: 'Q809', code: 'pol', label: 'Polish'),
  Language(qid: 'Q9027', code: 'swe', label: 'Swedish'),
  Language(qid: 'Q143', code: 'epo', label: 'Esperanto'),
];

final Map<String, Language> kLanguageByQid = {
  for (final l in kLanguages) l.qid: l,
};

final Map<String, String> kCategoryByCode = {
  for (final l in kLanguages) l.code: '${l.label} pronunciation',
};
