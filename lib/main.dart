import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:rinze/providers/addresses_provider.dart';
import 'package:rinze/providers/coupons_provider.dart';
import 'package:rinze/providers/service_provider.dart';
import 'package:rinze/providers/customer_provider.dart';
import 'package:rinze/routes.dart';
import 'package:rinze/screens/splash_screen.dart';
import 'package:flutter_downloader/flutter_downloader.dart'; // Add this import

const FlutterSecureStorage secureStorage = FlutterSecureStorage();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Flutter Downloader
  await FlutterDownloader.initialize(
    debug: true, // Set to false in production
  );

  // Load environment variables
  await dotenv.load();

  // Lock app orientation to portrait mode
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Read the stored token
  String? token = await secureStorage.read(key: 'Rin8k1H2mZ');

  // Initialize Notification Plugin
  const AndroidInitializationSettings initializationSettingAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings();

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingAndroid,
    iOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {},
  );

  // Request Notification Permissions
  await _requestNotificationPermissions();

  // Request Storage Permissions
  await _requestStoragePermissions();

  runApp(RinzeLaundryApp(
    token: token,
  ));
}

// Request Notification Permissions
Future<void> _requestNotificationPermissions() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
}

// Request Storage Permissions
Future<void> _requestStoragePermissions() async {
  final status = await Permission.storage.status;
  print('Storage permission status: $status');

  if (status.isDenied) {
    final result = await Permission.storage.request();
    print('Storage permission request result: $result');

    if (result.isPermanentlyDenied) {
      // Open app settings
      await openAppSettings();
    }
  }

  // For Android 11 and above
  final manageStatus = await Permission.manageExternalStorage.status;
  print('Manage External Storage permission status: $manageStatus');

  if (manageStatus.isDenied) {
    final manageResult = await Permission.manageExternalStorage.request();
    print('Manage External Storage permission request result: $manageResult');

    if (manageResult.isPermanentlyDenied) {
      // Open app settings
      await openAppSettings();
    }
  }
}

class RinzeLaundryApp extends StatelessWidget {
  const RinzeLaundryApp({super.key, required this.token});

  final String? token;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SGlobalState()),
        ChangeNotifierProvider(create: (context) => AddressesGlobalState()),
        ChangeNotifierProvider(create: (context) => CouponsGlobalState()),
        ChangeNotifierProvider(create: (context) => CustomerGlobalState()),
      ],
      child: MaterialApp(
        title: 'Rinze Customer App',
        home: SplashScreen(token: token),
        debugShowCheckedModeBanner: false,
        routes: AppRoutes.routes,
      ),
    );
  }
}
