import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';

class OrderTimelineCard extends StatefulWidget {
  const OrderTimelineCard({
    super.key,
    required this.title,
    required this.dateTime,
  });

  final String title;
  final String dateTime;

  @override
  State<OrderTimelineCard> createState() => _OrderTimelineCardState();
}

class _OrderTimelineCardState extends State<OrderTimelineCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              color: AppColors.black,
              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
              fontSize: AppFonts.fontSize14,
              fontWeight: AppFonts.fontWeightMedium,
            ),
          ),
          Text(
            widget.dateTime,
            style: TextStyle(
              color: AppColors.black.withValues(alpha: 0.6),
              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
              fontSize: AppFonts.fontSize12,
              fontWeight: AppFonts.fontWeightRegular,
            ),
          ),
        ],
      ),
    );
  }
}
