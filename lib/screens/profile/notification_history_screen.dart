import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rinze/constants/app_colors.dart';
import 'package:rinze/constants/app_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/notification_service.dart';

class NotificationHistoryScreen extends StatefulWidget {
  const NotificationHistoryScreen({super.key});

  @override
  _NotificationHistoryScreenState createState() =>
      _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState extends State<NotificationHistoryScreen> {
  Set<String> seenNotifications = {};

  @override
  void initState() {
    super.initState();
    _loadSeenNotifications();
  }

  Future<void> _loadSeenNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      seenNotifications =
          prefs.getStringList('seenNotifications')?.toSet() ?? {};
    });
  }

  // Future<void> _markNotificationsAsSeen() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final notificationIds =
  //       NotificationService.notificationHistory.map((n) => n.id).toList();
  //   await prefs.setStringList('seenNotifications', notificationIds);
  //   setState(() {
  //     seenNotifications = notificationIds.toSet();
  //   });
  // }

  @override
  void dispose() {
    // _markNotificationsAsSeen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reversedNotifications =
        NotificationService.notificationHistory.reversed.toList();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120.0),
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
                          color: AppColors.baseBlack,
                          fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                          fontSize: AppFonts.fontSize14,
                          fontWeight: AppFonts.fontWeightRegular,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Notification History',
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
        child: ListView.builder(
          itemCount: reversedNotifications.length,
          itemBuilder: (context, index) {
            final notification = reversedNotifications[index];
            // final isSeen = seenNotifications.contains(notification.id);

            return Container(
              decoration: BoxDecoration(
                color:
                    // isSeen ?
                    AppColors.black.withValues(alpha: 0.05),
                // : AppColors.white,
                border: Border(
                  bottom: BorderSide(
                      color: AppColors.baseBlack.withValues(alpha: 0.1)),
                ),
              ),
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.type,
                    style: TextStyle(
                      color: AppColors.black.withValues(alpha: 0.6),
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontWeight: AppFonts.fontWeightBold,
                      fontSize: AppFonts.fontSize10,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.title,
                    style: const TextStyle(
                      color: AppColors.hintBlack,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontWeight: AppFonts.fontWeightSemiBold,
                      fontSize: AppFonts.fontSize16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('d MMMM yyyy, h:mm a')
                        .format(notification.timeStamp),
                    style: const TextStyle(
                      color: AppColors.hintBlack,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontWeight: AppFonts.fontWeightMedium,
                      fontSize: AppFonts.fontSize12,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
