import 'package:eschool/cubits/appSettingsCubit.dart';
import 'package:eschool/data/repositories/authRepository.dart';
import 'package:eschool/data/repositories/systemInfoRepository.dart';
import 'package:eschool/ui/widgets/appSettingsBlocBuilder.dart';
import 'package:eschool/ui/widgets/customAppbar.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();

  static Widget routeInstance() {
    return BlocProvider<AppSettingsCubit>(
      create: (context) => AppSettingsCubit(SystemRepository()),
      child: const PrivacyPolicyScreen(),
    );
  }
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  final String privacyPolicyTypeLoggedIn = "privacy_policy";
  final String privacyPolicyTypeNotLoggedIn = "student_parent_privacy_policy";

  final isLoggedIn = AuthRepository().getIsLogIn();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (isLoggedIn) {
        context
            .read<AppSettingsCubit>()
            .fetchSchoolSettings(type: privacyPolicyTypeLoggedIn);
      } else {
        context
            .read<AppSettingsCubit>()
            .fetchAppSettings(type: privacyPolicyTypeNotLoggedIn);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AppSettingsBlocBuilder(
            appSettingsType: isLoggedIn
                ? privacyPolicyTypeLoggedIn
                : privacyPolicyTypeNotLoggedIn,
            useSchoolSettings: isLoggedIn,
          ),
          CustomAppBar(
            title: Utils.getTranslatedLabel(privacyPolicyKey),
          )
        ],
      ),
    );
  }
}
