import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_fonts.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final Uri _privacyPolicyUrl =
      Uri.parse('https://rinzelaundry.com/privacy-policy/');
  final Uri _termsConditionsUrl =
      Uri.parse('https://rinzelaundry.com/terms-conditions/');
  final Uri _xunoiaUrl = Uri.parse('https://xunoia.com');

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120.0),
        child: AppBar(
          backgroundColor: AppColors.lightWhite,
          surfaceTintColor: AppColors.lightWhite,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(
              top: 50.0,
              left: 28.0,
              right: 28.0,
            ),
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
                  'About Us',
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
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Text(
                'Welcome to Rinze Laundry, where we transform laundry from a chore into a breeze. Tired of spending hours on laundry? Let us take care of it for you!',
                style: TextStyle(
                  color: AppColors.black.withValues(alpha: 0.6),
                  fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  fontSize: AppFonts.fontSize14,
                  fontWeight: AppFonts.fontWeightSemiBold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Our premium laundry service offers a full range of options—washing, ironing, combined washing & ironing, and expert dry cleaning—to meet all your needs.',
                style: TextStyle(
                  color: AppColors.black.withValues(alpha: 0.6),
                  fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  fontSize: AppFonts.fontSize14,
                  height: 1.5,
                  fontWeight: AppFonts.fontWeightSemiBold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Located in Chimakurty, India, we proudly serve the community with high-quality service, reliable delivery options, and affordable prices. From removing stubborn stains to handling delicate fabrics, our dedicated team is here to ensure your clothes come back looking and feeling fresh. With Rinze Laundry, laundry day is now as easy as a tap on your app.',
                style: TextStyle(
                  color: AppColors.black.withValues(alpha: 0.6),
                  fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  height: 1.5,
                  fontSize: AppFonts.fontSize14,
                  fontWeight: AppFonts.fontWeightSemiBold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Our mission is simple: Make life easier by taking the load off your laundry. So go ahead, spend more time doing the things you love—leave the laundry to us.',
                style: TextStyle(
                  color: AppColors.black.withValues(alpha: 0.6),
                  height: 1.5,
                  fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  fontSize: AppFonts.fontSize14,
                  fontWeight: AppFonts.fontWeightSemiBold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    'Developed by ',
                    style: TextStyle(
                      color: AppColors.darkBlue,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize22,
                      fontWeight: AppFonts.fontWeightSemiBold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Image.asset(
                      'assets/images/xunoia.png',
                      height: 22,
                      width: 22,
                    ),
                  ),
                  const Text(
                    'unoia',
                    style: TextStyle(
                      color: AppColors.darkBlue,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize22,
                      fontWeight: AppFonts.fontWeightSemiBold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  text: 'Rinze Laundry is proud to collaborate with ',
                  style: TextStyle(
                    color: AppColors.black.withValues(alpha: 0.6),
                    fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                    fontSize: AppFonts.fontSize14,
                    fontWeight: AppFonts.fontWeightSemiBold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Xunoia',
                      style: const TextStyle(
                        color: AppColors.lightBlue,
                        fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                        fontSize: AppFonts.fontSize14,
                        fontWeight: AppFonts.fontWeightBlack,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          _launchUrl(Uri.parse('https://xunoia.com'));
                        },
                    ),
                    TextSpan(
                      text:
                          ', a company dedicated to crafting innovative and user-friendly applications. With a commitment to excellence, Xunoia ensures that the Rinze Laundry app delivers a seamless and enjoyable experience for all our users.',
                      style: TextStyle(
                        color: AppColors.black.withValues(alpha: 0.6),
                        fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                        fontSize: AppFonts.fontSize14,
                        fontWeight: AppFonts.fontWeightSemiBold,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              InkWell(
                onTap: () {
                  _launchUrl(_privacyPolicyUrl);
                },
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0x0F000000)),
                  ),
                  child: const Center(
                    child: Text(
                      'Privacy Policy',
                      style: TextStyle(
                        color: AppColors.black,
                        fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                        fontSize: AppFonts.fontSize14,
                        fontWeight: AppFonts.fontWeightRegular,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () {
                  _launchUrl(_termsConditionsUrl);
                },
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0x0F000000)),
                  ),
                  child: const Center(
                    child: Text(
                      'Terms & Conditions',
                      style: TextStyle(
                        color: AppColors.black,
                        fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                        fontSize: AppFonts.fontSize14,
                        fontWeight: AppFonts.fontWeightRegular,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
