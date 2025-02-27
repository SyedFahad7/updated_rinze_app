import 'package:flutter/material.dart';
import 'package:rinze/utils/string_utils.dart';

import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';
import '../screens/home_navigation_screen.dart';

class BasketItemRowPerKG extends StatefulWidget {
  const BasketItemRowPerKG({
    super.key,
    required this.category,
    required this.totalWeightPerCategory,
    required this.totalPiecesPerCategory,
    required this.firstItemName,
    required this.firstItemQuantity,
  });

  final String category;
  final String totalWeightPerCategory;
  final int totalPiecesPerCategory;
  final String firstItemName;
  final int firstItemQuantity;

  @override
  State<BasketItemRowPerKG> createState() => _BasketItemRowPerKGState();
}

class _BasketItemRowPerKGState extends State<BasketItemRowPerKG> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Shirt image
              Image.asset(
                'assets/images/group_laundry.png',
                width: 64.0,
              ),
              const SizedBox(width: 8.0),

              // Shirt details (column)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    capitalize(widget.category),
                    style: TextStyle(
                      color: AppColors.black.withValues(alpha: 0.5),
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize12,
                      fontWeight: AppFonts.fontWeightRegular,
                    ),
                  ),
                  Text(
                    widget.totalWeightPerCategory,
                    style: const TextStyle(
                      color: AppColors.hintBlack,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize18,
                      fontWeight: AppFonts.fontWeightSemiBold,
                    ),
                  ),
                  Text(
                    '${widget.totalPiecesPerCategory} P (${widget.firstItemQuantity}x${widget.firstItemName}...)',
                    style: const TextStyle(
                      color: AppColors.hintBlack,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize14,
                      fontWeight: AppFonts.fontWeightMedium,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            width: 66.0,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const HomeBottomNavigation(selectedIndex: 1),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                backgroundColor: AppColors.halfWhite,
                elevation: 0.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
                side: BorderSide(
                  width: 2.0,
                  color: AppColors.black.withValues(alpha: 0.06),
                ),
              ),
              child: const Text(
                'Change',
                style: TextStyle(
                  color: AppColors.black,
                  fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  fontSize: AppFonts.fontSize12,
                  fontWeight: AppFonts.fontWeightSemiBold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
