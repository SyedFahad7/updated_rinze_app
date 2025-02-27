import 'package:flutter/material.dart';
import 'package:rinze/constants/app_colors.dart';
import '../constants/app_fonts.dart';

class HomeCategorySection extends StatefulWidget {
  const HomeCategorySection({
    super.key,
    required this.category,
    required this.sections,
    required this.isTraditional,
    required this.isKids,
  });

  final String category;
  final List<SectionItem> sections;
  final bool isTraditional;
  final bool isKids;

  @override
  State<HomeCategorySection> createState() => _HomeCategorySectionState();
}

class _HomeCategorySectionState extends State<HomeCategorySection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.isKids) ...[
          Padding(
            padding: const EdgeInsets.only(left: 0.0), // Add left padding here
            child: Text(
              widget.category,
              style: const TextStyle(
                fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                fontSize: AppFonts.fontSize18,
                fontWeight: AppFonts.fontWeightSemiBold,
                color: AppColors.black,
              ),
            ),
          ),
        ] else if (widget.isTraditional) ...[
          Padding(
            padding: const EdgeInsets.only(left: 0.0), // Add left padding here
            child: Text(
              widget.category,
              style: const TextStyle(
                fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                fontSize: AppFonts.fontSize18,
                fontWeight: AppFonts.fontWeightRegular,
                color: AppColors.lightYellow,
              ),
            ),
          ),
        ] else ...[
          Padding(
            padding: const EdgeInsets.only(left: 0.0), // Add left padding here
            child: Text(
              widget.category,
              style: const TextStyle(
                fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                fontSize: AppFonts.fontSize18,
                fontWeight: AppFonts.fontWeightRegular,
                color: AppColors.black,
              ),
            ),
          ),
        ],
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.sections.length,
            itemBuilder: (context, index) {
              return SectionItem(
                imagePath: widget.sections[index].imagePath,
                title: widget.sections[index].title,
                onTap: widget.sections[index].onTap,
                isTraditional: widget.isTraditional,
                isKids: widget.isKids,
              );
            },
          ),
        ),
      ],
    );
  }
}

class SectionItem extends StatelessWidget {
  final String imagePath;
  final String title;
  final VoidCallback onTap;
  final bool? isTraditional;
  final bool? isKids;

  const SectionItem({
    super.key,
    required this.imagePath,
    required this.title,
    required this.onTap,
    this.isTraditional,
    this.isKids,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              height: 100.0,
              color: Colors.transparent,
              child: Image.network(imagePath),
            ),
            const SizedBox(height: 5.0),
            if (isTraditional ?? false) ...[
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.lightYellow,
                  fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  fontSize: AppFonts.fontSize14,
                  fontWeight: AppFonts.fontWeightRegular,
                ),
              ),
            ] else ...[
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.black,
                  fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  fontSize: AppFonts.fontSize14,
                  fontWeight: AppFonts.fontWeightRegular,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
