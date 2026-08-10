import 'package:eschool/app/routes.dart';
import 'package:eschool/cubits/studentProfileCubit.dart';
import 'package:eschool/ui/styles/appTokens.dart';
import 'package:eschool/ui/widgets/customUserProfileImageWidget.dart';
import 'package:eschool/ui/widgets/dashboard/infoChip.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

/// Restyled home header: avatar, name, class/roll chips and the chat button.
/// Same content and actions as the container it replaces.
///
/// Reads the same [StudentProfileCubit] the previous header used, so profile
/// refreshes and the tap-through to the profile screen behave identically.
class DashboardProfileHeader extends StatelessWidget {
  const DashboardProfileHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudentProfileCubit, StudentProfileState>(
      builder: (context, profileState) {
        final student = profileState is StudentProfileFetchSuccess
            ? profileState.student
            : context.read<StudentProfileCubit>().getCurrentStudentProfile();

        final className = student.classSection?.fullName ?? '';
        final rollNumber = student.rollNumber?.toString() ?? '';

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenH,
            AppSpacing.xxs,
            AppSpacing.screenH,
            AppSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _Avatar(
                imageUrl: student.image ?? "",
                onTap: () => Get.toNamed(Routes.studentProfile),
              ),
              const SizedBox(width: AppSpacing.sm),
              //Name with the class/roll chips stacked beneath it, all sharing
              //the space left over between the avatar and the action buttons.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      student.getFullName(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    if (className.isNotEmpty || rollNumber.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          if (className.isNotEmpty)
                            //Flexible so a long class name ellipsises rather
                            //than pushing the roll chip onto a second line.
                            Flexible(
                              child: InfoChip(
                                icon: Icons.menu_book_rounded,
                                label:
                                    "${Utils.getTranslatedLabel(classKey)}: $className",
                                accent: AppAccent.blue,
                              ),
                            ),
                          if (className.isNotEmpty && rollNumber.isNotEmpty)
                            const SizedBox(width: AppSpacing.xxs),
                          if (rollNumber.isNotEmpty)
                            InfoChip(
                              icon: Icons.groups_rounded,
                              label:
                                  "${Utils.getTranslatedLabel(rollNoKey)}: $rollNumber",
                              accent: AppAccent.green,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              _CircleIconButton(
                icon: Icons.notifications_rounded,
                onTap: () => Get.toNamed(Routes.notifications),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Avatar extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onTap;

  const _Avatar({required this.imageUrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 58,
        width: 58,
        padding: const EdgeInsets.all(2.5),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: AppShadows.card,
        ),
        child: ClipOval(
          child: CustomUserProfileImageWidget(
            profileUrl: imageUrl,
            color: AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

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
