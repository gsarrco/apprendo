import 'package:just_audio/just_audio.dart';

/// Singleton audio playback helper. Stops the previous stream when a new
/// one starts, mirroring the web app's behavior.
class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  final AudioPlayer _player = AudioPlayer();
  String? _currentSrc;

  /// [src] is a base64 data URL built from the attachment's raw bytes —
  /// attachments always come from local storage, never a remote url.
  Future<void> play(String src) async {
    if (src.isEmpty) return;
    try {
      if (_currentSrc != src) {
        await _player.setUrl(src);
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
}

/// Convenience wrapper matching the web app's `playAudio(url)`.
void playAudio(String? src) {
  if (src == null || src.isEmpty) return;
  AudioService.instance.play(src);
}
