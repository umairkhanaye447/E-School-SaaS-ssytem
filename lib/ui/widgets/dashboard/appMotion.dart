import 'package:eschool/utils/constants.dart';
import 'package:flutter/material.dart';

/// Crossfades between loading, error and loaded content instead of swapping
/// them instantly.
///
/// Cubit-driven screens rebuild with a completely different subtree when the
/// state changes, so content used to *pop* in the moment a request finished.
/// Wrapping the builder's result here fades the shimmer out as the real
/// content fades in, which is the difference between "functional" and
/// "polished" at no cost to the data flow.
///
/// [stateKey] must change when the state changes — usually the runtime type of
/// the cubit state — otherwise the switcher sees the same child and skips the
/// transition.
class StateCrossfade extends StatelessWidget {
  final Widget child;
  final Object stateKey;
  final Duration duration;

  const StateCrossfade({
    Key? key,
    required this.child,
    required this.stateKey,
    this.duration = const Duration(milliseconds: 260),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isApplicationItemAnimationOn) return child;

    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      //The default layout builder stacks children centred, which makes
      //differently-sized states jump. Aligning to the top keeps the content
      //anchored while it crossfades.
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.topCenter,
        children: [...previous, if (current != null) current],
      ),
      child: KeyedSubtree(key: ValueKey(stateKey), child: child),
    );
  }
}

/// Counts a number up to its final value when it first appears.
///
/// Used for the figures a viewer's eye goes to — attendance and result
/// percentages, fee totals. The value is still rendered as plain text, so
/// nothing changes for screen readers once the animation settles.
class AnimatedCountText extends StatelessWidget {
  final double value;
  final TextStyle? style;
  final int decimals;
  final String suffix;
  final Duration duration;

  const AnimatedCountText({
    Key? key,
    required this.value,
    this.style,
    this.decimals = 0,
    this.suffix = '',
    this.duration = const Duration(milliseconds: 700),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isApplicationItemAnimationOn) {
      return Text('${value.toStringAsFixed(decimals)}$suffix', style: style);
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Text(
        '${v.toStringAsFixed(decimals)}$suffix',
        style: style,
      ),
    );
  }
}
