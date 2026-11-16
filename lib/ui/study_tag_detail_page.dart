import 'package:material_ui/material_ui.dart';

import '../app.dart';
import '../domain/models.dart';

class StudyTagDetailPage extends StatefulWidget {
  final String studyTagId;

  const StudyTagDetailPage({super.key, required this.studyTagId});

  @override
  State<StudyTagDetailPage> createState() => _StudyTagDetailPageState();
}

class _StudyTagDetailPageState extends State<StudyTagDetailPage> {
  late final TextEditingController _name;
  String? _lastSavedName;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _saveName(String value) async {
    await appDb.renameStudyTag(widget.studyTagId, value.trim());
  }

  Future<void> _toggleDeck(StudyTag tag, String deckId) async {
    final next = tag.deckIds.contains(deckId)
        ? tag.deckIds.where((id) => id != deckId).toList()
        : [...tag.deckIds, deckId];
    await appDb.setStudyTagDecks(tag.id, next);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Study tag')),
      body: StreamBuilder<List<StudyTag>>(
        stream: appDb.watchStudyTags(),
        builder: (context, tagSnapshot) {
          final tag = tagSnapshot.data
              ?.where((t) => t.id == widget.studyTagId)
              .firstOrNull;
          if (tag == null) {
            return const Center(child: Text('Study tag not found.'));
          }
          if (_lastSavedName != tag.id) {
            _lastSavedName = tag.id;
            _name.text = tag.name;
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Changes are saved automatically.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                  hintText: 'Study tag name…',
                ),
                onChanged: (v) => _saveName(v),
              ),
              const SizedBox(height: 16),
              Text('Decks',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              StreamBuilder<List<Deck>>(
                stream: appDb.watchDecks(),
                builder: (context, deckSnapshot) {
                  final decks = deckSnapshot.data ?? const <Deck>[];
                  if (decks.isEmpty) {
                    return Text(
                      'No decks yet. Create one first.',
                      style: Theme.of(context).textTheme.bodySmall,
                    );
                  }
                  return Column(
                    children: [
                      for (final deck in decks)
                        Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: CheckboxListTile(
                            value: tag.deckIds.contains(deck.id),
                            title: Text(deck.name),
                            onChanged: (_) => _toggleDeck(tag, deck.id),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
