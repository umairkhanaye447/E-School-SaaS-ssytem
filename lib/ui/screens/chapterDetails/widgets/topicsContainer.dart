import 'package:eschool/app/routes.dart';
import 'package:eschool/data/models/topic.dart';
import 'package:eschool/ui/widgets/noDataContainer.dart';
import 'package:eschool/utils/animationConfiguration.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/ui/styles/appTokens.dart';
import 'package:eschool/ui/widgets/dashboard/appListCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class TopicsContainer extends StatelessWidget {
  final List<Topic> topics;
  final int? childId;
  const TopicsContainer({Key? key, required this.topics, this.childId})
      : super(key: key);

  /// Topic row, matching the chapter rows one level up: tinted icon well,
  /// name as the title, description beneath, chevron to indicate it opens.
  Widget _buildTopicDetailsContainer({
    required Topic topic,
    required BuildContext context,
  }) {
    return Animate(
      effects: customItemFadeAppearanceEffects(),
      child: AppListCard(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        onTap: () {
          Get.toNamed(
            Routes.topicDetails,
            arguments: {"topic": topic, "childId": childId},
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppIconWell(
              icon: Icons.article_rounded,
              accent: AppAccent.blue,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    topic.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  if (topic.description.trim().isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      topic.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: topics.isEmpty
          ? [
              CenteredNoDataContainer(
                titleKey: noTopicsKey,
                //Chapter header and tab bar above this tab's content.
                occupiedHeight: MediaQuery.sizeOf(context).height * 0.45,
              )
            ]
          : topics
              .map(
                (topic) =>
                    _buildTopicDetailsContainer(topic: topic, context: context),
              )
              .toList(),
    );
  }
}
