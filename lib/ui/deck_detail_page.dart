import 'package:material_ui/material_ui.dart';

import '../app.dart';
import '../domain/models.dart';
import '../services/audio_service.dart' as audio;
import '../services/offline_attachments.dart';
import 'study_session_page.dart';
import 'widgets/attachment_views.dart';
import 'widgets/card_form.dart';
import 'widgets/card_state_badge.dart';

class DeckDetailPage extends StatefulWidget {
  final String deckId;

  const DeckDetailPage({super.key, required this.deckId});

  @override
  State<DeckDetailPage> createState() => _DeckDetailPageState();
}

class _DeckDetailPageState extends State<DeckDetailPage> {
  String? _editingCardId;
  bool _downloading = false;
  int _downloadDone = 0;
  int _downloadTotal = 0;
  bool _cancelled = false;

  @override
  void dispose() {
    _cancelled = true;
    super.dispose();
  }

  Future<void> _toggleOffline(Deck deck) async {
    final next = !deck.keepAttachmentsOffline;
    await appDb.setKeepAttachmentsOffline(deck.id, next);
    if (!next) {
      _cancelled = true;
      await appDb.removeDeckBlobContent(deck.id);
    } else {
      _cancelled = false;
      final cards = await appDb.getCardsOfDecks([deck.id]);
      final pending = pendingCount(cards);
      if (pending > 0) {
        setState(() {
          _downloading = true;
          _downloadDone = 0;
          _downloadTotal = pending;
        });
        try {
          await downloadDeckAttachments(appDb, deck.id, () {
            if (mounted) setState(() => _downloadDone += 1);
          }, () => _cancelled);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Could not download attachments: $e')),
            );
          }
        } finally {
          if (mounted) setState(() => _downloading = false);
        }
      }
    }
  }

  Future<void> _renameDeck(Deck deck) async {
    final controller = TextEditingController(text: deck.name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename deck'),
        content: TextField(
          controller: controller,
          autofocus: true,
          onSubmitted: (v) => Navigator.of(context).pop(v),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Save')),
        ],
      ),
    );
    final trimmed = name?.trim();
    if (trimmed != null && trimmed.isNotEmpty && trimmed != deck.name) {
      await appDb.renameDeck(deck.id, trimmed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Deck>>(
      stream: appDb.watchDecks(),
      builder: (context, deckSnapshot) {
        final deck =
            deckSnapshot.data?.where((d) => d.id == widget.deckId).firstOrNull;
        return Scaffold(
          appBar: AppBar(
            title: InkWell(
              onTap: deck == null ? null : () => _renameDeck(deck),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deck?.name ?? '…',
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Decks',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            actions: [
              if (deck != null)
                Row(
                  children: [
                    Text(
                      'Save attachments',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    Switch(
                      value: deck.keepAttachmentsOffline,
                      onChanged: (_) => _toggleOffline(deck),
                    ),
                    IconButton(
                      tooltip:
                          'Downloads all Commons attachments, current and '
                          'future, so you can study without an internet '
                          'connection.',
                      icon: const Icon(Icons.info_outline, size: 20),
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Save attachments'),
                          content: const Text(
                            'Downloads all Commons attachments, current and '
                            'future, so you can study without an internet '
                            'connection.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          body: StreamBuilder<List<CardDoc>>(
            stream: appDb.watchCards(widget.deckId),
            builder: (context, cardSnapshot) {
              final cards = cardSnapshot.data ?? const <CardDoc>[];
              final editingCard =
                  cards.where((c) => c.id == _editingCardId).firstOrNull;
              final latestCard = cards.fold<CardDoc?>(null, (acc, c) =>
                  (acc == null || c.updatedAt > acc.updatedAt) ? c : acc);
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_downloading) ...[
                    LinearProgressIndicator(
                      value: _downloadTotal == 0
                          ? null
                          : _downloadDone / _downloadTotal,
                    ),
                    const SizedBox(height: 16),
                  ],
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            StudySessionPage(deckIds: [widget.deckId]),
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Study now'),
                  ),
                  const SizedBox(height: 16),
                  CardForm(
                    deckId: widget.deckId,
                    editingCard: editingCard,
                    latestCard: latestCard,
                    onDone: () =>
                        setState(() => _editingCardId = null),
                  ),
                  const SizedBox(height: 24),
                  Row(children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(cards.isEmpty
                          ? 'Cards'
                          : 'Cards · ${cards.length}'),
                    ),
                    const Expanded(child: Divider()),
                  ]),
                  const SizedBox(height: 8),
                  if (cards.isEmpty)
                    Text(
                      'No cards yet. Add one above.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    )
                  else
                    for (final card in cards)
                      _CardTile(
                        card: card,
                        selected: card.id == _editingCardId,
                        onTap: () => setState(() => _editingCardId =
                            _editingCardId == card.id ? null : card.id),
                        onDelete: () async {
                          await appDb.deleteCard(card.id);
                          if (_editingCardId == card.id) {
                            setState(() => _editingCardId = null);
                          }
                        },
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

class _CardTile extends StatelessWidget {
  final CardDoc card;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CardTile({
    required this.card,
    required this.selected,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      color: selected
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
          : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (card.frontAttachments
                        .any((a) => a.type == AttachmentType.image))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: AttachmentThumbnails(
                            attachments: card.frontAttachments),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            card.front,
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                        AttachmentAudioButtons(
                          attachments: card.frontAttachments,
                          onPlay: (i) => audio.playAudio(card.frontAttachments
                              .where((a) => a.type == AttachmentType.audio)
                              .toList()[i]
                              .src),
                        ),
                      ],
                    ),
                    if (card.backAttachments
                        .any((a) => a.type == AttachmentType.image))
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: AttachmentThumbnails(
                            attachments: card.backAttachments),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            card.back,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        AttachmentAudioButtons(
                          attachments: card.backAttachments,
                          onPlay: (i) => audio.playAudio(card.backAttachments
                              .where((a) => a.type == AttachmentType.audio)
                              .toList()[i]
                              .src),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CardStateBadge(state: card.state),
                  const SizedBox(height: 4),
                  Text(
                    'due ${DateTime.parse(card.due).toLocal().toString().substring(0, 16)}',
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
