import 'package:flutter_test/flutter_test.dart';
import 'package:apprendo/services/format.dart';
import 'package:apprendo/services/commons_api.dart';
import 'package:apprendo/domain/models.dart';

void main() {
  test('formatInterval matches the original app', () {
    expect(formatInterval(500), '1s');
    expect(formatInterval(45_000), '45s');
    expect(formatInterval(59_900), '60s');
    expect(formatInterval(720_000), '12m');
    expect(formatInterval(90 * 60_000), '2h');
    expect(formatInterval(5 * 86_400_000), '5d');
    expect(formatInterval(60 * 86_400_000), '2mo');
    expect(formatInterval(365 * 86_400_000), '1.0y');
    expect(formatInterval(730 * 86_400_000), '2.0y');
  });

  test('captionFromTitle cleans Commons titles', () {
    expect(
      captionFromTitle(
          'File:LL-Q1860 (eng)-Wodencafe-hello.wav', AttachmentType.audio),
      'hello',
    );
    expect(
      captionFromTitle(
          'File:LL-Q7411 (nld)-Speaker-huis.wav', AttachmentType.audio),
      'huis',
    );
    expect(
      captionFromTitle('File:Yellow_tomato.jpg', AttachmentType.image),
      'Yellow tomato',
    );
    expect(
      captionFromTitle('File:bonjour (fr).wav', AttachmentType.audio),
      'bonjour (fr)',
    );
  });

  test('attributionOf formats artist and license', () {
    const m = CommonsMedium(
      title: 'File:a.png',
      url: 'https://example.com/a.png',
      artist: '<a href="x">Jane Doe</a>',
      license: 'CC BY-SA 4.0',
    );
    expect(attributionOf(m), 'Jane Doe — CC BY-SA 4.0');
    const noLicense = CommonsMedium(
      title: 'File:a.png',
      url: 'https://example.com/a.png',
      artist: 'Jane Doe',
    );
    expect(attributionOf(noLicense), 'Jane Doe');
    const fallback = CommonsMedium(
      title: 'File:a.png',
      url: 'https://example.com/a.png',
    );
    expect(attributionOf(fallback), 'Wikipedia: File:a.png');
  });

  test('stripHtml removes tags and entities', () {
    expect(stripHtml('<a href="x">Jane</a>'), 'Jane');
    expect(stripHtml('A &amp; B'), 'A & B');
  });
}
