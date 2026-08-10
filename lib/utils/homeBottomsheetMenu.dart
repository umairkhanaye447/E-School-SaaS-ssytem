import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/systemModules.dart';
import 'package:eschool/utils/utils.dart';

class Menu {
  /// Identity key. Also the screen title, and what the home tap handler
  /// switches on — do not change it to shorten a tile label.
  final String title;
  final String iconUrl;
  final String menuModuleId; //This is fixed

  /// Optional shorter label for the grid tile. Falls back to [title].
  final String? displayTitle;

  Menu({
    required this.iconUrl,
    required this.title,
    required this.menuModuleId,
    this.displayTitle,
  });

  String get tileLabel => displayTitle ?? title;
}

//To add all more menu here

final List<Menu> homeBottomSheetMenu = [
  Menu(
      menuModuleId: assignmentManagementModuleId.toString(),
      iconUrl: Utils.getImagePath("dashboard/assignment.svg"),
      title: assignmentsKey),
  Menu(
      menuModuleId: attendanceManagementModuleId.toString(),
      iconUrl: Utils.getImagePath("dashboard/attendance.svg"),
      title: attendanceKey),
  Menu(
    menuModuleId: timetableManagementModuleId.toString(),
    iconUrl: Utils.getImagePath("dashboard/timetable.svg"),
    title: timeTableKey,
  ),
  Menu(
    menuModuleId: announcementManagementModuleId.toString(),
    iconUrl: Utils.getImagePath("dashboard/noticeboard.svg"),
    title: noticeBoardKey,
    displayTitle: noticeKey,
  ),
  Menu(
    menuModuleId: examManagementModuleId.toString(),
    iconUrl: Utils.getImagePath("dashboard/exams.svg"),
    title: examsKey,
  ),
  Menu(
      menuModuleId: examManagementModuleId.toString(),
      iconUrl: Utils.getImagePath("dashboard/results.svg"),
      title: resultKey),

  //Report module is combination of assginement and exam
  Menu(
      menuModuleId:
          "$assignmentManagementModuleId$moduleIdJoiner$examManagementModuleId",
      iconUrl: Utils.getImagePath("dashboard/reports.svg"),
      title: reportsKey),
  Menu(
    menuModuleId: defaultModuleId.toString(),
    iconUrl: Utils.getImagePath("dashboard/guardian.svg"),
    title: guardianDetailsKey,
    displayTitle: guardianKey,
  ),
  Menu(
      iconUrl: Utils.getImagePath("dashboard/holidays.svg"),
      title: holidaysKey,
      menuModuleId: holidayManagementModuleId.toString()),
  Menu(
      iconUrl: Utils.getImagePath("dashboard/gallery.svg"),
      title: galleryKey,
      menuModuleId: galleryManagementModuleId.toString()),
  Menu(
      iconUrl: Utils.getImagePath("dashboard/diary.svg"),
      title: myDiaryKey,
      menuModuleId: studentManagementModuleId.toString()),
  Menu(
      iconUrl: Utils.getImagePath("dashboard/transportation.svg"),
      title: transportationKey,
      menuModuleId: transportationManagementModuleId.toString()),
  Menu(
      iconUrl: Utils.getImagePath("dashboard/certificate.svg"),
      title: certificateKey,
      menuModuleId: certificateManagementModuleId.toString()),
  Menu(
      iconUrl: Utils.getImagePath("dashboard/teachers.svg"),
      title: teachersKey,
      menuModuleId: defaultModuleId.toString()),
  //Subjects opens the slide-up sheet; Settings now lives in the bottom nav.
  Menu(
      iconUrl: Utils.getImagePath("dashboard/subjects.svg"),
      title: mySubjectsKey,
      displayTitle: subjectsKey,
      menuModuleId: defaultModuleId.toString()),

  //Chat moved off the top header into the grid; gated by the chat module so
  //schools without it never see the tile.
];
