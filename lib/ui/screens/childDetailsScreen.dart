import 'package:eschool/app/routes.dart';
import 'package:eschool/cubits/noticeBoardCubit.dart';
import 'package:eschool/cubits/onlineClassesCubit.dart';
import 'package:eschool/cubits/schoolConfigurationCubit.dart';
import 'package:eschool/cubits/schoolGalleryCubit.dart';
import 'package:eschool/cubits/studentSubjectAndSlidersCubit.dart';
import 'package:eschool/data/models/student.dart';
import 'package:eschool/data/repositories/schoolRepository.dart';
import 'package:eschool/data/repositories/studentRepository.dart';
import 'package:eschool/ui/widgets/borderedProfilePictureContainer.dart';
import 'package:eschool/ui/widgets/customShimmerContainer.dart';
import 'package:eschool/ui/widgets/errorContainer.dart';
import 'package:eschool/ui/widgets/noDataContainer.dart';
import 'package:eschool/ui/widgets/onlineClassesContainer.dart';
import 'package:eschool/ui/widgets/schoolGalleryContainer.dart';
import 'package:eschool/ui/widgets/shimmerLoaders/announcementShimmerLoadingContainer.dart';
import 'package:eschool/ui/widgets/shimmerLoaders/subjectsShimmerLoadingContainer.dart';
import 'package:eschool/ui/widgets/shimmerLoadingContainer.dart';
import 'package:eschool/ui/widgets/studentSubjectsContainer.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/systemModules.dart';
import 'package:eschool/utils/utils.dart';
import 'package:eschool/ui/styles/appTokens.dart';
import 'package:eschool/cubits/schoolDetailsCubit.dart';
import 'package:eschool/ui/widgets/dashboard/dashboardHeroCard.dart';
import 'package:eschool/ui/widgets/dashboard/infoChip.dart';
import 'package:eschool/ui/widgets/dashboard/dashboardNoticeCard.dart';
import 'package:eschool/utils/constants.dart';
import 'package:eschool/ui/widgets/dashboard/appMotion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class ChildDetailsScreen extends StatefulWidget {
  final Student student;
  const ChildDetailsScreen({Key? key, required this.student}) : super(key: key);

  @override
  State<ChildDetailsScreen> createState() => _ChildDetailsScreenState();

  static Widget routeInstance() {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SchoolGalleryCubit(SchoolRepository()),
        ),
        BlocProvider(
          create: (context) => OnlineClassesCubit(StudentRepository()),
        ),
      ],
      child: ChildDetailsScreen(
        student: Get.arguments as Student,
      ),
    );
  }
}

class _ChildDetailsScreenState extends State<ChildDetailsScreen> {
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      fetchChildSchoolDetails();
      _ensureSchoolDetailsLoaded();
    });
    super.initState();
  }

  void fetchChildSchoolDetails() {
    context.read<SchoolConfigurationCubit>().fetchSchoolConfiguration(
        useParentApi: true, childId: widget.student.id ?? 0);
  }

  void fetchChildSubjectAndSliders() {
    context.read<StudentSubjectsAndSlidersCubit>().fetchSubjectsAndSliders(
        isSliderModuleEnable: Utils.isModuleEnabled(
            context: context, moduleId: sliderManagementModuleId.toString()),
        useParentApi: true,
        childId: widget.student.id ?? 0);
  }

  void fetchNoticeBoardDetails() {
    if (Utils.isModuleEnabled(
        context: context,
        moduleId: announcementManagementModuleId.toString())) {
      context.read<NoticeBoardCubit>().fetchNoticeBoardDetails(
          useParentApi: true, childId: widget.student.id);
    }
  }

  void fetchGalleryDetails() {
    if (Utils.isModuleEnabled(
        context: context, moduleId: galleryManagementModuleId.toString())) {
      context.read<SchoolGalleryCubit>().fetchSchoolGallery(
          useParentApi: true,
          sessionYearId: context
                  .read<SchoolConfigurationCubit>()
                  .getSchoolConfiguration()
                  .sessionYear
                  .id ??
              0);
    }
  }

  void fetchOnlineClasses() {
    if (Utils.isModuleEnabled(
        context: context,
        moduleId: timetableManagementModuleId.toString())) {
      context.read<OnlineClassesCubit>().fetchTodaysOnlineClasses(
            useParentApi: true,
            childId: widget.student.id,
          );
    }
  }

  void schoolConfigurationCubitListener(
      BuildContext context, SchoolConfigurationState state) {
    if (state is SchoolConfigurationFetchSuccess) {
      fetchChildSubjectAndSliders();
      fetchNoticeBoardDetails();
      fetchGalleryDetails();
      fetchOnlineClasses();
    }
  }

  /// Same welcome banner as the student dashboard, so the parent's view of a
  /// child opens on the identical hero.
  Widget _buildHeroCard() {
    return BlocBuilder<SchooldetailsCubit, SchooldetailsState>(
      builder: (context, state) {
        final details =
            state is SchooldetailsFetchSuccess ? state.schoolDetails : null;

        final images = <String>[
          ...?details?.schoolImages,
        ].where((e) => e.trim().isNotEmpty).toList();

        return DashboardHeroCard(
          welcomeLabel: Utils.getTranslatedLabel(welcomeToKey),
          title: details?.schoolName ?? "",
          subtitle: "",
          tagline: details?.schoolTagline ?? "",
          actionLabel: Utils.getTranslatedLabel(exploreMoreKey),
          imageUrls: images,
          onTapAction: Utils.isModuleEnabled(
            context: context,
            moduleId: galleryManagementModuleId.toString(),
          )
              ? () => Get.toNamed(Routes.schoolGallery)
              : null,
        );
      },
    );
  }

  /// The hero needs school name/tagline/photos; request them when they have
  /// not been loaded yet. Same endpoint, no new API surface.
  void _ensureSchoolDetailsLoaded() {
    final state = context.read<SchooldetailsCubit>().state;
    if (state is SchooldetailsInitial || state is SchooldetailsFetchFailure) {
      context.read<SchooldetailsCubit>().fetchSchooldetails();
    }
  }

  /// Same notice card as the student dashboard, with the same states,
  /// three-item cap and "View all" destination.
  Widget _buildLatestNotices() {
    return BlocBuilder<NoticeBoardCubit, NoticeBoardState>(
      builder: (context, state) {
        return StateCrossfade(
          stateKey: state.runtimeType,
          child: _noticesForState(state),
        );
      },
    );
  }

  Widget _noticesForState(NoticeBoardState state) {
    {
        if (state is NoticeBoardFetchSuccess) {
          final all = state.announcements;
          final latest = all.length > numberOfLatestNoticesInHomeScreen
              ? all.sublist(0, numberOfLatestNoticesInHomeScreen)
              : all;

          return DashboardNoticeCard(
            title: Utils.getTranslatedLabel(latestNoticesKey),
            announcements: latest,
            onTapViewAll: () => Get.toNamed(Routes.noticeBoard),
          );
        }

        if (state is NoticeBoardFetchInProgress ||
            state is NoticeBoardInitial) {
          return Column(
            children: List.generate(
              3,
              (_) => const AnnouncementShimmerLoadingContainer(),
            ),
          );
        }

        return const SizedBox();
    }
  }

  Widget _buildAppBar() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: AppColors.pageBackground,
          border: Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              AppSpacing.xs,
              AppSpacing.screenH,
              AppSpacing.md,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Back button, inline rather than stacked, so the row reads
                //like the student dashboard header.
                _CircleActionButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Get.back<void>(),
                ),
                const SizedBox(width: AppSpacing.xs),
                BorderedProfilePictureContainer(
                  onTap: () {
                    Get.toNamed(
                      Routes.studentProfile,
                      arguments: {
                        'childId': widget.student.id,
                        'userId': widget.student.userId ??
                            widget.student.childUserDetails?.id,
                      },
                    );
                  },
                  heightAndWidth: 54,
                  imageUrl: widget.student.childUserDetails?.image ?? "",
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.student.getFullName(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 5),
                      InfoChip(
                        icon: Icons.menu_book_rounded,
                        label:
                            "${Utils.getTranslatedLabel(classKey)}: ${widget.student.classSection?.fullName ?? ''}",
                        accent: AppAccent.blue,
                      ),
                    ],
                  ),
                ),
                BlocBuilder<StudentSubjectsAndSlidersCubit,
                    StudentSubjectsAndSlidersState>(
                  builder: (context, state) {
                    if (state is StudentSubjectsAndSlidersFetchSuccess) {
                      //Was tinted colorScheme.surface — white on a light
                      //header, so the menu was invisible.
                      return _CircleActionButton(
                        icon: Icons.more_vert_rounded,
                        onTap: () {
                          Get.toNamed(
                            Routes.parentMenu,
                            arguments: {
                              "student": widget.student,
                              "subjectsForFilter": context
                                  .read<StudentSubjectsAndSlidersCubit>()
                                  .getSubjectsForAssignmentContainer()
                            },
                          );
                        },
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataLoadingContainer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerLoadingContainer(
          child: CustomShimmerContainer(
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * (0.075),
            ),
            width: MediaQuery.of(context).size.width,
            borderRadius: 25,
            height: MediaQuery.of(context).size.height *
                Utils.appBarBiggerHeightPercentage,
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * (0.025),
        ),
        const SubjectsShimmerLoadingContainer(),
        SizedBox(
          height: MediaQuery.of(context).size.height * (0.025),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * (0.075),
          ),
          child: Column(
            children: List.generate(2, (index) => index)
                .map(
                  (e) => const AnnouncementShimmerLoadingContainer(),
                )
                .toList(),
          ),
        )
      ],
    );
  }

  Widget _buildSubjectsAndInformationsContainer() {
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: BlocBuilder<StudentSubjectsAndSlidersCubit,
          StudentSubjectsAndSlidersState>(
        builder: (context, state) {
          if (state is StudentSubjectsAndSlidersFetchSuccess) {
            final hasSliderData = state.sliders.isNotEmpty;
            final subjects =
                context.read<StudentSubjectsAndSlidersCubit>().getSubjects();
            final hasSubjectData = subjects.isNotEmpty;
            final hasNoticesData = Utils.isModuleEnabled(
                context: context,
                moduleId: announcementManagementModuleId.toString());
            final hasGalleryData = Utils.isModuleEnabled(
                context: context,
                moduleId: galleryManagementModuleId.toString());

            // Check if no data is available
            if (!hasSliderData && !hasSubjectData) {
              return Center(
                child: NoDataContainer(titleKey: nohomescreendatafoundKey),
              );
            }

            // Render the data if available
            return Column(
              children: [
                _buildHeroCard(),
                const SizedBox(height: AppSpacing.lg),
                if (hasSubjectData)
                  StudentSubjectsContainer(
                    subjects: subjects,
                    subjectsTitleKey: subjectsKey,
                    childId: widget.student.id,
                  ),
                if (Utils.isModuleEnabled(
                    context: context,
                    moduleId: timetableManagementModuleId.toString())) ...[
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.025,
                  ),
                  OnlineClassesContainer(
                    childId: widget.student.id,
                  ),
                ],
                if (hasNoticesData) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _buildLatestNotices(),
                ],
                if (hasGalleryData) ...[
                  const SizedBox(height: AppSpacing.lg),
                  SchoolGalleryContainer(
                    student: widget.student,
                  ),
                ],
              ],
            );
          }

          if (state is StudentSubjectsAndSlidersFetchFailure) {
            return Center(
              child: ErrorContainer(
                errorMessageCode: state.errorMessage,
                onTapRetry: fetchChildSubjectAndSliders,
              ),
            );
          }

          return _buildDataLoadingContainer();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: BlocConsumer<SchoolConfigurationCubit,
                SchoolConfigurationState>(
              listener: schoolConfigurationCubitListener,
              builder: (context, state) {
                if (state is SchoolConfigurationFetchSuccess) {
                  return _buildSubjectsAndInformationsContainer();
                }
                if (state is SchoolConfigurationFetchFailure) {
                  return Center(
                    child: ErrorContainer(
                      errorMessageCode: state.errorMessage,
                      onTapRetry: () {
                        fetchChildSchoolDetails();
                      },
                    ),
                  );
                }

                return _buildDataLoadingContainer();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        width: 42,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: AppShadows.card,
        ),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }
}
