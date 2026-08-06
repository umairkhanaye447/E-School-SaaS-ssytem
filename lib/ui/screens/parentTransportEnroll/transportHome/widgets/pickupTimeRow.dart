import 'package:eschool/ui/screens/parentTransportEnroll/transportHome/widgets/commonTransportWidgets.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PickupTimeRow extends StatelessWidget {
  final VoidCallback onTap;
  final String? pickupTime;
  const PickupTimeRow({super.key, required this.onTap, this.pickupTime});

  @override
  Widget build(BuildContext context) {
    // Check if pickup time indicates the bus has reached
    final bool hasReached = pickupTime?.contains('Reached') ?? false;

    // Format the value - only show "(Estimated)" if not reached
    final String displayValue = hasReached
        ? pickupTime ?? ''
        : "${pickupTime ?? ''} (${Utils.getTranslatedLabel(estimatedKey)})";

    return Row(
      children: [
        Expanded(
          child: LabelValue(
            label: Utils.getTranslatedLabel(pickupTimeKey),
            value: displayValue,
            smallValueStyle: true,
          ),
        ),
        InkWell(
          onTap: onTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF1F4B63),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                Utils.getImagePath('directions.svg'),
                width: 20,
                height: 20,
                colorFilter:
                    const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
