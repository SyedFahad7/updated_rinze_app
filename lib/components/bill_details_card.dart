import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';
import 'dashed_line_painter.dart';

class BillDetailsCard extends StatefulWidget {
  const BillDetailsCard({
    super.key,
    required this.serviceCost,
    required this.pickupAndDeliveryCost,
    required this.gstCost,
    required this.totalCost,
    required this.discount,
  });

  final double gstCost;
  final String serviceCost;
  final String pickupAndDeliveryCost;
  final String totalCost;
  final int discount;

  @override
  State<BillDetailsCard> createState() => _BillDetailsCard();
}

class _BillDetailsCard extends State<BillDetailsCard> {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Service Cost',
                style: TextStyle(
                  color: AppColors.black.withValues(alpha: 0.6),
                  fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  fontSize: AppFonts.fontSize14,
                  fontWeight: AppFonts.fontWeightMedium,
                ),
              ),
              Text(
                widget.serviceCost,
                style: TextStyle(
                  color: AppColors.black.withValues(alpha: 0.6),
                  fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  fontSize: AppFonts.fontSize14,
                  fontWeight: AppFonts.fontWeightMedium,
                ),
              ),
            ],
          ),
          if (widget.discount > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const Text(
                      'Discount',
                      style: TextStyle(
                        color: AppColors.retroLime,
                        fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                        fontSize: AppFonts.fontSize14,
                        fontWeight: AppFonts.fontWeightMedium,
                      ),
                    ),
                    CustomPaint(
                      size: const Size(60.0, 1.0),
                      painter: DashedLinePainter(),
                    ),
                  ],
                ),
                Text(
                  '-₹${(widget.discount).toString()}',
                  style: const TextStyle(
                    color: AppColors.retroLime,
                    fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                    fontSize: AppFonts.fontSize14,
                    fontWeight: AppFonts.fontWeightMedium,
                  ),
                ),
              ],
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pickup & Delivery Charges',
                style: TextStyle(
                  color: AppColors.black.withValues(alpha: 0.6),
                  fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  fontSize: AppFonts.fontSize14,
                  fontWeight: AppFonts.fontWeightMedium,
                ),
              ),
              Text(
                widget.pickupAndDeliveryCost,
                style: TextStyle(
                  color: AppColors.black.withValues(alpha: 0.6),
                  fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  fontSize: AppFonts.fontSize14,
                  fontWeight: AppFonts.fontWeightMedium,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CGST (9%)',
                style: TextStyle(
                  color: AppColors.black.withValues(alpha: 0.6),
                  fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  fontSize: AppFonts.fontSize14,
                  fontWeight: AppFonts.fontWeightMedium,
                ),
              ),
              Text(
                widget.gstCost.toStringAsFixed(2),
                style: TextStyle(
                  color: AppColors.black.withValues(alpha: 0.6),
                  fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  fontSize: AppFonts.fontSize14,
                  fontWeight: AppFonts.fontWeightMedium,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SGST (9%)',
                style: TextStyle(
                  color: AppColors.black.withValues(alpha: 0.6),
                  fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  fontSize: AppFonts.fontSize14,
                  fontWeight: AppFonts.fontWeightMedium,
                ),
              ),
              Text(
                widget.gstCost.toStringAsFixed(2),
                style: TextStyle(
                  color: AppColors.black.withValues(alpha: 0.6),
                  fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  fontSize: AppFonts.fontSize14,
                  fontWeight: AppFonts.fontWeightMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Bill',
                style: TextStyle(
                  color: AppColors.hintBlack,
                  fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  fontSize: AppFonts.fontSize18,
                  fontWeight: AppFonts.fontWeightSemiBold,
                ),
              ),
              Text(
                widget.totalCost,
                style: const TextStyle(
                  color: AppColors.hintBlack,
                  fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  fontSize: AppFonts.fontSize18,
                  fontWeight: AppFonts.fontWeightSemiBold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
