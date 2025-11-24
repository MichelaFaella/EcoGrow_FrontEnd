import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // === SETUP ANDROID ===
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    // === SETUP iOS ===
    final ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final settings = InitializationSettings(
      android: android,
      iOS: ios,
    );

    await _plugin.initialize(settings);

    // === RICHIESTA PERMESSI iOS + ANDROID 12- ===
    await _requestPermissions();
  }

  static Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      print("iOS notification permissions: $result");
    }

    // Android 13+ richiede permesso anche lui
    if (Platform.isAndroid) {
      final androidInfo = await _plugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      print("Android notification permission: $androidInfo");
    }
  }
}
