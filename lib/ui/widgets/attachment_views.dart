import 'dart:convert';

import 'package:material_ui/material_ui.dart';

import '../../domain/models.dart';

/// Renders any attachment source: base64 data URLs, or http(s) URLs.
class AttachmentImage extends StatelessWidget {
  final CardAttachment attachment;
  final double? width;
  final double? height;
  final BoxFit fit;

  const AttachmentImage({
    super.key,
    required this.attachment,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final src = attachment.src;
    ImageProvider provider;
    if (src.startsWith('data:')) {
      final comma = src.indexOf(',');
      final payload = src.substring(comma + 1);
      provider = MemoryImage(base64Decode(payload));
    } else if (src.startsWith('http')) {
      provider = NetworkImage(src);
    } else {
      return const SizedBox.shrink();
    }
    return Image(
      image: provider,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, _, _) => const SizedBox.shrink(),
    );
  }
}

/// Up to four image thumbnails plus a "+N" overflow tile.
class AttachmentThumbnails extends StatelessWidget {
  final List<CardAttachment> attachments;

  const AttachmentThumbnails({super.key, required this.attachments});

  @override
  Widget build(BuildContext context) {
    final images = attachments.where((a) => a.type == AttachmentType.image).toList();
    if (images.isEmpty) return const SizedBox.shrink();
    final shown = images.take(4).toList();
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final image in shown)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AttachmentImage(attachment: image, width: 48, height: 48),
          ),
        if (images.length > 4)
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: Text(
              '+${images.length - 4}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}

/// Large image grid used while studying.
class AttachmentImageGrid extends StatelessWidget {
  final List<CardAttachment> attachments;

  const AttachmentImageGrid({super.key, required this.attachments});

  @override
  Widget build(BuildContext context) {
    final images = attachments.where((a) => a.type == AttachmentType.image).toList();
    if (images.isEmpty) return const SizedBox.shrink();
    return GridView.count(
      crossAxisCount: images.length >= 3 ? 3 : 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1,
      children: [
        for (final image in images)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AttachmentImage(
              attachment: image,
              fit: BoxFit.contain,
            ),
          ),
      ],
    );
  }
}

/// One play button per audio attachment.
class AttachmentAudioButtons extends StatelessWidget {
  final List<CardAttachment> attachments;
  final void Function(int index) onPlay;

  const AttachmentAudioButtons({
    super.key,
    required this.attachments,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final audio = attachments.where((a) => a.type == AttachmentType.audio).toList();
    if (audio.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (i, _) in audio.indexed)
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Play audio ${i + 1}',
            onPressed: () => onPlay(i),
            icon: const Icon(Icons.volume_up_outlined),
          ),
      ],
    );
  }
}

/// Tiny attribution lines under a card side.
class AttachmentAttributions extends StatelessWidget {
  final List<CardAttachment> attachments;

  const AttachmentAttributions({super.key, required this.attachments});

  @override
  Widget build(BuildContext context) {
    final withAttr =
        attachments.where((a) => (a.attribution ?? '').isNotEmpty).toList();
    if (withAttr.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final a in withAttr)
          Text(
            a.attribution!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
      ],
    );
  }
}
