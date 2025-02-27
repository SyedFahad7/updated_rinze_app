import 'package:flutter/material.dart';
import 'package:rinze/constants/app_colors.dart';

import '../constants/app_fonts.dart';

class CouponCard extends StatelessWidget {
  const CouponCard({
    super.key,
    required this.subText,
    required this.headerText,
    required this.mainText,
  });

  final String subText;
  final String headerText;
  final String mainText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100.0,
      // color: AppColors.retroLime,
      decoration: BoxDecoration(
        color: AppColors.retroLime,
        borderRadius: const BorderRadius.all(
          Radius.circular(10.0),
        ),
        border: Border.all(
          color: AppColors.retroLime.withValues(alpha: 0.6),
          // color: widget.couponSelected
          //     ? AppColors.retroLime.withValues(alpha:0.6)
          //     : AppColors.black.withValues(alpha:0.06),
          width: 1.0,
        ),
      ),
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Transform.rotate(
                      angle: -1.57,
                      child: const Text(
                        'RINZE',
                        style: TextStyle(
                          color: AppColors.white,
                          fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                          fontSize: AppFonts.fontSize12,
                          fontWeight: AppFonts.fontWeightExtraBold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  color: AppColors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        headerText,
                        style: TextStyle(
                          color: AppColors.black.withValues(alpha: 0.6),
                          fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                          fontSize: AppFonts.fontSize10,
                          fontWeight: AppFonts.fontWeightBold,
                        ),
                      ),
                      Text(
                        mainText,
                        style: const TextStyle(
                          color: AppColors.hintBlack,
                          fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                          fontSize: AppFonts.fontSize16,
                          fontWeight: AppFonts.fontWeightBold,
                        ),
                      ),
                      Text(
                        subText,
                        style: const TextStyle(
                          color: AppColors.hintBlack,
                          fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                          fontSize: AppFonts.fontSize12,
                          fontWeight: AppFonts.fontWeightMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          CustomPaint(
            painter: SideCutsDesign(),
            child: const SizedBox(
              height: 100.0,
              width: double.infinity,
            ),
          ),
          CustomPaint(
            painter: DottedInitialPath(),
            child: const SizedBox(
              height: 100.0,
              width: double.infinity,
            ),
          ),
          CustomPaint(
            painter: DottedMiddlePath(),
            child: const SizedBox(
              height: 100.0,
              width: double.infinity,
            ),
          ),
        ],
      ),
    );
  }
}

class DottedMiddlePath extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 4.0;
    double dashSpace = 4.0;
    double startY = 10.0;

    final paint = Paint()
      ..color = AppColors.halfWhite
      ..strokeWidth = 1.0;

    while (startY < size.height - 10) {
      canvas.drawCircle(
        Offset(size.width / 5, startY),
        2.0,
        paint,
      );
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class DottedInitialPath extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 4.0;
    double dashSpace = 4.0;
    double startY = 10.0;

    final paint = Paint()
      ..color = AppColors.halfWhite
      ..strokeWidth = 1.0;

    while (startY < size.height - 10) {
      canvas.drawCircle(Offset(0, startY), 2.0, paint);
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class SideCutsDesign extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var height = size.height;
    var width = size.width;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(0, height / 2), radius: 10.0),
      0,
      10,
      false,
      Paint()
        ..style = PaintingStyle.fill
        ..color = AppColors.halfWhite,
    );

    canvas.drawArc(
      Rect.fromCircle(center: Offset(width, height / 2), radius: 10.0),
      0,
      10,
      false,
      Paint()
        ..style = PaintingStyle.fill
        ..color = AppColors.halfWhite,
    );

    canvas.drawArc(
      Rect.fromCircle(center: Offset(width, height / 2), radius: 10.0),
      -1.57,
      -3.14,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = AppColors.retroLime,
    );

    canvas.drawArc(
      Rect.fromCircle(center: Offset(width / 5, height), radius: 6.0),
      0,
      10,
      false,
      Paint()
        ..style = PaintingStyle.fill
        ..color = AppColors.halfWhite,
    );

    canvas.drawArc(
      Rect.fromCircle(center: Offset(width / 5, height), radius: 6.0),
      -1.57, // Start angle (-π/2 radians, or 90° from the top)
      1.57, // Sweep angle (π/2 radians, or 90° clockwise)
      false, // Not a full circle
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0 // Border thickness
        ..color = AppColors.retroLime, // Border color
    );

    canvas.drawArc(
      Rect.fromCircle(center: Offset(width / 5, 0), radius: 6.0),
      0,
      10,
      false,
      Paint()
        ..style = PaintingStyle.fill
        ..color = AppColors.halfWhite,
    );

    canvas.drawArc(
      Rect.fromCircle(center: Offset(width / 5, 0), radius: 6.0),
      1.57,
      -1.57,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0 // Adjust thickness
        ..color = AppColors.retroLime, // Border color
    );

    canvas.drawArc(
      Rect.fromCircle(center: Offset(0, height), radius: 6.0),
      0,
      10,
      false,
      Paint()
        ..style = PaintingStyle.fill
        ..color = AppColors.halfWhite,
    );

    canvas.drawArc(
      Rect.fromCircle(center: Offset(width, height), radius: 6.0),
      -1.57, // Start angle (π/2 radians)
      -1.57, // Sweep angle (π radians)
      false,
      Paint()
        ..style = PaintingStyle.fill
        ..strokeWidth = 1.0 // Border thickness
        ..color = AppColors.halfWhite, // Border color
    );

    canvas.drawArc(
      Rect.fromCircle(center: Offset(width, height), radius: 6.0),
      -1.57, // Start angle (π/2 radians)
      -1.57, // Sweep angle (π radians)
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0 // Border thickness
        ..color = AppColors.retroLime, // Border color
    );

    canvas.drawArc(
      Rect.fromCircle(center: const Offset(0, 0), radius: 6.0),
      0,
      10,
      false,
      Paint()
        ..style = PaintingStyle.fill
        ..color = AppColors.halfWhite,
    );

    canvas.drawArc(
      Rect.fromCircle(center: Offset(width, 0), radius: 6.0),
      3.14, // Start angle (π/2 radians)
      -1.57, // Sweep angle (π radians)
      false,
      Paint()
        ..style = PaintingStyle.fill
        ..strokeWidth = 1.0 // Border thickness
        ..color = AppColors.halfWhite, // Border color
    );

    canvas.drawArc(
      Rect.fromCircle(center: Offset(width, 0), radius: 6.0),
      3.14, // Start angle (π/2 radians)
      -1.57, // Sweep angle (π radians)
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0 // Border thickness
        ..color = AppColors.retroLime, // Border color
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
