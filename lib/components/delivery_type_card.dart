import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';

class DeliveryTypeCard extends StatefulWidget {
  const DeliveryTypeCard({
    super.key,
    required this.headerText,
    required this.mainText,
    required this.subText,
    required this.value,
    required this.onChanged,
  });

  final String subText;
  final String headerText;
  final String mainText;
  final bool value;
  final ValueChanged<bool?>? onChanged;

  @override
  State<DeliveryTypeCard> createState() => _DeliveryTypeCardState();
}

class _DeliveryTypeCardState extends State<DeliveryTypeCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: widget.value == true ? AppColors.white : AppColors.halfWhite,
        borderRadius: const BorderRadius.all(
          Radius.circular(10.0),
        ),
        border: Border.all(
          color: widget.value == true
              ? AppColors.retroLime
              : AppColors.black.withValues(alpha: 0.06),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.headerText,
                style: const TextStyle(
                  color: AppColors.retroLime,
                  fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  fontSize: AppFonts.fontSize10,
                  fontWeight: AppFonts.fontWeightBold,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                widget.mainText,
                style: const TextStyle(
                  color: AppColors.hintBlack,
                  fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  fontSize: AppFonts.fontSize16,
                  fontWeight: AppFonts.fontWeightSemiBold,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                widget.subText,
                style: TextStyle(
                  color: AppColors.hintBlack.withValues(alpha: 0.6),
                  fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  fontSize: AppFonts.fontSize12,
                  fontWeight: AppFonts.fontWeightMedium,
                ),
              ),
            ],
          ),
          Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: widget.value,
              onChanged: widget.onChanged,
              activeColor: AppColors.retroLime,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              side: BorderSide(
                width: 1.0,
                color: AppColors.black.withValues(alpha: 0.2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
