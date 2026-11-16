import 'dart:convert';

import 'package:http/http.dart' as http;

import '../data/database.dart';
import '../domain/models.dart';

/// An attachment needs downloading when it has a remote url but no
/// offline copy.
bool needsDownload(CardAttachment a) => a.url != null && a.blobContent == null;

int pendingCount(List<CardDoc> cards) => cards.fold(
    0,
    (sum, card) =>
        sum +
        card.frontAttachments.where(needsDownload).length +
        card.backAttachments.where(needsDownload).length);

/// Downloads [url] and returns it as a base64 data URL.
Future<String> downloadUrlAsDataUrl(String url, {http.Client? client}) async {
  final c = client ?? http.Client();
  final res = await c.get(Uri.parse(url));
  if (res.statusCode != 200) {
    throw Exception('Download failed (${res.statusCode})');
  }
  final mime =
      res.headers['content-type']?.split(';').first.trim() ?? 'application/octet-stream';
  return 'data:$mime;base64,${base64Encode(res.bodyBytes)}';
}

/// Sequentially downloads all pending attachments of a deck into their
/// offline copies. Reports each completed download via [onDownloaded].
Future<void> downloadDeckAttachments(
  AppDatabase db,
  String deckId,
  void Function() onDownloaded,
  bool Function() isCancelled,
) async {
  final cards = await db.getCardsOfDecks([deckId]);
  for (final card in cards) {
    for (final side in [card.frontAttachments, card.backAttachments]) {
      for (final attachment in side) {
        if (isCancelled()) return;
        if (!needsDownload(attachment)) continue;
        if (attachment.rowId == null) continue;
        final blob = await downloadUrlAsDataUrl(attachment.url!);
        await db.setAttachmentBlob(attachment.rowId!, blob);
        onDownloaded();
      }
    }
  }
}
