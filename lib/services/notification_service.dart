import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:uuid/uuid.dart';
import '../main.dart';
import '../model/notification_item.dart';

class NotificationService {
  static final List<NotificationModel> notificationHistory = [];
  // static const Uuid uuid = Uuid();

  static const DarwinNotificationDetails iosNotificationDetails =
      DarwinNotificationDetails();

  static const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
    'rinze_01',
    'rinze_laundry',
    importance: Importance.max,
    priority: Priority.high,
  );

  static const NotificationDetails notificationChannelSpecifics =
      NotificationDetails(
    android: androidNotificationDetails,
    iOS: iosNotificationDetails,
  );

  void requestIOSPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          sound: true,
          alert: true,
          badge: true,
        );
  }

  Future<void> requestNotificationPermission() async {
    PermissionStatus status = await Permission.notification.status;

    if (status.isDenied) {
      status = await Permission.notification.request();
    }

    if (status.isGranted) {
      if (kDebugMode) {
        print("Notification permission granted!");
      }
    } else {
      if (kDebugMode) {
        print("Notification permission denied.");
      }
    }
  }

  static Future<void> showNotification(
      String type, String title, String body) async {
    notificationHistory.add(
      NotificationModel(
        // id: uuid.v4(),
        type: type,
        title: title,
        body: body,
        timeStamp: DateTime.now(),
      ),
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationChannelSpecifics,
    );
  }
}
