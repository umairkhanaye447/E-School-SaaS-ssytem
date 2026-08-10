import 'package:eschool/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/*
 change the effects to apply your own custom effects - only if you know about the flutter_animate package
*/
List<Effect<dynamic>> listItemAppearanceEffects(
    {required int itemIndex, int totalLoadedItems = 15}) {
  return isApplicationItemAnimationOn
      ? [
          FadeEffect(
            delay: Duration(
              milliseconds: (itemIndex % totalLoadedItems) *
                  (listItemAnimationDelayInMilliseconds - 9),
            ),
          ),
          SlideEffect(
            delay: Duration(
              milliseconds: (itemIndex % totalLoadedItems) *
                  listItemAnimationDelayInMilliseconds,
            ),
            curve: Curves.easeInOut,
            end: SlideEffect.neutralValue.copyWith(dx: 0),
            begin: SlideEffect.neutralValue.copyWith(dx: -0.5),
          ),
        ]
      : [];
}

List<Effect<dynamic>> customItemFadeAppearanceEffects() {
  return isApplicationItemAnimationOn
      ? [
          const FadeEffect(
            duration: Duration(
              milliseconds: itemFadeAnimationDurationInMilliseconds,
            ),
          ),
        ]
      : [];
}

List<Effect<dynamic>> customItemZoomAppearanceEffects({
  Duration? delay,
  Duration? duration,
}) {
  return isApplicationItemAnimationOn
      ? [
          ScaleEffect(
            delay: delay,
            duration: duration ??
                const Duration(
                  milliseconds: itemZoomAnimationDurationInMilliseconds,
                ),
          ),
        ]
      : [];
}

List<Effect<dynamic>> customItemBounceScaleAppearanceEffects() {
  return isApplicationItemAnimationOn
      ? [
          const ScaleEffect(
            duration: Duration(
              milliseconds: itemBouncScaleAnimationDurationInMilliseconds,
            ),
            curve: Curves.bounceOut,
          )
        ]
      : [];
}

/// Staggered appearance for grid tiles.
///
/// The list variant slides in from the leading edge, which looks wrong on a
/// grid — tiles in the same row would slide from different distances. This
/// fades and lifts instead, and staggers by position so a row resolves
/// left-to-right without any single tile drawing attention.
List<Effect<dynamic>> gridItemAppearanceEffects({
  required int itemIndex,
  int totalLoadedItems = 20,
}) {
  if (!isApplicationItemAnimationOn) return [];
  final delay = Duration(
    milliseconds: (itemIndex % totalLoadedItems) * 35,
  );
  return [
    FadeEffect(delay: delay, duration: const Duration(milliseconds: 220)),
    MoveEffect(
      delay: delay,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      begin: const Offset(0, 12),
      end: Offset.zero,
    ),
  ];
}

/// Appearance for a section that arrives as one block (a card, a banner).
List<Effect<dynamic>> sectionAppearanceEffects() {
  if (!isApplicationItemAnimationOn) return [];
  return [
    const FadeEffect(duration: Duration(milliseconds: 260)),
    MoveEffect(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      begin: const Offset(0, 16),
      end: Offset.zero,
    ),
  ];
}
