import 'package:material_ui/material_ui.dart';

import '../app.dart';
import '../data/database.dart';
import '../domain/models.dart';
import 'deck_detail_page.dart';
import 'study_session_page.dart';
import 'study_tag_detail_page.dart';

class DeckIndexPage extends StatelessWidget {
  const DeckIndexPage({super.key});

  Future<void> _createDeck(BuildContext context) async {
    final name = await _promptText(
      context,
      title: 'New deck',
      hint: 'New deck name…',
    );
    if (name == null || name.trim().isEmpty) return;
    try {
      await appDb.insertDeck(Deck(
        id: newId(),
        name: name.trim(),
        keepAttachmentsOffline: false,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not create deck: $e')));
      }
    }
  }

  Future<void> _createStudyTag(BuildContext context) async {
    final tag = StudyTag(
      id: newId(),
      name: '',
      deckIds: const [],
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    try {
      await appDb.insertStudyTag(tag);
      if (context.mounted) {
        await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => StudyTagDetailPage(studyTagId: tag.id),
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not create study tag: $e')),
        );
      }
    }
  }

  Future<String?> _promptText(
    BuildContext context, {
    required String title,
    required String hint,
    String initial = '',
  }) {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: hint),
          onSubmitted: (v) => Navigator.of(context).pop(v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apprendo'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) =>
                Navigator.of(context).pushNamed(value),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: '/export',
                child: ListTile(
                  leading: Icon(Icons.download),
                  title: Text('Export'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: '/import',
                child: ListTile(
                  leading: Icon(Icons.upload),
                  title: Text('Import'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Create decks of flashcards and study them on a spaced-repetition '
            'schedule. Group some decks into study tags to study all of them '
            'at once.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _createDeck(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New deck'),
              ),
              OutlinedButton.icon(
                onPressed: () => _createStudyTag(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New study tag'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _StudyTagCarousel(),
          const _DeckList(),
        ],
      ),
    );
  }
}

class _StudyTagCarousel extends StatelessWidget {
  const _StudyTagCarousel();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<StudyTag>>(
      stream: appDb.watchStudyTags(),
      builder: (context, snapshot) {
        final tags = snapshot.data ?? const <StudyTag>[];
        if (tags.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: tags.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final tag = tags[i];
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => StudySessionPage(
                          deckIds: tag.deckIds,
                          studyTagName: tag.name,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: Text(
                      tag.name.isEmpty ? 'Untitled study tag' : tag.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Edit study tag',
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            StudyTagDetailPage(studyTagId: tag.id),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _DeckList extends StatefulWidget {
  const _DeckList();

  @override
  State<_DeckList> createState() => _DeckListState();
}

class _DeckListState extends State<_DeckList> {
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Deck>>(
      stream: appDb.watchDecks(),
      builder: (context, snapshot) {
        final decks = snapshot.data ?? const <Deck>[];
        if (decks.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 48),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).dividerColor,
              ),
            ),
            child: Column(
              children: [
                Text('No decks yet',
                    style: Theme.of(context).textTheme.titleSmall),
                Text(
                  'Create one above to get started.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        }
        return Column(
          children: [
            if (_selected.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_selected.length} selected',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    if (_selected.length == 1)
                      FilledButton(
                        onPressed: () {
                          final deckId = _selected.first;
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => StudySessionPage(deckIds: [deckId]),
                          ));
                        },
                        child: const Text('Study now'),
                      ),
                    const SizedBox(width: 8),
                    FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.error,
                      ),
                      onPressed: () => _deleteSelected(context, decks),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ),
            for (final deck in decks)
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => DeckDetailPage(deckId: deck.id),
                  )),
                  title: Text(deck.name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    'Created ${DateTime.fromMillisecondsSinceEpoch(deck.createdAt).toLocal().toString().split(' ').first}',
                  ),
                  leading: Checkbox(
                    value: _selected.contains(deck.id),
                    onChanged: (v) => setState(() {
                      if (v == true) {
                        _selected.add(deck.id);
                      } else {
                        _selected.remove(deck.id);
                      }
                    }),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _deleteSelected(BuildContext context, List<Deck> decks) async {
    final count = _selected.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $count deck${count == 1 ? '' : 's'}?'),
        content: Text(
            'This will delete $count deck${count == 1 ? '' : 's'} and all their cards.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await appDb.deleteDecks(_selected.toList());
      setState(() => _selected.clear());
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete: $e')),
        );
      }
    }
  }
}
