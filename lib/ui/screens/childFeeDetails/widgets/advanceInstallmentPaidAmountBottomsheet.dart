import 'package:eschool/cubits/schoolConfigurationCubit.dart';
import 'package:eschool/data/models/advanceFee.dart';
import 'package:eschool/ui/styles/appTokens.dart';
import 'package:eschool/ui/widgets/bottomsheetTopTitleAndCloseButton.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';

class AdvanceInstallmentPaidAmountBottomsheet extends StatelessWidget {
  final List<AdvanceFee> advanceFees;
  const AdvanceInstallmentPaidAmountBottomsheet(
      {super.key, required this.advanceFees});

  @override
  Widget build(BuildContext context) {
    final currencySymbol = context
            .read<SchoolConfigurationCubit>()
            .getSchoolConfiguration()
            .schoolSettings
            .currencySymbol ??
        '';
    double totalAdvancePaidAmount = 0.0;
    for (var advanceFee in advanceFees) {
      totalAdvancePaidAmount += (advanceFee.amount ?? 0.0);
    }

    return SingleChildScrollView(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
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
              titleKey: Utils.getTranslatedLabel(advancePaidAmountDetailsKey),
            ),
            Row(
              children: [
                Text(
                  Utils.getTranslatedLabel(totalAmountKey),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const Spacer(),
                Text(
                  "${currencySymbol}${totalAdvancePaidAmount.toStringAsFixed(2)}",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            const Divider(),
            Text(
              Utils.getTranslatedLabel(advanceAmountBreakdownKey),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            ...advanceFees
                .map((advanceFee) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "${Utils.getTranslatedLabel(paidOnKey)} ${Utils.formatDate(DateTime.parse(advanceFee.createdAt!))}",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                              ),
                            ),
                            Text(
                              "${currencySymbol}${advanceFee.amount?.toStringAsFixed(2) ?? '0.00'}",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            "${Utils.getTranslatedLabel(paymentIdKey)} : ${advanceFee.id}",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const Divider(color: AppColors.divider),
                      ],
                    ))
                .toList(),
            if (advanceFees.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Center(
                  child: Text(
                    Utils.getTranslatedLabel(noAdvancePaymentRecordsFoundKey),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              Utils.getTranslatedLabel(noteAdvanceAmountsKey),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.textTertiary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
