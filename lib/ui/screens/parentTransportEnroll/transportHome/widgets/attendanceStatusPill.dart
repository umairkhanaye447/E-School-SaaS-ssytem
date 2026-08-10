import 'package:eschool/ui/styles/appTokens.dart';
import 'package:flutter/material.dart';
import 'package:eschool/ui/widgets/customTextContainer.dart';

class AttendanceStatusPill extends StatelessWidget {
  final String status; // 'P' or 'A'
  const AttendanceStatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final bool present = status.toUpperCase() == 'P';
    final Color bg =
        present ? AppAccent.green.tint : AppAccent.red.tint;
    final Color fg =
        present ? AppColors.success : AppColors.danger;
    return Container(
      width: 40,
      height: 36,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.field),
      ),
      child: Center(
        child: CustomTextContainer(
          textKey: present ? 'P' : 'A',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: fg,
          ),
        ),
      ),
    );
  }
}
