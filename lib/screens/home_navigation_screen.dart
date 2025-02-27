import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:rinze/components/review_feedback.dart';

import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';
import '../providers/service_provider.dart';
import 'main/basket_screen.dart';
import 'main/home_screen.dart';
import 'main/orders_screen.dart';
import 'main/services_screen.dart';

class HomeBottomNavigation extends StatefulWidget {
  const HomeBottomNavigation({
    super.key,
    this.selectedIndex = 0,
    this.tabIndex,
    this.showReviewDialog = false, // Add this parameter
  });

  final int? selectedIndex;
  final int? tabIndex;
  final bool showReviewDialog; // Add this parameter

  static const id = '/home_navigation';

  @override
  State<HomeBottomNavigation> createState() => _HomeBottomNavigationState();
}

class _HomeBottomNavigationState extends State<HomeBottomNavigation>
    with SingleTickerProviderStateMixin {
  late int _selectedIndex;
  late AnimationController _controller;
  late Animation<double> _animation;
  int? orderTabIndex = 0;

  @override
  void initState() {
    super.initState();
    orderTabIndex = widget.tabIndex;
    _selectedIndex = widget.selectedIndex ?? 0;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: _selectedIndex.toDouble(),
      end: _selectedIndex.toDouble(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Show the review feedback dialog if showReviewDialog is true
    if (widget.showReviewDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (context) => const ReviewFeedback(),
        );
      });
    }
  }

  List<Widget> getSelectedScreens() {
    return [
      const HomeScreen(),
      const ServicesScreen(),
      OrdersScreen(tabIndex: orderTabIndex ?? 0),
      const BasketScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _animation = Tween<double>(
        begin: _selectedIndex.toDouble(),
        end: index.toDouble(),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
      _controller.forward(from: 0);
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalServiceCost =
        Provider.of<SGlobalState>(context, listen: true).calculateBillDetails();

    int totalServicesSelected =
        Provider.of<SGlobalState>(context, listen: true).basketProducts.length;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            getSelectedScreens()[_selectedIndex],
            if (totalServicesSelected != 0)
              if (_selectedIndex != 3)
                Positioned(
                  bottom: 0.0, // Position it just above the BottomNavigationBar
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      border: Border.symmetric(
                        horizontal: BorderSide(
                          color: AppColors.black.withOpacity(0.06),
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              totalServicesSelected < 10
                                  ? '0$totalServicesSelected Services'
                                  : '$totalServicesSelected Services',
                              style: const TextStyle(
                                color: AppColors.black,
                                fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                                fontSize: AppFonts.fontSize12,
                                fontWeight: AppFonts.fontWeightSemiBold,
                              ),
                            ),
                            const SizedBox(
                              width: 8.0,
                            ),
                            const Text('|'),
                            const SizedBox(
                              width: 8.0,
                            ),
                            Text(
                              '₹ $totalServiceCost',
                              style: const TextStyle(
                                color: AppColors.black,
                                fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                                fontSize: AppFonts.fontSize12,
                                fontWeight: AppFonts.fontWeightSemiBold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const HomeBottomNavigation(
                                          selectedIndex: 3),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                              backgroundColor: AppColors.darkerBlue,
                              elevation: 0.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Go to Basket',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontFamily:
                                        AppFonts.fontFamilyPlusJakartaSans,
                                    fontSize: AppFonts.fontSize12,
                                    fontWeight: AppFonts.fontWeightSemiBold,
                                  ),
                                ),
                                SvgPicture.asset(
                                  'assets/icons/arrow_right.svg',
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
        bottomNavigationBar: Stack(
          children: [
            SizedBox(
              height: 83.0,
              child: BottomNavigationBar(
                backgroundColor: AppColors.white,
                type: BottomNavigationBarType.fixed,
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      _selectedIndex == 0
                          ? 'assets/icons/home_filled.svg'
                          : 'assets/icons/house.svg',
                      colorFilter: ColorFilter.mode(
                        _selectedIndex == 0
                            ? AppColors.darkBlue
                            : AppColors.opaqueGrey,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      _selectedIndex == 1
                          ? 'assets/icons/services_filled.svg'
                          : 'assets/icons/services.svg',
                      colorFilter: ColorFilter.mode(
                        _selectedIndex == 1
                            ? AppColors.darkBlue
                            : AppColors.opaqueGrey,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: 'Services',
                  ),
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      _selectedIndex == 2
                          ? 'assets/icons/orders_filled.svg'
                          : 'assets/icons/orders.svg',
                      colorFilter: ColorFilter.mode(
                        _selectedIndex == 2
                            ? AppColors.darkBlue
                            : AppColors.opaqueGrey,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: 'Orders',
                  ),
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      _selectedIndex == 3
                          ? 'assets/icons/basket_filled.svg'
                          : 'assets/icons/basket.svg',
                      colorFilter: ColorFilter.mode(
                        _selectedIndex == 3
                            ? AppColors.darkBlue
                            : AppColors.opaqueGrey,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: 'Basket',
                  ),
                ],
                currentIndex: _selectedIndex,
                selectedItemColor: AppColors.darkBlue,
                onTap: _onItemTapped,
                iconSize: 18.0,
                selectedFontSize: AppFonts.fontSize10,
                selectedLabelStyle: const TextStyle(
                  fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  fontWeight: AppFonts.fontWeightSemiBold,
                ),
                unselectedFontSize: AppFonts.fontSize10,
                unselectedLabelStyle: const TextStyle(
                  fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  fontWeight: AppFonts.fontWeightSemiBold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
