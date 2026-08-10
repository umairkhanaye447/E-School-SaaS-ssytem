import 'dart:math';

import 'package:eschool/app/routes.dart';
import 'package:eschool/cubits/studentProfileCubit.dart';
import 'package:eschool/cubits/studentSubjectAndSlidersCubit.dart';
import 'package:eschool/ui/styles/appTokens.dart';
import 'package:eschool/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool/ui/widgets/customUserProfileImageWidget.dart';
import 'package:eschool/ui/widgets/noDataContainer.dart';
import 'package:eschool/ui/widgets/studentSubjectsContainer.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

/// Slide-up sheet holding the student's subjects.
///
/// Mirrors the layout the more-menu sheet used before its grid moved to the
/// home screen: profile row, divider, then the scrollable card grid. Subjects
/// come from the [StudentSubjectsAndSlidersCubit] the home screen already
/// populates, so opening the sheet costs no extra request.
class SubjectsBottomsheetContainer extends StatelessWidget {
  final Function closeBottomMenu;

  const SubjectsBottomsheetContainer({
    Key? key,
    required this.closeBottomMenu,
  }) : super(key: key);

  Widget _buildSubjects(BuildContext context) {
    return BlocBuilder<StudentSubjectsAndSlidersCubit,
        StudentSubjectsAndSlidersState>(
      builder: (context, state) {
        if (state is! StudentSubjectsAndSlidersFetchSuccess) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
            child: Center(child: CustomCircularProgressIndicator()),
          );
        }

        final subjects =
            context.read<StudentSubjectsAndSlidersCubit>().getSubjects();

        if (subjects.isEmpty) {
          return Center(
            child: NoDataContainer(titleKey: noSubjectsFoundKey),
          );
        }

        // The sheet supplies its own horizontal padding, so the grid runs
        // edge to edge inside it.
        return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: StudentSubjectsContainer(
            subjects: subjects,
            subjectsTitleKey: subjectsKey,
            horizontalMargin: 0,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * (0.85),
      ),
      padding: const EdgeInsets.only(top: 25.0, right: 25.0, left: 25.0),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              BlocBuilder<StudentProfileCubit, StudentProfileState>(
                builder: (context, profileState) {
                  final student = profileState is StudentProfileFetchSuccess
                      ? profileState.student
                      : context
                          .read<StudentProfileCubit>()
                          .getCurrentStudentProfile();

                  return Row(
                    children: [
                      Container(
                        height: boxConstraints.maxWidth * (0.22),
                        width: boxConstraints.maxWidth * (0.22),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2.0,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          borderRadius: BorderRadius.circular(
                            boxConstraints.maxWidth * (0.11),
                          ),
                        ),
                        child: CustomUserProfileImageWidget(
                          profileUrl: student.image ?? "",
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: boxConstraints.maxWidth * (0.075)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.getFullName(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              "${Utils.getTranslatedLabel(classKey)} : ${student.classSection?.fullName ?? ''}",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              "${Utils.getTranslatedLabel(rollNoKey)} : ${student.rollNumber ?? ''}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          closeBottomMenu();
                          Get.toNamed(Routes.studentProfile);
                        },
                        icon: Transform.rotate(
                          angle: pi,
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      )
                    ],
                  );
                },
              ),
              Divider(
                color: Theme.of(context).colorScheme.onSurface,
                height: 50,
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: _buildSubjects(context),
                ),
              ),
              SizedBox(height: Utils.getScrollViewBottomPadding(context)),
            ],
          );
        },
      ),
    );
  }
}
