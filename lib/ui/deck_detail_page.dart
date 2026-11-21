import 'package:material_ui/material_ui.dart';

import '../app.dart';
import '../domain/models.dart';
import '../services/audio_service.dart' as audio;
import '../services/languages.dart';
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
              child: Text(
                deck?.name ?? '',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          body: StreamBuilder<List<CardDoc>>(
            stream: appDb.watchCards(widget.deckId),
            builder: (context, cardSnapshot) {
              final cards = cardSnapshot.data ?? const <CardDoc>[];
              final editingCard =
                  cards.where((c) => c.id == _editingCardId).firstOrNull;
              final latestCard = cards.fold<CardDoc?>(null, (acc, c) =>
                  (acc == null || c.updatedAt > acc.updatedAt) ? c : acc);
              final frontDefaultLanguage =
                  lastAudioLanguage(cards.expand((c) => c.frontAttachments));
              final backDefaultLanguage =
                  lastAudioLanguage(cards.expand((c) => c.backAttachments));
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
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
                    key: ValueKey('card-form-${editingCard?.id ?? 'new'}'),
                    deckId: widget.deckId,
                    editingCard: editingCard,
                    latestCard: latestCard,
                    frontDefaultLanguage: frontDefaultLanguage,
                    backDefaultLanguage: backDefaultLanguage,
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
                        Flexible(
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
                              .dataUrl),
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
                        Flexible(
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
                              .dataUrl),
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
