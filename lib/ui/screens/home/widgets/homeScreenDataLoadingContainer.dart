import 'package:eschool/ui/styles/appTokens.dart';
import 'package:eschool/ui/widgets/customShimmerContainer.dart';
import 'package:eschool/ui/widgets/shimmerLoaders/announcementShimmerLoadingContainer.dart';
import 'package:eschool/ui/widgets/shimmerLoadingContainer.dart';
import 'package:flutter/material.dart';

/// Skeleton for the redesigned dashboard: profile header row, hero banner,
/// menu tile grid and notice placeholders — mirroring the loaded layout so
/// the crossfade to real content doesn't jump.
class HomeScreenDataLoadingContainer extends StatelessWidget {
  final bool addTopPadding;
  const HomeScreenDataLoadingContainer(
      {super.key, required this.addTopPadding});

  Widget _profileHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenH,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          const ShimmerLoadingContainer(
            child: CustomShimmerContainer(
              height: 48,
              width: 48,
              borderRadius: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerLoadingContainer(
                  child: CustomShimmerContainer(
                    height: 12,
                    width: 110,
                    borderRadius: AppRadius.field,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                ShimmerLoadingContainer(
                  child: CustomShimmerContainer(
                    height: 16,
                    width: 160,
                    borderRadius: AppRadius.field,
                  ),
                ),
              ],
            ),
          ),
          const ShimmerLoadingContainer(
            child: CustomShimmerContainer(
              height: 44,
              width: 44,
              borderRadius: AppRadius.iconTile,
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuGrid(BuildContext context) {
    final tileWidth = (MediaQuery.sizeOf(context).width -
            AppSpacing.screenH * 2 -
            AppSpacing.sm * 3) /
        4;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          4,
          (_) => ShimmerLoadingContainer(
            child: CustomShimmerContainer(
              height: tileWidth,
              width: tileWidth,
              borderRadius: AppRadius.card,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(
        top: addTopPadding ? MediaQuery.paddingOf(context).top : AppSpacing.lg,
      ),
      children: [
        _profileHeader(context),
        ShimmerLoadingContainer(
          child: CustomShimmerContainer(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
            width: MediaQuery.sizeOf(context).width,
            borderRadius: AppRadius.hero,
            height: 200,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _menuGrid(context),
        const SizedBox(height: AppSpacing.lg),
        Column(
          children: List.generate(3, (index) => index)
              .map((notice) => const AnnouncementShimmerLoadingContainer())
              .toList(),
        )
      ],
    );
  }
}
