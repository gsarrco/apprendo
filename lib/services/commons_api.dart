import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../domain/models.dart';
import 'languages.dart';

const String _apiUrl = 'https://commons.wikimedia.org/w/api.php';
const String _commonsContact = 'https://github.com/gsarrco/apprendo';

String _commonsUserAgent = 'apprendo ($_commonsContact)';

/// Wikimedia's User-Agent policy requires a descriptive agent with a way to
/// contact the operator. Requests without one (e.g. Dart's default
/// `Dart/x.y (dart:io)`) are answered with `429 Too Many Requests`, which
/// broke every media download from `upload.wikimedia.org`.
///
/// Call [initCommonsUserAgent] at startup so the app version from
/// `pubspec.yaml` is included; until then a version-less agent is used,
/// which Wikimedia still accepts.
String get commonsUserAgent => _commonsUserAgent;

http.Client? _testCommonsClient;

@visibleForTesting
void setCommonsClientForTesting(http.Client? client) {
  _testCommonsClient = client;
}

(http.Client, bool) _commonsClient(http.Client? client) {
  if (client != null) return (client, false);
  final test = _testCommonsClient;
  if (test != null) return (test, false);
  return (http.Client(), true);
}

/// Replaces the fallback agent with one carrying the real app version.
/// Failures keep the fallback instead of breaking media search.
Future<void> initCommonsUserAgent() async {
  try {
    final info = await PackageInfo.fromPlatform();
    if (info.version.isNotEmpty) {
      _commonsUserAgent = 'apprendo/${info.version} ($_commonsContact)';
    }
  } catch (_) {
    // Keep the version-less fallback.
  }
}

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
  final res = await client.get(
    Uri.parse('$_apiUrl?${Uri(queryParameters: params).query}'),
    headers: {'User-Agent': commonsUserAgent},
  );
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
}) async {
  final (c, owned) = _commonsClient(client);
  try {
    return await _searchCommons(
        'filetype:bitmap $query', RegExp(r'^image/'), limit, c);
  } finally {
    if (owned) c.close();
  }
}

String normalizeCommonsTitle(String title) =>
    title.replaceFirst(RegExp(r'\.[^.]+$'), '').toLowerCase();

List<CommonsMedium> _dedupeAudios(List<CommonsMedium> media, int limit) {
  final byKey = <String, CommonsMedium>{};
  for (final m in media) {
    final key = normalizeCommonsTitle(m.title);
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
  final (c, owned) = _commonsClient(client);
  try {
    final cat = kCategoryByCode[language.code]!;
    final llQuery =
        'intitle:"$query" filetype:audio intitle:"LL-${language.qid}"';
    final catQuery = 'intitle:"$query" filetype:audio incategory:"$cat"';
    final results = await Future.wait([
      _searchCommons(llQuery, RegExp(r'^audio/'), limit, c)
          .catchError((_) => const <CommonsMedium>[]),
      _searchCommons(catQuery, RegExp(r'^audio/'), limit, c)
          .catchError((_) => const <CommonsMedium>[]),
    ]);
    return _dedupeAudios([...results[0], ...results[1]], limit);
  } finally {
    if (owned) c.close();
  }
}
