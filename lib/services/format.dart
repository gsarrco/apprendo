import 'dart:math' as math;

/// Formats a duration in milliseconds the way the original app did:
/// "45s", "12m", "3h", "5d", "2mo", "1.5y".
String formatInterval(int ms) {
  if (ms < 60000) return '${math.max(1, (ms / 1000).round())}s';
  final minutes = (ms / 60000).round();
  if (minutes < 60) return '${minutes}m';
  final hours = (ms / 3600000).round();
  if (hours < 24) return '${hours}h';
  final days = (ms / 86400000).round();
  if (days < 30) return '${days}d';
  final months = (days / 30).round();
  if (months < 12) return '${months}mo';
  return '${(days / 365).toStringAsFixed(1)}y';
}
