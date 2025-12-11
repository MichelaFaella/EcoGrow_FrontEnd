import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    print('[NotificationService] init() called');

    const AndroidInitializationSettings androidInitSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
    InitializationSettings(android: androidInitSettings);

    await _plugin.initialize(initSettings);
    _initialized = true;

    print('[NotificationService] initialized = true');
  }

  Future<void> showReminderNotification({
    required String title,
    required String body,
  }) async {
    print('[NotificationService] showReminderNotification()');
    print('[NotificationService] title=$title');
    print('[NotificationService] body=$body');
    print('[NotificationService] initialized? $_initialized');

    if (!_initialized) {
      print('[NotificationService] WARNING: not initialized, aborting');
      return;
    }

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'reminders_channel',
      'Plant reminders',
      channelDescription: 'Notifications for plant watering reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidDetails);

    try {
      await _plugin.show(
        0,
        title,
        body,
        notificationDetails,
      );
      print('[NotificationService] show() completed');
    } catch (e) {
      print('[NotificationService] ERROR in show(): $e');
    }
  }

  /// Metodo di test manuale, da richiamare con un bottone
  Future<void> showTestNotification() async {
    await showReminderNotification(
      title: 'EcoGrow test',
      body: 'If you see this, notifications work.',
    );
  }
}
