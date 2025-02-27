import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_fonts.dart';

class FreeDeliveryModal extends StatelessWidget {
  const FreeDeliveryModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -15,
                  top: -10,
                  child: Transform.rotate(
                    angle: 0, // Rotation angle in radians
                    child: SvgPicture.asset(
                      'assets/images/graffiti.svg',
                    ),
                  ),
                ),
                Positioned(
                  left: -25,
                  top: 95,
                  child: Transform.rotate(
                    angle: 0, // Rotation angle in radians
                    child: SvgPicture.asset(
                      'assets/images/graffiti2.svg',
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Enjoy Free Delivery',
                      style: TextStyle(
                        fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                        fontSize: AppFonts.fontSize20,
                        fontWeight: AppFonts.fontWeightExtraBold,
                        color: AppColors.shadeBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Schedule your pickup today & \nGet free delivery on every order.',
                      style: TextStyle(
                        fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                        fontSize: AppFonts.fontSize16,
                        fontWeight: AppFonts.fontWeightSemiBold,
                        color: AppColors.darkBlue,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.shadeBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        child: Text(
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
                    const SizedBox(height: 140),
                  ],
                ),
                Positioned(
                  right: -10,
                  top: 123,
                  child: SvgPicture.asset(
                    'assets/icons/delivery_guy.svg',
                    height: 200,
                    width: 200,
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
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.close,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
