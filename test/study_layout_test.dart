import 'dart:typed_data';

import 'package:apprendo/app.dart';
import 'package:apprendo/data/database.dart';
import 'package:apprendo/domain/models.dart';
import 'package:apprendo/ui/study_session_page.dart';
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

  testWidgets('audio button sits right after the card text', (tester) async {
    await db.insertDeck(Deck(id: 'd1', name: 'Italian', createdAt: 1));
    await db.insertCard(CardDoc(
      id: 'c1',
      deckId: 'd1',
      front: 'ciao',
      back: 'hello',
      frontAttachments: [
        CardAttachment(
          type: AttachmentType.audio,
          mimeType: 'audio/ogg',
          content: Uint8List.fromList([1, 2, 3]),
          createdAt: 1,
        ),
      ],
      due: DateTime.utc(2020).toIso8601String(),
      createdAt: 1,
      updatedAt: 1,
    ));

    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const StudySessionPage(deckIds: ['d1']),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final text = find.text('ciao');
    expect(text, findsOneWidget);
    expect(tester.getSize(text).width, lessThan(120));

    final textRight = tester.getTopRight(text).dx;
    final iconLeft =
        tester.getTopLeft(find.byIcon(Icons.volume_up_outlined)).dx;
    expect(iconLeft - textRight, lessThan(32));
  });
}
