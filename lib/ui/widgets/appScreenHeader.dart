import 'package:eschool/ui/styles/appTokens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Light screen header: optional back button in a white rounded square,
/// followed by the screen title.
///
/// Replaces the blue [ScreenTopBackgroundContainer] treatment on redesigned
/// screens. The back button is optional because some screens are reached from
/// a bottom-nav tab and have nothing to pop.
class AppScreenHeader extends StatelessWidget {
  final String title;
  final bool showBackButton;
  final Widget? trailing;

  const AppScreenHeader({
    Key? key,
    required this.title,
    this.showBackButton = true,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.xs,
        AppSpacing.screenH,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          if (showBackButton) ...[
            _BackSquare(onTap: () => Get.back<void>()),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _BackSquare extends StatelessWidget {
  final VoidCallback onTap;

  const _BackSquare({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.fieldAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.fieldAll,
        child: Ink(
          height: 42,
          width: 42,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.fieldAll,
            boxShadow: AppShadows.card,
          ),
          //Directional so the arrow flips in RTL locales.
          child: const Icon(
            Icons.arrow_back_rounded,
            size: 20,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
