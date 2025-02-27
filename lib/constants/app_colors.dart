import 'dart:math';

import 'package:flutter/material.dart';

class AppColors {
  // Login page pane..
  static const Color white = Color(0xFFFFFFFF);
  static const Color hintWhite = Color(0xFFE8E8ED);
  static const Color halfWhite = Color(0xFFF9FAFB);
  static const Color baseWhite = Color(0xFFFCFCFD);
  static const Color backWhite = Color(0xFFF6F6F8);
  static const Color skillWhite = Color(0xFFEAEDF5);
  static const Color lightDark = Color(0xFFEAEDF6);
  static const Color baseGrey = Color(0xFFF7F7F9);
  static const Color lightGrey = Color(0xFFEEEDF7);
  static const Color hintGrey = Color(0xFFE6E7E9);
  static const Color black = Color(0xFF000000);
  static const Color hintBlack = Color(0xFF010307);
  static const Color baseBlack = Color(0xFF061027);
  static const Color backBlack = Color(0x00111111);
  static const Color darkBlack = Color(0xFF020610);
  static const Color lightRed = Color(0xFFFF6F6F);
  static const Color fadeRed = Color(0xFFD75757);
  static const Color shadePink = Color(0xFFF4A3A3);
  static const Color darkBlue = Color(0xFF1D1949);
  static const Color darkerBlue = Color(0xFF1C1949);
  static const Color darkestBlue = Color(0xFF050D1F);
  static const Color lightBlue = Color(0xFF1C4EC5);
  static const Color dimBlue = Color(0xFFB0C8EA);
  static const Color fadeBlue = Color(0xFF384052);
  static const Color greyPurple = Color(0xFF908BC9);
  static const Color retroLime = Color(0xFF109E6A);
  static const Color green = Color(0xFF056340);
  static const Color lightYellow = Color(0xFFE9D566);
  static const Color cream = Color(0xFFF4C786);
  static const Color maroon = Color(0xFF9A2143);
  static const Color darkYellow = Color(0xFF9E8C3F);
  static const Color whiteGrey = Color(0xFFD9D9D9);
  static const Color timeGrey = Color(0xFFE2E2E2);
  static const Color thumbGrey = Color(0xFF9A9A9A);
  static Color transparent = const Color(0xFFFFFFFF).withValues(alpha: 0.0);
  static const Color iconGrey = Color(0xFF6A707D);
  static const Color darkGrey = Color(0xFF1F1F1F);
  static const Color skyBlue = Color(0xFF9FC5FF);
  static const Color shadeBlue = Color(0xFF0E5AC4);
  static const Color greyBlack = Color(0xFF666666);
  static const Color lightGreen = Color(0xFFF9F8A3);
  static const Color lighterBlue = Color(0xFF9FC5FF);
  static const Color amber = Color(0xFFFFD029);
  static const Color lightGray = Color(0xFFEFF0F6);

  static const LinearGradient customBlueGradient = LinearGradient(
    begin: Alignment(0.45, -1), // Approximates 212° angle start
    end: Alignment(-0.45, 1), // Approximates 212° angle end
    colors: [
      Color(0xFF1C1949), // Start color
      Color(0xFF29219F), // End color
    ],
    stops: [0.1417, 0.8537], // Approximates 14.17% and 85.37% stops
  );
  static const LinearGradient blueGradient = LinearGradient(
    colors: [
      Color(0xFF1C1949), // Start color
      Color(0xFF29219F), // End color
    ],
    stops: [0, 0], // Approximates 14.17% and 85.37% stops
  );

  static const LinearGradient traditionalGradient = LinearGradient(
    begin: Alignment.topCenter, // Represents 180° start
    end: Alignment.bottomCenter, // Represents 180° end
    colors: [
      Color(0xFF531B29), // Start color
      Color(0xFFB93C5B), // End color
    ],
    stops: [0.0, 1.0], // Start and end at 0% and 100%
  );

  // Discount pane
  static const LinearGradient darkBlueGradient = LinearGradient(
    transform: GradientRotation(212 * (pi / 45)), // Convert degrees to radians
    colors: [
      Color(0xFF1C1949), // #1C1949
      Color(0xFF29219F), // #29219F
    ],
    stops: [0.1417, 0.8537], // 14.17% and 85.37%
  );

  //Viewed Notifcation Container
  static const Color fadeWhite = Color(0xFFFBFBFB);

  // Add Button
  static const Color lightWhite = Color(0xFFF9FAFB);

  // Tab Button (Men, Women, Children)
  static const Color opaqueGrey = Color(0x59061027);

  // Toggle Switch
  static const Color toggleSwitchColor = Color(0x29787880);

  // Discount/Quote Pane etc
  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF837ECC), // #837ECC
      Color(0xFF3C368D), // #3C368D
    ],
    stops: [0.0633, 0.918],
  );

  static const LinearGradient yellowGreenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE9D566), // #E9D566
      Color(0xFF26C4BA), // #26C4BA
    ],
    stops: [0.0633, 0.918],
  );

  static const LinearGradient yellowBlackGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF9FC5F),
      Color(0xFF949638),
    ],
    stops: [0.0367, 0.9719],
  );

  // Radial gradient approximation colors for progress bar
  static const Color radialDarkPurple = Color(0xFF191640); // Darkest purple
  static const Color radialMidPurple = Color(0xFF2A2754); // Medium purple
  static const Color radialGreyBlue = Color(0xFF37345E); // Grayish blue
  static const Color radialGreyPurple = Color(0xFF46446B); // Light grey-purple
  static const Color radialLightGreyPurple =
      Color(0xFF49466D); // Lighter grey-purple
  static const Color radialSoftGrey = Color(0xFF4D4B71); // Soft grey
  static const Color radialLightGrey = Color(0xFF524F74);
}
