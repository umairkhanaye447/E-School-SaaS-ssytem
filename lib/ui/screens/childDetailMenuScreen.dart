import 'package:eschool/app/routes.dart';
import 'package:eschool/cubits/authCubit.dart';
import 'package:eschool/cubits/vehicleAssignmentStatusCubit.dart';
import 'package:eschool/data/models/student.dart';
import 'package:eschool/data/models/subject.dart';
import 'package:eschool/ui/widgets/customBackButton.dart';
import 'package:eschool/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:eschool/utils/animationConfiguration.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/systemModules.dart';
import 'package:eschool/utils/utils.dart';
import 'package:eschool/ui/styles/appTokens.dart';
import 'package:eschool/ui/styles/appResponsive.dart';
import 'package:eschool/ui/widgets/dashboard/featureTile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:eschool/data/repositories/transportRepository.dart';
import 'package:eschool/ui/screens/parentTransportEnroll/transportHome/transportRequestDetailsScreen.dart';

class ChildDetailMenuScreen extends StatefulWidget {
  final Student student;
  final List<Subject> subjectsForFilter;
  const ChildDetailMenuScreen({
    Key? key,
    required this.student,
    required this.subjectsForFilter,
  }) : super(key: key);

  @override
  ChildDetailMenuScreenState createState() => ChildDetailMenuScreenState();

  static Widget routeInstance() {
    final arguments = Get.arguments as Map<String, dynamic>;
    return BlocProvider(
      create: (context) => VehicleAssignmentStatusCubit(),
      child: ChildDetailMenuScreen(
        subjectsForFilter: arguments['subjectsForFilter'],
        student: arguments['student'],
      ),
    );
  }
}

class ChildDetailMenuScreenState extends State<ChildDetailMenuScreen> {
  List<MenuContainerDetails> _menuItems = [];

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      // Check vehicle assignment status first
      context.read<VehicleAssignmentStatusCubit>().checkVehicleAssignmentStatus(
            userId: widget.student.userId ?? widget.student.id ?? 0,
          );
      setMenuItems();
    });
    super.initState();
  }

  Future<void> handleTransportNavigation() async {
    final assignmentCubit = context.read<VehicleAssignmentStatusCubit>();

    if (!assignmentCubit.isDataLoaded()) {
      // If data not loaded yet, default to enrollment screen
      Get.toNamed(
        Routes.staffTransportEnrollScreen,
        arguments: widget.student.userId ?? widget.student.id,
      );
      return;
    }

    // Check status and navigate accordingly based on API response data value
    if (assignmentCubit.isStatusAssigned()) {
      // data = "assigned" - navigate to transport home
      Get.toNamed(
        Routes.transportEnrollHomeScreen,
        arguments: widget.student.userId ?? widget.student.id,
      );
    } else if (assignmentCubit.isExpired()) {
      // data = "expired" - fetch request data and navigate to plan renewal
      await _navigateToPlanRenewal();
    } else if (assignmentCubit.isPending()) {
      // data = "pending" - fetch request data and navigate to request details
      await _navigateToRequestDetails();
    } else {
      // data = "false" or any other value - navigate to enrollment screen
      Get.toNamed(
        Routes.staffTransportEnrollScreen,
        arguments: widget.student.userId ?? widget.student.id,
      );
    }
  }

  Future<void> _navigateToPlanRenewal() async {
    final userId = widget.student.userId ?? widget.student.id ?? 0;

    // Navigate directly to plan renewal screen
    // planRenewalScreen will fetch all required data via API
    Get.toNamed(Routes.planRenewalScreen, arguments: {
      'userId': userId,
    });
  }

  Future<void> _navigateToRequestDetails() async {
    try {
      // Fetch request data
      final transportRepo = TransportRepository();
      final requestsResponse = await transportRepo.getTransportRequests(
        userId: widget.student.userId ?? widget.student.id ?? 0,
      );

      if (requestsResponse.data.isNotEmpty) {
        // Get the most recent request (first one)
        final request = requestsResponse.data.first;

        // Build request details arguments
        final args = RequestDetailsArgs(
          title: Utils.getTranslatedLabel(transportationRequestKey),
          requestedOn: request.requestedOn ?? 'N/A',
          statusText: request.status?.capitalize ?? 'Pending',
          statusBg: _getStatusColor(request.status).bg,
          statusFg: _getStatusColor(request.status).fg,
          sections: buildDynamicSections(request),
          footerNote: request.status?.toLowerCase() == 'rejected'
              ? Utils.getTranslatedLabel(
                  yourTransportationRequestWasRejectedKey)
              : Utils.getTranslatedLabel(yourRequestIsBeingProcessedKey),
          showNewRequest: request.status?.toLowerCase() == 'rejected',
          transportRequest: request,
        );

        // Navigate to request details screen
        Get.toNamed(Routes.transportRequestDetailsScreen, arguments: args);
      } else {
        // No requests found - redirect to enrollment screen
        if (context.mounted) {
          Utils.showCustomSnackBar(
            context: context,
            errorMessage: 'No pending requests found',
            backgroundColor: Theme.of(context).colorScheme.error,
          );
        }
        Get.toNamed(
          Routes.staffTransportEnrollScreen,
          arguments: widget.student.userId ?? widget.student.id,
        );
      }
    } catch (e) {
      // On error, show message and redirect to enrollment screen
    }
  }

  ({Color bg, Color fg}) _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return (bg: AppAccent.orange.tint, fg: AppColors.warning);
      case 'approved':
        return (bg: AppAccent.green.tint, fg: AppColors.success);
      case 'rejected':
        return (bg: AppAccent.red.tint, fg: AppColors.danger);
      default:
        return (bg: AppAccent.orange.tint, fg: AppColors.warning);
    }
  }

  void setMenuItems() {
    //Menu will have module Id attache to it same as student home bottm sheet
    _menuItems = [
      MenuContainerDetails(
        moduleId: assignmentManagementModuleId.toString(),
        route: Routes.childAssignments,
        arguments: {
          "childId": widget.student.id,
          "subjects": widget.subjectsForFilter,
        },
        iconPath: Utils.getImagePath("dashboard/assignment.svg"),
        title: Utils.getTranslatedLabel(assignmentsKey),
      ),
      MenuContainerDetails(
        moduleId: defaultModuleId.toString(),
        route: Routes.childTeachers,
        arguments: widget.student.userId,
        iconPath: Utils.getImagePath("dashboard/teachers.svg"),
        title: Utils.getTranslatedLabel(teachersKey),
      ),
      MenuContainerDetails(
        moduleId: attendanceManagementModuleId.toString(),
        route: Routes.childAttendance,
        arguments: widget.student.id,
        iconPath: Utils.getImagePath("dashboard/attendance.svg"),
        title: Utils.getTranslatedLabel(attendanceKey),
      ),
      MenuContainerDetails(
        moduleId: transportationManagementModuleId.toString(),
        route: '', // Route will be determined dynamically
        arguments: widget.student.userId ?? widget.student.id,
        iconPath: Utils.getImagePath("dashboard/transportation.svg"),
        title: Utils.getTranslatedLabel(transportationKey),
        isTransportation: true, // Flag to identify transportation menu
      ),
      MenuContainerDetails(
        moduleId: timetableManagementModuleId.toString(),
        route: Routes.childTimeTable,
        arguments: widget.student.id,
        iconPath: Utils.getImagePath("dashboard/timetable.svg"),
        title: Utils.getTranslatedLabel(timeTableKey),
      ),
      MenuContainerDetails(
        moduleId: holidayManagementModuleId.toString(),
        route: Routes.holidays,
        arguments: widget.student.id,
        iconPath: Utils.getImagePath("dashboard/holidays.svg"),
        title: Utils.getTranslatedLabel(holidaysKey),
      ),
      MenuContainerDetails(
        moduleId: examManagementModuleId.toString(),
        route: Routes.exam,
        arguments: {
          "childId": widget.student.id,
          "subjects": widget.subjectsForFilter,
        },
        iconPath: Utils.getImagePath("dashboard/exams.svg"),
        title: Utils.getTranslatedLabel(examsKey),
      ),
      MenuContainerDetails(
        moduleId: examManagementModuleId.toString(),
        route: Routes.childResults,
        arguments: {
          "childId": widget.student.id,
          "subjects": widget.subjectsForFilter,
        },
        iconPath: Utils.getImagePath("dashboard/results.svg"),
        title: Utils.getTranslatedLabel(resultKey),
      ),
      MenuContainerDetails(
        moduleId:
            "$assignmentManagementModuleId$moduleIdJoiner$examManagementModuleId",
        route: Routes.subjectWiseReport,
        arguments: {
          "childId": widget.student.id,
          "subjects": widget.subjectsForFilter,
        },
        iconPath: Utils.getImagePath("dashboard/reports.svg"),
        title: Utils.getTranslatedLabel(reportsKey),
      ),
      MenuContainerDetails(
        moduleId: feesManagementModuleId.toString(),
        route: Routes.childFees,
        arguments: widget.student,
        iconPath: Utils.getImagePath("dashboard/fees.svg"),
        title: Utils.getTranslatedLabel(feesKey),
      ),
      MenuContainerDetails(
        moduleId: galleryManagementModuleId.toString(),
        route: Routes.schoolGallery,
        arguments: widget.student,
        iconPath: Utils.getImagePath("dashboard/gallery.svg"),
        title: Utils.getTranslatedLabel(galleryKey),
      ),
      MenuContainerDetails(
        moduleId: certificateManagementModuleId.toString(),
        route: Routes.certificate,
        arguments: widget.student.userId,
        iconPath: Utils.getImagePath("dashboard/certificate.svg"),
        title: Utils.getTranslatedLabel(certificateKey),
      ),
      MenuContainerDetails(
        moduleId: studentManagementModuleId.toString(),
        route: Routes.studentDiaryScreen,
        arguments: {
          "studentId": widget.student.userId,
          "id": widget.student.id
        },
        iconPath: Utils.getImagePath("dashboard/diary.svg"),
        title: Utils.getTranslatedLabel(studentDiaryKey),
      ),
    ];

    setState(() {});
  }

  Widget _buildAppBar(BuildContext context) {
    return ScreenTopBackgroundContainer(
      heightPercentage: Utils.appBarSmallerHeightPercentage,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          context.read<AuthCubit>().isParent()
              ? const CustomBackButton()
              : const SizedBox(),
          Align(
            alignment: Alignment.topCenter,
            child: Text(
              Utils.getTranslatedLabel(menuKey),
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

  Widget _buildInformationAndMenu() {
    return BlocListener<VehicleAssignmentStatusCubit,
        VehicleAssignmentStatusState>(
      listener: (context, state) {
        // Update menu items when assignment status changes
        if (state is VehicleAssignmentStatusFetchSuccess) {
          setState(() {
            setMenuItems();
          });
        }
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: 25,
          left: MediaQuery.of(context).size.width * (0.075),
          right: MediaQuery.of(context).size.width * (0.075),
          top: Utils.getScrollViewTopPadding(
            context: context,
            appBarHeightPercentage: Utils.appBarMediumtHeightPercentage,
          ),
        ),
        child: _buildMenuGrid(),
      ),
    );
  }

  /// Module tiles, identical in geometry and styling to the student
  /// dashboard's Menu grid. Same entries, same module gating, same
  /// destinations — only the presentation changed from outlined rows.
  Widget _buildMenuGrid() {
    final visible = _menuItems
        .where((m) => Utils.isModuleEnabled(
              context: context,
              moduleId: m.moduleId,
            ))
        .toList();

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: visible.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: AppResponsive.gridColumns(context),
        crossAxisSpacing: AppTileCard.gridSpacing,
        mainAxisSpacing: AppTileCard.gridSpacing,
        childAspectRatio: AppTileCard.aspectRatio,
      ),
      itemBuilder: (context, index) {
        final menuItem = visible[index];
        return Animate(
          effects: gridItemAppearanceEffects(
            itemIndex: index,
            totalLoadedItems: visible.length,
          ),
          child: FeatureTile(
            iconAssetPath: menuItem.iconPath,
            label: menuItem.title,
            accent: accentForIcon(menuItem.iconPath),
            onTap: () async {
              // Transportation resolves its destination at tap time.
              if (menuItem.isTransportation) {
                await handleTransportNavigation();
              } else {
                Get.toNamed(menuItem.route, arguments: menuItem.arguments);
              }
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [_buildInformationAndMenu(), _buildAppBar(context)],
      ),
    );
  }
}

//class to maintain details required by each menu items
class MenuContainerDetails {
  String iconPath;
  String title;
  String route;
  String moduleId;
  Object? arguments;
  bool isTransportation;

  MenuContainerDetails({
    required this.iconPath,
    required this.title,
    required this.route,
    required this.moduleId,
    this.arguments,
    this.isTransportation = false,
  });
}
