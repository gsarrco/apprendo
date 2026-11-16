import 'package:material_ui/material_ui.dart';

import 'app.dart';
import 'seed/demo_data.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final db = appDb;
  if (const bool.fromEnvironment('SEED_DEMO')) {
    seedDemoData(db).catchError((Object e) {
      debugPrint('demo seeding failed: $e');
    });
  }
  runApp(const ApprendoApp());
}
