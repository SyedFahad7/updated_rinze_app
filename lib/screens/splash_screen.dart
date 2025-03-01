import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rinze/constants/app_colors.dart';
import 'package:rinze/constants/app_fonts.dart';
import 'package:rinze/screens/auth/login_screen.dart';
import 'package:rinze/screens/home_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  final String? token;

  static const id = '/splash';

  const SplashScreen({super.key, required this.token});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _contentController;
  late Animation<Offset> _contentOffsetAnimation;

  @override
  void initState() {
    super.initState();

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1001),
    );

    _contentOffsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0.099),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeInOut,
    ));

    _contentController.forward();

    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (!mounted) return; // Check if the widget is still in the tree
      if (widget.token != null && widget.token!.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeBottomNavigation(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: SlideTransition(
              position: _contentOffsetAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/images/splash_logo.svg',
                    width: 120.0,
                    height: 120.0,
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    "Rinze",
                    style: TextStyle(
                      fontSize: AppFonts.fontSize26,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontWeight: AppFonts.fontWeightExtraBold,
                      color: AppColors.shadeBlue,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    "Laundry Made Simple.",
                    style: TextStyle(
                      fontSize: AppFonts.fontSize18,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontWeight: AppFonts.fontWeightSemiBold,
                      color: AppColors.shadeBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 18.0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _contentOffsetAnimation,
              child: SlideTransition(
                position: _contentOffsetAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Developed by",
                      style: TextStyle(
                        fontSize: AppFonts.fontSize16,
                        fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                        fontWeight: AppFonts.fontWeightExtraBold,
                        color: AppColors.shadeBlue,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/xunoia.png',
                          width: 16.0,
                          height: 16.0,
                        ),
                        const SizedBox(width: 4.0),
                        const Text(
                          "XUNOIA",
                          style: TextStyle(
                            fontSize: AppFonts.fontSize16,
                            fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                            fontWeight: AppFonts.fontWeightExtraBold,
                            color: AppColors.shadeBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
