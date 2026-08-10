import 'package:eschool/cubits/authCubit.dart';
import 'package:eschool/cubits/studentProfileCubit.dart';
import 'package:eschool/cubits/studentSubjectAndSlidersCubit.dart';
import 'package:eschool/data/models/subject.dart';
import 'package:eschool/ui/widgets/customBackButton.dart';
import 'package:eschool/ui/widgets/errorContainer.dart';
import 'package:eschool/ui/widgets/noDataContainer.dart';
import 'package:eschool/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:eschool/ui/widgets/shimmerLoaders/subjectsShimmerLoadingContainer.dart';
import 'package:eschool/ui/widgets/studentSubjectsContainer.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/systemModules.dart';
import 'package:eschool/utils/utils.dart';
import 'package:eschool/ui/styles/appTokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class ReportSubjectsContainer extends StatefulWidget {
  final int? childId;
  final List<Subject>? subjects;
  const ReportSubjectsContainer({Key? key, this.childId, this.subjects})
      : super(key: key);

  @override
  ReportSubjectsContainerState createState() => ReportSubjectsContainerState();

  static Widget routeInstance() {
    final arguments = Get.arguments as Map<String, dynamic>;
    return ReportSubjectsContainer(
      childId: arguments['childId'],
      subjects: arguments['subjects'],
    );
  }
}

class ReportSubjectsContainerState extends State<ReportSubjectsContainer> {
  List<Subject>? subjects;

  @override
  void initState() {
    super.initState();
    if (widget.subjects != null) subjects = List.from(widget.subjects!);
  }

  Widget _buildAppBar() {
    return ScreenTopBackgroundContainer(
      padding: EdgeInsets.zero,
      heightPercentage: Utils.appBarSmallerHeightPercentage,
      child: Stack(
        children: [
          context.read<AuthCubit>().isParent()
              ? CustomBackButton(
                  topPadding: MediaQuery.of(context).padding.top +
                      Utils.appBarContentTopPadding,
                )
              : const SizedBox.shrink(),
          Align(
            child: Text(
              Utils.getTranslatedLabel(subjectsKey),
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: Utils.screenTitleFontSize,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMySubjects() {
    if (context.read<AuthCubit>().isParent() && subjects != null) {
      subjects!.removeWhere((element) => element.id == 0);
    }

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: Utils.getScrollViewBottomPadding(context),
        top: Utils.getScrollViewTopPadding(
          context: context,
          appBarHeightPercentage: Utils.appBarSmallerHeightPercentage,
        ),
      ),
      child: (context.read<AuthCubit>().isParent())
          ? (subjects != null && subjects!.isNotEmpty
              ? StudentSubjectsContainer(
                  subjects: subjects!,
                  subjectsTitleKey: '', // Already shown in title
                  childId: widget.childId,
                  showReport: true,
                )
              : CenteredNoDataContainer(
                  titleKey: noSubjectsFoundKey,
                  occupiedHeight: Utils.getScrollViewTopPadding(
                        context: context,
                        appBarHeightPercentage:
                            Utils.appBarSmallerHeightPercentage,
                      ) +
                      Utils.getScrollViewBottomPadding(context),
                ))
          : BlocBuilder<StudentSubjectsAndSlidersCubit,
              StudentSubjectsAndSlidersState>(
              builder: (context, state) {
                if (state is StudentSubjectsAndSlidersFetchSuccess) {
                  final cubitSubjects = context
                      .read<StudentSubjectsAndSlidersCubit>()
                      .getSubjects();

                  if (cubitSubjects.isEmpty) {
                    return CenteredNoDataContainer(
                      titleKey: noSubjectsFoundKey,
                      occupiedHeight: Utils.getScrollViewTopPadding(
                            context: context,
                            appBarHeightPercentage:
                                Utils.appBarSmallerHeightPercentage,
                          ) +
                          Utils.getScrollViewBottomPadding(context),
                    );
                  }

                  final student = context
                      .read<StudentProfileCubit>()
                      .getCurrentStudentProfile();
                  return StudentSubjectsContainer(
                    subjects: cubitSubjects,
                    subjectsTitleKey: '', // Already shown in title
                    childId: student.id,
                    showReport: true,
                  );
                }

                if (state is StudentSubjectsAndSlidersFetchFailure) {
                  return Center(
                    child: ErrorContainer(
                      errorMessageCode: state.errorMessage,
                      onTapRetry: () {
                        context
                            .read<StudentSubjectsAndSlidersCubit>()
                            .fetchSubjectsAndSliders(
                                useParentApi:
                                    context.read<AuthCubit>().isParent(),
                                isSliderModuleEnable: Utils.isModuleEnabled(
                                    context: context,
                                    moduleId:
                                        sliderManagementModuleId.toString()));
                      },
                    ),
                  );
                }

                return Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * (0.025),
                    ),
                    const SubjectsShimmerLoadingContainer(),
                  ],
                );
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return (context.read<AuthCubit>().isParent())
        ? Scaffold(
            body: Stack(
              children: [
                _buildMySubjects(),
                Align(
                  alignment: Alignment.topCenter,
                  child: _buildAppBar(),
                ),
              ],
            ),
          )
        : Stack(
            children: [
              _buildMySubjects(),
              Align(
                alignment: Alignment.topCenter,
                child: _buildAppBar(),
              ),
            ],
          );
  }
}
