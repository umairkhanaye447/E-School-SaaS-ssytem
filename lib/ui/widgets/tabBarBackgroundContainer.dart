import 'package:eschool/ui/styles/appTokens.dart';
import 'package:flutter/material.dart';

/// The sliding thumb of the Offline/Online segmented control.
///
/// Both this and the labels used to be painted in `scaffoldBackgroundColor` so
/// they'd read as white against the old blue header. The header is light now,
/// so the whole control was invisible: the thumb is an explicit white surface
/// with a shadow, and the track is drawn behind it by [SegmentedTrack].
class TabBarBackgroundContainer extends StatelessWidget {
  final BoxConstraints boxConstraints;

  const TabBarBackgroundContainer({Key? key, required this.boxConstraints})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: boxConstraints.maxWidth * (0.1),
        right: boxConstraints.maxWidth * (0.1),
        top: boxConstraints.maxHeight * (0.125),
      ),
      height: boxConstraints.maxHeight * (0.325),
      width: boxConstraints.maxWidth * (0.375),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.field),
        boxShadow: AppShadows.card,
      ),
    );
  }
}

/// Recessed track the thumb slides within, so the control reads as a filter
/// even before the user touches it.
class SegmentedTrack extends StatelessWidget {
  final BoxConstraints boxConstraints;

  const SegmentedTrack({Key? key, required this.boxConstraints})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        margin: EdgeInsets.only(
          left: boxConstraints.maxWidth * (0.1) - 4,
          top: boxConstraints.maxHeight * (0.125) - 4,
        ),
        height: boxConstraints.maxHeight * (0.325) + 8,
        //Spans both segments plus the gap between them.
        width: boxConstraints.maxWidth * (0.375) * 2 +
            boxConstraints.maxWidth * (0.2) +
            8,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.divider),
        ),
      ),
    );
  }
}
