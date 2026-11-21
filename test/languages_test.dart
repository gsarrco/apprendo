import 'dart:typed_data';

import 'package:apprendo/domain/models.dart';
import 'package:apprendo/services/languages.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  CardAttachment audio({required int createdAt, String? qid}) => CardAttachment(
        type: AttachmentType.audio,
        mimeType: 'audio/ogg',
        content: Uint8List.fromList([1]),
        languageQid: qid,
        createdAt: createdAt,
      );

  test('returns null when there is no audio language', () {
    expect(lastAudioLanguage(const []), isNull);
    expect(lastAudioLanguage([audio(createdAt: 1)]), isNull);
    expect(
      lastAudioLanguage([
        CardAttachment(
          type: AttachmentType.image,
          mimeType: 'image/png',
          content: Uint8List.fromList([1]),
          languageQid: 'Q150',
          createdAt: 2,
        ),
      ]),
      isNull,
    );
  });

  test('returns the language of the most recently added audio', () {
    final language = lastAudioLanguage([
      audio(createdAt: 10, qid: 'Q150'),
      audio(createdAt: 30, qid: 'Q1860'),
      audio(createdAt: 20, qid: 'Q188'),
      audio(createdAt: 40),
    ]);
    expect(language, kLanguages.first);
  });
}
