import 'package:eschool/data/models/announcement.dart';
import 'package:eschool/ui/styles/appTokens.dart';
import 'package:eschool/ui/widgets/dashboard/sectionHeader.dart';
import 'package:eschool/utils/animationConfiguration.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// "Latest Notice" card — a single surface holding the section header and up
/// to N announcement rows separated by hairlines, per the reference design.
class DashboardNoticeCard extends StatelessWidget {
  final String title;
  final List<Announcement> announcements;
  final VoidCallback onTapViewAll;
  final void Function(Announcement announcement)? onTapAnnouncement;

  /// Mirrors the original container's flag: suppressed when the widget is
  /// only being drawn as a static background behind the more-menu.
  final bool animate;

  const DashboardNoticeCard({
    Key? key,
    required this.title,
    required this.announcements,
    required this.onTapViewAll,
    this.onTapAnnouncement,
    this.animate = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardAll,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: title,
            icon: Icons.campaign_rounded,
            iconColor: AppAccent.orange.icon,
            onTapAction: onTapViewAll,
          ),
          const SizedBox(height: AppSpacing.sm),
          //With no notices the card stays, showing why it is empty. Hiding it
          //entirely left a gap with no explanation.
          if (announcements.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    height: 38,
                    width: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: AppRadius.iconTileAll,
                    ),
                    child: const Icon(
                      Icons.notifications_off_rounded,
                      size: 19,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      Utils.getTranslatedLabel(noAnnouncementKey),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          for (var i = 0; i < announcements.length; i++) ...[
            if (i > 0)
              const Divider(
                height: AppSpacing.lg,
                thickness: 1,
                color: AppColors.divider,
              ),
            Animate(
              effects: animate
                  ? listItemAppearanceEffects(
                      itemIndex: i,
                      totalLoadedItems: announcements.length,
                    )
                  : null,
              child: _NoticeRow(
                announcement: announcements[i],
                accent: AppAccent.cycle[i % AppAccent.cycle.length],
                onTap: onTapAnnouncement == null
                    ? null
                    : () => onTapAnnouncement!(announcements[i]),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NoticeRow extends StatelessWidget {
  final Announcement announcement;
  final AccentPair accent;
  final VoidCallback? onTap;

  const _NoticeRow({
    required this.announcement,
    required this.accent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: accent.tint,
              borderRadius: AppRadius.iconTileAll,
            ),
            child: Icon(
              Icons.description_rounded,
              size: 22,
              color: accent.icon,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  announcement.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (announcement.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    announcement.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          height: 1.3,
                        ),
                  ),
                ],
              ],
            ),
          ),
          if (announcement.createdAt.trim().isNotEmpty) ...[
            const SizedBox(width: AppSpacing.xs),
            ConstrainedBox(
              //Sized for the canonical "20 November 2023" on two lines; the
              //old 88 was cut for the previous "20-11-2023" format.
              constraints: const BoxConstraints(maxWidth: 108),
              child: Text(
                Utils.formatApiDate(announcement.createdAt),
                maxLines: 2,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
