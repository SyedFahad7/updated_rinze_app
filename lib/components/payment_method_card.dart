import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';

class PaymentMethodCard extends StatefulWidget {
  const PaymentMethodCard({
    super.key,
    required this.text,
    required this.value,
    required this.onChanged,
  });

  final String text;
  final bool value;
  final ValueChanged<bool?>? onChanged;

  @override
  State<PaymentMethodCard> createState() => _PaymentMethodCardState();
}

class _PaymentMethodCardState extends State<PaymentMethodCard> {
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
                widget.text,
                style: const TextStyle(
                  color: AppColors.hintBlack,
                  fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  fontSize: AppFonts.fontSize16,
                  fontWeight: AppFonts.fontWeightSemiBold,
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
