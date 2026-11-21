import 'package:apprendo/app.dart';
import 'package:apprendo/data/database.dart';
import 'package:apprendo/domain/models.dart';
import 'package:apprendo/services/languages.dart';
import 'package:apprendo/ui/deck_detail_page.dart';
import 'package:apprendo/ui/widgets/card_form.dart';
import 'package:apprendo/ui/widgets/media_search.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    setAppDatabaseForTesting(db);
  });

  tearDown(() async {
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
}
