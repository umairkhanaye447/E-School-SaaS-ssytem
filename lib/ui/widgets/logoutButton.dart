import 'package:eschool/app/routes.dart';
import 'package:eschool/cubits/authCubit.dart';
import 'package:eschool/cubits/studentSubjectAndSlidersCubit.dart';
import 'package:eschool/ui/widgets/appConfirmDialog.dart';
import 'package:eschool/ui/widgets/groupedListCard.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({Key? key}) : super(key: key);

  void showLogOutDialog(BuildContext context) {
    AppConfirmDialog.show(
      icon: Icons.logout_rounded,
      title: Utils.getTranslatedLabel(logoutKey),
      message: Utils.getTranslatedLabel(sureToLogoutKey),
      confirmLabel: Utils.getTranslatedLabel(yesKey),
      cancelLabel: Utils.getTranslatedLabel(noKey),
      onConfirm: () {
        //clear the student subjects list at the time of logout
        context.read<StudentSubjectsAndSlidersCubit>().clearSubjects();

        if (context.read<AuthCubit>().isParent()) {
          //If parent is logging out then pop the dialog
          Get.back();
        }
        context.read<AuthCubit>().signOut();
        Get.back();
        Get.offNamed(Routes.auth);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DangerActionCard(
      icon: Icons.logout_rounded,
      title: Utils.getTranslatedLabel(logoutAccountKey),
      subtitle: Utils.getTranslatedLabel(signOutFromYourSessionKey),
      onTap: () => showLogOutDialog(context),
    );
  }
}
