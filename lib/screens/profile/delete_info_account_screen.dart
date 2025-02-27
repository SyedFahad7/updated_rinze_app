import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'delete_account_screen.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_fonts.dart';

class DeleteInfoAccountScreen extends StatefulWidget {
  const DeleteInfoAccountScreen({super.key});

  @override
  State<DeleteInfoAccountScreen> createState() =>
      _DeleteInfoAccountScreenState();
}

class _DeleteInfoAccountScreenState extends State<DeleteInfoAccountScreen> {
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
                  'Delete account',
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
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Delete my account',
                style: TextStyle(
                  color: AppColors.black,
                  fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  fontSize: AppFonts.fontSize20,
                  fontWeight: AppFonts.fontWeightSemiBold,
                ),
              ),
              Text(
                'Why would you like to delete your account?',
                style: TextStyle(
                  color: AppColors.black.withValues(alpha: 0.5),
                  fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  fontSize: AppFonts.fontSize14,
                  fontWeight: AppFonts.fontWeightMedium,
                ),
              ),
              const SizedBox(height: 26),
              _buildReasonTab(context, 'I don\'t want to use Rinze anymore.'),
              _buildReasonTab(context, 'I am using a different account.'),
              _buildReasonTab(context, 'I am worried about my privacy.'),
              _buildReasonTab(context,
                  'You are sending me too many emails / notifications.'),
              _buildReasonTab(context, 'This app is not working properly.'),
              _buildReasonTab(context, 'Other.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReasonTab(BuildContext context, String reason) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DeleteAccountScreen(reason: reason),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 54,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(
            color: AppColors.black.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                reason,
                style: const TextStyle(
                  color: AppColors.black,
                  fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  fontSize: AppFonts.fontSize12,
                  fontWeight: AppFonts.fontWeightMedium,
                ),
              ),
            ),
            SvgPicture.asset('assets/icons/arrow_right.svg'),
          ],
        ),
      ),
    );
  }
}
