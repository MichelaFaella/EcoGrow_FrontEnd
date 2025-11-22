import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'authentication/login_page.dart';
import 'authentication/splash_screen.dart';
import 'authentication/test.dart';
import 'dashboard/dashboard_page.dart';
import 'utility/storage_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Nasconde completamente barra di navigazione + barra superiore
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
    final userId = await StorageService.getUserId();

    if (!mounted) return;

    // NON autenticato → login
    if (token == null || token.isEmpty || userId == null) {
      setState(() {
        _authenticated = false;
        _questionnaireDone = false;
        _loading = false;
      });
      return;
    }

    // Controllo flag per-utente
    final done = await StorageService.isQuestionnaireDoneForUser(userId);

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

    // Loggato ma test NON fatto
    if (!_questionnaireDone) {
      return const TestPage();
    }

    // Loggato + test completato
    return const DashboardPage();
  }
}
