import 'package:eschool/ui/styles/appTokens.dart';
import 'package:eschool/utils/utils.dart';
import 'package:flutter/material.dart';

class ScreenTopBackgroundContainer extends StatelessWidget {
  final Widget? child;
  final double? heightPercentage;
  final EdgeInsets? padding;
  const ScreenTopBackgroundContainer({
    Key? key,
    this.child,
    this.heightPercentage,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ??
          EdgeInsets.only(
            top: MediaQuery.of(context).padding.top +
                Utils.screenContentTopPadding,
          ),
      alignment: Alignment.topCenter,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height *
          (heightPercentage ?? Utils.appBarBiggerHeightPercentage),
      //Light header. Height and padding are deliberately untouched: every
      //screen offsets its scroll view by this widget's heightPercentage, so
      //changing the geometry would shift content on ~28 screens.
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
