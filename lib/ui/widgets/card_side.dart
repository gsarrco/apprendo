import 'package:material_ui/material_ui.dart';

import '../../domain/models.dart';
import '../../services/languages.dart';
import 'media_search.dart';

/// Editor tab of one card side; the same three media components are
/// available on both sides.
enum SideTab { text, pronunciation, image }

/// Everything one side of a card carries in the editor: its text, its
/// attachments, the tab to show and the default audio language.
@immutable
class CardSide {
  final String text;
  final List<CardAttachment> attachments;
  final SideTab tab;
  final Language? defaultLanguage;

  const CardSide({
    this.text = '',
    this.attachments = const [],
    this.tab = SideTab.text,
    this.defaultLanguage,
  });

  CardSide copyWith({
    String? text,
    List<CardAttachment>? attachments,
    SideTab? tab,
    Language? defaultLanguage,
  }) =>
      CardSide(
        text: text ?? this.text,
        attachments: attachments ?? this.attachments,
        tab: tab ?? this.tab,
        defaultLanguage: defaultLanguage ?? this.defaultLanguage,
      );

  /// Tab to open for a new side, matching what the template side holds.
  static SideTab tabOf(List<CardAttachment> attachments) {
    if (attachments.any((x) => x.type == AttachmentType.image)) {
      return SideTab.image;
    }
    if (attachments.any((x) => x.type == AttachmentType.audio)) {
      return SideTab.pronunciation;
    }
    return SideTab.text;
  }

  CardSide withAttachments(List<CardAttachment> value) => copyWith(
        attachments: value,
        defaultLanguage: lastAudioLanguage(value) ?? defaultLanguage,
      );

  bool get isEmpty => text.trim().isEmpty && attachments.isEmpty;
}

/// Text / pronunciation / image editor for one card side.
class CardSideEditor extends StatelessWidget {
  final String heading;
  final TextEditingController text;
  final CardSide side;
  final ValueChanged<SideTab> onTabChange;
  final ValueChanged<List<CardAttachment>> onAttachmentsChange;

  const CardSideEditor({
    super.key,
    required this.heading,
    required this.text,
    required this.side,
    required this.onTabChange,
    required this.onAttachmentsChange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(heading,
            style:
                theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        SegmentedButton<SideTab>(
          segments: const [
            ButtonSegment(
              value: SideTab.text,
              label: Text('Text'),
              icon: Icon(Icons.text_fields, size: 16),
            ),
            ButtonSegment(
              value: SideTab.pronunciation,
              label: Text('Audio'),
              icon: Icon(Icons.graphic_eq, size: 16),
            ),
            ButtonSegment(
              value: SideTab.image,
              label: Text('Image'),
              icon: Icon(Icons.image_outlined, size: 16),
            ),
          ],
          selected: {side.tab},
          onSelectionChanged: (s) => onTabChange(s.first),
          showSelectedIcon: false,
        ),
        const SizedBox(height: 8),
        switch (side.tab) {
          SideTab.text => TextField(
              controller: text,
              minLines: 2,
              maxLines: 5,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: heading,
              ),
            ),
          SideTab.pronunciation => MediaSearch(
              type: AttachmentType.audio,
              defaultLanguage: side.defaultLanguage,
              selected: side.attachments,
              onChange: onAttachmentsChange,
            ),
          SideTab.image => MediaSearch(
              type: AttachmentType.image,
              defaultLanguage: null,
              selected: side.attachments,
              onChange: onAttachmentsChange,
            ),
        },
      ],
    );
  }
}
