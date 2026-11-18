import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../data/database.dart';
import '../../domain/models.dart';
import '../../fsrs/fsrs.dart';
import '../../app.dart';
import '../../fsrs/mappers.dart';
import '../../services/languages.dart';
import 'media_search.dart';

enum _SideTab { text, pronunciation, image }

enum _Step { front, back }

/// Add/edit card form. Each side mixes text, pronunciation audio and
/// images; new cards inherit the tab and language of the deck's most
/// recent card, exactly like the original app.
class CardForm extends StatefulWidget {
  final String deckId;
  final CardDoc? editingCard;
  final CardDoc? latestCard;
  final VoidCallback? onDone;

  const CardForm({
    super.key,
    required this.deckId,
    this.editingCard,
    this.latestCard,
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
  List<CardAttachment> _frontAttachments = [];
  List<CardAttachment> _backAttachments = [];
  bool _busy = false;

  _SideTab _frontDefaultTab = _SideTab.text;
  _SideTab _backDefaultTab = _SideTab.text;
  Language? _frontDefaultLanguage;
  Language? _backDefaultLanguage;

  @override
  void initState() {
    super.initState();
    _front = TextEditingController(text: widget.editingCard?.front ?? '');
    _back = TextEditingController(text: widget.editingCard?.back ?? '');
    final template = widget.editingCard ?? widget.latestCard;
    if (widget.editingCard != null) {
      _frontAttachments = widget.editingCard!.frontAttachments;
      _backAttachments = widget.editingCard!.backAttachments;
    }
    if (template != null) {
      _frontDefaultTab = _defaultTab(template.frontAttachments);
      _backDefaultTab = _defaultTab(template.backAttachments);
      _frontDefaultLanguage = _audioLanguage(template.frontAttachments);
      _backDefaultLanguage = _audioLanguage(template.backAttachments);
    }
  }

  @override
  void dispose() {
    _front.dispose();
    _back.dispose();
    super.dispose();
  }

  static _SideTab _defaultTab(List<CardAttachment> a) {
    if (a.any((x) => x.type == AttachmentType.image)) return _SideTab.image;
    if (a.any((x) => x.type == AttachmentType.audio)) {
      return _SideTab.pronunciation;
    }
    return _SideTab.text;
  }

  static Language? _audioLanguage(List<CardAttachment> a) {
    final qid = a
        .where((x) => x.type == AttachmentType.audio)
        .map((x) => x.languageQid)
        .firstWhere((q) => q != null, orElse: () => null);
    return qid == null ? null : kLanguageByQid[qid];
  }

  Future<void> _submit() async {
    final f = _front.text.trim();
    final b = _back.text.trim();
    final hasFront = f.isNotEmpty || _frontAttachments.isNotEmpty;
    final hasBack = b.isNotEmpty || _backAttachments.isNotEmpty;
    if (!hasFront || !hasBack) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(!hasFront
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
          front: f,
          back: b,
          frontAttachments: _frontAttachments,
          backAttachments: _backAttachments,
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
          front: f,
          back: b,
          frontAttachments: _frontAttachments,
          backAttachments: _backAttachments,
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
    _frontAttachments = [];
    _backAttachments = [];
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
        if (editing)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Edit card #${widget.editingCard!.id.length >= 4 ? widget.editingCard!.id.substring(widget.editingCard!.id.length - 4) : widget.editingCard!.id}',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        if (!editing)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'New card',
              style: Theme.of(context).textTheme.titleMedium
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
            child: switch (_step) {
              _Step.front => _frontStep(editing),
              _Step.back => _backStep(editing),
            },
          ),
        ),
      ],
    );
  }

  Widget _frontStep(bool editing) => Column(
        key: const ValueKey(_Step.front),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardSideEditor(
            key: const ValueKey('front-editor'),
            heading: 'Front',
            text: _front,
            attachments: _frontAttachments,
            onAttachmentsChange: (v) => setState(() => _frontAttachments = v),
            defaultTab: _frontDefaultTab,
            defaultLanguage: _frontDefaultLanguage,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: _busy ? null : () => _goTo(_Step.back),
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('Back'),
              ),
              if (editing) _cancelButton(),
            ],
          ),
        ],
      );

  Widget _backStep(bool editing) => Column(
        key: const ValueKey(_Step.back),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardSideEditor(
            key: const ValueKey('back-editor'),
            heading: 'Back',
            text: _back,
            attachments: _backAttachments,
            onAttachmentsChange: (v) => setState(() => _backAttachments = v),
            defaultTab: _backDefaultTab,
            defaultLanguage: _backDefaultLanguage,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
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
              if (editing) _cancelButton(),
            ],
          ),
        ],
      );

  Widget _cancelButton() => OutlinedButton(
        onPressed: () {
          _reset();
          widget.onDone?.call();
        },
        child: const Text('Cancel'),
      );
}

class _CardSideEditor extends StatefulWidget {
  final String heading;
  final TextEditingController text;
  final List<CardAttachment> attachments;
  final ValueChanged<List<CardAttachment>> onAttachmentsChange;
  final _SideTab defaultTab;
  final Language? defaultLanguage;

  const _CardSideEditor({
    super.key,
    required this.heading,
    required this.text,
    required this.attachments,
    required this.onAttachmentsChange,
    required this.defaultTab,
    this.defaultLanguage,
  });

  @override
  State<_CardSideEditor> createState() => _CardSideEditorState();
}

class _CardSideEditorState extends State<_CardSideEditor> {
  late _SideTab _tab;

  @override
  void initState() {
    super.initState();
    _tab = widget.defaultTab;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.heading,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        SegmentedButton<_SideTab>(
          segments: const [
            ButtonSegment(
              value: _SideTab.text,
              label: Text('Text'),
              icon: Icon(Icons.text_fields, size: 16),
            ),
            ButtonSegment(
              value: _SideTab.pronunciation,
              label: Text('Audio'),
              icon: Icon(Icons.graphic_eq, size: 16),
            ),
            ButtonSegment(
              value: _SideTab.image,
              label: Text('Image'),
              icon: Icon(Icons.image_outlined, size: 16),
            ),
          ],
          selected: {_tab},
          onSelectionChanged: (s) => setState(() => _tab = s.first),
          showSelectedIcon: false,
        ),
        const SizedBox(height: 8),
        switch (_tab) {
          _SideTab.text => TextField(
              controller: widget.text,
              minLines: 2,
              maxLines: 5,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: widget.heading,
              ),
            ),
          _SideTab.pronunciation => MediaSearch(
              type: AttachmentType.audio,
              defaultLanguage: widget.defaultLanguage,
              selected: widget.attachments,
              onChange: widget.onAttachmentsChange,
            ),
          _SideTab.image => MediaSearch(
              type: AttachmentType.image,
              defaultLanguage: null,
              selected: widget.attachments,
              onChange: widget.onAttachmentsChange,
            ),
        },
      ],
    );
  }
}
