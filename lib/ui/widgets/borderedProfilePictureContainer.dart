import 'package:eschool/ui/widgets/customUserProfileImageWidget.dart';

import 'package:eschool/ui/styles/appTokens.dart';
import 'package:flutter/material.dart';

class BorderedProfilePictureContainer extends StatelessWidget {
  final String imageUrl;
  final Function? onTap;
  final double heightAndWidth;
  const BorderedProfilePictureContainer({
    Key? key,
    required this.imageUrl,
    required this.heightAndWidth,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(
        heightAndWidth * 0.5,
      ),
      onTap: () {
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(3.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surface,
          border: Border.all(color: AppColors.divider, width: 1.5),
          boxShadow: AppShadows.card,
        ),
        width: heightAndWidth,
        height: heightAndWidth,
        child: ClipOval(
          child: CustomUserProfileImageWidget(profileUrl: imageUrl),
        ),
      ),
    );
  }
}
