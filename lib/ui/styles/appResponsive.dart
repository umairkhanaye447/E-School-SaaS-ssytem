import 'package:flutter/widgets.dart';

/// Breakpoint helpers for the redesign.
///
/// The existing screens size themselves with `MediaQuery.of(context).size *
/// fraction` in 334 places. That reads fine on a phone but breaks on tablets:
/// cards stretch edge to edge, text stays phone-sized, and grids keep their
/// phone column count at 1024px wide. Migrated screens should use fixed
/// spacing from `AppSpacing` plus these breakpoints instead of percentages.
enum AppBreakpoint { compact, medium, expanded }

class AppResponsive {
  const AppResponsive._();

  /// Phones in portrait.
  static const double compactMax = 600;

  /// Large phones in landscape, small tablets.
  static const double mediumMax = 905;

  static AppBreakpoint of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < compactMax) return AppBreakpoint.compact;
    if (width < mediumMax) return AppBreakpoint.medium;
    return AppBreakpoint.expanded;
  }

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).shortestSide >= compactMax;

  /// Column count for the dashboard feature grid. The reference shows 4 on a
  /// phone; wider surfaces get more columns rather than wider tiles.
  static int gridColumns(BuildContext context) {
    switch (of(context)) {
      case AppBreakpoint.compact:
        return 4;
      case AppBreakpoint.medium:
        return 6;
      case AppBreakpoint.expanded:
        return 8;
    }
  }

  /// Caps content width on tablets so a phone-shaped layout does not stretch
  /// into unreadable full-bleed rows.
  static double contentMaxWidth(BuildContext context) {
    switch (of(context)) {
      case AppBreakpoint.compact:
        return double.infinity;
      case AppBreakpoint.medium:
        return 720;
      case AppBreakpoint.expanded:
        return 960;
    }
  }

  /// Pick a value per breakpoint without a switch at the call site.
  static T value<T>(
    BuildContext context, {
    required T compact,
    T? medium,
    T? expanded,
  }) {
    switch (of(context)) {
      case AppBreakpoint.compact:
        return compact;
      case AppBreakpoint.medium:
        return medium ?? compact;
      case AppBreakpoint.expanded:
        return expanded ?? medium ?? compact;
    }
  }
}

/// Centres and width-caps page content on large screens. Wrap the body of a
/// migrated screen with this to get tablet behaviour for free.
class AppContentBounds extends StatelessWidget {
  final Widget child;

  const AppContentBounds({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: AppResponsive.contentMaxWidth(context),
        ),
        child: child,
      ),
    );
  }
}
