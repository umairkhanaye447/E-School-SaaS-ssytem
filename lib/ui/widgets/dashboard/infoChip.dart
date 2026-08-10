import 'package:eschool/ui/styles/appTokens.dart';
import 'package:flutter/material.dart';

/// Pill used in the dashboard header for "Class: 8 (A)" and "Roll: 12".
///
/// Sizes itself to its content and ellipsises long values, so a long class
/// name cannot overflow the header row.
class InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final AccentPair accent;

  const InfoChip({
    Key? key,
    required this.icon,
    required this.label,
    required this.accent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.tint,
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: accent.icon),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: accent.icon,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
