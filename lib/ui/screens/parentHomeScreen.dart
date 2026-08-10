import 'package:eschool/app/routes.dart';
import 'package:eschool/cubits/appConfigurationCubit.dart';
import 'package:eschool/cubits/authCubit.dart';
import 'package:eschool/cubits/schoolConfigurationCubit.dart';
import 'package:eschool/cubits/slidersCubit.dart';
import 'package:eschool/cubits/socketSettingCubit.dart';
import 'package:eschool/data/models/student.dart';
import 'package:eschool/data/repositories/schoolRepository.dart';
import 'package:eschool/ui/screens/home/widgets/homeContainerTopProfileContainer.dart';
import 'package:eschool/ui/widgets/appUnderMaintenanceContainer.dart';
import 'package:eschool/ui/widgets/borderedProfilePictureContainer.dart';
import 'package:eschool/ui/widgets/customRoundedButton.dart';
import 'package:eschool/ui/widgets/errorContainer.dart';
import 'package:eschool/ui/widgets/forceUpdateDialogContainer.dart';
import 'package:eschool/ui/widgets/customShimmerContainer.dart';
import 'package:eschool/ui/widgets/noDataContainer.dart';
import 'package:eschool/ui/widgets/shimmerLoadingContainer.dart';
import 'package:eschool/utils/animationConfiguration.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/notificationUtility.dart';
import 'package:eschool/utils/systemModules.dart';
import 'package:eschool/utils/utils.dart';
import 'package:eschool/ui/styles/appTokens.dart';
import 'package:eschool/ui/widgets/dashboard/sectionHeader.dart';
import 'package:eschool/ui/widgets/dashboard/infoChip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({Key? key}) : super(key: key);

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();

  static Widget routeInstance() {
    return BlocProvider<SlidersCubit>(
      create: (context) => SlidersCubit(SchoolRepository()),
      child: const ParentHomeScreen(),
    );
  }
}

class _ParentHomeScreenState extends State<ParentHomeScreen>
    with WidgetsBindingObserver {
  var canPop = false;

  /// Returns true if the parent has at least one child assigned.
  bool _hasChildren() {
    final children = context.read<AuthCubit>().getParentDetails().children;
    return children != null && children.isNotEmpty;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    Future.delayed(Duration.zero, () {
      _fetchSchoolConfiguration();
      NotificationUtility.setUpNotificationService();
    });
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // When app resumes from background, recheck notification permissions
    // This handles the case where user manually enables notifications in Settings
    if (state == AppLifecycleState.resumed) {
      NotificationUtility.recheckNotificationPermissions();

      // Reconnect WebSocket to pick up messages sent while app was in background
      if (_hasChildren() &&
          Utils.isModuleEnabled(
              context: context, moduleId: chatModuleId.toString())) {
        context.read<SocketSettingCubit>().reconnect();
      }
    }
  }

  void _fetchSchoolConfiguration() {
    if (!_hasChildren()) return;

    final firstChildId =
        context.read<AuthCubit>().getParentDetails().children!.first.id ?? 0;
    context
        .read<SchoolConfigurationCubit>()
        .fetchSchoolConfiguration(useParentApi: true, childId: firstChildId);
  }

  /// Parent header, matching the student dashboard header: ringed avatar,
  /// name on the display ramp, an info chip for the account, and the same
  /// circular action buttons.
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
                BorderedProfilePictureContainer(
                  heightAndWidth: 58,
                  onTap: () => Get.toNamed(Routes.parentProfile),
                  imageUrl:
                      context.read<AuthCubit>().getParentDetails().image ?? "",
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.read<AuthCubit>().getParentDetails()
                            .getFullName(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      InfoChip(
                        icon: Icons.mail_outline_rounded,
                        label: context
                                .read<AuthCubit>()
                                .getParentDetails()
                                .email ??
                            "",
                        accent: AppAccent.blue,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                BlocBuilder<AppConfigurationCubit, AppConfigurationState>(
                  builder: (context, state) {
                    return Utils.isModuleEnabled(
                      context: context,
                      moduleId: chatModuleId.toString(),
                    )
                        ? _HeaderActionButton(
                            icon: Icons.chat_bubble_rounded,
                            onTap: () => Get.toNamed(Routes.chatContacts),
                          )
                        : const SizedBox();
                  },
                ),
                const SizedBox(width: AppSpacing.xs),
                _HeaderActionButton(
                  icon: Icons.settings_rounded,
                  onTap: () => Get.toNamed(Routes.settings),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Child tile, in the app's card language: white surface, avatar in a
  /// tinted ring, name and class stacked, chevron on the trailing edge.
  ///
  /// Was a solid blue block with a white circle arrow overhanging the bottom
  /// edge, which clipped against neighbouring tiles and matched nothing else.
  Widget _buildChildDetailsContainer({
    required double width,
    required Student student,
  }) {
    return Animate(
      effects: customItemZoomAppearanceEffects(),
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadius.cardAll,
        child: InkWell(
          borderRadius: AppRadius.cardAll,
          onTap: () {
            Get.toNamed(Routes.parentChildDetails, arguments: student);
          },
          child: Ink(
            width: width,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.cardAll,
              boxShadow: AppShadows.card,
            ),
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.card,
                  ),
                  child: BorderedProfilePictureContainer(
                    onTap: () {
                      Get.toNamed(
                        Routes.parentChildDetails,
                        arguments: student,
                      );
                    },
                    heightAndWidth: 48,
                    imageUrl: student.childUserDetails?.image ?? "",
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        student.getFullName(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${Utils.getTranslatedLabel(classKey)} - ${student.classSection?.fullName ?? ''}",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
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
      ),
    );
  }

  Widget _buildChildrenContainer() {
    return Padding(
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * (0.075),
        right: MediaQuery.of(context).size.width * (0.075),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: Utils.getTranslatedLabel(myChildrenKey),
            icon: Icons.groups_rounded,
          ),
          const SizedBox(height: AppSpacing.sm),
          LayoutBuilder(
            builder: (context, boxConstraints) {
              return Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children:
                    (context.read<AuthCubit>().getParentDetails().children ??
                            [])
                        .map(
                          (student) => _buildChildDetailsContainer(
                            width: boxConstraints.maxWidth,
                            student: student,
                          ),
                        )
                        .toList(),
              );
            },
          )
        ],
      ),
    );
  }

  void _onWillPop() {
    setState(() {
      canPop = true;
    });
    Utils.showCustomSnackBar(
      context: context,
      errorMessage: Utils.getTranslatedLabel(pressbackagaintoexitKey),
      backgroundColor: Theme.of(context).colorScheme.error,
    ); // Do not exit the app
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        canPop = false;
      });
    });
  }

  Future<void> _refreshParentData() async {
    try {
      // Call the new API to get updated parent data
      await context.read<AuthCubit>().updateParentDetails();

      if (mounted) setState(() {});

      if (!_hasChildren()) return;

      // Refresh school configuration to get latest data
      final firstChildId =
          context.read<AuthCubit>().getParentDetails().children!.first.id ?? 0;

      await context.read<SchoolConfigurationCubit>().fetchSchoolConfiguration(
            useParentApi: true,
            childId: firstChildId,
          );
    } catch (e) {
      if (mounted) {
        Utils.showCustomSnackBar(
          context: context,
          errorMessage: e.toString(),
          backgroundColor: Theme.of(context).colorScheme.error,
        );
      }
    }
  }

  Widget _buildAppBarShimmer() {
    final width = MediaQuery.of(context).size.width;
    return ShimmerLoadingContainer(
      child: Container(
        width: width,
        height: MediaQuery.of(context).size.height *
            Utils.appBarMediumtHeightPercentage,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
        ),
        padding: EdgeInsetsDirectional.only(
          start: width * 0.056,
          end: width * 0.02,
          top: MediaQuery.of(context).padding.top + 10,
        ),
        child: Row(
          children: [
            CustomShimmerContainer(
              width: 65,
              height: 65,
              borderRadius: 32.5,
            ),
            SizedBox(width: width * 0.04),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomShimmerContainer(
                  width: width * 0.35,
                  height: 18,
                  borderRadius: 4,
                ),
                const SizedBox(height: 10),
                CustomShimmerContainer(
                  width: width * 0.45,
                  height: 12,
                  borderRadius: 3,
                ),
              ],
            ),
            const Spacer(),
            CustomShimmerContainer(
              width: 24,
              height: 24,
              borderRadius: 12,
            ),
            const SizedBox(width: 12),
            CustomShimmerContainer(
              width: 24,
              height: 24,
              borderRadius: 12,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildrenShimmer() {
    final width = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.075),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, boxConstraints) {
              return Wrap(
                spacing: boxConstraints.maxWidth * 0.05,
                runSpacing: 32.5,
                children: List.generate(
                  4,
                  (index) => ShimmerLoadingContainer(
                    child: CustomShimmerContainer(
                      width: boxConstraints.maxWidth * 0.45,
                      height: 150,
                      borderRadius: 20,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildAppBarShimmer(),
          const SizedBox(height: 25),
          _buildChildrenShimmer(),
        ],
      ),
    );
  }

  Widget _buildNoChildrenScreen() {
    return RefreshIndicator(
      onRefresh: _refreshParentData,
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      edgeOffset: MediaQuery.of(context).size.height *
          Utils.appBarMediumtHeightPercentage,
      child: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: CenteredNoDataContainer(
              titleKey: noChildrenFoundKey,
              //The app bar above the scroll area plus the scroll top padding.
              occupiedHeight: MediaQuery.sizeOf(context).height *
                      Utils.appBarMediumtHeightPercentage +
                  AppSpacing.md,
            ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;

        _onWillPop();
      },
      child: Scaffold(
        body: context.read<AppConfigurationCubit>().appUnderMaintenance() ||
                context.read<AppConfigurationCubit>().systemUnderMaintenance()
            ? const AppUnderMaintenanceContainer()
            : !_hasChildren()
                ? _buildNoChildrenScreen()
                : BlocConsumer<SchoolConfigurationCubit,
                    SchoolConfigurationState>(
                    listener: (context, state) {
                      if (state is SchoolConfigurationFetchSuccess) {
                        if (Utils.isModuleEnabled(
                            context: context,
                            moduleId: chatModuleId.toString())) {
                          context.read<SocketSettingCubit>().init(
                              userId: context
                                      .read<AuthCubit>()
                                      .getParentDetails()
                                      .id ??
                                  0);
                        }

                        // Process pending notification after app is fully initialized
                        // This handles notifications when app was opened from terminated state
                        if (NotificationUtility.hasPendingNotification) {
                          Future.delayed(const Duration(milliseconds: 500), () {
                            NotificationUtility.processPendingNotification();
                          });
                        }
                      }
                    },
                    builder: (context, state) {
                      if (state is SchoolConfigurationFetchSuccess) {
                        return RefreshIndicator(
                          onRefresh: _refreshParentData,
                          color: Theme.of(context).colorScheme.primary,
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          edgeOffset: MediaQuery.of(context).size.height *
                              Utils.appBarMediumtHeightPercentage,
                          child: Column(
                            children: [
                              _buildAppBar(),
                              Expanded(
                                child: SingleChildScrollView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.only(
                                    top: AppSpacing.md,
                                    bottom: 50,
                                  ),
                                  child: Column(
                                    children: [
                                      _buildChildrenContainer(),
                                    ],
                                  ),
                                ),
                              ),
                              //Check force update here
                              context
                                      .read<AppConfigurationCubit>()
                                      .forceUpdate()
                                  ? FutureBuilder<bool>(
                                      future: Utils.forceUpdate(
                                        context
                                            .read<AppConfigurationCubit>()
                                            .getAppVersion(),
                                      ),
                                      builder: (context, snaphsot) {
                                        if (snaphsot.hasData) {
                                          return (snaphsot.data ?? false)
                                              ? const ForceUpdateDialogContainer()
                                              : const SizedBox();
                                        }

                                        return const SizedBox();
                                      },
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                        );
                      }

                      if (state is SchoolConfigurationFetchFailure) {
                        return Center(
                          child: Column(
                            children: [
                              HomeContainerTopProfileContainer(),
                              const SizedBox(height: 15),
                              ErrorContainer(
                                errorMessageCode: state.errorMessage,
                                onTapRetry: _fetchSchoolConfiguration,
                              ),
                              const SizedBox(height: 20),
                              CustomRoundedButton(
                                height: 40,
                                widthPercentage: 0.3,
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                onTap: () {
                                  Get.toNamed(Routes.settings);
                                },
                                titleColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                buttonTitle:
                                    Utils.getTranslatedLabel(settingsKey),
                                showBorder: false,
                              )
                            ],
                          ),
                        );
                      }

                      // Initial loading state - show shimmer
                      return _buildShimmerLoading();
                    },
                  ),
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        width: 44,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: AppShadows.card,
        ),
        child: Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
