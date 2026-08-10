import 'package:eschool/ui/styles/appTokens.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Tint per module, matched to the hue of that module's icon art.
///
/// Deriving the tint from a hash produces clashes such as a green calendar on
/// a peach well, so the pairing is explicit. Unknown entries fall back to
/// [AppAccent.forKey] so a newly added menu item still renders sensibly.
const Map<String, AccentPair> menuAccents = <String, AccentPair>{
  attendanceKey: AppAccent.green,
  timeTableKey: AppAccent.blue,
  noticeBoardKey: AppAccent.orange,
  examsKey: AppAccent.red,
  resultKey: AppAccent.green,
  reportsKey: AppAccent.blue,
  guardianDetailsKey: AppAccent.teal,
  holidaysKey: AppAccent.orange,
  galleryKey: AppAccent.purple,
  myDiaryKey: AppAccent.pink,
  transportationKey: AppAccent.orange,
  certificateKey: AppAccent.blue,
  teachersKey: AppAccent.green,
  mySubjectsKey: AppAccent.indigo,
  assignmentsKey: AppAccent.purple,
};

AccentPair accentForMenu(String titleKey) =>
    menuAccents[titleKey] ?? AppAccent.forKey(titleKey);

/// Accent for a module tile keyed on its icon asset.
///
/// The student grid keys off label keys, but the parent menu carries
/// already-translated titles, so the two sides would hash to different hues.
/// Both now share the `dashboard/*.svg` set, which makes the asset name a
/// stable key across them.
const Map<String, AccentPair> _iconAccents = <String, AccentPair>{
  'assignment': AppAccent.purple,
  'attendance': AppAccent.green,
  'timetable': AppAccent.blue,
  'noticeboard': AppAccent.orange,
  'exams': AppAccent.red,
  'results': AppAccent.green,
  'reports': AppAccent.blue,
  'guardian': AppAccent.teal,
  'holidays': AppAccent.orange,
  'gallery': AppAccent.purple,
  'diary': AppAccent.pink,
  'transportation': AppAccent.orange,
  'certificate': AppAccent.blue,
  'teachers': AppAccent.green,
  'subjects': AppAccent.indigo,
  'chat': AppAccent.green,
  'settings': AppAccent.indigo,
  'fees': AppAccent.green,
};

AccentPair accentForIcon(String assetPath) {
  final name = assetPath.split('/').last.replaceAll('.svg', '');
  return _iconAccents[name] ?? AppAccent.forKey(name);
}

/// The shared tile card used across the app: a white card holding a 46pt
/// rounded icon well with a label beneath it.
///
/// [well] is supplied by the caller so the same card can hold an SVG module
/// icon, a network subject image, or a subject-code fallback.
class AppTileCard extends StatefulWidget {
  final Widget well;
  final String label;
  final VoidCallback? onTap;

  /// Lines allowed for the label. Module tiles use 2; subject tiles pass 1 so
  /// long names ellipsise on a single line rather than growing the tile.
  final int maxLabelLines;

  /// Grid aspect ratio. The reference tiles are close to square; this leaves
  /// just enough room for the well plus a two-line label at the default text
  /// scale. The label sits in a [Flexible], so a larger accessibility scale
  /// ellipsises rather than overflowing.
  static const double aspectRatio = 0.90;

  /// Edge length of the icon well.
  static const double wellSize = 42;

  /// Gap between tiles, matching the reference grid.
  static const double gridSpacing = 10;

  const AppTileCard({
    Key? key,
    required this.well,
    required this.label,
    this.onTap,
    this.maxLabelLines = 2,
  }) : super(key: key);

  @override
  State<AppTileCard> createState() => _AppTileCardState();
}

class _AppTileCardState extends State<AppTileCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.96 : 1,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: _buildCard(context),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.cardAll,
      child: InkWell(
        onTap: widget.onTap,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        borderRadius: AppRadius.cardAll,
        child: Ink(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.cardAll,
            boxShadow: AppShadows.card,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxs,
            vertical: AppSpacing.xs,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: AppTileCard.wellSize,
                width: AppTileCard.wellSize,
                child: widget.well,
              ),
              const SizedBox(height: 6),
              // Multi-word labels ("Guardian Details") wrap onto two lines.
              // A single long word ("Transportation") cannot wrap without
              // breaking mid-word, so it shrinks to fit instead.
              Flexible(
                child: _TileLabel(
                  label: widget.label,
                  maxLines: widget.maxLabelLines,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A menu entry rendered as an [AppTileCard] with a tinted SVG well.
class FeatureTile extends StatelessWidget {
  final String iconAssetPath;
  final String label;
  final AccentPair accent;
  final VoidCallback onTap;

  const FeatureTile({
    Key? key,
    required this.iconAssetPath,
    required this.label,
    required this.accent,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppTileCard(
      label: label,
      onTap: onTap,
      well: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: accent.tint,
          borderRadius: AppRadius.iconTileAll,
        ),
        child: SvgPicture.asset(iconAssetPath),
      ),
    );
  }
}

class _TileLabel extends StatelessWidget {
  final String label;
  final int maxLines;

  const _TileLabel({required this.label, this.maxLines = 2});

  @override
  Widget build(BuildContext context) {
    // Slightly tighter than labelMedium: the reference tile labels are small
    // and dense, with a touch of letter-spacing to stay legible at 11pt.
    final style = Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.textPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          height: 1.15,
          letterSpacing: 0.1,
        );

    final isMultiWord = label.trim().contains(' ');

    final text = Text(
      label,
      maxLines: isMultiWord ? maxLines : 1,
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      style: style,
    );

    // A FittedBox hands its child unbounded width, which would collapse a
    // multi-word label onto a single line. Only single words — which cannot
    // wrap anyway — get the shrink-to-fit treatment. scaleDown never enlarges,
    // so short labels keep their designed size.
    return isMultiWord ? text : FittedBox(fit: BoxFit.scaleDown, child: text);
  }
}
