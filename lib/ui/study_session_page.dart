import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../app.dart';
import '../data/database.dart';
import '../domain/models.dart';
import '../fsrs/fsrs.dart';
import '../fsrs/mappers.dart';
import '../services/audio_service.dart' as audio;
import '../services/format.dart';
import 'widgets/attachment_views.dart';
import 'widgets/card_state_badge.dart';
import 'widgets/rating_buttons.dart';

const Duration _learnAhead = Duration(seconds: 30);

class _SessionEntry {
  final CardDoc card;
  final DateTime due;

  const _SessionEntry({required this.card, required this.due});
}

/// The study session: shows cards that are due, reveals the answer, and
/// applies FSRS ratings. A card leaves the session once it reaches the
/// Review state; learning cards stay until they graduate.
class StudySessionPage extends StatefulWidget {
  final List<String> deckIds;
  final String? studyTagName;

  const StudySessionPage({super.key, required this.deckIds, this.studyTagName});

  @override
  State<StudySessionPage> createState() => _StudySessionPageState();
}

class _StudySessionPageState extends State<StudySessionPage> {
  final Fsrs _fsrs = Fsrs();
  List<_SessionEntry> _session = [];
  int _initialCount = 0;
  bool _loaded = false;
  bool _showBack = false;
  bool _busy = false;
  DateTime _now = DateTime.now();
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _seed();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _seed() async {
    if (widget.deckIds.isEmpty) return;
    final cards = await appDb.getCardsOfDecks(widget.deckIds);
    final now = DateTime.now();
    final due = cards.where((c) => !c.dueDate.isAfter(now)).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    if (!mounted) return;
    setState(() {
      _session = [
        for (final card in due) _SessionEntry(card: card, due: card.dueDate)
      ];
      _initialCount = _session.length;
      _loaded = true;
    });
    _startTicker();
  }

  void _startTicker() {
    _ticker?.cancel();
    if (_session.isEmpty) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  List<_SessionEntry> get _ready {
    final horizon = _now.add(_learnAhead);
    return _session.where((e) => !e.due.isAfter(horizon)).toList()
      ..sort((a, b) => a.due.compareTo(b.due));
  }

  List<_SessionEntry> get _pending {
    final horizon = _now.add(_learnAhead);
    return _session.where((e) => e.due.isAfter(horizon)).toList()
      ..sort((a, b) => a.due.compareTo(b.due));
  }

  Map<Rating, String> _previews(CardDoc card) {
    final fsrsCard = FsrsMappers.toFsrsCard(card);
    final now = DateTime.now();
    final out = <Rating, String>{};
    for (final rating in Rating.values) {
      try {
        final res = _fsrs.next(fsrsCard, now, rating);
        out[rating] = formatInterval(
            res.card.due.difference(now).inMilliseconds);
      } catch (_) {
        out[rating] = '';
      }
    }
    return out;
  }

  Future<void> _rate(Rating rating) async {
    final entry = _ready.firstOrNull;
    if (entry == null || _busy) return;
    setState(() => _busy = true);
    try {
      final cardDoc = entry.card;
      final fsrsCard = FsrsMappers.toFsrsCard(cardDoc);
      final now = DateTime.now();
      final result = _fsrs.next(fsrsCard, now, rating);
      final updated = FsrsMappers.fromFsrsCard(
        result.card,
        cardDoc,
        now.millisecondsSinceEpoch,
      );
      await appDb.applyReview(updated);
      await appDb.insertReviewLog(
          FsrsMappers.fromFsrsLog(result.log, newId(), cardDoc.id));
      if (!mounted) return;
      setState(() {
        final idx = _session.indexWhere((e) => e.card.id == cardDoc.id);
        if (idx != -1) {
          if (result.card.state == FsrsState.review) {
            _session.removeAt(idx);
          } else {
            _session[idx] = _SessionEntry(card: updated, due: result.card.due);
          }
        }
        _showBack = false;
        _now = DateTime.now();
      });
      _startTicker();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save review: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final ready = _ready;
    final pending = _pending;
    final current = ready.firstOrNull?.card;
    final nextDueAt = pending.firstOrNull?.due;
    final total = _initialCount == 0 ? 1 : _initialCount;
    final progress = (_initialCount - _session.length) / total;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.studyTagName == null
            ? 'Study'
            : 'Study · ${widget.studyTagName}'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_session.length} card${_session.length == 1 ? '' : 's'} remaining',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Exit'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 16),
              if (current == null && pending.isNotEmpty) ...[
                _waitPanel(context, nextDueAt!, pending.length),
              ] else if (current == null) ...[
                _donePanel(context),
              ] else ...[
                Expanded(
                  child: SingleChildScrollView(
                    child: _cardPanel(context, current),
                  ),
                ),
                if (_showBack)
                  RatingButtons(
                    previews: _previews(current),
                    onRate: _rate,
                    disabled: _busy,
                  )
                else
                  FilledButton(
                    onPressed: _busy ? null : () => setState(() => _showBack = true),
                    child: const Text('Show answer'),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardPanel(BuildContext context, CardDoc card) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              children: [
                CardStateBadge(state: card.state, expanded: true),
                FutureBuilder<Deck?>(
                  future: appDb.getDeck(card.deckId),
                  builder: (context, snapshot) {
                    final name = snapshot.data?.name;
                    if (name == null) return const SizedBox.shrink();
                    final label = widget.studyTagName != null
                        ? '${widget.studyTagName}: $name'
                        : name;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            AttachmentImageGrid(attachments: card.frontAttachments),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    card.front,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                AttachmentAudioButtons(
                  attachments: card.frontAttachments,
                  onPlay: (i) {
                    if (!_showBack) return;
                    audio.playAudio(card.frontAttachments
                        .where((a) => a.type == AttachmentType.audio)
                        .toList()[i]
                        .dataUrl);
                  },
                ),
              ],
            ),
            AttachmentAttributions(attachments: card.frontAttachments),
            if (_showBack) ...[
              const Divider(height: 24),
              AttachmentImageGrid(attachments: card.backAttachments),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      card.back,
                      style: theme.textTheme.bodyLarge?.copyWith(
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
              AttachmentAttributions(attachments: card.backAttachments),
            ],
          ],
        ),
      ),
    );
  }

  Widget _waitPanel(BuildContext context, DateTime nextDueAt, int pendingCount) {
    final waitMs = nextDueAt.difference(_now).inMilliseconds.clamp(0, 1 << 62);
    return Expanded(
      child: Center(
        child: Card(
          color: Theme.of(context).colorScheme.tertiaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.schedule, size: 48),
                const SizedBox(height: 12),
                Text(
                  'Come back in ${formatInterval(waitMs)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '$pendingCount card${pendingCount == 1 ? '' : 's'} still learning.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _donePanel(BuildContext context) {
    return Expanded(
      child: Center(
        child: Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, size: 48),
                const SizedBox(height: 12),
                Text(
                  'All done!',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Text('No more due cards.'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
