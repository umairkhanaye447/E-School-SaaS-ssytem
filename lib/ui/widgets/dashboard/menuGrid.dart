import 'package:eschool/ui/styles/appResponsive.dart';
import 'package:eschool/ui/widgets/dashboard/featureTile.dart';
import 'package:eschool/utils/homeBottomsheetMenu.dart';
import 'package:eschool/utils/utils.dart';
import 'package:eschool/utils/animationConfiguration.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';

/// Grid of the app's module shortcuts, previously shown in the more-menu
/// bottom sheet and now rendered inline on the home screen.
///
/// Entries, module gating and tap indices are unchanged: [onTapMenuItem]
/// receives the item's index in the *unfiltered* [homeBottomSheetMenu], which
/// is what the existing navigation handler expects.
class MenuGrid extends StatelessWidget {
  final void Function(int menuIndex) onTapMenuItem;

  const MenuGrid({Key? key, required this.onTapMenuItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final visible = homeBottomSheetMenu
        .where((menu) => Utils.isModuleEnabled(
              context: context,
              moduleId: menu.menuModuleId,
            ))
        .toList();

    if (visible.isEmpty) return const SizedBox();

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: visible.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: AppResponsive.gridColumns(context),
        crossAxisSpacing: AppTileCard.gridSpacing,
        mainAxisSpacing: AppTileCard.gridSpacing,
        childAspectRatio: AppTileCard.aspectRatio,
      ),
      itemBuilder: (context, index) {
        final menu = visible[index];
        return Animate(
          effects: gridItemAppearanceEffects(
            itemIndex: index,
            totalLoadedItems: visible.length,
          ),
          child: FeatureTile(
            iconAssetPath: menu.iconUrl,
            label: Utils.getTranslatedLabel(menu.tileLabel),
            accent: accentForIcon(menu.iconUrl),
            onTap: () => onTapMenuItem(
              homeBottomSheetMenu
                  .indexWhere((element) => element.title == menu.title),
            ),
          ),
        );
      },
    );
  }
}
