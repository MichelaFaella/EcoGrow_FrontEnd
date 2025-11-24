import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'authentication/login_page.dart';
import 'authentication/splash_screen.dart';
import 'authentication/test.dart';
import 'dashboard/dashboard_page.dart';
import 'dashboard/pages/service/notification_service.dart';
import 'utility/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Timezone per notifiche
  tz.initializeTimeZones();

  // 2) Inizializza il sistema notifiche
  await NotificationService.init();

  // 3) Nascondi system bars
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

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await StorageService.getToken();

    if (!mounted) return;

    if (token == null || token.isEmpty) {
      setState(() {
        _authenticated = false;
        _questionnaireDone = false;
        _loading = false;
      });
      return;
    }

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
    if (!_authenticated) {
      return const LoginPage();
    }
    if (!_questionnaireDone) {
      return const TestPage();
    }
    return const DashboardPage();
  }
}
