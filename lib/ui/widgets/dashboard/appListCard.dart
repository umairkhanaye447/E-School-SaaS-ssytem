import 'package:eschool/ui/styles/appTokens.dart';
import 'package:flutter/material.dart';

/// The standard surface for a row in any list: white card, 16pt radius, one
/// soft shadow, screen-edge margins.
///
/// Every restyled screen builds its rows on this so spacing and elevation stay
/// identical app-wide.
class AppListCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  const AppListCard({
    Key? key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.sm),
    this.margin,
  }) : super(key: key);

  @override
  State<AppListCard> createState() => _AppListCardState();
}

class _AppListCardState extends State<AppListCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: widget.margin ??
          const EdgeInsets.only(
            left: AppSpacing.screenH,
            right: AppSpacing.screenH,
            bottom: AppSpacing.sm,
          ),
      padding: widget.padding,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardAll,
        boxShadow: AppShadows.card,
      ),
      child: widget.child,
    );

    if (widget.onTap == null) return card;

    //Same press dip as the grid tiles, so every tappable card in the app
    //responds identically.
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: card,
      ),
    );
  }
}

/// Tinted rounded-square icon well — the motif shared by the home grid,
/// notice rows, assignment rows and settings tiles.
class AppIconWell extends StatelessWidget {
  final IconData icon;
  final AccentPair accent;
  final double size;

  const AppIconWell({
    Key? key,
    required this.icon,
    required this.accent,
    this.size = 42,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: accent.tint,
        borderRadius: AppRadius.iconTileAll,
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: size * 0.5, color: accent.icon),
    );
  }
}

/// Small tinted pill used for statuses and metric pairs ("Grade A", "82.5%").
class AppStatChip extends StatelessWidget {
  final String label;
  final AccentPair accent;
  final IconData? icon;

  const AppStatChip({
    Key? key,
    required this.label,
    required this.accent,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: accent.tint,
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: accent.icon),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: accent.icon,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
