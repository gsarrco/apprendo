import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:apprendo/app.dart';
import 'package:apprendo/data/database.dart';
import 'package:apprendo/domain/models.dart';
import 'package:apprendo/ui/deck_index_page.dart';
import 'package:drift/native.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    setAppDatabaseForTesting(db);
  });

  tearDown(() async {
    await db.close();
  });

  Widget wrap(Widget child) =>
      MaterialApp(theme: ThemeData(useMaterial3: true), home: child);

  testWidgets('creates a deck through the dialog and shows it',
      (tester) async {
    await tester.pumpWidget(wrap(const DeckIndexPage()));
    await tester.pumpAndSettle();

    expect(find.text('No decks yet'), findsOneWidget);

    await tester.tap(find.text('New deck'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Italian Vocabulary');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('Italian Vocabulary'), findsOneWidget);
    final decks = await db.getDecksAll();
    expect(decks.single.name, 'Italian Vocabulary');
  });

  testWidgets('rejects an empty deck name', (tester) async {
    await tester.pumpWidget(wrap(const DeckIndexPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('New deck'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '  ');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('No decks yet'), findsOneWidget);
    expect(await db.getDecksAll(), isEmpty);
  });

  testWidgets('renders existing decks and study tags', (tester) async {
    await db.insertDeck(Deck(
      id: 'd1',
      name: 'Dutch Nouns',
      createdAt: 100,
    ));
    await db.insertStudyTag(StudyTag(
      id: 't1',
      name: 'Daily mix',
      deckIds: const ['d1'],
      createdAt: 200,
    ));
    await tester.pumpWidget(wrap(const DeckIndexPage()));
    await tester.pumpAndSettle();

    expect(find.text('Dutch Nouns'), findsOneWidget);
    expect(find.text('Daily mix'), findsOneWidget);
  });
}
