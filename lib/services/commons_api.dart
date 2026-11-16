import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/models.dart';
import 'languages.dart';

const String _apiUrl = 'https://commons.wikimedia.org/w/api.php';

class CommonsMedium {
  final String title;
  final String url;
  final String? artist;
  final String? license;
  final String? credit;

  const CommonsMedium({
    required this.title,
    required this.url,
    this.artist,
    this.license,
    this.credit,
  });
}

/// Strips HTML tags from Commons metadata values.
String stripHtml(String s) {
  var out = s.replaceAll(RegExp(r'<[^>]*>'), ' ');
  out = out.replaceAll('&amp;', '&').replaceAll('&quot;', '"');
  out = out.replaceAll(RegExp(r'\s+'), ' ').trim();
  return out;
}

/// Cleans a Commons file title into a display caption, handling
/// LinguaLibre pronunciations ("LL-Q1860 (eng)-Wodencafe-hello.wav" ->
/// "hello").
String captionFromTitle(String title, AttachmentType type) {
  var s = title.replaceFirst(RegExp(r'^File:'), '').replaceAll('_', ' ').trim();
  s = s.replaceFirst(RegExp(r'\.[^.]+$'), '').trim();
  if (type == AttachmentType.audio && s.startsWith('LL-Q')) {
    final parts = s.split('-');
    return parts.isEmpty ? s : parts.last;
  }
  return s;
}

/// Builds the attribution line shown under attachments.
String attributionOf(CommonsMedium m) {
  final artist = m.artist == null ? '' : stripHtml(m.artist!);
  final license = m.license == null ? '' : stripHtml(m.license!);
  final credit = m.credit == null ? '' : stripHtml(m.credit!);
  if (artist.isNotEmpty && license.isNotEmpty) return '$artist — $license';
  if (artist.isNotEmpty) return artist;
  if (credit.isNotEmpty) return credit;
  return 'Wikipedia: ${m.title}';
}

CommonsMedium? _extractMedium(Map page, RegExp mimeFilter) {
  final info = (page['imageinfo'] as List?)?.firstOrNull;
  if (info is! Map) return null;
  final url = info['url'] as String?;
  final mime = info['mime'] as String?;
  if (url == null || mime == null || !mimeFilter.hasMatch(mime)) return null;
  final meta = info['extmetadata'] as Map<String, dynamic>?;
  String? metaValue(String key) {
    final v = meta?[key];
    if (v is Map && v['value'] is String) return v['value'] as String;
    return null;
  }

  return CommonsMedium(
    title: page['title'] as String,
    url: url,
    artist: metaValue('Artist'),
    license: metaValue('LicenseShortName'),
    credit: metaValue('Credit'),
  );
}

Future<List<CommonsMedium>> _searchCommons(
    String srsearch, RegExp mimeFilter, int limit, http.Client client) async {
  final params = <String, String>{
    'action': 'query',
    'generator': 'search',
    'gsrsearch': srsearch,
    'gsrnamespace': '6',
    'gsrlimit': (limit * 2).toString(),
    'prop': 'imageinfo',
    'iiprop': 'url|mime|extmetadata',
    'format': 'json',
    'origin': '*',
  };
  final res = await client.get(Uri.parse('$_apiUrl?${Uri(queryParameters: params).query}'));
  if (res.statusCode != 200) {
    throw Exception('MediaWiki request failed: ${res.statusCode}');
  }
  final data = jsonDecode(res.body) as Map<String, dynamic>;
  final query = data['query'] as Map<String, dynamic>?;
  final pages = query?['pages'] as Map<String, dynamic>?;
  if (pages == null) return const [];
  return pages.values
      .map((p) => p is Map ? _extractMedium(p, mimeFilter) : null)
      .whereType<CommonsMedium>()
      .take(limit)
      .toList();
}

Future<List<CommonsMedium>> searchCommonsImages(
  String query, {
  int limit = 3,
  http.Client? client,
}) {
  return _searchCommons(
      'filetype:bitmap $query', RegExp(r'^image/'), limit, client ?? http.Client());
}

String _normalizeTitle(String title) =>
    title.replaceFirst(RegExp(r'\.[^.]+$'), '').toLowerCase();

List<CommonsMedium> _dedupeAudios(List<CommonsMedium> media, int limit) {
  final byKey = <String, CommonsMedium>{};
  for (final m in media) {
    final key = _normalizeTitle(m.title);
    final existing = byKey[key];
    if (existing == null) {
      byKey[key] = m;
      continue;
    }
    bool isLinguaLibre(String t) => t.contains('LL-Q');
    if (isLinguaLibre(m.title) && !isLinguaLibre(existing.title)) {
      byKey[key] = m;
    }
  }
  return byKey.values.take(limit).toList();
}

Future<List<CommonsMedium>> searchCommonsAudio(
  String query,
  Language language, {
  int limit = 3,
  http.Client? client,
}) async {
  final c = client ?? http.Client();
  final cat = kCategoryByCode[language.code]!;
  final llQuery =
      'intitle:"$query" filetype:audio intitle:"LL-${language.qid}"';
  final catQuery = 'intitle:"$query" filetype:audio incategory:"$cat"';
  final results = await Future.wait([
    _searchCommons(llQuery, RegExp(r'^audio/'), limit, c).catchError((_) => const <CommonsMedium>[]),
    _searchCommons(catQuery, RegExp(r'^audio/'), limit, c).catchError((_) => const <CommonsMedium>[]),
  ]);
  return _dedupeAudios([...results[0], ...results[1]], limit);
}
