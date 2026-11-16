import 'package:material_ui/material_ui.dart';

import 'data/database.dart';
import 'ui/deck_index_page.dart';
import 'ui/export_page.dart';
import 'ui/import_page.dart';

AppDatabase? _db;

/// The single app-wide database instance (lazily opened).
AppDatabase get appDb => _db ??= AppDatabase.open();

/// Replaces the app-wide database with [db] in tests.
@visibleForTesting
void setAppDatabaseForTesting(AppDatabase db) => _db = db;

class ApprendoApp extends StatelessWidget {
  const ApprendoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apprendo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      routes: {
        '/': (context) => const DeckIndexPage(),
        '/export': (context) => const ExportPage(),
        '/import': (context) => const ImportPage(),
      },
    );
  }
}
