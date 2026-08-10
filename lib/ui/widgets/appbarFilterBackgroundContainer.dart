import 'package:eschool/utils/constants.dart';
import 'package:eschool/ui/styles/appTokens.dart';
import 'package:flutter/material.dart';

class AppbarFilterBackgroundContainer extends StatelessWidget {
  final Widget child;
  final double height;
  const AppbarFilterBackgroundContainer(
      {super.key, required this.child, this.height = 70});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: height,
      padding: EdgeInsets.all(appContentHorizontalPadding),
      decoration: const BoxDecoration(
        color: AppColors.pageBackground,
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: child,
    );
  }
}
