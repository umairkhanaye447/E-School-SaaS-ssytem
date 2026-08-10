import 'dart:async';

import 'package:eschool/ui/styles/appTheme.dart';
import 'package:eschool/ui/styles/appTokens.dart';
import 'package:eschool/ui/widgets/networkImageHandler.dart';
import 'package:eschool/utils/utils.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

/// Welcome banner at the top of the home screen: a brand-gradient card whose
/// right edge curves away to reveal the school photo, with paging dots when
/// more than one image is available.
class DashboardHeroCard extends StatefulWidget {
  final String welcomeLabel;
  final String title;
  final String subtitle;
  final String tagline;
  final String actionLabel;
  final VoidCallback? onTapAction;
  final List<String> imageUrls;

  const DashboardHeroCard({
    Key? key,
    required this.welcomeLabel,
    required this.title,
    required this.subtitle,
    required this.tagline,
    required this.actionLabel,
    required this.imageUrls,
    this.onTapAction,
  }) : super(key: key);

  @override
  State<DashboardHeroCard> createState() => _DashboardHeroCardState();
}

class _DashboardHeroCardState extends State<DashboardHeroCard> {
  late final PageController _pageController = PageController();
  int _page = 0;
  Timer? _autoAdvance;

  /// How long each school photo stays on screen.
  static const Duration _dwell = Duration(seconds: 4);

  @override
  void didUpdateWidget(covariant DashboardHeroCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    //Images arrive asynchronously, so the timer starts once there is more
    //than one to cycle through.
    _syncAutoAdvance();
  }

  @override
  void initState() {
    super.initState();
    _syncAutoAdvance();
  }

  void _syncAutoAdvance() {
    final count = widget.imageUrls.where((e) => e.trim().isNotEmpty).length;
    if (count > 1) {
      _autoAdvance ??= Timer.periodic(_dwell, (_) => _advance(count));
    } else {
      _autoAdvance?.cancel();
      _autoAdvance = null;
    }
  }

  void _advance(int count) {
    if (!mounted || !_pageController.hasClients) return;
    _pageController.animateToPage(
      (_page + 1) % count,
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _autoAdvance?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final images = widget.imageUrls.where((e) => e.trim().isNotEmpty).toList();

    final media = MediaQuery.of(context);
    //The card must grow with the user's system font size and on narrow
    //screens (where the title wraps sooner), otherwise the copy column
    //overflows the fixed height and the button collides with the dots.
    final double textScale = media.textScaler.scale(1.0).clamp(1.0, 1.3);
    final double heroHeight =
        (media.size.width < 370 ? 218.0 : 200.0) * textScale;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      height: heroHeight,
      decoration: BoxDecoration(
        borderRadius: AppRadius.heroAll,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: brand.heroGradient,
        ),
        boxShadow: AppShadows.card,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.heroAll,
        child: Stack(
          fit: StackFit.expand,
          children: [
            //Photo sits on the right, clipped by the sweeping curve.
            PositionedDirectional(
              top: 0,
              bottom: 0,
              end: 0,
              width: MediaQuery.sizeOf(context).width * 0.52,
              child: ClipPath(
                clipper: _HeroCurveClipper(),
                child: images.isEmpty
                    ? _PhotoFallback(background: brand.primaryDark)
                    : PageView.builder(
                        controller: _pageController,
                        itemCount: images.length,
                        onPageChanged: (i) {
                          setState(() => _page = i);
                          //Restart the dwell so a manual swipe is not
                          //immediately overridden by a pending tick.
                          if (_autoAdvance != null) {
                            _autoAdvance!.cancel();
                            _autoAdvance = Timer.periodic(
                              _dwell,
                              (_) => _advance(images.length),
                            );
                          }
                        },
                        itemBuilder: (_, i) => NetworkImageHandler(
                          imageUrl: images[i],
                          fit: BoxFit.cover,
                          placeholder:
                              _PhotoFallback(background: brand.primaryDark),
                          errorWidget:
                              _PhotoFallback(background: brand.primaryDark),
                        ),
                      ),
              ),
            ),

            //Copy block. Constrained to the left ~58% so long school names
            //wrap instead of running under the photo.
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FractionallySizedBox(
                widthFactor: 0.58,
                child: Padding(
                  //Extra bottom inset keeps the action button clear of the
                  //paging-dots row on every screen size.
                  padding: EdgeInsets.only(
                    left: AppSpacing.md,
                    right: AppSpacing.md,
                    top: AppSpacing.sm,
                    bottom:
                        AppSpacing.sm + (images.length > 1 ? AppSpacing.md : 0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.welcomeLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textOnBrand,
                            ),
                      ),
                      const SizedBox(height: 2),
                      //Flexible lets the text give up lines instead of
                      //overflowing when space runs out on small screens.
                      Flexible(
                        child: Text(
                          widget.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: AppColors.textOnBrand,
                                fontWeight: FontWeight.w700,
                                height: 1.15,
                              ),
                        ),
                      ),
                      if (widget.subtitle.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          widget.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textOnBrand,
                                  ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        height: 3,
                        width: 26,
                        decoration: BoxDecoration(
                          color: brand.accent,
                          borderRadius: BorderRadius.circular(AppRadius.chip),
                        ),
                      ),
                      if (widget.tagline.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Flexible(
                          child: Text(
                            widget.tagline,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textOnBrand,
                                    ),
                          ),
                        ),
                      ],
                      if (widget.onTapAction != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        _ExploreButton(
                          label: widget.actionLabel,
                          onTap: widget.onTapAction!,
                          color: brand.primary,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            //Dots live under the photo half only, so they can never overlap
            //the copy block or its action button.
            if (images.length > 1)
              PositionedDirectional(
                bottom: AppSpacing.sm,
                end: 0,
                width: MediaQuery.sizeOf(context).width * 0.42,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (i) {
                    final active = i == _page;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 6,
                      width: active ? 18 : 6,
                      decoration: BoxDecoration(
                        color: AppColors.textOnBrand
                            .withValues(alpha: active ? 1 : 0.45),
                        borderRadius: BorderRadius.circular(AppRadius.chip),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ExploreButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ExploreButton({
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
        boxShadow: AppShadows.card,
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(width: 5),
            Icon(Icons.arrow_forward_rounded, size: 15, color: color),
          ],
        ),
      ),
    );
  }
}

/// Sweeping concave edge on the leading side of the hero photo.
class _HeroCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(size.width * 0.30, 0)
      ..quadraticBezierTo(
        -size.width * 0.06,
        size.height * 0.5,
        size.width * 0.30,
        size.height,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Shown in the hero's photo area when the school has no images configured,
/// while one is loading, or when a URL fails. A muted gallery glyph on the
/// darker brand tone reads as "no photo" rather than as a broken layout.
class _PhotoFallback extends StatelessWidget {
  final Color background;

  const _PhotoFallback({required this.background});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: background,
      child: Center(
        child: SvgPicture.asset(
          Utils.getImagePath("chat_gallery.svg"),
          width: 44,
          height: 44,
          colorFilter: ColorFilter.mode(
            AppColors.textOnBrand.withValues(alpha: 0.35),
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
