import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'authentication/login_page.dart';
import 'authentication/service/notification_service.dart';
import 'authentication/splash_screen.dart';
import 'authentication/test.dart';
import 'dashboard/dashboard_page.dart';
import 'dashboard/pages/service/reminder_service.dart';
import 'utility/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializza il database dei fusi orari per device_calendar
  tz.initializeTimeZones();
  // opzionale: puoi impostare una location specifica, ma tz.local di solito va bene
  // tz.setLocalLocation(tz.getLocation('Europe/Rome'));

  await NotificationService().init();

  // Nasconde completamente barra superiore + barra di navigazione
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const EcoGrowApp());
}

class EcoGrowApp extends StatelessWidget {
  const EcoGrowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoGrow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins',
      ),
      home: const RootPage(),
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  bool _loading = true;
  bool _authenticated = false;
  bool _questionnaireDone = false;

  Timer? _reminderTimer;
  final ReminderService _reminderService = ReminderService();

  String? _lastReminderKey;
  DateTime? _lastReminderAt;

  static const Duration _reminderCooldown = Duration(seconds: 20);

  @override
  void initState() {
    super.initState();
    _checkAuth();
    _startReminderTimer();
  }


  void _startReminderTimer() {
    _reminderTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (!_authenticated || !_questionnaireDone) return;
      if (!mounted) return;

      final (ok, message, due, duePlants) =
      await _reminderService.fetchDuePlantsReminder();

      if (!ok) {
        print('[Reminder] Error: $message');
        return;
      }

      final plants = duePlants ?? <String>[];
      final newKey = '$due|${plants.join(",")}';
      final now = DateTime.now();

      // Se non ci sono piante "due", resettiamo stato e usciamo
      if (!due) {
        _lastReminderKey = null;
        _lastReminderAt = null;
        return;
      }

      // Se il promemoria è lo stesso di prima...
      final sameReminder = newKey == _lastReminderKey;

      // ...e siamo ancora nel periodo di cooldown, non notifichiamo
      final bool stillInCooldown = _lastReminderAt != null &&
          now.difference(_lastReminderAt!) < _reminderCooldown;

      if (sameReminder && stillInCooldown) {
        // stesso promemoria e troppo presto per ripeterlo
        return;
      }

      // Aggiorniamo stato dell'ultimo reminder
      _lastReminderKey = newKey;
      _lastReminderAt = now;

      if (message != null) {
        print('[Reminder] MESSAGE: $message');
        print('[Reminder] DUE PLANTS: $plants');

        final plantsText = plants.join(', ');
        final text = plantsText.isEmpty ? message : '$message\n$plantsText';

        await NotificationService().showReminderNotification(
          title: 'EcoGrow - Plant reminder',
          body: text,
        );
      }
    });
  }

  Future<void> _askNotificationPermissionIfNeeded() async {
    final status = await Permission.notification.status;

    // Se è già stato concesso o limitato, non facciamo nulla
    if (status.isGranted || status.isLimited) {
      print('[Notifications] Permission already granted: $status');
      return;
    }

    // Se è permanentemente negato, possiamo portare l’utente alle impostazioni
    if (status.isPermanentlyDenied) {
      print('[Notifications] Permission permanently denied, opening settings');
      await openAppSettings();
      return;
    }

    // Altrimenti chiediamo il permesso
    final newStatus = await Permission.notification.request();
    print('[Notifications] New notification permission status: $newStatus');
  }

  void _syncReminderTimer() {
    final shouldRun = _authenticated && _questionnaireDone;

    if (!shouldRun) {
      _reminderTimer?.cancel();
      _reminderTimer = null;
      _lastReminderKey = null;
      _lastReminderAt = null;
      return;
    }

    // se già attivo, non crearne un altro
    if (_reminderTimer != null) return;

    _startReminderTimer();
  }


  @override
  void dispose() {
    _reminderTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    final token = await StorageService.getToken();

    if (!mounted) return;

    // Nessun token → utente non loggato
    if (token == null || token.isEmpty) {
      setState(() {
        _authenticated = false;
        _questionnaireDone = false;
        _loading = false;
      });
      return;
    }

    // Token presente → utente autenticato
    final done = await StorageService.isQuestionnaireDone();

    setState(() {
      _authenticated = true;
      _questionnaireDone = done;
      _loading = false;
    });

    await _askNotificationPermissionIfNeeded();
    _syncReminderTimer();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SplashScreen();
    }

    // Non loggato
    if (!_authenticated) {
      return const LoginPage();
    }

    // Loggato ma non ha completato il questionario
    if (!_questionnaireDone) {
      return const TestPage();
    }

    // Loggato e questionario completato
    return const DashboardPage();
  }
}
