import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';

class OffersCard extends StatefulWidget {
  const OffersCard({
    super.key,
    required this.headerText,
    required this.mainText,
    required this.subText,
  });

  final String subText;
  final String headerText;
  final String mainText;

  @override
  State<OffersCard> createState() => _OffersCard();
}

class _OffersCard extends State<OffersCard> {
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
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            offset: const Offset(0, 1),
            blurRadius: 8.0,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.headerText,
            style: TextStyle(
              color: AppColors.black.withValues(alpha: 0.6),
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
              fontWeight: AppFonts.fontWeightBold,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            widget.subText,
            style: const TextStyle(
              color: AppColors.hintBlack,
              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
              fontSize: AppFonts.fontSize12,
              fontWeight: AppFonts.fontWeightMedium,
            ),
          ),
        ],
      ),
    );
  }
}
