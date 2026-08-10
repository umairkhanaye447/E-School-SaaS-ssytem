import 'package:eschool/ui/styles/appTokens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Confirmation dialog matching the redesigned card language: icon well,
/// title + message, and a neutral/accent button pair.
///
/// Replaces the bare [AlertDialog] + [CupertinoButton] confirms that shipped
/// with the original app. Pass the *translated* strings — this widget does not
/// translate, so call sites keep control over which label keys they use.
class AppConfirmDialog extends StatelessWidget {
  final IconData icon;

  /// Tints the icon well and the confirm button — [AppColors.danger] for
  /// destructive actions, the brand primary for neutral confirmations.
  final Color accentColor;
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const AppConfirmDialog({
    Key? key,
    required this.icon,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.onConfirm,
    this.onCancel,
    this.accentColor = AppColors.danger,
  }) : super(key: key);

  /// Opens the dialog via GetX so call sites stay one-liners.
  static void show({
    required IconData icon,
    required String title,
    required String message,
    required String confirmLabel,
    required String cancelLabel,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    Color accentColor = AppColors.danger,
  }) {
    Get.dialog(
      AppConfirmDialog(
        icon: icon,
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirm: onConfirm,
        onCancel: onCancel,
        accentColor: accentColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: TweenAnimationBuilder<double>(
        //Slight scale-up entrance so the card settles instead of popping.
        tween: Tween<double>(begin: 0.92, end: 1),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.hero)),
            boxShadow: AppShadows.raised,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30, color: accentColor),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: _DialogButton(
                      label: cancelLabel,
                      background: AppColors.surfaceMuted,
                      foreground: AppColors.textPrimary,
                      onTap: onCancel ?? () => Get.back(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _DialogButton(
                      label: confirmLabel,
                      background: accentColor,
                      foreground: AppColors.textOnBrand,
                      onTap: onConfirm,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  const _DialogButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: AppRadius.fieldAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.fieldAll,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}
