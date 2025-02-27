import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_fonts.dart';

class WardrobeModalScreen extends StatelessWidget {
  const WardrobeModalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          child: Container(
            padding: const EdgeInsets.only(top: 24),
            decoration: const BoxDecoration(
              color: AppColors.dimBlue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: 0,
                  top: 0,
                  child: SvgPicture.asset(
                    'assets/images/clouds.svg',
                  ),
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.only(left: 16.0, top: 20),
                      child: Text(
                        'Your Wardrobe’s \n Best Friend',
                        style: TextStyle(
                          fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                          fontSize: AppFonts.fontSize20,
                          fontWeight: AppFonts.fontWeightExtraBold,
                          color: AppColors.shadeBlue,
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: Text(
                        'Your partner in \n perfect laundry care,\n day after day.',
                        style: TextStyle(
                          fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                          fontSize: AppFonts.fontSize16,
                          fontWeight: AppFonts.fontWeightSemiBold,
                          color: AppColors.darkBlue,
                        ),
                      ),
                    ),
                    SizedBox(height: 140),
                  ],
                ),
                Positioned(
                  right: 0,
                  top: 123,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: SvgPicture.asset(
                      'assets/images/clothes_hanging.svg',
                    ),
                  ),
                ),
                Positioned(
                  top: 180,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 26.0, top: 20),
                    child: SizedBox(
                      width: 146,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.shadeBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                            fontSize: AppFonts.fontSize16,
                            fontWeight: AppFonts.fontWeightSemiBold,
                            color: AppColors.baseWhite,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.close,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
