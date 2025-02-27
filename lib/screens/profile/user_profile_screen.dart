import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:rinze/main.dart';
import 'package:rinze/providers/addresses_provider.dart';
import 'package:rinze/providers/service_provider.dart';
import 'package:rinze/providers/customer_provider.dart';
import 'package:rinze/screens/auth/login_screen.dart';
import 'package:rinze/screens/home_navigation_screen.dart';
import 'package:rinze/screens/profile/notification_history_screen.dart';
import 'package:rinze/screens/profile/about_screen.dart' as about;
import 'package:rinze/screens/profile/delivery_addresses_screen.dart';
import 'package:rinze/screens/profile/edit_profile_screen.dart';
import 'package:rinze/screens/profile/help_support_screen.dart' as help;
import 'package:rinze/screens/profile/account_privacy_screen.dart';
import 'package:rinze/screens/profile/user_account_details_screen.dart';
import 'package:rinze/services/notification_service.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_fonts.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 6),
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
                    color: AppColors.black,
                    fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                    fontSize: AppFonts.fontSize14,
                    fontWeight: AppFonts.fontWeightRegular,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Container(
                color: AppColors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Consumer<CustomerGlobalState>(
                    builder: (context, customerProvider, child) {
                      final userData = customerProvider.userData;
                      final profileImageUrl = userData['profileImg'] ??
                          'https://placehold.co/100x100';
                      final fullName = userData['fullName'] ?? 'N/A';
                      final email = userData['email'] ?? 'N/A';
                      final phoneNumber = userData['mobileNumber'] ?? 'N/A';
                      final customerId = userData['profile'] != null &&
                              userData['profile']['profileRef'] != null &&
                              userData['profile']['profileRef']['customerId'] !=
                                  null
                          ? userData['profile']['profileRef']['customerId']
                          : 'N/A';

                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 49,
                                backgroundImage: NetworkImage(profileImageUrl),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fullName.length > 15
                                        ? '${fullName.substring(0, 15)}...'
                                        : fullName,
                                    style: const TextStyle(
                                      fontSize: AppFonts.fontSize18,
                                      fontWeight: AppFonts.fontWeightSemiBold,
                                      color: AppColors.darkBlue,
                                      fontFamily:
                                          AppFonts.fontFamilyPlusJakartaSans,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    customerId,
                                    style: TextStyle(
                                      fontSize: AppFonts.fontSize10,
                                      fontWeight: AppFonts.fontWeightSemiBold,
                                      color: AppColors.black
                                          .withValues(alpha: 0.5),
                                      fontFamily:
                                          AppFonts.fontFamilyPlusJakartaSans,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    email.length > 20
                                        ? '${email.substring(0, 20)}...'
                                        : email,
                                    style: const TextStyle(
                                      fontSize: AppFonts.fontSize14,
                                      fontWeight: AppFonts.fontWeightMedium,
                                      color: AppColors.darkBlue,
                                      fontFamily:
                                          AppFonts.fontFamilyPlusJakartaSans,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    phoneNumber,
                                    style: const TextStyle(
                                      fontSize: AppFonts.fontSize14,
                                      fontWeight: AppFonts.fontWeightMedium,
                                      color: AppColors.darkBlue,
                                      fontFamily:
                                          AppFonts.fontFamilyPlusJakartaSans,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Column(
                            children: [
                              _buildMenuItem(
                                  'My Account', 'assets/icons/account.svg',
                                  onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const UserAccountDetailsScreen()),
                                );
                              }),
                              _buildMenuItem('Saved Addresses',
                                  'assets/icons/building.svg', onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const DeliveryAddressesScreen(),
                                  ),
                                );
                              }),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const NotificationHistoryScreen(),
                                    ),
                                  );
                                },
                                child: _buildMenuItem('All Notifications',
                                    'assets/icons/bell_dark.svg'),
                              ),
                              _buildMenuItem(
                                  'Help & Support', 'assets/icons/question.svg',
                                  onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const help.HelpSupportScreen()),
                                );
                              }),
                              _buildMenuItem(
                                'Order History',
                                'assets/icons/clipboard.svg',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const HomeBottomNavigation(
                                        tabIndex: 1,
                                        selectedIndex: 2,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              _buildMenuItem(
                                  'Account Privacy', 'assets/icons/lock.svg',
                                  onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const AccountPrivacyScreen()),
                                );
                              }),
                              _buildMenuItem(
                                  'About Us', 'assets/icons/Info.svg',
                                  onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const about.AboutScreen()),
                                );
                              }),
                              _buildMenuItem(
                                  'Share the app', 'assets/icons/share.svg',
                                  onTap: () {}),
                              _buildMenuItem(
                                  'Logout', 'assets/icons/signout.svg',
                                  onTap: () {
                                _showLogoutDialog(context);
                              }),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/images/splash_logo.svg',
                        width: 35,
                        height: 35,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Transform.translate(
                    offset: const Offset(0, -4),
                    child: const Text(
                      'v1.0',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: AppFonts.fontSize14,
                        fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, String iconPath, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 42,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: AppColors.lightWhite,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.black.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  iconPath,
                  colorFilter: ColorFilter.mode(
                    AppColors.black.withValues(alpha: 0.6),
                    BlendMode.srcIn,
                  ),
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: AppFonts.fontSize14,
                    fontWeight: AppFonts.fontWeightMedium,
                    color: AppColors.hintBlack,
                    fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  ),
                ),
              ],
            ),
            SvgPicture.asset(
              'assets/icons/arrow_right.svg',
              colorFilter: ColorFilter.mode(
                AppColors.black.withValues(alpha: 0.6),
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.baseGrey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            width: 321,
            height: 173,
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Confirm Log out',
                  style: TextStyle(
                    color: AppColors.hintBlack,
                    fontSize: AppFonts.fontSize20,
                    fontWeight: AppFonts.fontWeightSemiBold,
                    fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Are you sure you want to log out?',
                  style: TextStyle(
                    color: AppColors.hintBlack,
                    fontSize: AppFonts.fontSize12,
                    fontWeight: AppFonts.fontWeightRegular,
                    fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Padding(padding: EdgeInsets.only(bottom: 42)),
                    GestureDetector(
                      onTap: () async {
                        await secureStorage.delete(key: 'Rin8k1H2mZ');
                        clearGlobalStates();
                        NotificationService.showNotification(
                          'Alert',
                          'Logged out',
                          'You have been logged out',
                        );

                        Navigator.pushAndRemoveUntil(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                const LoginScreen(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                          (Route<dynamic> route) => false,
                        );
                      },
                      child: const Text(
                        'Log out',
                        style: TextStyle(
                          color: AppColors.fadeRed,
                          fontSize: AppFonts.fontSize14,
                          fontWeight: AppFonts.fontWeightBold,
                          fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                        ),
                      ),
                    ),
                    const SizedBox(width: 26),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppColors.darkBlue,
                          fontSize: AppFonts.fontSize14,
                          fontWeight: AppFonts.fontWeightBold,
                          fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void clearGlobalStates() {
    Provider.of<SGlobalState>(context, listen: false).selectedServices.clear();
    Provider.of<SGlobalState>(context, listen: false).selectedProducts.clear();
    Provider.of<SGlobalState>(context, listen: false).basketProducts.clear();
    Provider.of<AddressesGlobalState>(context, listen: false).addresses.clear();
    Provider.of<CustomerGlobalState>(context, listen: false).userData.clear();
    Provider.of<AddressesGlobalState>(context, listen: false)
        .defaultAddress
        .clear();
  }
}
