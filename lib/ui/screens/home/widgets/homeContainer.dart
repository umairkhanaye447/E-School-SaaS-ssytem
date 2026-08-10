import 'package:eschool/app/routes.dart';
import 'package:eschool/cubits/noticeBoardCubit.dart';
import 'package:eschool/cubits/onlineClassesCubit.dart';
import 'package:eschool/cubits/schoolConfigurationCubit.dart';
import 'package:eschool/cubits/schoolDetailsCubit.dart';
import 'package:eschool/cubits/studentProfileCubit.dart';
import 'package:eschool/cubits/studentSubjectAndSlidersCubit.dart';
import 'package:eschool/ui/screens/home/widgets/homeScreenDataLoadingContainer.dart';
import 'package:eschool/ui/styles/appTokens.dart';
import 'package:eschool/ui/widgets/dashboard/dashboardHeroCard.dart';
import 'package:eschool/ui/widgets/dashboard/dashboardNoticeCard.dart';
import 'package:eschool/ui/widgets/dashboard/menuGrid.dart';
import 'package:eschool/ui/widgets/dashboard/sectionHeader.dart';
import 'package:eschool/ui/widgets/dashboard/dashboardProfileHeader.dart';
import 'package:eschool/ui/widgets/errorContainer.dart';
import 'package:eschool/ui/widgets/noDataContainer.dart';
import 'package:eschool/ui/widgets/onlineClassesContainer.dart';
import 'package:eschool/ui/widgets/schoolGalleryContainer.dart';
import 'package:eschool/ui/widgets/shimmerLoaders/announcementShimmerLoadingContainer.dart';
import 'package:eschool/utils/constants.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/notificationUtility.dart';
import 'package:eschool/utils/systemModules.dart';
import 'package:eschool/utils/utils.dart';
import 'package:eschool/ui/widgets/dashboard/appMotion.dart';
import 'package:eschool/utils/animationConfiguration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class HomeContainer extends StatefulWidget {
  //Need this flag in order to show the homeContainer
  //in background when bottom menu is open

  //If it is just for background showing purpose then it will not reactive or not making any api call
  final bool isForBottomMenuBackground;

  /// Invoked with the item's index in the unfiltered [homeBottomSheetMenu].
  /// HomeScreen passes its existing menu handler here.
  final void Function(int menuIndex)? onTapMenuItem;

  const HomeContainer({
    Key? key,
    required this.isForBottomMenuBackground,
    this.onTapMenuItem,
  }) : super(key: key);

  @override
  State<HomeContainer> createState() => _HomeContainerState();
}

class _HomeContainerState extends State<HomeContainer> {
  @override
  void initState() {
    super.initState();
    if (!widget.isForBottomMenuBackground) {
      Future.delayed(Duration.zero, () {
        fetchSubjectSlidersAndNoticeBoardDetails();
        _ensureSchoolDetailsLoaded();
      });
    }
  }

  /// The hero banner needs the school name/tagline/photos. Only the
  /// onboarding screens fetched these before, so request them here when they
  /// have not loaded yet. Same endpoint, no new API surface.
  void _ensureSchoolDetailsLoaded() {
    final state = context.read<SchooldetailsCubit>().state;
    if (state is SchooldetailsInitial || state is SchooldetailsFetchFailure) {
      context.read<SchooldetailsCubit>().fetchSchooldetails();
    }
  }

  void fetchSubjectSlidersAndNoticeBoardDetails() {
    context.read<StudentSubjectsAndSlidersCubit>().fetchSubjectsAndSliders(
        useParentApi: false,
        isSliderModuleEnable: Utils.isModuleEnabled(
            context: context, moduleId: sliderManagementModuleId.toString()));

    if (Utils.isModuleEnabled(
        context: context,
        moduleId: announcementManagementModuleId.toString())) {
      context
          .read<NoticeBoardCubit>()
          .fetchNoticeBoardDetails(useParentApi: false);
    }

    if (Utils.isModuleEnabled(
        context: context,
        moduleId: timetableManagementModuleId.toString())) {
      context
          .read<OnlineClassesCubit>()
          .fetchTodaysOnlineClasses(useParentApi: false);
    }
  }

  /// One-time staggered entrance for the top dashboard sections when the data
  /// first arrives. Sections further down animate their own items, so only
  /// the header and hero need this.
  Widget _entrance({required int step, required Widget child}) {
    if (widget.isForBottomMenuBackground || !isApplicationItemAnimationOn) {
      return child;
    }
    return Animate(
      delay: Duration(milliseconds: step * 90),
      effects: sectionAppearanceEffects(),
      child: child,
    );
  }

  /// Module shortcuts, moved here from the more-menu bottom sheet. Tapping a
  /// tile calls back into HomeScreen's existing handler, so every destination
  /// behaves exactly as it did from the sheet.
  Widget _buildMenuGrid() {
    if (widget.onTapMenuItem == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: Utils.getTranslatedLabel(menuKey),
            icon: Icons.grid_view_rounded,
          ),
          const SizedBox(height: AppSpacing.xs),
          MenuGrid(onTapMenuItem: widget.onTapMenuItem!),
        ],
      ),
    );
  }

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

  /// Same data, states and destinations as the original
  /// [LatestNoticiesContainer] — only the presentation changed.
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
            animate: !widget.isForBottomMenuBackground,
            onTapViewAll: () => Get.toNamed(Routes.noticeBoard),
          );
        }

        //Preserve the original shimmer placeholders while loading.
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

  Widget _buildSlidersSubjectsAndLatestNotcies() {
    return BlocConsumer<StudentSubjectsAndSlidersCubit,
        StudentSubjectsAndSlidersState>(
      listener: (context, state) {
        if (state is StudentSubjectsAndSlidersFetchSuccess) {
          // Process pending notification after subjects are loaded
          // This ensures data is ready for navigation from terminated state
          if (NotificationUtility.hasPendingNotification) {
            NotificationUtility.processPendingNotification();
          }

          if (state.doesClassHaveElectiveSubjects &&
              state.electiveSubjects.isEmpty) {
            if (Get.currentRoute == Routes.selectSubjects) {
              return;
            }
            Get.toNamed(Routes.selectSubjects);
          }
        }
      },
      builder: (context, state) {
        if (state is StudentSubjectsAndSlidersFetchSuccess) {
          final subjects =
              context.read<StudentSubjectsAndSlidersCubit>().getSubjects();
          final sliders =
              context.read<StudentSubjectsAndSlidersCubit>().getSliders();

          // Show NoDataContainer only when both subjects and sliders are empty
          final hasNoData = subjects.isEmpty && sliders.isEmpty;

          if (hasNoData) {
            return Center(
                child: NoDataContainer(
              titleKey: nohomescreendatafoundKey,
            ));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Pinned: the profile row stays put while the content scrolls.
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.paddingOf(context).top,
                ),
                child: _entrance(
                  step: 0,
                  child: const DashboardProfileHeader(),
                ),
              ),
              Expanded(child: RefreshIndicator(
            displacement: Utils.getScrollViewTopPadding(
              context: context,
              appBarHeightPercentage: Utils.appBarBiggerHeightPercentage,
            ),
            color: Theme.of(context).colorScheme.primary,
            onRefresh: () async {
              // Refresh school configuration
              context
                  .read<SchoolConfigurationCubit>()
                  .fetchSchoolConfiguration(useParentApi: false);

              // Refresh student profile data
              context.read<StudentProfileCubit>().refreshStudentProfile(
                    useParentApi: false,
                  );
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                bottom: Utils.getScrollViewBottomPadding(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _entrance(step: 1, child: _buildHeroCard()),
                  const SizedBox(height: AppSpacing.md),
                  //Grid tiles stagger themselves, so no section wrapper here.
                  _buildMenuGrid(),
                  Utils.isModuleEnabled(
                          context: context,
                          moduleId: timetableManagementModuleId.toString())
                      ? Column(
                          children: [
                            const SizedBox(height: AppSpacing.lg),
                            OnlineClassesContainer(
                              animate: !widget.isForBottomMenuBackground,
                            ),
                          ],
                        )
                      : const SizedBox(),
                  Utils.isModuleEnabled(
                          context: context,
                          moduleId: announcementManagementModuleId.toString())
                      ? Column(
                          children: [
                            const SizedBox(height: AppSpacing.lg),
                            _buildLatestNotices(),
                          ],
                        )
                      : const SizedBox(),
                  Utils.isModuleEnabled(
                          context: context,
                          moduleId: galleryManagementModuleId.toString())
                      ? Column(
                          children: [
                            //Matches the leading gap every other section has,
                            //so the Gallery header no longer sits flush
                            //against the notices card.
                            const SizedBox(height: AppSpacing.lg),
                            BlocBuilder<StudentProfileCubit,
                                StudentProfileState>(
                              builder: (context, profileState) {
                                final student =
                                    profileState is StudentProfileFetchSuccess
                                        ? profileState.student
                                        : context
                                            .read<StudentProfileCubit>()
                                            .getCurrentStudentProfile();
                                return SchoolGalleryContainer(student: student);
                              },
                            ),
                          ],
                        )
                      : const SizedBox(),
                ],
              ),
            ),
              )),
            ],
          );
        }

        if (state is StudentSubjectsAndSlidersFetchFailure) {
          return Center(
            child: ErrorContainer(
              onTapRetry: () {
                context
                    .read<StudentSubjectsAndSlidersCubit>()
                    .fetchSubjectsAndSliders(
                        useParentApi: false,
                        isSliderModuleEnable: Utils.isModuleEnabled(
                            context: context,
                            moduleId: sliderManagementModuleId.toString()));
              },
              errorMessageCode: state.errorMessage,
            ),
          );
        }

        return HomeScreenDataLoadingContainer(
          addTopPadding: true,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // The header is part of the scrollable content now, so no overlay stack.
    return _buildSlidersSubjectsAndLatestNotcies();
  }
}
