import 'package:material_ui/material_ui.dart';

const List<String> _stateLabels = ['New', 'Learning', 'Review', 'Relearning'];

const List<Color> _stateColors = [
  Color(0xFF71717A), // zinc
  Color(0xFFF59E0B), // amber
  Color(0xFF10B981), // emerald
  Color(0xFFEF4444), // red
];

class CardStateBadge extends StatelessWidget {
  final int state;
  final bool expanded;

  const CardStateBadge({super.key, required this.state, this.expanded = false});

  @override
  Widget build(BuildContext context) {
    final i = state >= 0 && state < _stateLabels.length ? state : 0;
    final color = _stateColors[i];
    return Container(
      padding: expanded
          ? const EdgeInsets.symmetric(horizontal: 10, vertical: 4)
          : const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: ShapeDecoration(
        shape: const StadiumBorder(
          side: BorderSide(color: Color(0x66000000), width: 0.5),
        ),
        color: color.withValues(alpha: 0.12),
      ),
      child: Text(
        _stateLabels[i],
        style: TextStyle(
          color: color,
          fontSize: expanded ? 11 : 10,
          fontWeight: FontWeight.w600,
          letterSpacing: expanded ? 0.5 : 0,
        ),
      ),
    );
  }
}
