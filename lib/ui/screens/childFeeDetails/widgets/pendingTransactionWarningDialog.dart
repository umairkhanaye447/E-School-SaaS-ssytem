import 'package:eschool/ui/styles/appTokens.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PendingTransactionWarningDialog extends StatelessWidget {
  const PendingTransactionWarningDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.cardAll),
      content: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm),
        child: Text(
          Utils.getTranslatedLabel(pendingPaymentTransactionWarningKey),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
      actions: [
        CupertinoButton(
            child: Text(Utils.getTranslatedLabel(waitKey)),
            onPressed: () {
              Get.back(result: false);
            }),
        CupertinoButton(
            child: Text(Utils.getTranslatedLabel(continuePaymentKey)),
            onPressed: () {
              Get.back(result: true);
            }),
      ],
    );
  }
}
