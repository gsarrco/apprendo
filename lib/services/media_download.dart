import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'commons_api.dart' show commonsUserAgent;

/// Media file downloaded into memory as raw bytes plus its mime type.
class DownloadedMedia {
  final Uint8List bytes;
  final String mimeType;
  const DownloadedMedia({required this.bytes, required this.mimeType});
}

/// Downloads [url] into memory. Attachments are always stored in the
/// database, so media picked from Wikimedia Commons is fetched right
/// away instead of keeping a remote reference.
Future<DownloadedMedia> downloadMedia(String url, {http.Client? client}) async {
  final c = client ?? http.Client();
  try {
    final res = await c.get(
      Uri.parse(url),
      headers: {'User-Agent': commonsUserAgent},
    );
    if (res.statusCode != 200) {
      throw Exception('Download failed (${res.statusCode})');
    }
    final mime = res.headers['content-type']?.split(';').first.trim() ??
        'application/octet-stream';
    return DownloadedMedia(bytes: res.bodyBytes, mimeType: mime);
  } finally {
    if (client == null) c.close();
  }
}

/// Guesses the mime type of an uploaded file from its name.
String mimeFromFileName(String name) {
  final dot = name.lastIndexOf('.');
  final ext = dot == -1 ? '' : name.substring(dot + 1).toLowerCase();
  return switch (ext) {
    'jpg' || 'jpeg' => 'image/jpeg',
    'png' => 'image/png',
    'gif' => 'image/gif',
    'webp' => 'image/webp',
    'bmp' => 'image/bmp',
    'mp3' => 'audio/mpeg',
    'ogg' || 'oga' || 'opus' => 'audio/ogg',
    'wav' => 'audio/wav',
    'm4a' => 'audio/mp4',
    'aac' => 'audio/aac',
    'flac' => 'audio/flac',
    'webm' => 'audio/webm',
    _ => 'application/octet-stream',
  };
}

/// Splits a `data:<mime>;base64,…` URL into its mime type and raw bytes,
/// or returns null when [dataUrl] is not a base64 data URL.
({String mimeType, Uint8List bytes})? parseDataUrl(String dataUrl) {
  if (!dataUrl.startsWith('data:')) return null;
  final comma = dataUrl.indexOf(',');
  if (comma == -1) return null;
  final meta = dataUrl.substring(5, comma);
  if (!meta.endsWith(';base64')) return null;
  var mime = meta.substring(0, meta.length - ';base64'.length);
  if (mime.isEmpty) mime = 'application/octet-stream';
  final Uint8List bytes;
  try {
    bytes = base64Decode(dataUrl.substring(comma + 1));
  } catch (_) {
    return null;
  }
  return (mimeType: mime, bytes: bytes);
}
