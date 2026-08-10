import 'dart:math';
import 'package:eschool/app/routes.dart';
import 'package:eschool/cubits/studentProfileCubit.dart';
import 'package:eschool/ui/styles/appResponsive.dart';
import 'package:eschool/ui/widgets/dashboard/featureTile.dart';
import 'package:eschool/ui/widgets/customUserProfileImageWidget.dart';
import 'package:eschool/utils/homeBottomsheetMenu.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/utils.dart';
import 'package:eschool/ui/styles/appTokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class MoreMenuBottomsheetContainer extends StatelessWidget {
  final Function onTapMoreMenuItemContainer;
  final Function closeBottomMenu;   
  const MoreMenuBottomsheetContainer({
    Key? key,
    required this.onTapMoreMenuItemContainer,
    required this.closeBottomMenu,
  }) : super(key: key);

  /// Same menu entries, same module filtering and the same tap index as
  /// before — only the tile presentation changed.
  Widget _buildMenuGrid(BuildContext context) {
    final visible = homeBottomSheetMenu
        .where((menu) => Utils.isModuleEnabled(
              context: context,
              moduleId: menu.menuModuleId,
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
        final menu = visible[index];
        return FeatureTile(
          iconAssetPath: menu.iconUrl,
          label: Utils.getTranslatedLabel(menu.title),
          accent: accentForMenu(menu.title),
          onTap: () {
            onTapMoreMenuItemContainer(
              homeBottomSheetMenu
                  .indexWhere((element) => element.title == menu.title),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * (0.85)),
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
                  // Get student data from profile cubit or fallback to current profile
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
                      SizedBox(
                        width: boxConstraints.maxWidth * (0.075),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.getFullName(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.w500,
                                fontSize: 18.0,
                              ),
                            ),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    "${Utils.getTranslatedLabel(classKey)} : ${student.classSection?.fullName ?? ''}",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w400,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    "${Utils.getTranslatedLabel(rollNoKey)} : ${student.rollNumber ?? ''}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w400,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            )
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
              Expanded(
                child: SingleChildScrollView(
                  child: _buildMenuGrid(context),
                ),
              ),
              SizedBox(
                height: Utils.getScrollViewBottomPadding(context),
              ),
            ],
          );
        },
      ),
    );
  }
}
