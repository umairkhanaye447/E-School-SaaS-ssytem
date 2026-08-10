import 'package:eschool/data/models/paymentGateway.dart';
import 'package:eschool/ui/styles/appTokens.dart';
import 'package:eschool/ui/widgets/bottomsheetTopTitleAndCloseButton.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectPaymentMethodBottomsheet extends StatelessWidget {
  final List<PaymentGeteway> paymentGeteways;
  const SelectPaymentMethodBottomsheet(
      {super.key, required this.paymentGeteways});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * (0.075),
          vertical: MediaQuery.of(context).size.height * (0.04),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            BottomsheetTopTitleAndCloseButton(
              onTapCloseButton: () {
                Get.back();
              },
              titleKey: choosePayViaKey,
            ),
            Column(
              children: paymentGeteways.map((paymentGateway) {
                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: AppRadius.fieldAll,
                  ),
                  child: ListTile(
                    onTap: () {
                      Get.back(result: paymentGateway);
                    },
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.fieldAll,
                    ),
                    dense: false,
                    title: Text(
                      "${Utils.getTranslatedLabel(payUsingKey)} ${paymentGateway.paymentMethod}",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}
