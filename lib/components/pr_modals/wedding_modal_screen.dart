import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_fonts.dart';

class WeddingModalScreen extends StatelessWidget {
  const WeddingModalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          child: Container(
            padding: const EdgeInsets.only(top: 0),
            decoration: const BoxDecoration(
              color: AppColors.maroon,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 120,
                  top: 0,
                  child: SvgPicture.asset(
                    'assets/images/flowers.svg',
                  ),
                ),
                Positioned(
                  right: 40,
                  top: 0,
                  child: SvgPicture.asset(
                    'assets/images/flowers2.svg',
                  ),
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.only(left: 22.0, top: 20),
                      child: Text(
                        'Celebrate in \n Style 🎉',
                        style: TextStyle(
                          fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                          fontSize: AppFonts.fontSize20,
                          fontWeight: AppFonts.fontWeightExtraBold,
                          color: AppColors.cream,
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    Padding(
                      padding: EdgeInsets.only(left: 22.0),
                      child: Text(
                        'Say “I Do” to \n Sparkling Clean \n Clothes,Only with \n Rinze Laundry',
                        style: TextStyle(
                          fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                          fontSize: AppFonts.fontSize16,
                          fontWeight: AppFonts.fontWeightSemiBold,
                          color: AppColors.shadePink,
                        ),
                      ),
                    ),
                    SizedBox(height: 140),
                  ],
                ),
                Positioned(
                  right: 0,
                  top: 70,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 32.0),
                    child: SvgPicture.asset(
                      'assets/images/couple.svg',
                    ),
                  ),
                ),
                Positioned(
                  top: 180,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 22.0, top: 50),
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
                          'Book Now',
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
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset(
                'assets/icons/close.svg',
                // ignore: deprecated_member_use
                color: AppColors.baseWhite,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
