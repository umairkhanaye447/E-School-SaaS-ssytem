import 'package:eschool/app/routes.dart';
import 'package:eschool/cubits/appConfigurationCubit.dart';
import 'package:eschool/cubits/studentProfileCubit.dart';
import 'package:eschool/ui/widgets/borderedProfilePictureContainer.dart';
import 'package:eschool/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:eschool/ui/widgets/svgButton.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/systemModules.dart';
import 'package:eschool/utils/utils.dart';
import 'package:eschool/ui/styles/appTokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class HomeContainerTopProfileContainer extends StatelessWidget {
  const HomeContainerTopProfileContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenTopBackgroundContainer(
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          return Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsetsDirectional.only(
                    end: boxConstraints.maxWidth * (0.065),
                    start: boxConstraints.maxWidth * (0.056),
                    bottom: boxConstraints.maxHeight * (0.2),
                  ),
                  child: BlocBuilder<StudentProfileCubit, StudentProfileState>(
                    builder: (context, profileState) {
                      // Get student data from profile cubit or fallback to current profile
                      final student = profileState is StudentProfileFetchSuccess
                          ? profileState.student
                          : context
                              .read<StudentProfileCubit>()
                              .getCurrentStudentProfile();

                      return Row(
                        children: [
                          BorderedProfilePictureContainer(
                            heightAndWidth: 60,
                            imageUrl: student.image ?? "",
                            onTap: () {
                              Get.toNamed(Routes.studentProfile);
                            },
                          ),
                          SizedBox(
                            width: boxConstraints.maxWidth * (0.03),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  student.getFullName(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        "${Utils.getTranslatedLabel(classKey)} : ${student.classSection?.fullName ?? ''}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10.0,
                                    ),
                                    Container(
                                      width: 1.5,
                                      height: 12.0,
                                      color: AppColors.textPrimary,
                                    ),
                                    const SizedBox(
                                      width: 10.0,
                                    ),
                                    Flexible(
                                      child: Text(
                                        "${Utils.getTranslatedLabel(rollNoKey)} : ${student.rollNumber ?? ''}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          BlocBuilder<AppConfigurationCubit,
                              AppConfigurationState>(
                            builder: (context, state) {
                              return Utils.isModuleEnabled(
                                      context: context,
                                      moduleId: chatModuleId.toString())
                                  ? SvgButton(
                                      onTap: () {
                                        Get.toNamed(Routes.chatContacts);
                                      },
                                      svgIconUrl:
                                          Utils.getImagePath("chat_icon.svg"),
                                    )
                                  : const SizedBox();
                            },
                          )
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
