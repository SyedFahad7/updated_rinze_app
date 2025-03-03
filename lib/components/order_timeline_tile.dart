import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../constants/app_colors.dart';
import 'order_timeline_card.dart';

class OrderTimelineTile extends StatefulWidget {
  const OrderTimelineTile({
    super.key,
    required this.isFirst,
    required this.isLast,
    required this.isPast,
    required this.title,
    required this.dateTime,
    required this.imagePath, // Add imagePath parameter
    required this.showImage, // Add showImage parameter
  });

  final bool isFirst;
  final bool isLast;
  final bool isPast;
  final String title;
  final String dateTime;
  final String imagePath; // Add imagePath parameter
  final bool showImage; // Add showImage parameter

  @override
  State<OrderTimelineTile> createState() => _OrderTimelineTileState();
}

class _OrderTimelineTileState extends State<OrderTimelineTile> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80.0,
      child: TimelineTile(
        isFirst: widget.isFirst,
        isLast: widget.isLast,
        beforeLineStyle: LineStyle(
          color: widget.isPast ? AppColors.retroLime : AppColors.transparent,
          thickness: 1.0,
        ),
        indicatorStyle: IndicatorStyle(
          indicator: Container(
            decoration: widget.isPast
                ? BoxDecoration(
                    color: AppColors.retroLime,
                    borderRadius: BorderRadius.circular(100.0),
                  )
                : BoxDecoration(
                    color: AppColors.transparent,
                    borderRadius: BorderRadius.circular(100.0),
                    border: Border.all(
                      color: AppColors.black.withOpacity(0.2),
                      width: 1.0,
                    ),
                  ),
          ),
          padding: const EdgeInsets.only(top: 6.0, bottom: 6.0),
          width: 8.0,
          height: 8.0,
          color: widget.isPast ? AppColors.thumbGrey : AppColors.black,
        ),
        endChild: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center horizontally
          crossAxisAlignment: CrossAxisAlignment.center, // Center vertically
          children: [
            Expanded(
              child: OrderTimelineCard(
                title: widget.title,
                dateTime: widget.dateTime,
              ),
            ),
            if (widget.showImage)
              Padding(
                padding: const EdgeInsets.only(left: 16.0), // Add spacing
                child: Image.asset(
                  widget.imagePath,
                  width: 40.0, 
                  height: 40.0, 
                ),
              ),
          ],
        ),
      ),
    );
  }
}
