import 'package:eschool/data/models/transportDashboard.dart';
import 'package:eschool/ui/screens/parentTransportEnroll/transportHome/widgets/commonTransportWidgets.dart';
import 'package:eschool/ui/screens/parentTransportEnroll/transportHome/widgets/pickupTimeRow.dart';
import 'package:eschool/ui/screens/parentTransportEnroll/transportHome/widgets/liveRouteBottomSheet.dart';
import 'package:eschool/data/repositories/authRepository.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/utils.dart';
import 'package:flutter/material.dart';

class LiveTrackingCard extends StatelessWidget {
  final LiveSummary? liveSummary;
  final int? studentId;

  const LiveTrackingCard({super.key, this.liveSummary, this.studentId});

  @override
  Widget build(BuildContext context) {
    return EnrollCard(
      title: liveTrackingKey,
      trailing: liveSummary != null && liveSummary!.status != null
          ? _buildStatusBadge(context, liveSummary!.status!)
          : const SizedBox.shrink(),
      children: [
        if (liveSummary != null) ...[
          LiveTrackingContent(liveSummary: liveSummary),
          SizedBox(height: 8),
          PickupTimeRow(
            pickupTime: liveSummary?.estimatedTime,
            onTap: () {
              _showLiveRouteBottomSheet(context);
            },
          ),
        ] else ...[
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Icon(
                    Icons.directions_bus_outlined,
                    size: 48,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Utils.getTranslatedLabel(noOngoingTripKey),
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]
      ],
    );
  }

  /// Build status badge widget for different bus tracking statuses
  Widget _buildStatusBadge(BuildContext context, String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    // Normalize status to lowercase for comparison
    final normalizedStatus = status.toLowerCase();

    switch (normalizedStatus) {
      case 'on_time':
      case 'ontime':
      case 'on time':
        backgroundColor = const Color(0xFFDFF6E2);
        textColor = const Color(0xFF37C748);
        displayText = Utils.getTranslatedLabel(onTimeKey);
        break;
      case 'delayed':
        backgroundColor = const Color(0xFFFFF2E8);
        textColor = const Color(0xFFFF8C00);
        displayText = Utils.getTranslatedLabel(delayedKey);
        break;
      case 'reached':
        backgroundColor = const Color(0xFFE8F5E8);
        textColor = const Color(0xFF2E7D32);
        displayText = Utils.getTranslatedLabel(reachedKey);
        break;
      default:
        backgroundColor = const Color(0xFFE0EDF6);
        textColor = const Color(0xFF29638A);
        displayText = status;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showLiveRouteBottomSheet(BuildContext context) {
    // Use the student ID from the widget parameter first, then fallback to auth repository
    int? userId = studentId;

    if (userId == null) {
      final student = AuthRepository.getStudentDetails();
      userId = student.id;
    }

    if (userId == null || userId == 0) {
      debugPrint("Error: No valid student ID found for live route tracking");
      return;
    }

    LiveRouteBottomSheet.show(context, userId: userId);
  }
}
