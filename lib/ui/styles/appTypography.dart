import 'package:eschool/ui/styles/appTokens.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Type ramp for the redesign.
///
/// The app already bundles Poppins via `google_fonts/`, so this keeps the same
/// family and only fixes the scale — the existing code sets sizes inline in
/// 528 places, which is what makes hierarchy inconsistent today.
///
/// Names map onto the reference dashboard:
///   [h1]      "Rahim Hassan"      — screen/user title
///   [h2]      "Santona School"    — hero headline
///   [title]   "My Dashboard"      — section heading
///   [subtitle]"Monthly Parents…"  — list-row title
///   [body]    notice description
///   [caption] dates, meta
///   [label]   tile labels, chips, nav
class AppTypography {
  const AppTypography._();

  static TextTheme textTheme() {
    return TextTheme(
      displaySmall: _poppins(28, FontWeight.w700, AppColors.textPrimary),
      headlineMedium: _poppins(22, FontWeight.w700, AppColors.textPrimary),
      headlineSmall: _poppins(20, FontWeight.w600, AppColors.textPrimary),
      titleLarge: _poppins(18, FontWeight.w600, AppColors.textPrimary),
      titleMedium: _poppins(16, FontWeight.w600, AppColors.textPrimary),
      titleSmall: _poppins(15, FontWeight.w500, AppColors.textPrimary),
      bodyLarge: _poppins(15, FontWeight.w400, AppColors.textPrimary),
      bodyMedium: _poppins(14, FontWeight.w400, AppColors.textSecondary),
      bodySmall: _poppins(12, FontWeight.w400, AppColors.textSecondary),
      labelLarge: _poppins(14, FontWeight.w600, AppColors.textPrimary),
      labelMedium: _poppins(12, FontWeight.w500, AppColors.textSecondary),
      labelSmall: _poppins(11, FontWeight.w500, AppColors.textTertiary),
    );
  }

  static TextStyle _poppins(double size, FontWeight weight, Color color) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 1.35,
      //Explicitly zero: the Material baseline typography applies tracking to
      //the small label styles, which made dates and captions read as though
      //they were spaced out letter by letter.
      letterSpacing: 0,
    );
  }

  ///[Convenience accessors]
  //Screens migrated to the new design read styles from the theme; these
  //shorthands keep call sites short without reintroducing inline TextStyles.
  static TextStyle h1(BuildContext c) =>
      Theme.of(c).textTheme.headlineMedium!;
  static TextStyle h2(BuildContext c) => Theme.of(c).textTheme.headlineSmall!;
  static TextStyle title(BuildContext c) => Theme.of(c).textTheme.titleLarge!;
  static TextStyle subtitle(BuildContext c) =>
      Theme.of(c).textTheme.titleMedium!;
  static TextStyle body(BuildContext c) => Theme.of(c).textTheme.bodyMedium!;
  static TextStyle caption(BuildContext c) => Theme.of(c).textTheme.bodySmall!;
  static TextStyle label(BuildContext c) => Theme.of(c).textTheme.labelMedium!;
}
