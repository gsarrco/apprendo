import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../data/database.dart';
import '../../domain/models.dart';
import '../../fsrs/fsrs.dart';
import '../../app.dart';
import '../../fsrs/mappers.dart';
import '../../services/languages.dart';
import 'card_side.dart';

enum _Step { front, back }

/// Add/edit card form. Each side mixes text, pronunciation audio and
/// images; new cards inherit the tab and language of the deck's most
/// recent card, exactly like the original app.
class CardForm extends StatefulWidget {
  final String deckId;
  final CardDoc? editingCard;
  final CardDoc? latestCard;
  final Language? frontDefaultLanguage;
  final Language? backDefaultLanguage;
  final VoidCallback? onDone;

  const CardForm({
    super.key,
    required this.deckId,
    this.editingCard,
    this.latestCard,
    this.frontDefaultLanguage,
    this.backDefaultLanguage,
    this.onDone,
  });

  @override
  State<CardForm> createState() => _CardFormState();
}

class _CardFormState extends State<CardForm> {
  _Step _step = _Step.front;
  int _stepDirection = -1;
  late final TextEditingController _front;
  late final TextEditingController _back;
  CardSide _frontSide = const CardSide();
  CardSide _backSide = const CardSide();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final editing = widget.editingCard;
    _front = TextEditingController(text: editing?.front ?? '');
    _back = TextEditingController(text: editing?.back ?? '');
    final template = editing ?? widget.latestCard;
    _frontSide = CardSide(
      text: _front.text,
      attachments: editing?.frontAttachments ?? const [],
      tab: CardSide.tabOf(template?.frontAttachments ?? const []),
      defaultLanguage: editing != null
          ? lastAudioLanguage(editing.frontAttachments)
          : widget.frontDefaultLanguage,
    );
    _backSide = CardSide(
      text: _back.text,
      attachments: editing?.backAttachments ?? const [],
      tab: CardSide.tabOf(template?.backAttachments ?? const []),
      defaultLanguage: editing != null
          ? lastAudioLanguage(editing.backAttachments)
          : widget.backDefaultLanguage,
    );
  }

  @override
  void dispose() {
    _front.dispose();
    _back.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CardForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.editingCard != null) return;
    if (widget.frontDefaultLanguage != oldWidget.frontDefaultLanguage) {
      _frontSide = _frontSide.copyWith(
          defaultLanguage: widget.frontDefaultLanguage);
    }
    if (widget.backDefaultLanguage != oldWidget.backDefaultLanguage) {
      _backSide =
          _backSide.copyWith(defaultLanguage: widget.backDefaultLanguage);
    }
  }

  void _updateSide(_Step step, CardSide side) {
    setState(() {
      if (step == _Step.front) {
        _frontSide = side;
      } else {
        _backSide = side;
      }
    });
  }

  Future<void> _submit() async {
    final front = _frontSide.copyWith(text: _front.text.trim());
    final back = _backSide.copyWith(text: _back.text.trim());
    if (front.isEmpty || back.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(front.isEmpty
            ? 'Add at least one of text, pronunciation, or image on the front'
            : 'Add at least one of text, pronunciation, or image on the back'),
      ));
      return;
    }
    setState(() => _busy = true);
    try {
      final db = appDb;
      final now = DateTime.now().millisecondsSinceEpoch;
      final editing = widget.editingCard;
      if (editing != null) {
        await db.updateCardContent(CardDoc(
          id: editing.id,
          deckId: editing.deckId,
          front: front.text,
          back: back.text,
          frontAttachments: front.attachments,
          backAttachments: back.attachments,
          due: editing.due,
          stability: editing.stability,
          difficulty: editing.difficulty,
          elapsedDays: editing.elapsedDays,
          scheduledDays: editing.scheduledDays,
          learningSteps: editing.learningSteps,
          reps: editing.reps,
          lapses: editing.lapses,
          state: editing.state,
          lastReview: editing.lastReview,
          createdAt: editing.createdAt,
          updatedAt: now,
        ));
      } else {
        final fsrs = Fsrs();
        final empty = fsrs.createEmptyCard(DateTime.now());
        final base = CardDoc(
          id: newId(),
          deckId: widget.deckId,
          front: front.text,
          back: back.text,
          frontAttachments: front.attachments,
          backAttachments: back.attachments,
          due: toIsoUtc(empty.due),
          createdAt: now,
          updatedAt: now,
        );
        await db.insertCard(FsrsMappers.fromFsrsCard(empty, base, now));
      }
      _reset();
      widget.onDone?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save card: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _reset() {
    _front.clear();
    _back.clear();
    _frontSide = const CardSide();
    _backSide = const CardSide();
    _step = _Step.front;
    _stepDirection = -1;
  }

  void _goTo(_Step step) => setState(() {
        _stepDirection = step == _Step.back ? 1 : -1;
        _step = step;
      });

  @override
  Widget build(BuildContext context) {
    final editing = widget.editingCard != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            editing
                ? 'Edit card #${_shortId(widget.editingCard!.id)}'
                : 'New card',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeInOutCubic,
            switchOutCurve: Curves.easeInOutCubic,
            transitionBuilder: (child, animation) {
              final incoming = child.key == ValueKey(_step);
              final half = math.pi / 2;
              final progress =
                  incoming ? animation : ReverseAnimation(animation);
              final angle = Tween<double>(
                begin: incoming ? -_stepDirection * half : 0,
                end: incoming ? 0 : _stepDirection * half,
              ).animate(progress);
              return ClipRect(
                child: AnimatedBuilder(
                  animation: angle,
                  builder: (context, _) => Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.0015)
                      ..rotateY(angle.value),
                    alignment: Alignment.center,
                    child: child,
                  ),
                ),
              );
            },
            child: _stepPage(_step, editing),
          ),
        ),
      ],
    );
  }

  static String _shortId(String id) =>
      id.length >= 4 ? id.substring(id.length - 4) : id;

  Widget _stepPage(_Step step, bool editing) {
    final isFront = step == _Step.front;
    final heading = isFront ? 'Front' : 'Back';
    final side = isFront ? _frontSide : _backSide;
    return Column(
      key: ValueKey(step),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CardSideEditor(
          key: ValueKey('${heading.toLowerCase()}-editor'),
          heading: heading,
          text: isFront ? _front : _back,
          side: side,
          onTabChange: (tab) => _updateSide(step, side.copyWith(tab: tab)),
          onAttachmentsChange: (v) =>
              _updateSide(step, side.withAttachments(v)),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (isFront)
              FilledButton.icon(
                onPressed: _busy ? null : () => _goTo(_Step.back),
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('Back'),
              )
            else ...[
              OutlinedButton.icon(
                onPressed: _busy ? null : () => _goTo(_Step.front),
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Front'),
              ),
              FilledButton.icon(
                onPressed: _busy ? null : _submit,
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Done'),
              ),
            ],
            if (editing) _cancelButton(),
          ],
        ),
      ],
    );
  }

  Widget _cancelButton() => OutlinedButton(
        onPressed: () {
          _reset();
          widget.onDone?.call();
        },
        child: const Text('Cancel'),
      );
}
