import 'package:eschool/ui/styles/appTokens.dart';
import 'package:eschool/utils/animationConfiguration.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';

/// An uppercase group caption above a [GroupedListCard], e.g. "ACCOUNT &
/// SECURITY".
class GroupCaption extends StatelessWidget {
  final String title;

  const GroupCaption({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: AppSpacing.xxs,
        bottom: AppSpacing.xs,
      ),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}

/// A white card holding a vertical run of [GroupedListRow]s separated by
/// hairline dividers that start past the icon well.
///
/// Callers may pass `null` children so a conditionally-visible row can be
/// written inline; nulls are dropped before dividers are inserted, which keeps
/// a trailing divider from appearing when the last row is hidden.
class GroupedListCard extends StatelessWidget {
  final List<Widget?> children;

  /// Position of this group on the screen, used to stagger its arrival.
  final int groupIndex;

  const GroupedListCard({
    Key? key,
    required this.children,
    this.groupIndex = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rows = children.whereType<Widget>().toList();
    if (rows.isEmpty) return const SizedBox();

    return Animate(
      effects: gridItemAppearanceEffects(itemIndex: groupIndex),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.cardAll,
          boxShadow: AppShadows.card,
        ),
        child: ClipRRect(
          borderRadius: AppRadius.cardAll,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                rows[i],
                if (i != rows.length - 1)
                  const Padding(
                    padding: EdgeInsetsDirectional.only(start: 66),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.divider,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// One tappable row: tinted icon well, title, trailing chevron.
class GroupedListRow extends StatelessWidget {
  final IconData icon;
  final AccentPair accent;
  final String title;
  final VoidCallback onTap;

  const GroupedListRow({
    Key? key,
    required this.icon,
    required this.accent,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Container(
                height: 38,
                width: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.tint,
                  borderRadius: BorderRadius.circular(AppRadius.field),
                ),
                child: Icon(icon, size: 20, color: accent.icon),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Destructive action card — solid icon well, title, supporting line and a
/// trailing arrow, all on a soft danger tint.
class DangerActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const DangerActionCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: AppAccent.red.tint,
      borderRadius: AppRadius.cardAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.cardAll,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              Container(
                height: 42,
                width: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.danger,
                  borderRadius: BorderRadius.circular(AppRadius.field),
                ),
                child: Icon(icon, size: 22, color: AppColors.textOnBrand),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.danger.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 20,
                color: AppColors.danger,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
