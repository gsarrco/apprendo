import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../app.dart';
import '../export/export_file.dart';

class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  bool _importing = false;
  String? _fileName;

  Future<void> _pickAndImport() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    final file = files.firstOrNull;
    if (file == null) return;
    setState(() {
      _importing = true;
      _fileName = file.name;
    });
    try {
      final text = String.fromCharCodes(await file.readAsBytes());
      final exportFile = parseExport(text);
      await restoreExport(appDb, exportFile);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Imported ${exportFile.decks.length} deck${exportFile.decks.length == 1 ? '' : 's'}',
            ),
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not import: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Select an Apprendo export file (.json) to restore its decks, '
                'cards, review history, and study tags. Existing data with '
                'the same IDs will be overwritten.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _importing ? null : _pickAndImport,
                icon: const Icon(Icons.upload),
                label: Text(_importing ? 'Importing…' : 'Choose export file'),
              ),
              if (_fileName != null) ...[
                const SizedBox(height: 12),
                Text(
                  _fileName!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
