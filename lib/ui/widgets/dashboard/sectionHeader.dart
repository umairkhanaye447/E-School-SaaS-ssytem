import 'package:eschool/ui/styles/appTokens.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/utils.dart';
import 'package:flutter/material.dart';

/// "▦ My Dashboard" / "📣 Latest Notice ... View All →"
///
/// [title] is a raw, already-translated string so callers stay free to compose
/// it; use [Utils.getTranslatedLabel] at the call site.
class SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTapAction;

  const SectionHeader({
    Key? key,
    required this.title,
    required this.icon,
    this.iconColor,
    this.onTapAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // The leading icon carries the section's own hue; the action link always
    // uses the brand colour, as in the reference design.
    final color = iconColor ?? Theme.of(context).colorScheme.primary;
    final actionColor = Theme.of(context).colorScheme.primary;

    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        if (onTapAction != null)
          GestureDetector(
            onTap: onTapAction,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  Utils.getTranslatedLabel(viewAllKey),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: actionColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(width: 3),
                Icon(Icons.arrow_forward_rounded, size: 15, color: actionColor),
              ],
            ),
          ),
      ],
    );
  }
}
