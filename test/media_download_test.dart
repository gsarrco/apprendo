import 'dart:typed_data';

import 'package:apprendo/services/commons_api.dart';
import 'package:apprendo/services/media_download.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  test('initCommonsUserAgent embeds the package version', () async {
    PackageInfo.setMockInitialValues(
      appName: 'apprendo',
      packageName: 'study.apprendo',
      version: '9.8.7',
      buildNumber: '1',
      buildSignature: '',
    );

    await initCommonsUserAgent();

    expect(commonsUserAgent, contains('apprendo/9.8.7'));
    expect(commonsUserAgent, contains('github.com/gsarrco/apprendo'));
  });
  test('downloadMedia sends a descriptive User-Agent', () async {
    late http.Request seen;
    final client = MockClient((req) async {
      seen = req;
      return http.Response.bytes(
        Uint8List.fromList([1, 2, 3]),
        200,
        headers: {'content-type': 'audio/ogg; codecs=opus'},
      );
    });

    final media = await downloadMedia(
      'https://upload.wikimedia.org/wikipedia/commons/a/ab/hello.ogg',
      client: client,
    );

    expect(seen.headers['user-agent'], commonsUserAgent);
    expect(media.mimeType, 'audio/ogg');
    expect(media.bytes, [1, 2, 3]);
  });

  test('downloadMedia reports non-200 responses', () async {
    final client = MockClient((_) async => http.Response('rate limited', 429));
    await expectLater(
      downloadMedia('https://upload.wikimedia.org/x.jpg', client: client),
      throwsA(predicate((e) => e.toString().contains('429'))),
    );
  });
}
