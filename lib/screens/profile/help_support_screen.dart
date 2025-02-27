import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_fonts.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final List<bool> _isOpen = List.generate(6, (_) => false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(280.0),
        child: AppBar(
          backgroundColor: AppColors.lightWhite,
          surfaceTintColor: AppColors.lightWhite,
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
                  'Help & Support',
                  style: TextStyle(
                    color: AppColors.darkBlue,
                    fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                    fontSize: AppFonts.fontSize24,
                    fontWeight: AppFonts.fontWeightSemiBold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Let's take a step ahead & help you better",
                  style: TextStyle(
                    color: AppColors.black.withValues(alpha: 0.6),
                    fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                    fontSize: AppFonts.fontSize16,
                    fontWeight: AppFonts.fontWeightRegular,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    SvgPicture.asset('assets/icons/phone.svg'),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Call Us',
                          style: TextStyle(
                            color: AppColors.darkBlue,
                            fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                            fontSize: AppFonts.fontSize16,
                            fontWeight: AppFonts.fontWeightSemiBold,
                          ),
                        ),
                        Text(
                          '+910000000000',
                          style: TextStyle(
                            color: AppColors.black.withValues(alpha: 0.6),
                            fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                            fontSize: AppFonts.fontSize14,
                            fontWeight: AppFonts.fontWeightRegular,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    SvgPicture.asset('assets/icons/email.svg'),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mail Us',
                          style: TextStyle(
                            color: AppColors.darkBlue,
                            fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                            fontSize: AppFonts.fontSize16,
                            fontWeight: AppFonts.fontWeightSemiBold,
                          ),
                        ),
                        Text(
                          'rinzelaudry@gmail.com',
                          style: TextStyle(
                            color: AppColors.black.withValues(alpha: 0.6),
                            fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                            fontSize: AppFonts.fontSize14,
                            fontWeight: AppFonts.fontWeightRegular,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text(
                'FAQs',
                style: TextStyle(
                  color: AppColors.darkBlue,
                  fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  fontSize: AppFonts.fontSize28,
                  fontWeight: AppFonts.fontWeightSemiBold,
                ),
              ),
              const SizedBox(height: 16),
              _buildFaqItem(0, 'What services are available?',
                  "We offer a complete range of laundry services including washing, ironing & dry cleaning"),
              _buildFaqItem(1, 'How do I schedule a laundry pickup?',
                  "Simply open the Rinze Laundry app, choose your services, select a pickup time, and confirm your order. Our team will handle the rest!"),
              _buildFaqItem(2, 'What areas do you currently serve?',
                  "We offer a complete range of laundry services including washing, ironing & dry cleaning"),
              _buildFaqItem(3, 'What is the minimum order value?',
                  "Yes, we have a minimum order requirement for delivery. Please check the app for the latest details on minimum order requirements"),
              _buildFaqItem(4, 'How long does order completion take?',
                  "Our standard turnaround time depends on the service. Washing and ironing usually take 1–2 days, while dry cleaning may require a bit longer. You can check the estimated time when placing an order."),
              _buildFaqItem(5, 'Do you have a refund policy?',
                  "Yes, we have a refund policy"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqItem(int index, String question, String answer) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isOpen[index] = !_isOpen[index];
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.halfWhite,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    question,
                    style: const TextStyle(
                      color: AppColors.black,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize14,
                      fontWeight: AppFonts.fontWeightMedium,
                    ),
                  ),
                ),
                SvgPicture.asset(
                  _isOpen[index]
                      ? 'assets/icons/arrow_up.svg'
                      : 'assets/icons/arrow_down.svg',
                  colorFilter: const ColorFilter.mode(
                    AppColors.black,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
            if (_isOpen[index])
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  answer,
                  style: const TextStyle(
                    color: AppColors.black,
                    fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                    fontSize: AppFonts.fontSize12,
                    fontWeight: AppFonts.fontWeightRegular,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
