import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rinze/components/review_feedback.dart';

import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';
import 'home_navigation_screen.dart';

class PaymentConfirmationScreen extends StatefulWidget {
  const PaymentConfirmationScreen({super.key});

  @override
  State<PaymentConfirmationScreen> createState() =>
      _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.darkBlueGradient,
          ),
          child: Stack(
            children: [
              // Confetti SVG as background
              Positioned(
                child: SvgPicture.asset(
                  'assets/images/confetti.svg',
                  fit: BoxFit.cover,
                  height: MediaQuery.of(context).size.height - 200,
                ),
              ),
              // Main content
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Spacer to push the check circle down a bit
                  const Spacer(flex: 2),
                  // Check circle SVG centered
                  SvgPicture.asset(
                    'assets/icons/check_circle.svg',
                  ),
                  const SizedBox(
                      height: 8), // Space between check circle and text
                  // Order Placed Text
                  const Text(
                    'Order Placed',
                    style: TextStyle(
                      color: AppColors.white,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize24,
                      fontWeight: AppFonts.fontWeightExtraBold,
                    ),
                  ),
                  const SizedBox(
                      height: 16), // Space between text and description
                  // Partner Pickup Text
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'Our Partner will be there soon to pickup your clothes',
                      style: TextStyle(
                        color: AppColors.white,
                        fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                        fontSize: AppFonts.fontSize16,
                        fontWeight: AppFonts.fontWeightSemiBold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Spacer(flex: 1), // Push the button towards the bottom
                  // Continue Button with Transition
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 60.0), // Add padding at the bottom
                    child: SizedBox(
                      width: 312, // Set button width
                      height: 64, // Set button height
                      child: ElevatedButton(
                        onPressed: () async {
                          // Navigate to HomeBottomNavigation
                          await Navigator.push(
                            context,
                            PageTransition(
                              curve: Curves.linear,
                              type: PageTransitionType.bottomToTop,
                              child: const HomeBottomNavigation(
                                  selectedIndex: 0, showReviewDialog: true),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColors.white, // Button background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            color: AppColors.darkBlue, // Text color
                            fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                            fontSize: AppFonts.fontSize16,
                            fontWeight: AppFonts.fontWeightSemiBold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
