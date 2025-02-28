import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';

class CancellationPolicyCard extends StatelessWidget {
  const CancellationPolicyCard({super.key});

  Future<void> _launchURL() async {
    const url = 'https://rinzelaundry.com/terms-conditions';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.all(
          Radius.circular(10.0),
        ),
        border: Border.all(
          color: AppColors.black.withOpacity(0.06),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            offset: const Offset(0, 1),
            blurRadius: 8.0,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Free cancellation before clothes pickup',
            style: TextStyle(
              color: AppColors.hintBlack,
              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
              fontSize: AppFonts.fontSize14,
              fontWeight: AppFonts.fontWeightMedium,
            ),
          ),
          const SizedBox(height: 4.0),
          const Text(
            '20% Cancellation fee after clothes pickup',
            style: TextStyle(
              color: AppColors.hintBlack,
              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
              fontSize: AppFonts.fontSize14,
              fontWeight: AppFonts.fontWeightMedium,
            ),
          ),
          const SizedBox(height: 4.0),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'No cancellation ',
                  style: TextStyle(
                    color: AppColors.hintBlack,
                    fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                    fontSize: AppFonts.fontSize14,
                    fontWeight: AppFonts.fontWeightBold,
                  ),
                ),
                TextSpan(
                  text: 'after services are started',
                  style: TextStyle(
                    color: AppColors.hintBlack,
                    fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                    fontSize: AppFonts.fontSize14,
                    fontWeight: AppFonts.fontWeightMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24.0),
          GestureDetector(
            onTap: _launchURL,
            child: Row(
              children: [
                const Text(
                  'Click to read the terms and conditions',
                  style: TextStyle(
                    color: AppColors.darkBlue,
                    fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                    fontSize: AppFonts.fontSize14,
                    fontWeight: AppFonts.fontWeightBold,
                  ),
                ),
                const SizedBox(width: 2.0),
                SvgPicture.asset('assets/icons/arrow_right.svg'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
