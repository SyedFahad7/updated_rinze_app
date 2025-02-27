import 'package:flutter/material.dart';
import 'package:rinze/utils/string_utils.dart';

import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';

class BasketItemRow extends StatefulWidget {
  const BasketItemRow({
    super.key,
    required this.counter,
    required this.onPressIncrement,
    required this.onPressDecrement,
    required this.itemName,
    required this.itemImagePath,
    this.pricePerItem,
    required this.category,
  });

  final String itemName;
  final String itemImagePath;
  final String category;
  final String? pricePerItem;
  final int counter;
  final VoidCallback onPressIncrement;
  final VoidCallback onPressDecrement;

  @override
  State<BasketItemRow> createState() => _BasketItemRowState();
}

class _BasketItemRowState extends State<BasketItemRow> {
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
              Image.network(
                widget.itemImagePath,
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
                      fontWeight: AppFonts.fontWeightMedium,
                    ),
                  ),
                  Text(
                    formatStringToMultiline(widget.itemName),
                    style: const TextStyle(
                      color: AppColors.hintBlack,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize18,
                      fontWeight: AppFonts.fontWeightSemiBold,
                    ),
                  ),
                  Text(
                    '₹${widget.pricePerItem} / piece',
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
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: widget.onPressDecrement,
              ),
              Text(
                '${widget.counter}'.toString().padLeft(2, '0'),
                style: const TextStyle(
                  fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  fontSize: AppFonts.fontSize14,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: widget.onPressIncrement,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
