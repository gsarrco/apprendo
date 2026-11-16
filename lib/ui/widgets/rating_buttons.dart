import 'package:material_ui/material_ui.dart';

import '../../fsrs/fsrs.dart';

class RatingButtons extends StatelessWidget {
  final Map<Rating, String> previews;
  final void Function(Rating rating) onRate;
  final bool disabled;

  const RatingButtons({
    super.key,
    required this.previews,
    required this.onRate,
    this.disabled = false,
  });

  static const _labels = {
    Rating.again: 'Again',
    Rating.hard: 'Hard',
    Rating.good: 'Good',
    Rating.easy: 'Easy',
  };

  static const _colors = {
    Rating.again: Color(0xFFEF4444),
    Rating.hard: Color(0xFFF59E0B),
    Rating.good: Color(0xFF10B981),
    Rating.easy: Color(0xFF6366F1),
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            for (final rating in [Rating.again, Rating.hard])
              Expanded(child: _button(context, rating)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final rating in [Rating.good, Rating.easy])
              Expanded(child: _button(context, rating)),
          ],
        ),
      ],
    );
  }

  Widget _button(BuildContext context, Rating rating) {
    final color = _colors[rating]!;
    final preview = previews[rating] ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilledButton.tonal(
        onPressed: disabled ? null : () => onRate(rating),
        style: FilledButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.12),
          foregroundColor: color,
          disabledBackgroundColor: color.withValues(alpha: 0.06),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _labels[rating]!,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              if (preview.isNotEmpty)
                Text(preview, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
