import 'package:flutter/material.dart';

import 'authentication/login_page.dart';
import 'authentication/splash_screen.dart';
import 'dashboard/dashboard_page.dart';
import 'utility/app_colors.dart';
import 'utility/storage_service.dart'; // <-- aggiungi questo import con il path giusto

void main() {
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

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await StorageService.getToken();

    if (!mounted) return;

    setState(() {
      _authenticated = token != null && token.isNotEmpty;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SplashScreen();
    }

    // se c'è il token vado in dashboard, altrimenti login
    return _authenticated ? const DashboardPage() : LoginPage();
  }
}

