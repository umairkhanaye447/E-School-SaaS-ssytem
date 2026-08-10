import 'package:eschool/app/routes.dart';
import 'package:eschool/data/models/subject.dart';
import 'package:eschool/ui/styles/appResponsive.dart';
import 'package:eschool/ui/styles/appTokens.dart';
import 'package:eschool/ui/widgets/dashboard/featureTile.dart';
import 'package:eschool/ui/widgets/dashboard/sectionHeader.dart';
import 'package:eschool/ui/widgets/subjectImageContainer.dart';
import 'package:eschool/utils/systemModules.dart';
import 'package:eschool/utils/utils.dart';
import 'package:eschool/utils/animationConfiguration.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StudentSubjectsContainer extends StatelessWidget {
  final String subjectsTitleKey;
  final List<Subject> subjects;
  final int? childId;
  final bool showReport;
  final bool animate;

  /// Horizontal inset around the grid. Hosts that already pad their own
  /// content — such as the subjects bottom sheet — pass 0.
  final double horizontalMargin;

  const StudentSubjectsContainer({
    Key? key,
    this.childId,
    required this.subjects,
    required this.subjectsTitleKey,
    this.showReport = false,
    this.animate = true,
    this.horizontalMargin = AppSpacing.screenH,
  }) : super(key: key);

  Widget _buildSubjectContainer({
    required Subject subject,
    required BuildContext context,
  }) {
    return AppTileCard(
      label: subject.getSubjectName(context: context),
      //One line, ellipsised. Subject names vary a lot in length and letting
      //them wrap made the tiles taller than the home menu grid.
      maxLabelLines: 1,
      // The subject's colour comes from the panel and its artwork is a white
      // glyph, so the well stays saturated rather than tinted — a light tint
      // would make the glyph invisible.
      well: SubjectImageContainer(
        showShadow: false,
        animate: animate,
        width: AppTileCard.wellSize,
        height: AppTileCard.wellSize,
        radius: AppRadius.iconTile,
        subject: subject,
      ),
      onTap: () {
        if (showReport) {
          Get.toNamed(
            Routes.subjectWiseDetailedReport,
            arguments: {
              "subject": subject,
              "childId": childId ?? 0,
              "subjects": subjects,
            },
          );
        } else {
          //If lessonModule or announcement moudle is enable then navigate to subejct details
          //If module is not enable then do not navigate to subject details screen
          bool sholdNavigateToSubjectDetailsScreen = Utils.isModuleEnabled(
                  context: context,
                  moduleId: announcementManagementModuleId.toString()) ||
              Utils.isModuleEnabled(
                  context: context,
                  moduleId: lessonManagementModuleId.toString());

          if (sholdNavigateToSubjectDetailsScreen) {
            Get.toNamed(
              Routes.subjectDetails,
              arguments: {
                "childId": childId,
                "subject": subject,
              },
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return subjects.isEmpty
        ? const SizedBox()
        : Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: Utils.getTranslatedLabel(subjectsTitleKey),
                  icon: Icons.menu_book_rounded,
                ),
                const SizedBox(height: AppSpacing.xs),
                GridView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: subjects.length,
                  //Identical geometry to the home menu grid so both read as
                  //the same component.
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: AppResponsive.gridColumns(context),
                    crossAxisSpacing: AppTileCard.gridSpacing,
                    mainAxisSpacing: AppTileCard.gridSpacing,
                    childAspectRatio: AppTileCard.aspectRatio,
                  ),
                  itemBuilder: (context, index) => Animate(
                    effects: gridItemAppearanceEffects(
                      itemIndex: index,
                      totalLoadedItems: subjects.length,
                    ),
                    child: _buildSubjectContainer(
                      context: context,
                      subject: subjects[index],
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
