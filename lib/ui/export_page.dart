import 'dart:io' as io;

import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../app.dart';
import '../export/export_file.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  final Set<String> _selected = {};
  bool _includeReviewLogs = true;
  bool _exporting = false;

  Future<void> _export() async {
    if (_selected.isEmpty) return;
    setState(() => _exporting = true);
    try {
      final file = await buildExport(appDb, _selected.toList(),
          includeReviewLogs: _includeReviewLogs);
      final date = DateTime.fromMillisecondsSinceEpoch(file.exportedAt)
          .toIso8601String()
          .substring(0, 10);
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/apprendo-export-$date.json';
      await io.File(path).writeAsString(file.encode());
      final result = await SharePlus.instance.share(
        ShareParams(
          files: [XFile(path, name: 'apprendo-export-$date.json')],
        ),
      );
      if (result.status == ShareResultStatus.success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export ready')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not export: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export')),
      body: StreamBuilder(
        stream: appDb.watchDecks(),
        builder: (context, snapshot) {
          final decks = snapshot.data ?? const [];
          final allSelected = decks.isNotEmpty && _selected.length == decks.length;
          if (decks.isEmpty) {
            return const Center(child: Text('No decks yet'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Select the decks you want to export. The export includes '
                'their cards, attachments, and any study tags that reference '
                'them.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: allSelected,
                title: const Text('Select all'),
                onChanged: (_) => setState(() {
                  _selected.clear();
                  if (!allSelected) {
                    _selected.addAll(decks.map((d) => d.id));
                  }
                }),
              ),
              for (final deck in decks)
                CheckboxListTile(
                  value: _selected.contains(deck.id),
                  title: Text(deck.name),
                  onChanged: (_) => setState(() {
                    if (_selected.contains(deck.id)) {
                      _selected.remove(deck.id);
                    } else {
                      _selected.add(deck.id);
                    }
                  }),
                ),
              SwitchListTile(
                value: _includeReviewLogs,
                title: const Text('Include review history'),
                onChanged: (v) => setState(() => _includeReviewLogs = v),
              ),
              Text(
                'Turn off to share a deck with other learners without your '
                'personal study progress.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _selected.isEmpty || _exporting ? null : _export,
                icon: const Icon(Icons.download),
                label: Text(
                  _exporting
                      ? 'Exporting…'
                      : 'Export ${_selected.length} deck${_selected.length == 1 ? '' : 's'}',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
