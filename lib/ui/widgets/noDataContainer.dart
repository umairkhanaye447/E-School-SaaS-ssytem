import 'package:eschool/ui/styles/appTokens.dart';
import 'package:eschool/utils/animationConfiguration.dart';
import 'package:eschool/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Centers the no-data artwork in the *visible* portion of the screen.
///
/// Inside a scroll view a plain [Center] collapses to its child's height, so
/// the artwork ends up near the top of the screen instead of the middle. This
/// wrapper reserves the rest of the visible viewport and centers within it.
///
/// [occupiedHeight] is the vertical space already consumed around this widget
/// — the scroll view's top/bottom padding, app bar, filter rows — which the
/// call site knows and this widget cannot measure.
class CenteredNoDataContainer extends StatelessWidget {
  final String titleKey;
  final double occupiedHeight;
  final bool animate;
  final Color? textColor;

  const CenteredNoDataContainer({
    Key? key,
    required this.titleKey,
    this.occupiedHeight = 0,
    this.animate = true,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final available = media.size.height - media.padding.top - occupiedHeight;

    return SizedBox(
      //Never squash below what the artwork + caption need on short screens.
      height: available.clamp(320.0, media.size.height),
      child: Center(
        child: NoDataContainer(
          titleKey: titleKey,
          animate: animate,
          textColor: textColor,
        ),
      ),
    );
  }
}

class NoDataContainer extends StatelessWidget {
  final Color? textColor;
  final String titleKey;
  final bool animate;
  const NoDataContainer(
      {Key? key, this.textColor, required this.titleKey, this.animate = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: animate ? customItemBounceScaleAppearanceEffects() : null,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //Capped rather than a flat 35% of screen height: the old ratio
            //overwhelmed short screens and stretched the art on tablets.
            SizedBox(
              height: (MediaQuery.sizeOf(context).height * 0.24).clamp(
                140.0,
                240.0,
              ),
              child: SvgPicture.asset(
                Utils.getImagePath("fileNotFound.svg"),
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                Utils.getTranslatedLabel(titleKey),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: textColor ?? AppColors.textSecondary,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
