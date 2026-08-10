import 'package:eschool/ui/styles/appTokens.dart';
import 'package:eschool/ui/widgets/dashboard/appListCard.dart';
import 'package:eschool/utils/animationConfiguration.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Row shared by the Exams and Results lists.
///
/// Same data and tap target as before; presentation now follows the home
/// screen's card language. Grade and percentage only appear once a result has
/// been published, exactly as before.
class ListItemForExamAndResult extends StatelessWidget {
  final String examStartingDate;
  final String examName;
  final int index;
  final String resultGrade;
  final double resultPercentage;
  final VoidCallback onItemTap;

  const ListItemForExamAndResult({
    Key? key,
    required this.examStartingDate,
    required this.examName,
    required this.resultGrade,
    required this.resultPercentage,
    required this.onItemTap,
    required this.index,
  }) : super(key: key);

  bool get _hasResult => resultGrade != '' && resultPercentage != 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = examStartingDate == ''
        ? '--'
        : Utils.formatApiDate(examStartingDate);

    return Animate(
      effects: listItemAppearanceEffects(itemIndex: index),
      child: AppListCard(
        onTap: onItemTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const AppIconWell(
                  icon: Icons.assignment_turned_in_rounded,
                  accent: AppAccent.red,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        examName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "${Utils.getTranslatedLabel(dateKey)}: $formattedDate",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
            if (_hasResult) ...[
              const Divider(
                height: AppSpacing.lg,
                thickness: 1,
                color: AppColors.divider,
              ),
              Row(
                children: [
                  AppStatChip(
                    icon: Icons.workspace_premium_rounded,
                    label:
                        "${Utils.getTranslatedLabel(gradeKey)} $resultGrade",
                    accent: AppAccent.indigo,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  AppStatChip(
                    icon: Icons.percent_rounded,
                    label: resultPercentage.toStringAsFixed(2),
                    accent: AppAccent.green,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
