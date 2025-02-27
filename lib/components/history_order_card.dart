import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rinze/screens/history_order_details_screen.dart';

import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';

class HistoryOrderCard extends StatefulWidget {
  const HistoryOrderCard({
    super.key,
    required this.serviceTitle,
    required this.totalItems,
    required this.deliveryDate,
    required this.orderId,
    required this.pickupDate,
    required this.progress,
    required this.status,
  });

  final String serviceTitle;
  final int totalItems;
  final String orderId;
  final String deliveryDate;
  final String pickupDate;
  final double progress;
  final String status;

  @override
  State<HistoryOrderCard> createState() => _HistoryOrderCardState();
}

class _HistoryOrderCardState extends State<HistoryOrderCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HistoryOrderDetailsScreen(
              orderId: widget.orderId,
            ),
          ),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.asset(
                'assets/images/washing_machine_sm.png',
                scale: 0.9,
              ),
              // Container(
              //   width: 100.0,
              //   height: 100.0,
              //   color: AppColors.white.withValues(alpha:0.5),
              // ),
              Positioned(
                top: 0.0,
                left: 0.0,
                right: 0.0,
                bottom: 0.0,
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  color: AppColors.white.withValues(alpha: 0.5),
                  child: widget.status == 'cancelled'
                      ? SvgPicture.asset(
                          'assets/icons/check_circle.svg',
                          colorFilter: const ColorFilter.mode(
                            AppColors.fadeRed,
                            BlendMode.srcIn,
                          ),
                        )
                      : SvgPicture.asset(
                          'assets/icons/check_circle.svg',
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.serviceTitle,
                        style: TextStyle(
                          color: AppColors.black.withValues(alpha: 0.6),
                          fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                          fontSize: AppFonts.fontSize10,
                          fontWeight: AppFonts.fontWeightSemiBold,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/hanger.svg',
                          ),
                          const SizedBox(width: 2.0),
                          Text(
                            '${widget.totalItems} Items',
                            style: const TextStyle(
                              color: AppColors.black,
                              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                              fontSize: AppFonts.fontSize14,
                              fontWeight: AppFonts.fontWeightRegular,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 15.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DELIVERED ON',
                        style: TextStyle(
                          color: AppColors.black.withValues(alpha: 0.6),
                          fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                          fontSize: AppFonts.fontSize10,
                          fontWeight: AppFonts.fontWeightSemiBold,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Row(
                        children: [
                          SvgPicture.asset('assets/icons/calendar_check.svg'),
                          const SizedBox(width: 2.0),
                          Text(
                            widget.deliveryDate.split('T')[0],
                            style: const TextStyle(
                              color: AppColors.black,
                              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                              fontSize: AppFonts.fontSize14,
                              fontWeight: AppFonts.fontWeightRegular,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              Text(
                'PROGRESS',
                style: TextStyle(
                  color: AppColors.black.withValues(alpha: 0.6),
                  fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  fontSize: AppFonts.fontSize10,
                  fontWeight: AppFonts.fontWeightSemiBold,
                ),
              ),
              const SizedBox(height: 4.0),
              SizedBox(
                width: 190.0,
                child: LinearProgressIndicator(
                  value: widget.progress,
                  minHeight: 8.0,
                  backgroundColor: AppColors.whiteGrey,
                  color: AppColors.darkBlue,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'View All Details',
                style: TextStyle(
                  color: AppColors.darkerBlue,
                  fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  fontSize: AppFonts.fontSize12,
                  fontWeight: AppFonts.fontWeightSemiBold,
                ),
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ],
      ),
    );
  }
}
