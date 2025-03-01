import 'package:flutter/material.dart';
import 'package:rinze/constants/app_colors.dart';
import '../constants/app_fonts.dart';

class ServiceSectionItem extends StatelessWidget {
  final String imagePath;
  final String title;
  final VoidCallback onTap;

  const ServiceSectionItem({
    super.key,
    required this.imagePath,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              height: 100.0,
              width: 100.0, // Set the width to match the height
              color: Colors.transparent,
              child: Image.network(imagePath, fit: BoxFit.cover),
            ),
            Container(
              width: 100.0,
              height: 50.0,
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Center(
                // Center the text vertically and horizontally
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2, // Set max lines to 2
                  overflow: TextOverflow.ellipsis, // Handle overflow
                  style: const TextStyle(
                    color: AppColors.black,
                    fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                    fontSize: AppFonts.fontSize12,
                    fontWeight: AppFonts.fontWeightMedium,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
