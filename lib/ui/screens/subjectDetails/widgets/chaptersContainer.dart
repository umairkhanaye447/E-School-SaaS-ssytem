import 'package:eschool/app/routes.dart';
import 'package:eschool/cubits/authCubit.dart';
import 'package:eschool/cubits/subjectLessonsCubit.dart';
import 'package:eschool/data/models/lesson.dart';
import 'package:eschool/ui/widgets/customShimmerContainer.dart';
import 'package:eschool/ui/widgets/errorContainer.dart';
import 'package:eschool/ui/widgets/noDataContainer.dart';
import 'package:eschool/ui/widgets/shimmerLoadingContainer.dart';
import 'package:eschool/utils/animationConfiguration.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/ui/styles/appTokens.dart';
import 'package:eschool/ui/widgets/dashboard/appListCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class ChaptersContainer extends StatefulWidget {
  final int classSubjectId;
  final int? childId;
  const ChaptersContainer(
      {Key? key, required this.classSubjectId, this.childId})
      : super(key: key);

  @override
  State<ChaptersContainer> createState() => _ChaptersContainerState();
}

class _ChaptersContainerState extends State<ChaptersContainer> {
  /// Chapter row, in the app's list-card language: tinted icon well, chapter
  /// name as the title, description beneath, chevron to indicate it opens.
  ///
  /// Was a bare label/value stack — the only tappable list in the app with no
  /// icon and no affordance, which is what made this screen read as sparse.
  Widget _buildChapterDetailsContainer({required Lesson lesson}) {
    return AppListCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      onTap: () {
        Get.toNamed(
          Routes.chapterDetails,
          arguments: {"lesson": lesson, "childId": widget.childId},
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppIconWell(
            icon: Icons.menu_book_rounded,
            accent: AppAccent.indigo,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  lesson.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (lesson.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    lesson.description,
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
    );
  }

  Widget _buildChapterDetailsShimmerContainer() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        width: MediaQuery.of(context).size.width * (0.85),
        child: LayoutBuilder(
          builder: (context, boxConstraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoadingContainer(
                  child: CustomShimmerContainer(
                    margin: EdgeInsetsDirectional.only(
                      end: boxConstraints.maxWidth * (0.7),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                ShimmerLoadingContainer(
                  child: CustomShimmerContainer(
                    margin: EdgeInsetsDirectional.only(
                      end: boxConstraints.maxWidth * (0.5),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                ShimmerLoadingContainer(
                  child: CustomShimmerContainer(
                    margin: EdgeInsetsDirectional.only(
                      end: boxConstraints.maxWidth * (0.7),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                ShimmerLoadingContainer(
                  child: CustomShimmerContainer(
                    margin: EdgeInsetsDirectional.only(
                      end: boxConstraints.maxWidth * (0.5),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubjectLessonsCubit, SubjectLessonsState>(
      builder: (context, state) {
        if (state is SubjectLessonsFetchSuccess) {
          return state.lessons.isEmpty
              ? CenteredNoDataContainer(
                  titleKey: noChaptersKey,
                  //Subject header and tab bar above this tab's content.
                  occupiedHeight: MediaQuery.sizeOf(context).height * 0.45,
                )
              : Column(
                  children: List.generate(
                    state.lessons.length,
                    (index) => Animate(
                      effects: listItemAppearanceEffects(
                        itemIndex: index,
                        totalLoadedItems: state.lessons.length,
                      ),
                      child: _buildChapterDetailsContainer(
                        lesson: state.lessons[index],
                      ),
                    ),
                  ),
                );
        }
        if (state is SubjectLessonsFetchFailure) {
          return ErrorContainer(
            errorMessageCode: state.errorMessage,
            onTapRetry: () {
              context.read<SubjectLessonsCubit>().fetchSubjectLessons(
                    classSubjectId: widget.classSubjectId,
                    useParentApi: context.read<AuthCubit>().isParent(),
                    childId: widget.childId,
                  );
            },
          );
        }
        return Column(
          children: List.generate(5, (index) => index)
              .map(
                (e) => _buildChapterDetailsShimmerContainer(),
              )
              .toList(),
        );
      },
    );
  }
}
