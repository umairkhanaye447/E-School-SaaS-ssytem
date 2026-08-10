import 'package:eschool/ui/styles/appTokens.dart';
import 'package:eschool/utils/utils.dart';
import 'package:flutter/material.dart';

class BottomNavItem {
  final String title;

  /// Filled glyph for the selected state, outline for the rest — the same
  /// pairing the reference design uses.
  final IconData activeIcon;
  final IconData icon;

  BottomNavItem({
    required this.activeIcon,
    required this.icon,
    required this.title,
  });
}

class BottomNavItemContainer extends StatefulWidget {
  final BoxConstraints boxConstraints;
  final int index;
  final int currentIndex;
  final AnimationController animationController;
  final BottomNavItem bottomNavItem;
  final Function onTap;
  final String showCaseDescription;
  const BottomNavItemContainer({
    Key? key,
    required this.boxConstraints,
    required this.currentIndex,
    required this.showCaseDescription,
    required this.bottomNavItem,
    required this.animationController,
    required this.onTap,
    required this.index,
  }) : super(key: key);

  @override
  State<BottomNavItemContainer> createState() => _BottomNavItemContainerState();
}

class _BottomNavItemContainerState extends State<BottomNavItemContainer> {
  @override
  Widget build(BuildContext context) {
    final bool isSelected = widget.index == widget.currentIndex;
    final Color selectedColor = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: () async {
        widget.onTap(widget.index);
      },
      child: SizedBox(
        width: widget.boxConstraints.maxWidth * (0.25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.05),
                end: const Offset(0.0, 0.35),
              ).animate(
                CurvedAnimation(
                  parent: widget.animationController,
                  curve: Curves.easeInOut,
                ),
              ),
              //Small overshoot pop when a tab becomes active — enough to feel
              //springy without moving neighbouring items.
              child: AnimatedScale(
                scale: isSelected ? 1.12 : 1.0,
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutBack,
                child: Icon(
                  isSelected
                      ? widget.bottomNavItem.activeIcon
                      : widget.bottomNavItem.icon,
                  size: 25,
                  color: isSelected ? selectedColor : AppColors.textTertiary,
                ),
              ),
            ),
            SizedBox(
              height: widget.boxConstraints.maxHeight * (0.051),
            ),
            FadeTransition(
              opacity: Tween<double>(begin: 1.0, end: 0.0)
                  .animate(widget.animationController),
              child: SlideTransition(
                position: Tween<Offset>(
                  // ignore: use_named_constants
                  begin: const Offset(0.0, 0.0),
                  end: const Offset(0.0, 0.5),
                ).animate(
                  CurvedAnimation(
                    parent: widget.animationController,
                    curve: Curves.easeInOut,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      Utils.getTranslatedLabel(
                        widget.bottomNavItem.title,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: isSelected
                                    ? selectedColor
                                    : AppColors.textTertiary,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                    ),
                    const SizedBox(height: 3),
                    //Underline marker beneath the active item.
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 3,
                      width: isSelected ? 18 : 0,
                      decoration: BoxDecoration(
                        color: selectedColor,
                        borderRadius: BorderRadius.circular(AppRadius.chip),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
