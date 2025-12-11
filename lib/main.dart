import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'authentication/login_page.dart';
import 'authentication/splash_screen.dart';
import 'authentication/test.dart';
import 'dashboard/dashboard_page.dart';
import 'dashboard/pages/service/reminder_service.dart';
import 'utility/storage_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializza il database dei fusi orari per device_calendar
  tz.initializeTimeZones();
  // opzionale: puoi impostare una location specifica, ma tz.local di solito va bene
  // tz.setLocalLocation(tz.getLocation('Europe/Rome'));


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

  @override
  void initState() {
    super.initState();
    _checkAuth();
    _startReminderTimer();
  }

  void _startReminderTimer() {
    _reminderTimer = Timer.periodic(const Duration(seconds: 20), (_) async {
      // Se non è autenticato o non ha finito il questionario, non chiamiamo nulla
      if (!_authenticated || !_questionnaireDone) return;
      if (!mounted) return;

      final (ok, message, due, duePlants) =
      await _reminderService.fetchDuePlantsReminder();

      if (!ok) {
        print('[Reminder] Error: $message');
        return;
      }

      // Costruiamo una “firma” del promemoria per non ripetere sempre lo stesso messaggio
      final plants = duePlants ?? <String>[];
      final newKey = '$due|${plants.join(",")}';

      if (newKey == _lastReminderKey) {
        // Niente di nuovo da mostrare
        return;
      }
      _lastReminderKey = newKey;

      if (due && message != null) {
        print('[Reminder] MESSAGE: $message');
        print('[Reminder] DUE PLANTS: $plants');

        final plantsText = plants.join(', ');
        final text = plantsText.isEmpty ? message : '$message\n$plantsText';

        // Mostra uno Snackbar in stile Android
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(text),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });
  }

  @override
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
