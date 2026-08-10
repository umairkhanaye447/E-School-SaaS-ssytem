import 'package:eschool/app/routes.dart';
import 'package:eschool/cubits/appConfigurationCubit.dart';
import 'package:eschool/cubits/attendanceCubit.dart';
import 'package:eschool/cubits/holidaysCubit.dart';
import 'package:eschool/cubits/onlineClassesCubit.dart';
import 'package:eschool/cubits/resultsCubit.dart';
import 'package:eschool/cubits/schoolConfigurationCubit.dart';
import 'package:eschool/cubits/schoolGalleryCubit.dart';
import 'package:eschool/cubits/schoolSessionYearsCubit.dart';
import 'package:eschool/cubits/socketSettingCubit.dart';
import 'package:eschool/cubits/studentProfileCubit.dart';
import 'package:eschool/cubits/studentGuardianDetailsCubit.dart';
import 'package:eschool/cubits/timeTableCubit.dart';
import 'package:eschool/cubits/vehicleAssignmentStatusCubit.dart';
import 'package:eschool/data/repositories/authRepository.dart';
import 'package:eschool/data/repositories/schoolRepository.dart';
import 'package:eschool/data/repositories/studentRepository.dart';
import 'package:eschool/data/repositories/systemInfoRepository.dart';
import 'package:eschool/ui/screens/home/cubits/assignmentsTabSelectionCubit.dart';
import 'package:eschool/ui/screens/home/widgets/bottomNavigationItemContainer.dart';
import 'package:eschool/ui/screens/home/widgets/examContainer.dart';
import 'package:eschool/ui/screens/home/widgets/homeContainer.dart';
import 'package:eschool/ui/screens/home/widgets/subjectsBottomsheetContainer.dart';
import 'package:eschool/ui/screens/home/widgets/homeScreenDataLoadingContainer.dart';
import 'package:eschool/ui/widgets/dashboard/dashboardProfileHeader.dart';
import 'package:eschool/ui/screens/home/widgets/parentProfileContainer.dart';
import 'package:eschool/ui/screens/reports/reportSubjectsContainer.dart';
import 'package:eschool/ui/widgets/appUnderMaintenanceContainer.dart';
import 'package:eschool/ui/widgets/assignmentsContainer.dart';
import 'package:eschool/ui/widgets/attendanceContainer.dart';
import 'package:eschool/ui/widgets/customRoundedButton.dart';
import 'package:eschool/ui/widgets/errorContainer.dart';
import 'package:eschool/ui/widgets/forceUpdateDialogContainer.dart';
import 'package:eschool/ui/widgets/holidaysContainer.dart';
import 'package:eschool/ui/widgets/noticeBoardContainer.dart';
import 'package:eschool/ui/widgets/schoolGalleryWithSessionYearFilterContainer.dart';
import 'package:eschool/ui/widgets/settingsContainer.dart';
import 'package:eschool/ui/widgets/timetableContainer.dart';
import 'package:eschool/utils/homeBottomsheetMenu.dart';
import 'package:eschool/utils/constants.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/notificationUtility.dart';
import 'package:eschool/ui/screens/chatContacts/chatContactsScreen.dart';
import 'package:eschool/utils/systemModules.dart';
import 'package:eschool/utils/utils.dart';
import 'package:eschool/utils/pendingExamSubmissionHandler.dart';
import 'package:eschool/ui/styles/appTokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../widgets/resultsContainer.dart';

class HomeScreen extends StatefulWidget {
  static HomeScreenState? currentState;

  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => HomeScreenState();

  static Widget routeInstance() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TimeTableCubit>(
          create: (_) => TimeTableCubit(StudentRepository()),
        ),
        BlocProvider<OnlineClassesCubit>(
          create: (_) => OnlineClassesCubit(StudentRepository()),
        ),
        BlocProvider<StudentGuardianDetailsCubit>(
          create: (_) => StudentGuardianDetailsCubit(
            StudentRepository(),
          ),
        ),
        BlocProvider<AttendanceCubit>(
          create: (context) => AttendanceCubit(StudentRepository()),
        ),
        BlocProvider<HolidaysCubit>(
          create: (context) => HolidaysCubit(SystemRepository()),
        ),
        BlocProvider<AssignmentsTabSelectionCubit>(
          create: (_) => AssignmentsTabSelectionCubit(),
        ),
        BlocProvider<ResultsCubit>(
          create: (_) => ResultsCubit(StudentRepository()),
        ),
        BlocProvider<SchoolGalleryCubit>(
          create: (_) => SchoolGalleryCubit(SchoolRepository()),
        ),
        BlocProvider<StudentProfileCubit>(
          create: (_) =>
              StudentProfileCubit(StudentRepository(), AuthRepository()),
        ),
        BlocProvider<VehicleAssignmentStatusCubit>(
          create: (_) => VehicleAssignmentStatusCubit(),
        ),
      ],
      child: const HomeScreen(),
    );
  }
}

class HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  late final Animation<double> _bottomNavAndTopProfileAnimation =
      Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ),
  );

  var canPop = false;

  late final List<AnimationController> _bottomNavItemTitlesAnimationController =
      [];

  //Slide-up sheet for the "Subject" tab. Same behaviour the more-menu tab
  //had: tapping the last nav item toggles it, and closing restores the tab
  //that was showing underneath.
  late final AnimationController _subjectsSheetAnimationController =
      AnimationController(
    vsync: this,
    duration: homeMenuBottomSheetAnimationDuration,
  );

  late final Animation<Offset> _subjectsSheetAnimation =
      Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero).animate(
    CurvedAnimation(
      parent: _subjectsSheetAnimationController,
      curve: Curves.easeInOut,
    ),
  );

  late final Animation<double> _subjectsSheetScrimAnimation =
      Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(
      parent: _subjectsSheetAnimationController,
      curve: Curves.easeInOut,
    ),
  );

  late bool _isSubjectsSheetOpen = false;

  late int _currentSelectedBottomNavIndex = 0;

  //index of opened homeBottomsheet menu
  late int _currentlyOpenMenuIndex = -1;

  late List<BottomNavItem> _bottomNavItems = [];

  @override
  void initState() {
    super.initState();

    HomeScreen.currentState = this;

    WidgetsBinding.instance.addObserver(this);
    _animationController.forward();

    Future.delayed(Duration.zero, () {
      context
          .read<SchoolConfigurationCubit>()
          .fetchSchoolConfiguration(useParentApi: false);

      // Initialize student profile data
      context.read<StudentProfileCubit>().fetchStudentProfile(
            useParentApi: false,
          );

      //setup notification callback here
      NotificationUtility.setUpNotificationService();

      // Check for pending exam submissions (in case app was terminated during exam)
      PendingExamSubmissionHandler.checkAndSubmitPendingExam();
    });
  }

  void updateBottomNavItems() {
    //Settings occupies the last tab; Subjects is reached from the home grid,
    //where it opens a slide-up sheet. Chat keeps the same module gating the
    //grid tile used to apply; Assignment moved into the home grid.
    final bool chatEnabled = Utils.isModuleEnabled(
      context: context,
      moduleId: chatModuleId.toString(),
    );

    _bottomNavItems = [
      BottomNavItem(
        activeIcon: Icons.home_rounded,
        icon: Icons.home_outlined,
        title: homeKey,
      ),
      if (chatEnabled)
        BottomNavItem(
          activeIcon: Icons.chat_bubble_rounded,
          icon: Icons.chat_bubble_outline_rounded,
          title: chatsKey,
        ),
      BottomNavItem(
        activeIcon: Icons.settings_rounded,
        icon: Icons.settings_outlined,
        title: settingsKey,
      ),
    ];

    //Update the animaitons controller based on assignment module enable
    initAnimations();

    setState(() {});
  }

  void navigateToAssignmentContainer() {
    Get.until((route) => route.isFirst);
    changeBottomNavItem(1);
  }

  void initAnimations() {
    for (var i = 0; i < _bottomNavItems.length; i++) {
      _bottomNavItemTitlesAnimationController.add(
        AnimationController(
          value: i == _currentSelectedBottomNavIndex ? 0.0 : 1.0,
          vsync: this,
          duration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  @override
  void dispose() {
    // Only clear the shared reference if it still points at this instance, so a
    // newly mounted HomeScreen that registered itself first is not wiped out.
    if (identical(HomeScreen.currentState, this)) {
      HomeScreen.currentState = null;
    }
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    _subjectsSheetAnimationController.dispose();
    for (var animationController in _bottomNavItemTitlesAnimationController) {
      animationController.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // When app resumes from background, recheck notification permissions
    // This handles the case where user manually enables notifications in Settings
    if (state == AppLifecycleState.resumed) {
      NotificationUtility.recheckNotificationPermissions();

      // Reconnect WebSocket to pick up messages sent while app was in background
      if (Utils.isModuleEnabled(
          context: context, moduleId: chatModuleId.toString())) {
        context.read<SocketSettingCubit>().reconnect();
      }
    }
  }

  Future<void> changeBottomNavItem(int index) async {
    if (_subjectsSheetAnimationController.isAnimating) {
      return;
    }

    _bottomNavItemTitlesAnimationController[_currentSelectedBottomNavIndex]
        .forward();

    setState(() {
      _currentSelectedBottomNavIndex = index;
      //Switching tabs leaves any inline menu screen that was open.
      _currentlyOpenMenuIndex = -1;
    });

    _bottomNavItemTitlesAnimationController[_currentSelectedBottomNavIndex]
        .reverse();

    //A tab change always dismisses the subjects sheet.
    if (_subjectsSheetAnimationController.isCompleted) {
      await _closeSubjectsSheet();
    }
  }

  Future<void> _openSubjectsSheet() async {
    await _subjectsSheetAnimationController.forward();
    if (!mounted) return;
    setState(() {
      _isSubjectsSheetOpen = true;
    });
  }

  Future<void> _closeSubjectsSheet() async {
    await _subjectsSheetAnimationController.reverse();
    if (!mounted) return;
    setState(() {
      _isSubjectsSheetOpen = false;
    });
  }

  ///Dismisses the sheet, leaving the tab underneath as it was.
  Future<void> _dismissSubjectsSheet() async {
    await _closeSubjectsSheet();
  }

  Future<void> _handleTransportNavigation() async {
    // Get current student profile
    final student =
        context.read<StudentProfileCubit>().getCurrentStudentProfile();
    final studentId = student.id ?? 0;

    final assignmentCubit = context.read<VehicleAssignmentStatusCubit>();

    // If data is not loaded yet, fetch it first
    if (!assignmentCubit.isDataLoaded()) {
      // Trigger the API call
      assignmentCubit.checkVehicleAssignmentStatus(userId: studentId);

      // Wait for the response using stream
      await assignmentCubit.stream.firstWhere((state) =>
          state is VehicleAssignmentStatusFetchSuccess ||
          state is VehicleAssignmentStatusFetchFailure);
    }

    // Check if assigned
    if (assignmentCubit.isStatusAssigned()) {
      // Navigate to transport home screen
      await Get.toNamed(
        Routes.transportEnrollHomeScreen,
        arguments: studentId,
      );
    } else {
      // Show snack bar with status message
      final status = assignmentCubit.getAssignmentStatus();
      final message = status?.message ?? 'Transportation not assigned';

      if (mounted) {
        Utils.showCustomSnackBar(
          context: context,
          errorMessage: message,
          backgroundColor: Theme.of(context).colorScheme.error,
        );
      }
    }
  }

  /// Handles a tap on the home screen's module grid. Destinations are
  /// unchanged from the old more-menu sheet: four items push a route, the
  /// rest render inline over the home tab via [_currentlyOpenMenuIndex].
  Future<void> _onTapMoreMenuItemContainer(int index) async {
    final String title = homeBottomSheetMenu[index].title;

    if (title == myDiaryKey) {
      final student =
          context.read<StudentProfileCubit>().getCurrentStudentProfile();
      await Get.toNamed(Routes.studentDiaryScreen,
          arguments: {'studentId': student.id ?? 0, 'id': student.id ?? 0});
      if (mounted) setState(() {});
      return;
    }

    if (title == transportationKey) {
      await _handleTransportNavigation();
      if (mounted) setState(() {});
      return;
    }

    if (title == teachersKey) {
      final student =
          context.read<StudentProfileCubit>().getCurrentStudentProfile();
      await Get.toNamed(Routes.childTeachers, arguments: student.id ?? 0);
      if (mounted) setState(() {});
      return;
    }

    if (title == mySubjectsKey) {
      await _openSubjectsSheet();
      return;
    }

    if (title == certificateKey) {
      await Get.toNamed(Routes.certificate);
      if (mounted) setState(() {});
      return;
    }

    setState(() {
      _currentlyOpenMenuIndex = index;
    });
  }

  Widget _buildBottomNavigationContainer() {
    return FadeTransition(
      opacity: _bottomNavAndTopProfileAnimation,
      child: SlideTransition(
        position: _bottomNavAndTopProfileAnimation.drive(
          Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero),
        ),
        child: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(
            bottom: Utils.bottomNavigationBottomMargin,
          ),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Utils.getColorScheme(context)
                    .secondary
                    .withValues(alpha: 0.15),
                offset: const Offset(2.5, 2.5),
                blurRadius: 20,
              )
            ],
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.field),
          ),
          width: MediaQuery.of(context).size.width * (0.85),
          height: MediaQuery.of(context).size.height *
              Utils.bottomNavigationHeightPercentage,
          child: LayoutBuilder(
            builder: (context, boxConstraints) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _bottomNavItems.isEmpty
                    ? [const SizedBox()]
                    : _bottomNavItems.map((bottomNavItem) {
                        final int index = _bottomNavItems
                            .indexWhere((e) => e.title == bottomNavItem.title);
                        return BottomNavItemContainer(
                          showCaseDescription: bottomNavItem.title,
                          onTap: changeBottomNavItem,
                          boxConstraints: boxConstraints,
                          currentIndex: _currentSelectedBottomNavIndex,
                          bottomNavItem: _bottomNavItems[index],
                          animationController:
                              _bottomNavItemTitlesAnimationController[index],
                          index: index,
                        );
                      }).toList(),
              );
            },
          ),
        ),
      ),
    );
  }

  //To load the selected menu item
  //it _currentlyOpenMenuIndex is 0 then load the container based on homeBottomSheetMenu[_currentlyOpenMenuIndex]
  Widget _buildMenuItemContainer() {
    if (homeBottomSheetMenu[_currentlyOpenMenuIndex].title == assignmentsKey) {
      return const AssignmentsContainer(isForBottomMenuBackground: false);
    }
    if (homeBottomSheetMenu[_currentlyOpenMenuIndex].title == attendanceKey) {
      return const AttendanceContainer();
    }
    if (homeBottomSheetMenu[_currentlyOpenMenuIndex].title == timeTableKey) {
      return const TimeTableContainer();
    }
    if (homeBottomSheetMenu[_currentlyOpenMenuIndex].title == settingsKey) {
      return const SettingsContainer();
    }
    if (homeBottomSheetMenu[_currentlyOpenMenuIndex].title == noticeBoardKey) {
      return const NoticeBoardContainer(
        showBackButton: false,
      );
    }
    if (homeBottomSheetMenu[_currentlyOpenMenuIndex].title ==
        guardianDetailsKey) {
      return const GuardianProfileContainer();
    }

    if (homeBottomSheetMenu[_currentlyOpenMenuIndex].title == holidaysKey) {
      return const HolidaysContainer();
    }
    if (homeBottomSheetMenu[_currentlyOpenMenuIndex].title == examsKey) {
      return const ExamContainer();
    }
    if (homeBottomSheetMenu[_currentlyOpenMenuIndex].title == resultKey) {
      return BlocProvider(
        create: (context) => SchoolSessionYearsCubit(SchoolRepository()),
        child: const ResultsContainer(),
      );
    }

    if (homeBottomSheetMenu[_currentlyOpenMenuIndex].title == reportsKey) {
      return const ReportSubjectsContainer();
    }

    if (homeBottomSheetMenu[_currentlyOpenMenuIndex].title == galleryKey) {
      return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => SchoolGalleryCubit(SchoolRepository()),
          ),
          BlocProvider(
            create: (context) => SchoolSessionYearsCubit(SchoolRepository()),
          ),
        ],
        child: BlocBuilder<StudentProfileCubit, StudentProfileState>(
          builder: (context, profileState) {
            final student = profileState is StudentProfileFetchSuccess
                ? profileState.student
                : context
                    .read<StudentProfileCubit>()
                    .getCurrentStudentProfile();
            return SchoolGalleryWithSessionYearFilterContainer(
                showBackButton: false, student: student);
          },
        ),
      );
    }
    return const SizedBox();
  }

  Widget _buildSheetScrim() {
    return GestureDetector(
      onTap: _dismissSubjectsSheet,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.75),
      ),
    );
  }

  /// Tabs occupy indices 0..n-1; the inline menu screen lives in the slot
  /// right after them.
  int get _visibleContentIndex => _currentlyOpenMenuIndex != -1
      ? _bottomNavItems.length
      : _currentSelectedBottomNavIndex;

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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop:
          _currentSelectedBottomNavIndex == 0 && _currentlyOpenMenuIndex == -1
              ? canPop
              : false,
      onPopInvokedWithResult: (didPop, _) {
        //Back leaves an inline menu screen first, then returns to Home,
        //then arms the press-again-to-exit prompt.
        if (_isSubjectsSheetOpen) {
          _dismissSubjectsSheet();
          return;
        }
        if (_currentlyOpenMenuIndex != -1) {
          setState(() {
            _currentlyOpenMenuIndex = -1;
          });
          return;
        }
        if (_currentSelectedBottomNavIndex != 0) {
          changeBottomNavItem(0);
          return;
        }
        _onWillPop();
      },
      child: Scaffold(
        body: context.read<AppConfigurationCubit>().appUnderMaintenance() ||
                context.read<AppConfigurationCubit>().systemUnderMaintenance()
            ? const AppUnderMaintenanceContainer()
            : BlocConsumer<SchoolConfigurationCubit, SchoolConfigurationState>(
                listener: (context, state) {
                  if (state is SchoolConfigurationFetchSuccess ||
                      state is SchoolConfigurationFetchFailure) {
                    updateBottomNavItems();
                    if (state is SchoolConfigurationFetchSuccess) {
                      // Initialize student profile data
                      context.read<StudentProfileCubit>().fetchStudentProfile(
                            useParentApi: false,
                          );

                      if (Utils.isModuleEnabled(
                          context: context,
                          moduleId: galleryManagementModuleId.toString())) {
                        context.read<SchoolGalleryCubit>().fetchSchoolGallery(
                            useParentApi: false,
                            sessionYearId:
                                state.schoolConfiguration.sessionYear.id ?? 0);
                      }

                      ///[Setting up the socket connection]

                      if (Utils.isModuleEnabled(
                          context: context,
                          moduleId: chatModuleId.toString())) {
                        final student = context
                            .read<StudentProfileCubit>()
                            .getCurrentStudentProfile();
                        context
                            .read<SocketSettingCubit>()
                            .init(userId: student.id ?? 0);
                      }

                      // Note: Pending notification is processed in HomeContainer
                      // after subjects are loaded (StudentSubjectsAndSlidersFetchSuccess)
                    }
                  }
                },
                builder: (context, state) {
                  if (state is SchoolConfigurationFetchSuccess) {
                    return Stack(
                      children: [
                        IndexedStack(
                          index: _visibleContentIndex,
                          children: [
                            HomeContainer(
                              isForBottomMenuBackground: false,
                              onTapMenuItem: _onTapMoreMenuItemContainer,
                            ),
                            if (Utils.isModuleEnabled(
                              context: context,
                              moduleId: chatModuleId.toString(),
                            ))
                              ChatContactsScreen.routeInstance(),
                            const SettingsContainer(),
                            //Trailing slot: the inline screen for a tapped
                            //module tile. Kept out of the tab list so the
                            //bottom nav indices stay 1:1 with the tabs.
                            _currentlyOpenMenuIndex != -1
                                ? _buildMenuItemContainer()
                                : const SizedBox(),
                          ],
                        ),
                        IgnorePointer(
                          ignoring: !_isSubjectsSheetOpen,
                          child: FadeTransition(
                            opacity: _subjectsSheetScrimAnimation,
                            child: _buildSheetScrim(),
                          ),
                        ),

                        //Subjects sheet
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: SlideTransition(
                            position: _subjectsSheetAnimation,
                            child: SubjectsBottomsheetContainer(
                              closeBottomMenu: _dismissSubjectsSheet,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: _buildBottomNavigationContainer(),
                        ),

                        //Check forece update here
                        context.read<AppConfigurationCubit>().forceUpdate()
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
                    );
                  }
                  if (state is SchoolConfigurationFetchFailure) {
                    return Center(
                      child: Column(
                        children: [
                          SafeArea(
                            bottom: false,
                            child: DashboardProfileHeader(),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          ErrorContainer(
                            errorMessageCode: state.errorMessage,
                            onTapRetry: () {
                              context
                                  .read<SchoolConfigurationCubit>()
                                  .fetchSchoolConfiguration(
                                      useParentApi: false);
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
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
                            buttonTitle: Utils.getTranslatedLabel(settingsKey),
                            showBorder: false,
                          )
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      SafeArea(
                        bottom: false,
                        child: DashboardProfileHeader(),
                      ),
                      Expanded(
                          child: HomeScreenDataLoadingContainer(
                        addTopPadding: false,
                      )),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
