/*import 'package:flutter/material.dart';
import 'authentication/auth_service.dart';
import 'authentication/login_page.dart';
import 'dashboard/dashboard_page.dart';

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
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final auth = await AuthService().isAuthenticated();
      if (!mounted) return;
      setState(() {
        _authenticated = auth;
        _loading = false;
      });
    } catch (e) {
      // In caso di errore (es. backend non raggiungibile)
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SplashScreen();
    }

    if (_error) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              const Text(
                'Unable to connect to server',
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _checkAuth,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    //return _authenticated ? const DashboardPage() : const LoginPage();
    return const LoginPage();
  }
}

/// Simple splash screen (adattabile a qualsiasi dispositivo)
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_florist,
              color: Colors.green,
              size: screenWidth * 0.25, // Adattabile
            ),
            SizedBox(height: screenWidth * 0.05),
            Text(
              'EcoGrow',
              style: TextStyle(
                color: Colors.green[700],
                fontSize: screenWidth * 0.08,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenWidth * 0.1),
            const CircularProgressIndicator(color: Colors.green),
          ],
        ),
      ),
    );
  }
}*/

import 'package:Ecogrow/dashboard/pages/profile.dart';
import 'package:flutter/material.dart';
import 'authentication/login_page.dart';
import 'dashboard/dashboard_page.dart';

void main() {
  runApp(const EcoGrowApp());
}

class EcoGrowApp extends StatelessWidget {
  const EcoGrowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EcoGrow',
      home: LoginPage(), // Mostra direttamente la pagina di login
    );
  }
}


