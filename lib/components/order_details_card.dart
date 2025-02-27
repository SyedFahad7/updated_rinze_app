import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';
import '../utils/string_utils.dart';

class OrderDetailsCard extends StatelessWidget {
  const OrderDetailsCard({
    super.key,
    required this.pickupType,
    required this.date,
    required this.time,
    required this.agentId,
    required this.agentName,
    required this.agentMobileNumber,
    required this.agentType,
  });

  final String agentType;
  final String pickupType;
  final String date;
  final String time;
  final String agentId;
  final String agentName;
  final String agentMobileNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.halfWhite,
        borderRadius: const BorderRadius.all(
          Radius.circular(10.0),
        ),
        border: Border.all(
          color: AppColors.black.withValues(alpha: 0.06),
          width: 2.0,
        ),
      ),
      child: Column(
        spacing: 16.0,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                agentType,
                style: const TextStyle(
                  color: AppColors.hintBlack,
                  fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  fontSize: AppFonts.fontSize18,
                  fontWeight: AppFonts.fontWeightSemiBold,
                ),
              ),
              if (pickupType != 'None')
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6.0,
                    horizontal: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.retroLime.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                  child: Text(
                    capitalize(
                      splitString(pickupType),
                    ),
                    style: const TextStyle(
                      color: AppColors.green,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize12,
                      fontWeight: AppFonts.fontWeightRegular,
                    ),
                  ),
                ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                spacing: 6.0,
                children: [
                  Column(
                    spacing: 4.0,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        spacing: 3.0,
                        children: [
                          SvgPicture.asset('assets/icons/calendar_blank.svg'),
                          Opacity(
                            opacity: 0.6,
                            child: Text(
                              '$agentType Date',
                              style: const TextStyle(
                                color: AppColors.black,
                                fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                                fontSize: AppFonts.fontSize12,
                                fontWeight: AppFonts.fontWeightMedium,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        date,
                        style: const TextStyle(
                          color: AppColors.black,
                          fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                          fontSize: AppFonts.fontSize14,
                          fontWeight: AppFonts.fontWeightMedium,
                        ),
                      ),
                    ],
                  ),
                  if (time != ' ')
                    Column(
                      spacing: 4.0,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          spacing: 3.0,
                          children: [
                            SvgPicture.asset('assets/icons/clock.svg'),
                            Opacity(
                              opacity: 0.6,
                              child: Text(
                                '$agentType Time',
                                style: const TextStyle(
                                  color: AppColors.black,
                                  fontFamily:
                                      AppFonts.fontFamilyPlusJakartaSans,
                                  fontSize: AppFonts.fontSize12,
                                  fontWeight: AppFonts.fontWeightMedium,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          time,
                          style: const TextStyle(
                            color: AppColors.black,
                            fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                            fontSize: AppFonts.fontSize14,
                            fontWeight: AppFonts.fontWeightMedium,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              Column(
                spacing: 4.0,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: 3.0,
                    children: [
                      SvgPicture.asset('assets/icons/user_circle.svg'),
                      Opacity(
                        opacity: 0.6,
                        child: Text(
                          '$agentType Agent',
                          style: const TextStyle(
                            color: AppColors.black,
                            fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                            fontSize: AppFonts.fontSize12,
                            fontWeight: AppFonts.fontWeightMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                  agentName == 'To be assigned'
                      ? const Text(
                          'To be assigned',
                          style: TextStyle(
                            color: AppColors.black,
                            fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                            fontSize: AppFonts.fontSize14,
                            fontWeight: AppFonts.fontWeightMedium,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 4.0,
                          children: [
                            Text(
                              'ID : $agentId',
                              style: const TextStyle(
                                color: AppColors.greyBlack,
                                fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                                fontSize: AppFonts.fontSize14,
                                fontWeight: AppFonts.fontWeightMedium,
                              ),
                            ),
                            Text(
                              capitalize(agentName),
                              style: const TextStyle(
                                color: AppColors.black,
                                fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                                fontSize: AppFonts.fontSize14,
                                fontWeight: AppFonts.fontWeightMedium,
                              ),
                            ),
                            Text(
                              '+91 $agentMobileNumber',
                              style: const TextStyle(
                                color: AppColors.black,
                                fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                                fontSize: AppFonts.fontSize14,
                                fontWeight: AppFonts.fontWeightMedium,
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
