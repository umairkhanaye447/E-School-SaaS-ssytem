import 'package:flutter/material.dart';

/// Design tokens derived from the Vismic Learn dashboard reference.
///
/// This is the single source of truth for colour, spacing, radius and
/// elevation. Widgets should prefer reading these through [Theme.of] (see
/// `appTheme.dart`); direct token access is acceptable for decorative values
/// that do not belong in [ThemeData], such as the accent tints below.
///
/// Everything here is `const` so it stays usable inside `const` widget trees.
/// When the branding layer lands, the *brand* colours below become the
/// fallback defaults and the runtime values arrive via a ThemeExtension.
class AppColors {
  const AppColors._();

  ///[Brand]
  static const Color brandPrimary = Color(0xFF1B4DE4);
  static const Color brandPrimaryDark = Color(0xFF0B2FA8);
  static const Color brandPrimaryLight = Color(0xFF4F7BFF);
  static const Color brandSecondary = Color(0xFF0F172A);
  static const Color brandAccent = Color(0xFFFFC107);

  /// Gradient used by the dashboard hero card, top to bottom-right.
  static const List<Color> heroGradient = <Color>[
    Color(0xFF1E50E2),
    Color(0xFF0B2FA8),
  ];

  ///[Neutrals]
  static const Color pageBackground = Color(0xFFF5F7FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF7F8FB);
  static const Color divider = Color(0xFFEEF1F6);

  static const Color textPrimary = Color(0xFF1A1D29);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9AA1AE);
  static const Color textOnBrand = Color(0xFFFFFFFF);

  ///[Semantic]
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF97316);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  ///[Shimmer]
  static const Color shimmerBase = Color(0xFFE9EDF5);
  static const Color shimmerHighlight = Color(0xFFF7F9FC);
}

/// Tint + icon colour pairs used by the dashboard feature tiles, status chips
/// and list-row leading icons.
///
/// The reference design assigns each module its own hue; keeping the pairs
/// together here stops the two halves drifting apart across screens.
class AppAccent {
  const AppAccent._();

  static const AccentPair green =
      AccentPair(tint: Color(0xFFE8F7EE), icon: Color(0xFF22C55E));
  static const AccentPair blue =
      AccentPair(tint: Color(0xFFE7F0FE), icon: Color(0xFF3B82F6));
  static const AccentPair purple =
      AccentPair(tint: Color(0xFFF0EBFE), icon: Color(0xFF8B5CF6));
  static const AccentPair orange =
      AccentPair(tint: Color(0xFFFFF1E6), icon: Color(0xFFF97316));
  static const AccentPair red =
      AccentPair(tint: Color(0xFFFEECEC), icon: Color(0xFFEF4444));
  static const AccentPair teal =
      AccentPair(tint: Color(0xFFE6F7F5), icon: Color(0xFF14B8A6));
  static const AccentPair pink =
      AccentPair(tint: Color(0xFFFDECF3), icon: Color(0xFFEC4899));
  static const AccentPair indigo =
      AccentPair(tint: Color(0xFFEAECFD), icon: Color(0xFF6366F1));

  /// Ordered list used when a hue has to be derived from an index, e.g. a
  /// dynamic module grid whose entries are not known at compile time.
  static const List<AccentPair> cycle = <AccentPair>[
    green,
    blue,
    purple,
    orange,
    red,
    teal,
    pink,
    indigo,
  ];

  /// Stable hue for [key] so the same module keeps the same colour between
  /// launches, even when enabled-module filtering changes the grid order.
  static AccentPair forKey(String key) {
    if (key.isEmpty) return blue;
    var hash = 0;
    for (var i = 0; i < key.length; i++) {
      hash = (hash + key.codeUnitAt(i) * (i + 1)) & 0x7fffffff;
    }
    return cycle[hash % cycle.length];
  }
}

@immutable
class AccentPair {
  final Color tint;
  final Color icon;

  const AccentPair({required this.tint, required this.icon});
}

/// 4pt spacing scale. Use these instead of bare numbers so rhythm stays
/// consistent as screens are migrated.
class AppSpacing {
  const AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;

  /// Horizontal gutter for screen-level content.
  static const double screenH = 16;
}

/// Corner radii. The existing codebase mixes 12 different values; these four
/// replace all of them.
class AppRadius {
  const AppRadius._();

  static const double chip = 999;
  static const double field = 12;
  static const double iconTile = 14;
  static const double card = 16;
  static const double hero = 20;
  static const double sheet = 24;

  static const BorderRadius cardAll = BorderRadius.all(Radius.circular(card));
  static const BorderRadius heroAll = BorderRadius.all(Radius.circular(hero));
  static const BorderRadius fieldAll = BorderRadius.all(Radius.circular(field));
  static const BorderRadius iconTileAll =
      BorderRadius.all(Radius.circular(iconTile));

  /// Bottom sheets are rounded on the top edge only.
  static const BorderRadius sheetTop = BorderRadius.only(
    topLeft: Radius.circular(sheet),
    topRight: Radius.circular(sheet),
  );
}

/// The reference design is almost flat — depth comes from tint fills rather
/// than heavy drop shadows. Two levels cover the whole app.
class AppShadows {
  const AppShadows._();

  /// Cards, tiles, list containers.
  ///
  /// The key is the NEGATIVE spread. Without it a blurred shadow bleeds out
  /// past the card on every side and reads as a second, darker card sitting
  /// behind — which is exactly how the previous version looked. Pulling the
  /// shadow in tighter than the card and pushing it down means only the lower
  /// edge shows, which is what the eye reads as elevation.
  ///
  /// Two layers: a wide, very soft ambient shadow for depth, and a small
  /// close one that grounds the card without hardening its edge.
  static const List<BoxShadow> card = <BoxShadow>[
    BoxShadow(
      color: Color(0x12101828),
      blurRadius: 24,
      offset: Offset(0, 8),
      spreadRadius: -8,
    ),
    BoxShadow(
      color: Color(0x0D101828),
      blurRadius: 8,
      offset: Offset(0, 3),
      spreadRadius: -3,
    ),
  ];

  /// A more pronounced card shadow for content that must read as clearly
  /// lifted off the page — transport plan cards, for example, where the soft
  /// default was too faint to separate stacked cards.
  static const List<BoxShadow> cardStrong = <BoxShadow>[
    BoxShadow(
      color: Color(0x1F101828),
      blurRadius: 32,
      offset: Offset(0, 12),
      spreadRadius: -10,
    ),
    BoxShadow(
      color: Color(0x14101828),
      blurRadius: 10,
      offset: Offset(0, 4),
      spreadRadius: -4,
    ),
  ];

  /// Floating surfaces: bottom nav, sheets, dialogs.
  static const List<BoxShadow> raised = <BoxShadow>[
    BoxShadow(
      color: Color(0x14101828),
      blurRadius: 24,
      offset: Offset(0, -2),
    ),
  ];
}
