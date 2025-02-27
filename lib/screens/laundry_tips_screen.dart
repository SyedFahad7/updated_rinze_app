import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rinze/constants/app_colors.dart';
import 'package:rinze/constants/app_fonts.dart';

class LaundryTipsScreen extends StatefulWidget {
  const LaundryTipsScreen({super.key});

  @override
  _LaundryTipsScreenState createState() => _LaundryTipsScreenState();
}

class _LaundryTipsScreenState extends State<LaundryTipsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.backWhite,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: GestureDetector(
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
                    color: Color(0xFF1D1949),
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: AppColors.backWhite,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                    ),
                    child: Text(
                      'Laundry Tips',
                      style: TextStyle(
                        color: AppColors.darkBlue,
                        fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                        fontSize: AppFonts.fontSize28,
                        fontWeight: AppFonts.fontWeightSemiBold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'Maximize your laundry results!\nSwipe for quick tips on prepping & caring for your clothes.',
                      style: TextStyle(
                        color: AppColors.black.withValues(alpha: 0.5),
                        fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                        fontSize: AppFonts.fontSize14,
                        fontWeight: AppFonts.fontWeightMedium,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: 312,
                          height: 50,
                          color: const Color.fromRGBO(6, 16, 39, 0.35),
                          child: TabBar(
                            isScrollable: true,
                            padding: EdgeInsets.zero,
                            unselectedLabelColor: AppColors.baseWhite,
                            unselectedLabelStyle: const TextStyle(
                              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                              fontSize: AppFonts.fontSize14,
                              fontWeight: AppFonts.fontWeightSemiBold,
                            ),
                            labelColor: AppColors.darkBlue,
                            labelStyle: const TextStyle(
                              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                              fontSize: AppFonts.fontSize14,
                              fontWeight: AppFonts.fontWeightSemiBold,
                            ),
                            indicator: const BoxDecoration(
                              color: AppColors.baseWhite,
                              borderRadius: BorderRadius.all(
                                Radius.circular(5.0),
                              ),
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicatorPadding: const EdgeInsets.all(3.0),
                            indicatorColor: Colors.transparent,
                            controller: _tabController,
                            tabs: const [
                              Tab(text: 'Packing'),
                              Tab(text: 'Stains'),
                              Tab(text: 'Ironing'),
                              Tab(text: 'Storage'),
                              Tab(text: 'Fabric Care'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  buildPackingTab(),
                  buildStainsTab(),
                  buildIroningTab(),
                  buildStorageTab(),
                  buildFabricCareTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPackingTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset('assets/icons/packing.svg'),
                const SizedBox(width: 8),
                const Text(
                  'Packing',
                  style: TextStyle(
                    fontSize: AppFonts.fontSize24,
                    fontWeight: AppFonts.fontWeightBold,
                    color: AppColors.darkBlue,
                    fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            buildTipItem('Sort by Color and Fabric',
                'Group clothes by color (lights, darks, and whites) and fabric type to prevent color transfer and damage.'),
            buildTipItem('Check Pockets',
                'Remove items like keys, pens, and tissues to avoid damage and staining.'),
            buildTipItem('Secure Buttons & Zips',
                'Fasten buttons and close zippers to prevent snagging and keep garments in good shape during handling.'),
            buildTipItem('Label Special Care Items',
                'Label any items that need extra care or attention, such as hand-wash only or delicate items.'),
          ],
        ),
      ),
    );
  }

  Widget buildStainsTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset('assets/icons/spray.svg'),
                const SizedBox(width: 8),
                const Text(
                  'Stains',
                  style: TextStyle(
                    fontSize: AppFonts.fontSize24,
                    fontWeight: AppFonts.fontWeightBold,
                    color: AppColors.darkBlue,
                    fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            buildTipItem('Act Quickly',
                'Treat stains as soon as possible to prevent them from setting.'),
            buildTipItem('Blot, Don\'t Rub',
                'Blot stains with a clean cloth to absorb as much as possible before washing.'),
            buildTipItem('Use the Right Stain Remover',
                'Different stains require different treatments. Use the appropriate stain remover for the best results.'),
          ],
        ),
      ),
    );
  }

  Widget buildIroningTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset('assets/icons/iron.svg'),
                const SizedBox(width: 8),
                const Text(
                  'Ironing',
                  style: TextStyle(
                    fontSize: AppFonts.fontSize24,
                    fontWeight: AppFonts.fontWeightBold,
                    color: AppColors.darkBlue,
                    fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            buildTipItem('Check Fabric Labels',
                'Always check the fabric care labels for ironing instructions.'),
            buildTipItem('Use the Right Temperature',
                'Set the iron to the appropriate temperature for the fabric type.'),
            buildTipItem('Iron Inside Out',
                'Iron clothes inside out to prevent shine and protect the fabric.'),
          ],
        ),
      ),
    );
  }

  Widget buildStorageTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset('assets/icons/cloth_hanger.svg'),
                const SizedBox(width: 8),
                const Text(
                  'Storage',
                  style: TextStyle(
                    fontSize: AppFonts.fontSize24,
                    fontWeight: AppFonts.fontWeightBold,
                    color: AppColors.darkBlue,
                    fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            buildTipItem('Fold or Hang',
                'Fold knitwear and hang woven garments to maintain their shape.'),
            buildTipItem('Use Cedar or Lavender',
                'Use cedar blocks or lavender sachets to keep clothes fresh and repel moths.'),
            buildTipItem('Store in a Cool, Dry Place',
                'Store clothes in a cool, dry place to prevent mold and mildew.'),
          ],
        ),
      ),
    );
  }

  Widget buildFabricCareTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset('assets/icons/shirt.svg'),
                const SizedBox(width: 8),
                const Text(
                  'Fabric Care',
                  style: TextStyle(
                    fontSize: AppFonts.fontSize24,
                    fontWeight: AppFonts.fontWeightBold,
                    color: AppColors.darkBlue,
                    fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            buildTipItem('Read Care Labels',
                'Always read and follow the care labels on your clothes.'),
            buildTipItem('Use Gentle Detergents',
                'Use gentle detergents for delicate fabrics to prevent damage.'),
            buildTipItem('Avoid Overloading',
                'Avoid overloading the washing machine to ensure clothes are cleaned properly.'),
          ],
        ),
      ),
    );
  }

  Widget buildTipItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: AppFonts.fontSize18,
              fontWeight: AppFonts.fontWeightSemiBold,
              color: AppColors.black,
              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: AppFonts.fontSize16,
              fontWeight: AppFonts.fontWeightRegular,
              color: AppColors.black.withValues(alpha: 0.5),
              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
            ),
          ),
        ],
      ),
    );
  }
}
