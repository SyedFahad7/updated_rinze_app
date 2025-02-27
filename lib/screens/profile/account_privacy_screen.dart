import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rinze/screens/profile/delete_info_account_screen.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_fonts.dart';

class AccountPrivacyScreen extends StatefulWidget {
  const AccountPrivacyScreen({super.key});

  @override
  State<AccountPrivacyScreen> createState() => _AccountPrivacyScreenState();
}

class _AccountPrivacyScreenState extends State<AccountPrivacyScreen> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120.0),
        child: AppBar(
          backgroundColor: AppColors.lightWhite,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 50.0, left: 28.0, right: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/arrow_left.svg',
                      ),
                      const SizedBox(width: 2),
                      const Text(
                        'Back',
                        style: TextStyle(
                          color: AppColors.black,
                          fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                          fontSize: AppFonts.fontSize14,
                          fontWeight: AppFonts.fontWeightRegular,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Account privacy',
                  style: TextStyle(
                    color: AppColors.darkBlue,
                    fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                    fontSize: AppFonts.fontSize28,
                    fontWeight: AppFonts.fontWeightSemiBold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Account privacy and policy',
                style: TextStyle(
                  color: AppColors.black,
                  fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  fontSize: AppFonts.fontSize20,
                  fontWeight: AppFonts.fontWeightMedium,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We i.e. "Rinze pvt. limited"("Company"), are committed to protecting the privacy and security of your personal information. '
                'Your privacy is important to us and maintaining your trust is paramount. ',
                style: TextStyle(
                  color: AppColors.black.withValues(alpha: 0.6),
                  fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  fontSize: AppFonts.fontSize12,
                  fontWeight: AppFonts.fontWeightRegular,
                  height: 1.5,
                ),
              ),
              if (_isExpanded) ...[
                const SizedBox(height: 8),
                Text(
                  'This privacy policy explains how we collect, use, process and disclose information about you. '
                  'By using our website/ app/platform and affiliated services, you consent to the terms of our privacy policy ("Privacy Policy") in addition to our \'Terms of Use\'. '
                  'We encourage you to read this privacy policy to understand the collection, use, and disclosure of your information from time to time, to keep yourself updated with the changes and updates that we make to this policy. ',
                  style: TextStyle(
                    color: AppColors.black.withValues(alpha: 0.6),
                    fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                    fontSize: AppFonts.fontSize12,
                    fontWeight: AppFonts.fontWeightRegular,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This privacy policy describes our privacy practices for all websites, products and services that are linked to it. ',
                  style: TextStyle(
                    color: AppColors.black.withValues(alpha: 0.6),
                    fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                    fontSize: AppFonts.fontSize12,
                    fontWeight: AppFonts.fontWeightRegular,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'However this policy does not apply to those affiliates and partners that have their own privacy policy. In such situations, we recommend that you read the privacy policy on the applicable site. ',
                  style: TextStyle(
                    color: AppColors.black.withValues(alpha: 0.6),
                    fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                    fontSize: AppFonts.fontSize12,
                    fontWeight: AppFonts.fontWeightRegular,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    text:
                        'Should you have any clarifications regarding this privacy policy, please write to us at ',
                    style: TextStyle(
                      color: AppColors.black.withValues(alpha: 0.6),
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize12,
                      fontWeight: AppFonts.fontWeightRegular,
                      height: 1.5,
                    ),
                    children: const [
                      TextSpan(
                        text: 'rinzelaundry@gmail.com',
                        style: TextStyle(
                          color: AppColors.darkBlue,
                          fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                          fontSize: AppFonts.fontSize12,
                          fontWeight: AppFonts.fontWeightRegular,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Row(
                  children: [
                    Text(
                      _isExpanded ? 'Read Less' : 'Read More',
                      style: const TextStyle(
                        color: AppColors.darkBlue,
                        fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                        fontSize: AppFonts.fontSize14,
                        fontWeight: AppFonts.fontWeightSemiBold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    SvgPicture.asset(
                      _isExpanded
                          ? 'assets/icons/arrow_up.svg'
                          : 'assets/icons/arrow_down.svg',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DeleteInfoAccountScreen()),
                  );
                },
                child: Container(
                  width: 321,
                  height: 54,
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset('assets/icons/bin.svg'),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Request to delete account',
                            style: TextStyle(
                              color: AppColors.black,
                              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                              fontSize: AppFonts.fontSize14,
                              fontWeight: AppFonts.fontWeightSemiBold,
                            ),
                          ),
                          Text(
                            'Request to closure of your account',
                            style: TextStyle(
                              color: AppColors.black,
                              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                              fontSize: AppFonts.fontSize12,
                              fontWeight: AppFonts.fontWeightRegular,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      SvgPicture.asset('assets/icons/arrow_right.svg'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
