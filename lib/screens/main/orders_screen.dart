import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/tabs/orders_tabs/active/active_tab.dart';
import '../../components/tabs/orders_tabs/history/history_tab.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_fonts.dart';
import '../../providers/service_provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({
    super.key,
    required this.tabIndex,
  });

  static const id = '/orders';

  final int tabIndex;

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
    );
    changeTab(widget.tabIndex);
  }

  void changeTab(int index) {
    if (mounted) {
      setState(() {
        _tabController.animateTo(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalServicesSelected =
        Provider.of<SGlobalState>(context).basketProducts.length;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Blue Container
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 24.0,
              ),
              width: double.infinity,
              height: 200.0,
              decoration: const BoxDecoration(
                gradient: AppColors.customBlueGradient,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Orders',
                    style: TextStyle(
                      color: AppColors.hintWhite,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize26,
                      fontWeight: AppFonts.fontWeightSemiBold,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  const Text(
                    'Status and history of orders',
                    style: TextStyle(
                      color: AppColors.hintWhite,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize14,
                      fontWeight: AppFonts.fontWeightRegular,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.05),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    child: TabBar(
                      padding: const EdgeInsets.all(4.0),
                      dividerColor: AppColors.transparent,
                      unselectedLabelColor: AppColors.white,
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
                      indicatorColor: Colors.transparent,
                      controller: _tabController,
                      tabs: const [
                        Tab(
                          text: 'Active',
                        ),
                        Tab(
                          text: 'History',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            //White Container
            Expanded(
              child: Container(
                width: double.infinity,
                color: AppColors.white,
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    ActiveTabScreen(),
                    HistoryTabScreen(),
                  ],
                ),
              ),
            ),
            if (totalServicesSelected != 0) const SizedBox(height: 64.0),
          ],
        ),
      ),
    );
  }
}
