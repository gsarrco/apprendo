import 'package:apprendo/app.dart';
import 'package:apprendo/data/database.dart';
import 'package:apprendo/ui/widgets/card_form.dart';
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
}
