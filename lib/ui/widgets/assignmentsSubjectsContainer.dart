import 'package:eschool/cubits/assignmentsCubit.dart';
import 'package:eschool/cubits/examsOnlineCubit.dart';
import 'package:eschool/cubits/resultsCubit.dart';
import 'package:eschool/data/models/subject.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/ui/styles/appTokens.dart';
import 'package:eschool/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//It must be child of AssignmentsCibit
class AssignmentsSubjectContainer extends StatefulWidget {
  final List<Subject> subjects;
  final Function(int) onTapSubject;
  final int selectedClassSubjectId;
  final String cubitAndState;

  const AssignmentsSubjectContainer({
    Key? key,
    required this.subjects,
    required this.onTapSubject,
    required this.selectedClassSubjectId,
    required this.cubitAndState,
  }) : super(key: key);

  @override
  State<AssignmentsSubjectContainer> createState() =>
      _AssignmentsSubjectContainerState();
}

class _AssignmentsSubjectContainerState
    extends State<AssignmentsSubjectContainer> {
  late final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        controller: _scrollController,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              if (widget.cubitAndState == "onlineExam") {
                if (context.read<ExamsOnlineCubit>().state
                    is ExamsOnlineFetchInProgress) {
                  return;
                }
              } else if (widget.cubitAndState == "onlineResult") {
                //change cubit later - according to Online Result
                if (context.read<ResultsCubit>().state
                    is ResultsFetchInProgress) {
                  return;
                }
              } else {
                if (context.read<AssignmentsCubit>().state
                    is AssignmentsFetchInProgress) {
                  return;
                }
              }

              if (widget.subjects[index].classSubjectId ==
                  widget.selectedClassSubjectId) {
                return;
              }

              final subjectIdIndex = widget.subjects.indexWhere(
                (element) =>
                    widget.subjects[index].classSubjectId ==
                    element.classSubjectId,
              );

              final selectedSubjectIdIndex = widget.subjects.indexWhere(
                (element) =>
                    widget.selectedClassSubjectId == element.classSubjectId,
              );

              _scrollController.animateTo(
                _scrollController.offset +
                    (subjectIdIndex > selectedSubjectIdIndex ? 1 : -1) *
                        MediaQuery.of(context).size.width *
                        (0.2),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );

              //

              widget.onTapSubject(widget.subjects[index].classSubjectId ?? 0);
            },
            child: Builder(
              builder: (context) {
                final bool isSelected = widget.selectedClassSubjectId ==
                    widget.subjects[index].classSubjectId;

                //Unselected chips read as tappable options rather than plain
                //text: a white pill on the page tint, brand-filled when active.
                return Container(
                  margin: const EdgeInsetsDirectional.only(
                      end: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                    boxShadow: isSelected ? null : AppShadows.card,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.subjects[index].classSubjectId == 0
                        ? Utils.getTranslatedLabel(allSubjectsKey)
                        : widget.subjects[index]
                            .getSubjectName(context: context),
                    style:
                        Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.textOnBrand
                                  : AppColors.textSecondary,
                            ),
                  ),
                );
              },
            ),
          );
        },
        itemCount: widget.subjects.length,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      ),
    );
  }
}
