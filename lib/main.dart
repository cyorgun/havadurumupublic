import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:havadurumu/lang/translation_service.dart';
import 'package:havadurumu/routes/app_pages.dart';
import 'package:havadurumu/services/auth/auth_service.dart';
import 'package:havadurumu/shared/shared_prefs_helper.dart';

FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SharedPrefsHelper.init();

  _setupLocalNotifications();
  setupFirebaseNotifications();

  Get.put(AuthService());
  runApp(const MyApp());
}

void _setupLocalNotifications() {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings settings =
      InitializationSettings(android: androidSettings);
  _localNotifications.initialize(settings);
}

void setupFirebaseNotifications() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      showLocalNotification(message);
    }
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //Get.toNamed(Routes.NOTIFICATIONS);
  });
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.notification != null) {
    // do smth when you catch push notif when app is closed (or in background?)
  }
}

void showLocalNotification(RemoteMessage message) async {
  var androidDetails = const AndroidNotificationDetails(
    'channel_id',
    'channel_name',
    importance: Importance.high,
    priority: Priority.high,
    playSound: true,
  );

  var platformDetails = NotificationDetails(android: androidDetails);
  await _localNotifications.show(
    message.messageId.hashCode,
    message.notification?.title,
    message.notification?.body,
    platformDetails,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(builder: (theme, darkTheme) {
      return GetMaterialApp(
        key: const Key('GetMaterialApp'),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
          useMaterial3: true,
        ),
        title: 'appName'.tr,
        enableLog: true,
        translations: Messages(),
        locale: Get.deviceLocale,
        fallbackLocale: const Locale('en', 'US'),
        initialRoute: AppPages.initial,
        getPages: AppPages.routes,
      );
    });
  }
}
