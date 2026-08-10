import 'package:eschool/ui/styles/appTokens.dart';
import 'package:eschool/ui/styles/appTypography.dart';
import 'package:flutter/material.dart';

/// Brand colours exposed on the theme.
///
/// This exists so the deferred branding layer becomes a drop-in change: when
/// the panel starts serving `primary_color` / `secondary_color`, only
/// [AppTheme.light] needs to read them — every widget already resolves brand
/// colour through `Theme.of(context).extension<AppBrand>()`.
@immutable
class AppBrand extends ThemeExtension<AppBrand> {
  final Color primary;
  final Color primaryDark;
  final Color secondary;
  final Color accent;
  final List<Color> heroGradient;

  const AppBrand({
    required this.primary,
    required this.primaryDark,
    required this.secondary,
    required this.accent,
    required this.heroGradient,
  });

  static const AppBrand fallback = AppBrand(
    primary: AppColors.brandPrimary,
    primaryDark: AppColors.brandPrimaryDark,
    secondary: AppColors.brandSecondary,
    accent: AppColors.brandAccent,
    heroGradient: AppColors.heroGradient,
  );

  @override
  AppBrand copyWith({
    Color? primary,
    Color? primaryDark,
    Color? secondary,
    Color? accent,
    List<Color>? heroGradient,
  }) {
    return AppBrand(
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      heroGradient: heroGradient ?? this.heroGradient,
    );
  }

  @override
  AppBrand lerp(ThemeExtension<AppBrand>? other, double t) {
    if (other is! AppBrand) return this;
    return AppBrand(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      heroGradient: <Color>[
        Color.lerp(heroGradient.first, other.heroGradient.first, t)!,
        Color.lerp(heroGradient.last, other.heroGradient.last, t)!,
      ],
    );
  }
}

/// Convenience access to brand colours from any widget.
extension AppBrandContext on BuildContext {
  AppBrand get brand =>
      Theme.of(this).extension<AppBrand>() ?? AppBrand.fallback;
}

class AppTheme {
  const AppTheme._();

  /// Builds the app theme. [brand] defaults to the Vismic Learn palette; the
  /// branding layer will pass a school-specific value here later.
  static ThemeData light({AppBrand brand = AppBrand.fallback}) {
    final textTheme = AppTypography.textTheme();

    return ThemeData(
      useMaterial3: false,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.pageBackground,
      canvasColor: AppColors.surface,
      dividerColor: AppColors.divider,
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[brand],
      // IMPORTANT: 532 existing call sites read colours from this scheme, and
      // several slots are used with NON-standard Material semantics. Preserve
      // the legacy meaning of each slot or migrated and unmigrated screens will
      // disagree:
      //
      //   primary     brand colour                          (164 uses) standard
      //   secondary   dark TEXT colour, not an accent        (123 uses)
      //   onPrimary   success GREEN used as a background,    ( 11 uses)
      //               e.g. the login success snackbar. Setting this to white
      //               per Material convention renders white-on-white.
      //   onSecondary success GREEN used as a value colour   ( 10 uses)
      //   tertiary    light grey fill / border               ( 26 uses)
      //   surface     muted page-level grey                  ( 55 uses)
      //   onSurface   body text                              ( 82 uses)
      //
      // Once every screen is migrated these can be normalised; until then the
      // mapping below is deliberate.
      colorScheme: ColorScheme.light(
        primary: brand.primary,
        onPrimary: AppColors.success,
        secondary: AppColors.textPrimary,
        onSecondary: AppColors.success,
        tertiary: AppColors.divider,
        //White, not the muted grey. The old scheme paired a grey `surface`
        //with a white page; the redesign tints the page instead, so a muted
        //surface leaves cards indistinguishable from the background — which
        //is what made Exam Timetable, Subject Details and Settings read as
        //empty.
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.danger,
        onError: AppColors.textOnBrand,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.pageBackground,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardAll),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brand.primary,
          foregroundColor: AppColors.textOnBrand,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          textStyle: textTheme.labelLarge?.copyWith(
            color: AppColors.textOnBrand,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.fieldAll,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: brand.primary,
          textStyle: textTheme.labelLarge?.copyWith(color: brand.primary),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: brand.primary,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: brand.primary),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.fieldAll,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textTertiary,
        ),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.fieldAll,
          borderSide: BorderSide(color: AppColors.divider),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.fieldAll,
          borderSide: BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.fieldAll,
          borderSide: BorderSide(color: brand.primary, width: 1.4),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.fieldAll,
          borderSide: BorderSide(color: AppColors.danger),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardAll),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: brand.primary,
        unselectedItemColor: AppColors.textTertiary,
        selectedLabelStyle: textTheme.labelMedium?.copyWith(
          color: brand.primary,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: textTheme.labelMedium,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceMuted,
        labelStyle: textTheme.labelMedium!,
        shape: const StadiumBorder(),
        side: BorderSide.none,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: brand.primary,
      ),
    );
  }
}
