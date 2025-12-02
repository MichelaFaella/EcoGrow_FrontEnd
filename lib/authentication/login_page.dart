import 'package:Ecogrow/authentication/test.dart';
import 'package:Ecogrow/authentication/widgets/login_sheet.dart';
import 'package:Ecogrow/authentication/widgets/register_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utility/app_colors.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  void _showLoginSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => const LoginSheet(),
    );
  }

  void _showRegistrationSheet(BuildContext context) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => const RegisterSheet(),
    );

    // Se non è andata a buon fine, non facciamo nulla
    if (result != true) return;

    // ✅ Dopo OGNI registrazione → TestPage
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const TestPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Image.asset(
                        "images/EcoGrow.png",
                        height: 90,
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Hi there!\nAre you ready to create your digital garden?\nHere you can take care of your plant in an easy, smart and eco-friendly way.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Image.asset(
                    "images/mainLogin.png",
                    height: MediaQuery.of(context).size.height * 0.4,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 40),
                  Column(
                    children: [
                      SizedBox(
                        width: 280,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () => _showRegistrationSheet(context),
                          child: const Text(
                            "CREATE ACCOUNT",
                            style: TextStyle(
                              fontFamily: "Poppins",
                              color: AppColors.dark_green,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: 280,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.white,
                              width: 1.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () => _showLoginSheet(context),
                          child: const Text(
                            "LOG IN",
                            style: TextStyle(
                              fontFamily: "Poppins",
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
