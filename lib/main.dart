import 'package:material_ui/material_ui.dart';

import 'app.dart';
import 'seed/demo_data.dart';
import 'services/commons_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initCommonsUserAgent();
  final db = appDb;
  if (const bool.fromEnvironment('SEED_DEMO')) {
    seedDemoData(db).catchError((Object e) {
      debugPrint('demo seeding failed: $e');
    });
  }
  runApp(const ApprendoApp());
}
