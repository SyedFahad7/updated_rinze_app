import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:rinze/providers/coupons_provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';

class CouponsScreen extends StatefulWidget {
  const CouponsScreen({super.key, required this.couponsData});

  final List<dynamic>? couponsData;

  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  @override
  Widget build(BuildContext context) {
    final couponGlobalState = Provider.of<CouponsGlobalState>(context);
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120.0),
        child: AppBar(
          backgroundColor: AppColors.backWhite,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 50.0, left: 24.0, right: 24.0),
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
                const SizedBox(
                  height: 16,
                ),
                const Text(
                  'Available Coupons:-',
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
          padding: const EdgeInsets.all(24.0),
          child: ListView.builder(
            itemCount: widget.couponsData?.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> couponData = widget.couponsData?[index];
              String discountCode = couponData['discount_code'];
              String discountType = couponData['discount_type'];
              int discountValue = couponData['discount_value'];
              int minimumPurchaseAmount =
                  couponData['discount_minimum_purchase_amount'];

              return GestureDetector(
                onTap: () {
                  couponGlobalState.setSelectedCoupon(couponData);
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12.0),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: AppColors.halfWhite,
                    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                    border: Border.all(
                      color: AppColors.black.withValues(alpha: 0.06),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'COUPON CODE: "$discountCode"',
                        style: const TextStyle(
                          color: AppColors.hintBlack,
                          fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                          fontSize: AppFonts.fontSize16,
                          fontWeight: AppFonts.fontWeightBold,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      discountType == 'fixed'
                          ? Text(
                              'Get up to ₹$discountValue off on orders above ₹$minimumPurchaseAmount.',
                              style: const TextStyle(
                                color: AppColors.hintBlack,
                                fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                                fontSize: AppFonts.fontSize12,
                                fontWeight: AppFonts.fontWeightMedium,
                              ),
                            )
                          : Text(
                              'Enjoy up to $discountValue% off on orders over ₹$minimumPurchaseAmount.',
                              style: const TextStyle(
                                color: AppColors.hintBlack,
                                fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                                fontSize: AppFonts.fontSize12,
                                fontWeight: AppFonts.fontWeightMedium,
                              ),
                            ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Row(
// mainAxisAlignment:
// MainAxisAlignment.spaceBetween,
// children: [
// Text(
// capitalize('${address['addressType']}'),
// style: TextStyle(
// color: AppColors.black.withValues(alpha:0.6),
// fontFamily:
// AppFonts.fontFamilyPlusJakartaSans,
// fontSize: AppFonts.fontSize10,
// fontWeight: AppFonts.fontWeightBold,
// ),
// ),
// if (address == defaultAddress)
// const Text(
// 'Default',
// style: TextStyle(
// color: AppColors.retroLime,
// fontFamily: AppFonts
//     .fontFamilyPlusJakartaSans,
// fontSize: AppFonts.fontSize10,
// fontWeight: AppFonts.fontWeightBold,
// ),
// ),
// ],
// ),
// Text(
// '${address['formatted_address']}',
// style: const TextStyle(
// color: AppColors.hintBlack,
// fontFamily:
// AppFonts.fontFamilyPlusJakartaSans,
// fontSize: AppFonts.fontSize16,
// fontWeight: AppFonts.fontWeightSemiBold,
// ),
// ),
// Text(
// '${address['street_number']}, ${address['route']}, ${address['locality']}, ${address['administrative_area_level_1']}, ${address['country']}',
// style: const TextStyle(
// color: AppColors.hintBlack,
// fontFamily:
// AppFonts.fontFamilyPlusJakartaSans,
// fontSize: AppFonts.fontSize12,
// fontWeight: AppFonts.fontWeightMedium,
// ),
// ),
// Text(
// '${address['postal_code']}',
// style: const TextStyle(
// color: AppColors.hintBlack,
// fontFamily:
// AppFonts.fontFamilyPlusJakartaSans,
// fontSize: AppFonts.fontSize12,
// fontWeight: AppFonts.fontWeightMedium,
// ),
// ),
