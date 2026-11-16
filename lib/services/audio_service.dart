import 'dart:convert';

import 'package:just_audio/just_audio.dart';

/// Singleton audio playback helper. Stops the previous stream when a new
/// one starts, mirroring the web app's behavior.
class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  final AudioPlayer _player = AudioPlayer();
  String? _currentSrc;

  Future<void> play(String src) async {
    if (src.isEmpty) return;
    try {
      if (_currentSrc != src) {
        final uri = await _resolveSource(src);
        await _player.setUrl(uri);
        _currentSrc = src;
      } else {
        await _player.seek(Duration.zero);
      }
      await _player.play();
    } catch (_) {
      // Playback failures are ignored, like in the original app.
    }
  }

  Future<void> stop() async {
    await _player.stop();
  }

  /// Resolves http(s) URLs directly; base64 data URLs are decoded into a
  /// data: URI AudioSource understands.
  Future<String> _resolveSource(String src) async {
    if (src.startsWith('data:')) return src;
    return src;
  }
}

/// Convenience wrapper matching the web app's `playAudio(url)`.
void playAudio(String? src) {
  if (src == null || src.isEmpty) return;
  AudioService.instance.play(src);
}

/// Decodes a data URL into raw bytes (for tests and file export).
List<int> dataUrlBytes(String dataUrl) {
  final comma = dataUrl.indexOf(',');
  if (!dataUrl.startsWith('data:') || comma == -1) {
    throw const FormatException('Not a data URL');
  }
  final meta = dataUrl.substring(5, comma);
  final isBase64 = meta.endsWith(';base64');
  final payload = dataUrl.substring(comma + 1);
  return isBase64 ? base64Decode(payload) : utf8.encode(payload);
}
