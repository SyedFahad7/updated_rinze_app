import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:rinze/screens/profile/edit_profile_screen.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_fonts.dart';
import '../../providers/customer_provider.dart';
import 'package:intl/intl.dart';

class UserAccountDetailsScreen extends StatefulWidget {
  const UserAccountDetailsScreen({super.key});

  @override
  State<UserAccountDetailsScreen> createState() =>
      _UserAccountDetailsScreenState();
}

class _UserAccountDetailsScreenState extends State<UserAccountDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
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
                const SizedBox(height: 0),
                const Text(
                  'My Account',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Consumer<CustomerGlobalState>(
            builder: (context, customerProvider, child) {
              final userData = customerProvider.userData;
              final profileImageUrl =
                  userData['profileImg'] ?? 'https://placehold.co/100x100';
              final fullName = userData['fullName'] ?? 'N/A';
              final email = userData['email'] ?? 'N/A';
              final phoneNumber = userData['mobileNumber'] ?? 'N/A';
              final customerId =
                  userData['profile']['profileRef']['customerId'] ?? 'N/A';
              final ordersCount =
                  userData['profile']['profileRef']['orders']?.length ?? 0;
              final createdAt = userData['createdAt'] != null
                  ? DateFormat.yMMMd()
                      .format(DateTime.parse(userData['createdAt']))
                  : 'N/A';
              final updatedAt = userData['updatedAt'] != null
                  ? DateFormat.yMMMd()
                      .format(DateTime.parse(userData['updatedAt']))
                  : 'N/A';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(profileImageUrl),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Full Name',
                    style: TextStyle(
                      fontSize: AppFonts.fontSize16,
                      fontWeight: AppFonts.fontWeightSemiBold,
                      color: AppColors.darkBlue,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fullName,
                    style: const TextStyle(
                      fontSize: AppFonts.fontSize14,
                      fontWeight: AppFonts.fontWeightRegular,
                      color: AppColors.black,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Email',
                    style: TextStyle(
                      fontSize: AppFonts.fontSize16,
                      fontWeight: AppFonts.fontWeightSemiBold,
                      color: AppColors.darkBlue,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: AppFonts.fontSize14,
                      fontWeight: AppFonts.fontWeightRegular,
                      color: AppColors.black,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Phone Number',
                    style: TextStyle(
                      fontSize: AppFonts.fontSize16,
                      fontWeight: AppFonts.fontWeightSemiBold,
                      color: AppColors.darkBlue,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phoneNumber,
                    style: const TextStyle(
                      fontSize: AppFonts.fontSize14,
                      fontWeight: AppFonts.fontWeightRegular,
                      color: AppColors.black,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Customer ID',
                    style: TextStyle(
                      fontSize: AppFonts.fontSize16,
                      fontWeight: AppFonts.fontWeightSemiBold,
                      color: AppColors.darkBlue,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    customerId,
                    style: const TextStyle(
                      fontSize: AppFonts.fontSize14,
                      fontWeight: AppFonts.fontWeightRegular,
                      color: AppColors.black,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Orders Placed',
                    style: TextStyle(
                      fontSize: AppFonts.fontSize16,
                      fontWeight: AppFonts.fontWeightSemiBold,
                      color: AppColors.darkBlue,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$ordersCount',
                    style: const TextStyle(
                      fontSize: AppFonts.fontSize14,
                      fontWeight: AppFonts.fontWeightRegular,
                      color: AppColors.black,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Account Created',
                    style: TextStyle(
                      fontSize: AppFonts.fontSize16,
                      fontWeight: AppFonts.fontWeightSemiBold,
                      color: AppColors.darkBlue,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    createdAt,
                    style: const TextStyle(
                      fontSize: AppFonts.fontSize14,
                      fontWeight: AppFonts.fontWeightRegular,
                      color: AppColors.black,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Last Updated',
                    style: TextStyle(
                      fontSize: AppFonts.fontSize16,
                      fontWeight: AppFonts.fontWeightSemiBold,
                      color: AppColors.darkBlue,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    updatedAt,
                    style: const TextStyle(
                      fontSize: AppFonts.fontSize14,
                      fontWeight: AppFonts.fontWeightRegular,
                      color: AppColors.black,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                    ),
                  ),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8), // Optional padding
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.darkBlue, // Border color
                          width: 2.0, // Border width
                        ),
                        borderRadius:
                            BorderRadius.circular(8), // Rounded corners
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfileScreen(),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontSize: AppFonts.fontSize16,
                                fontWeight: AppFonts.fontWeightSemiBold,
                                color: AppColors.darkBlue,
                                fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                              ),
                            ),
                            const SizedBox(
                                width: 8), // Add spacing between text and icon
                            SvgPicture.asset(
                              'assets/icons/pencil.svg', // Use your SVG icon here
                              height: 16, // Adjust icon size as needed
                              width: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
