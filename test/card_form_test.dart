import 'dart:convert';

import 'package:apprendo/app.dart';
import 'package:apprendo/data/database.dart';
import 'package:apprendo/domain/models.dart';
import 'package:apprendo/services/commons_api.dart';
import 'package:apprendo/services/languages.dart';
import 'package:apprendo/ui/deck_detail_page.dart';
import 'package:apprendo/ui/widgets/card_form.dart';
import 'package:apprendo/ui/widgets/media_search.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    setAppDatabaseForTesting(db);
  });

  tearDown(() async {
    setCommonsClientForTesting(null);
    await db.close();
  });

  Widget wrap(Widget child) => MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(body: child),
      );

  testWidgets('asks for the front first, then slides to the back step',
      (tester) async {
    await tester.pumpWidget(wrap(CardForm(deckId: 'd1')));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Front'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Back'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Back'), findsOneWidget);
    expect(find.text('Done'), findsNothing);

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Back'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Front'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Done'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Front'), findsNothing);
  });

  testWidgets('slides back to the front step when Front is tapped',
      (tester) async {
    await tester.pumpWidget(wrap(CardForm(deckId: 'd1')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Front'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Front'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Back'), findsOneWidget);
    expect(find.text('Done'), findsNothing);
  });

  testWidgets('Done with an empty front shows the front validation message',
      (tester) async {
    await tester.pumpWidget(wrap(CardForm(deckId: 'd1')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Done'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      find.text('Add at least one of text, pronunciation, or image on the front'),
      findsOneWidget,
    );
    expect(await db.getCardsOfDecks(const ['d1']), isEmpty);
  });

  testWidgets('prefills the form when a card is selected for editing',
      (tester) async {
    await db.insertDeck(Deck(id: 'd1', name: 'Italian', createdAt: 1));
    await db.insertCard(CardDoc(
      id: 'card-1',
      deckId: 'd1',
      front: 'il gatto',
      back: 'the cat',
      due: DateTime.utc(2026, 1, 1).toIso8601String(),
      createdAt: 2,
      updatedAt: 2,
    ));
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const DeckDetailPage(deckId: 'd1'),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('il gatto'));
    await tester.pumpAndSettle();

    expect(tester.widget<TextField>(find.byType(TextField)).controller?.text,
        'il gatto');

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    expect(tester.widget<TextField>(find.byType(TextField)).controller?.text,
        'the cat');

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('il gatto'));
    await tester.pumpAndSettle();

    expect(tester.widget<TextField>(find.byType(TextField)).controller?.text,
        'il gatto');
  });

  testWidgets('prefills each side with its last-used audio language',
      (tester) async {
    await tester.pumpWidget(wrap(CardForm(
      deckId: 'd1',
      frontDefaultLanguage: kLanguages[1],
      backDefaultLanguage: kLanguages[3],
    )));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Audio'));
    await tester.pumpAndSettle();
    expect(find.text('French'), findsOneWidget);

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Audio'));
    await tester.pumpAndSettle();
    expect(find.text('German'), findsOneWidget);
  });

  testWidgets('adopts the audio language once the deck cards load',
      (tester) async {
    await tester.pumpWidget(wrap(CardForm(deckId: 'd1')));
    await tester.pumpAndSettle();

    await tester.pumpWidget(wrap(CardForm(
      deckId: 'd1',
      frontDefaultLanguage: kLanguages[1],
      backDefaultLanguage: kLanguages[3],
    )));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Audio'));
    await tester.pumpAndSettle();
    expect(find.text('French'), findsOneWidget);

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Audio'));
    await tester.pumpAndSettle();
    expect(find.text('German'), findsOneWidget);
  });

  testWidgets('audio language dropdown follows a new default language',
      (tester) async {
    Widget build(Language? language) => wrap(MediaSearch(
          type: AttachmentType.audio,
          defaultLanguage: language,
          selected: const [],
          onChange: (_) {},
        ));

    await tester.pumpWidget(build(null));
    expect(find.text('No language'), findsOneWidget);

    await tester.pumpWidget(build(kLanguages[1]));
    await tester.pumpAndSettle();
    expect(find.text('French'), findsOneWidget);
  });

  testWidgets('typing drafts and runs both media searches automatically',
      (tester) async {
    final requests = <http.Request>[];
    setCommonsClientForTesting(MockClient((req) async {
      requests.add(req);
      return http.Response('{}', 200);
    }));
    await tester.pumpWidget(wrap(CardForm(
      deckId: 'd1',
      frontDefaultLanguage: kLanguages[4],
    )));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextField, 'Front'), '  il gatto  ');
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(mediaQueryOf(tester, 'Search image'), 'il gatto');
    expect(mediaQueryOf(tester, 'Search audio'), 'il gatto');
    expect(
      requests.any((r) => r.url.query.contains('filetype%3Abitmap+il+gatto')),
      isTrue,
    );
    expect(
      requests.where((r) => r.url.query.contains('filetype%3Aaudio')).length,
      2,
    );
  });

  testWidgets(
      'without a default audio language the query is drafted but not searched',
      (tester) async {
    final requests = <http.Request>[];
    setCommonsClientForTesting(MockClient((req) async {
      requests.add(req);
      return http.Response('{}', 200);
    }));
    await tester.pumpWidget(wrap(CardForm(deckId: 'd1')));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Front'), 'il gatto');
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(
      requests.where((r) => r.url.query.contains('filetype%3Aaudio')),
      isEmpty,
    );

    await tester.tap(find.text('Audio'));
    await tester.pumpAndSettle();

    final audioField = find
        .byType(TextField, skipOffstage: false)
        .evaluate()
        .map((e) => e.widget as TextField)
        .singleWhere(
            (f) => (f.decoration as InputDecoration).hintText == 'Search audio');
    expect(audioField.controller!.text, 'il gatto');
    expect(audioField.enabled, isFalse);

    await tester.tap(find.text('No language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Italian'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();

    expect(
      requests.where((r) => r.url.query.contains('filetype%3Aaudio')).length,
      2,
    );
  });

  testWidgets('comma queries fan out to alternating per-part results',
      (tester) async {
    http.Response respond(List<String> titles, String mime) => http.Response(
          jsonEncode({
            'query': {
              'pages': {
                for (final (i, t) in titles.indexed)
                  '$i': {
                    'title': 'File:$t',
                    'imageinfo': [
                      {'url': 'https://example.com/$t', 'mime': mime},
                    ],
                  },
              },
            },
          }),
          200,
        );
    final requests = <http.Request>[];
    setCommonsClientForTesting(MockClient((req) async {
      requests.add(req);
      final q = req.url.query;
      final image = q.contains('filetype%3Abitmap');
      for (final part in const ['gatto', 'cane']) {
        final marker = image ? 'bitmap+$part' : '%22$part%22';
        if (!q.contains(marker)) continue;
        final mime = image ? 'image/jpeg' : 'audio/ogg';
        if (image) {
          return respond(
              part == 'gatto'
                  ? const ['img gatto 1.jpg', 'img cane 1.jpg']
                  : const ['img cane 1.jpg', 'img cane 2.jpg'],
              mime);
        }
        return respond(
            part == 'gatto'
                ? const ['aud gatto 1.jpg', 'aud cane 1.jpg']
                : const ['aud cane 1.jpg', 'aud cane 2.jpg'],
            mime);
      }
      return respond(const [], 'image/jpeg');
    }));
    await tester.pumpWidget(wrap(CardForm(
      deckId: 'd1',
      frontDefaultLanguage: kLanguages[4],
    )));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextField, 'Front'), ' gatto ,  cane ');
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(mediaQueryOf(tester, 'Search image'), 'gatto, cane');
    expect(mediaQueryOf(tester, 'Search audio'), 'gatto, cane');
    expect(
      requests.any((r) => r.url.query.contains('filetype%3Abitmap+gatto')),
      isTrue,
    );
    expect(
      requests.any((r) => r.url.query.contains('filetype%3Abitmap+cane')),
      isTrue,
    );
    expect(
      requests.where((r) => r.url.query.contains('filetype%3Aaudio')).length,
      4,
    );

    await tester.tap(find.text('Audio'));
    await tester.pumpAndSettle();

    final captions = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data)
        .whereType<String>()
        .where((s) => s.startsWith('aud '))
        .toList();
    expect(captions, [
      'aud gatto 1',
      'aud cane 1',
      'aud cane 2',
    ]);
  });

  test('audio results dedupe by url and normalized title', () {
    final cleaned = ResultList(AttachmentType.audio, [
      CommonsMedium(title: 'File:cane.ogg', url: 'u1'),
      CommonsMedium(title: 'File:Cane.ogg', url: 'u2'),
      CommonsMedium(title: 'File:dog.oga', url: 'u3'),
      CommonsMedium(title: 'File:cane.ogg', url: 'u1'),
    ]).clean().results;
    expect(cleaned.map((m) => m.url), ['u1', 'u3']);
  });

  test('image results dedupe by url only', () {
    final cleaned = ResultList(AttachmentType.image, [
      CommonsMedium(title: 'File:cat.jpg', url: 'u1'),
      CommonsMedium(title: 'File:cat.png', url: 'u2'),
      CommonsMedium(title: 'File:cat.jpg', url: 'u1'),
    ]).clean().results;
    expect(cleaned.map((m) => m.url), ['u1', 'u2']);
  });
}

String mediaQueryOf(WidgetTester tester, String hint) => find
    .byType(TextField, skipOffstage: false)
    .evaluate()
    .map((e) => e.widget as TextField)
    .singleWhere((f) => (f.decoration as InputDecoration).hintText == hint)
    .controller!
    .text;
