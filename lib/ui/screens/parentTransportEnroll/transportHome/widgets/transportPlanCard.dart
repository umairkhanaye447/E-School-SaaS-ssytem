import 'package:eschool/app/routes.dart';
import 'package:eschool/cubits/authCubit.dart';
import 'package:eschool/data/models/transportDashboard.dart';
import 'package:eschool/ui/screens/parentTransportEnroll/transportHome/widgets/commonTransportWidgets.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/utils.dart';
import 'package:eschool/ui/styles/appTokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class TransportPlanCard extends StatelessWidget {
  final TransportPlan? plan;
  final int? studentId;

  const TransportPlanCard({super.key, this.plan, this.studentId});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(plan?.status);
    final isExpiring = plan?.expiresInDays != null && plan!.expiresInDays! <= 7;
    final isParent = context.read<AuthCubit>().isParent();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        EnrollCard(
          onTap: isParent
              ? () {
                  Get.toNamed(Routes.transportPlanDetailsScreen,
                      arguments: studentId);
                }
              : null,
          title: transportationPlanKey,
          trailing: EnrollStatusChip(
            title: plan?.status?.capitalize ?? activeKey,
            background: statusColor.background,
            foreground: statusColor.foreground,
          ),
          children: [
            LabelValue(
              label: planKey,
              value: plan?.duration ?? monthlyKey,
            ),
            LabelValue(
              label: validityKey,
              value: plan != null &&
                      plan!.validFrom != null &&
                      plan!.validTo != null
                  ? '${plan!.validFrom} - ${plan!.validTo}'
                  : 'N/A',
            ),
            LabelValue(
              label: routeNameKey,
              value: plan?.route?.name ?? 'N/A',
            ),
            if (isExpiring) ...[
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 10),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: isParent
                    ? () => Get.toNamed(
                          Routes.planRenewalScreen,
                          arguments: {
                            'plan': plan,
                            'userId': studentId,
                          },
                        )
                    : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
        boxShadow: AppShadows.card,
                    borderRadius: BorderRadius.circular(AppRadius.field),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppAccent.red.tint,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: Theme.of(context).colorScheme.error,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Utils.getTranslatedLabel(planExpiringTitleKey),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.danger,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${Utils.getTranslatedLabel(yourPlanWillExpireInKey)} ${plan?.expiresInDays} ${Utils.getTranslatedLabel(daysKey)}.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isParent)
                        Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: AppColors.textPrimary,
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  ({Color background, Color foreground}) _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return (
          background: AppAccent.green.tint,
          foreground: AppColors.success,
        );
      case 'inactive':
        return (
          background: AppAccent.orange.tint,
          foreground: AppColors.warning,
        );
      case 'expired':
        return (
          background: AppAccent.red.tint,
          foreground: AppColors.danger,
        );
      default:
        return (
          background: AppAccent.green.tint,
          foreground: AppColors.success,
        );
    }
  }
}
