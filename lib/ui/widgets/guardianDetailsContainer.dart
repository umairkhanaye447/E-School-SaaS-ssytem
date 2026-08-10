import 'package:eschool/data/models/guardian.dart';
import 'package:eschool/ui/styles/appTokens.dart';
import 'package:eschool/ui/widgets/customUserProfileImageWidget.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/utils.dart';
import 'package:flutter/material.dart';

/// Guardian card: ringed avatar and name at the top, then one row per detail.
///
/// The previous version hung the avatar 40px above the card's top edge and
/// separated it with a heavy 75%-alpha rule, which read as a broken layout —
/// the avatar appeared to float outside its own container. Everything now sits
/// inside the card, on the same row/hairline pattern used elsewhere.
class GuardianDetailsContainer extends StatelessWidget {
  final Guardian guardian;

  const GuardianDetailsContainer({
    Key? key,
    required this.guardian,
  }) : super(key: key);

  Widget _detailRow({
    required BuildContext context,
    required IconData icon,
    required AccentPair accent,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 38,
            width: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.tint,
              borderRadius: BorderRadius.circular(AppRadius.field),
            ),
            child: Icon(icon, size: 20, color: accent.icon),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 1),
                Text(value, style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final address = guardian.currentAddress ?? "";
    final mobile = guardian.mobile ?? "";

    final rows = <Widget>[
      _detailRow(
        context: context,
        icon: Icons.person_rounded,
        accent: AppAccent.blue,
        title: Utils.getTranslatedLabel(nameKey),
        value: Utils.formatEmptyValue(guardian.getFullName()),
      ),
      _detailRow(
        context: context,
        icon: Icons.mail_rounded,
        accent: AppAccent.indigo,
        title: Utils.getTranslatedLabel(emailKey),
        value: Utils.formatEmptyValue(guardian.email ?? ""),
      ),
      if (mobile.isNotEmpty)
        _detailRow(
          context: context,
          icon: Icons.phone_rounded,
          accent: AppAccent.green,
          title: Utils.getTranslatedLabel(phoneNumberKey),
          value: Utils.formatEmptyValue(mobile),
        ),
      if (address.isNotEmpty)
        _detailRow(
          context: context,
          icon: Icons.location_on_rounded,
          accent: AppAccent.orange,
          title: Utils.getTranslatedLabel(addressKey),
          value: Utils.formatEmptyValue(address),
        ),
    ];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      decoration: const BoxDecoration(
        borderRadius: AppRadius.cardAll,
        color: AppColors.surface,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.lg,
              bottom: AppSpacing.md,
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    final imageUrl = guardian.image ?? '';
                    if (imageUrl.isNotEmpty) {
                      Utils.showImagePreview(
                        context: context,
                        imageUrl: imageUrl,
                        heroTag: 'guardian_profile_image_${guardian.id}',
                      );
                    }
                  },
                  child: Hero(
                    tag: 'guardian_profile_image_${guardian.id}',
                    child: Container(
                      height: 84,
                      width: 84,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surface,
                        border: Border.all(
                          color: AppColors.divider,
                          width: 1.5,
                        ),
                        boxShadow: AppShadows.card,
                      ),
                      child: ClipOval(
                        child: CustomUserProfileImageWidget(
                          profileUrl: guardian.image ?? "",
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Text(
                    Utils.formatEmptyValue(guardian.getFullName()),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.divider,
          ),
          for (var i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i != rows.length - 1)
              const Padding(
                padding: EdgeInsetsDirectional.only(start: 66),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.divider,
                ),
              ),
          ],
          const SizedBox(height: AppSpacing.xs),
        ],
      ),
    );
  }
}
