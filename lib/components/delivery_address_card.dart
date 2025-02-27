import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';

class DeliveryAddressCard extends StatefulWidget {
  const DeliveryAddressCard({
    super.key,
    required this.addressTpe,
    required this.address,
  });

  final String addressTpe;
  final String address;

  @override
  State<DeliveryAddressCard> createState() => _DeliveryAddressCardState();
}

class _DeliveryAddressCardState extends State<DeliveryAddressCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.all(
          Radius.circular(10.0),
        ),
        border: Border.all(
          color: AppColors.black.withValues(alpha: 0.06),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.addressTpe,
            style: TextStyle(
              color: AppColors.black.withValues(alpha: 0.6),
              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
              fontSize: AppFonts.fontSize10,
              fontWeight: AppFonts.fontWeightBold,
            ),
          ),
          Text(
            widget.address,
            style: const TextStyle(
              color: AppColors.hintBlack,
              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
              fontSize: AppFonts.fontSize16,
              fontWeight: AppFonts.fontWeightSemiBold,
            ),
          ),
        ],
      ),
    );
  }
}
