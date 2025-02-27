import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';
import '../screens/active_order_details_screen.dart';

class ActiveOrderCard extends StatefulWidget {
  const ActiveOrderCard({
    super.key,
    required this.serviceTitle,
    required this.totalItems,
    required this.deliveryDate,
    required this.orderId,
    required this.pickupDate,
    required this.progress,
  });

  final String serviceTitle;
  final int totalItems;
  final String orderId;
  final String deliveryDate;
  final String pickupDate;
  final double progress;

  @override
  State<ActiveOrderCard> createState() => _ActiveOrderCardState();
}

class _ActiveOrderCardState extends State<ActiveOrderCard> {
  List<String> displayDate() {
    DateTime pickupDateTime = DateTime.parse(widget.pickupDate);
    DateTime deliveryDateTime = DateTime.parse(widget.deliveryDate);
    DateTime currentDate = DateTime.now().toUtc();

    // Extract only the date part (without the time)
    String pickupDateOnly =
        pickupDateTime.toLocal().toIso8601String().split('T')[0];
    String deliveryDateOnly =
        deliveryDateTime.toLocal().toIso8601String().split('T')[0];

    if (pickupDateTime.isAfter(currentDate)) {
      return [
        'PICKUP ON',
        pickupDateOnly,
      ]; // Only date part returned
    } else {
      return [
        'DELIVERY ON',
        deliveryDateOnly,
      ]; // Only date part returned
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ActiveOrderDetailsScreen(
              orderId: widget.orderId,
            ),
          ),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/images/washing_machine_sm.png',
            scale: 0.9,
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
                              fontSize: AppFonts.fontSize12,
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
                        displayDate()[0],
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
                            displayDate()[1],
                            style: const TextStyle(
                              color: AppColors.black,
                              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                              fontSize: AppFonts.fontSize12,
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
