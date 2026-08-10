import 'package:eschool/app/routes.dart';
import 'package:eschool/cubits/appConfigurationCubit.dart';
import 'package:eschool/cubits/appLocalizationCubit.dart';
import 'package:eschool/cubits/authCubit.dart';
import 'package:eschool/cubits/changePasswordCubit.dart';
import 'package:eschool/data/repositories/authRepository.dart';
import 'package:eschool/ui/styles/appTokens.dart';
import 'package:eschool/ui/widgets/appScreenHeader.dart';
import 'package:eschool/ui/widgets/changeLanguageBottomsheetContainer.dart';
import 'package:eschool/ui/widgets/changePasswordBottomsheet.dart';
import 'package:eschool/ui/widgets/groupedListCard.dart';
import 'package:eschool/ui/widgets/logoutButton.dart';
import 'package:eschool/utils/errorMessageKeysAndCodes.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsContainer extends StatelessWidget {
  const SettingsContainer({Key? key}) : super(key: key);

  Future<void> _shareApp(BuildContext context) async {
    final appUrl = context.read<AppConfigurationCubit>().getAppLink();
    if (await canLaunchUrl(Uri.parse(appUrl))) {
      launchUrl(Uri.parse(appUrl));
    } else {
      if (context.mounted) {
        Utils.showCustomSnackBar(
          context: context,
          errorMessage: Utils.getTranslatedLabel(
            ErrorMessageKeysAndCode.shareAppLinkKey,
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        );
      }
    }
  }

  void _openChangePassword(BuildContext context) {
    Utils.showBottomSheet(
      child: BlocProvider<ChangePasswordCubit>(
        create: (_) => ChangePasswordCubit(AuthRepository()),
        child: const ChangePasswordBottomsheet(),
      ),
      context: context,
    ).then((value) {
      if (value != null && !value['error']) {
        Utils.showCustomSnackBar(
          context: context,
          errorMessage: Utils.getTranslatedLabel(
            passwordChangedSuccessfullyKey,
          ),
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
        );
      }
    });
  }

  /// Language, transactions (parent only), password and notifications.
  Widget _buildAccountGroup(BuildContext context) {
    final isParent = context.read<AuthCubit>().isParent();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GroupCaption(title: Utils.getTranslatedLabel(accountAndSecurityKey)),
        GroupedListCard(
          groupIndex: 0,
          children: [
            //Rebuilt on its own so switching language updates the row label.
            BlocBuilder<AppLocalizationCubit, AppLocalizationState>(
              builder: (context, state) {
                return GroupedListRow(
                  icon: Icons.language_rounded,
                  accent: AppAccent.blue,
                  title:
                      context.read<AppLocalizationCubit>().currentLanguageName,
                  onTap: () => Utils.showBottomSheet(
                    child: const ChangeLanguageBottomsheetContainer(),
                    context: context,
                  ),
                );
              },
            ),
            if (isParent)
              GroupedListRow(
                icon: Icons.receipt_long_rounded,
                accent: AppAccent.teal,
                title: Utils.getTranslatedLabel(transactionsKey),
                onTap: () => Get.toNamed(Routes.transactions),
              ),
            GroupedListRow(
              icon: Icons.vpn_key_rounded,
              accent: AppAccent.orange,
              title: Utils.getTranslatedLabel(changePasswordKey),
              onTap: () => _openChangePassword(context),
            ),
            GroupedListRow(
              icon: Icons.notifications_rounded,
              accent: AppAccent.purple,
              title: Utils.getTranslatedLabel(notificationsKey),
              onTap: () => Get.toNamed(Routes.notifications),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAppInformationGroup(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GroupCaption(title: Utils.getTranslatedLabel(appInformationKey)),
        GroupedListCard(
          groupIndex: 1,
          children: [
            GroupedListRow(
              icon: Icons.shield_rounded,
              accent: AppAccent.blue,
              title: Utils.getTranslatedLabel(privacyPolicyKey),
              onTap: () => Get.toNamed(Routes.privacyPolicy),
            ),
            GroupedListRow(
              icon: Icons.description_rounded,
              accent: AppAccent.indigo,
              title: Utils.getTranslatedLabel(termsAndConditionKey),
              onTap: () => Get.toNamed(Routes.termsAndCondition),
            ),
            GroupedListRow(
              icon: Icons.info_rounded,
              accent: AppAccent.pink,
              title: Utils.getTranslatedLabel(aboutUsKey),
              onTap: () => Get.toNamed(Routes.aboutUs),
            ),
          ],
        ),
      ],
    );
  }

  /// Contact plus the two store links, which stay gated on the app link being
  /// configured in the panel.
  Widget _buildSupportGroup(BuildContext context) {
    final hasAppLink =
        context.read<AppConfigurationCubit>().getAppLink().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GroupCaption(title: Utils.getTranslatedLabel(supportKey)),
        GroupedListCard(
          groupIndex: 2,
          children: [
            GroupedListRow(
              icon: Icons.headset_mic_rounded,
              accent: AppAccent.teal,
              title: Utils.getTranslatedLabel(contactUsKey),
              onTap: () => Get.toNamed(Routes.contactUs),
            ),
            if (hasAppLink)
              GroupedListRow(
                icon: Icons.star_rounded,
                accent: AppAccent.orange,
                title: Utils.getTranslatedLabel(rateUsKey),
                onTap: () => _shareApp(context),
              ),
            if (hasAppLink)
              GroupedListRow(
                icon: Icons.share_rounded,
                accent: AppAccent.green,
                title: Utils.getTranslatedLabel(shareKey),
                onTap: () => _shareApp(context),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + AppSpacing.xs,
        bottom: Utils.getScrollViewBottomPadding(context) +
            MediaQuery.of(context).size.height *
                Utils.bottomNavigationHeightPercentage,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Students reach Settings from a bottom-nav tab, so there is nothing
          //to pop; only the parent flow pushes this screen.
          AppScreenHeader(
            title: Utils.getTranslatedLabel(settingsKey),
            showBackButton: context.read<AuthCubit>().isParent(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAccountGroup(context),
                const SizedBox(height: AppSpacing.lg),
                _buildAppInformationGroup(context),
                const SizedBox(height: AppSpacing.lg),
                _buildSupportGroup(context),
                const SizedBox(height: AppSpacing.lg),
                const LogoutButton(),
                const SizedBox(height: AppSpacing.sm),
                Center(
                  child: Text(
                    "${Utils.getTranslatedLabel(appVersionKey)}  ${context.read<AppConfigurationCubit>().getAppVersion()}",
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
