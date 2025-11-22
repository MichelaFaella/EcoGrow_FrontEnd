import 'package:flutter/material.dart';

import '../utility/app_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/EcoGrow.png',
              width: 300,
            ),
            SizedBox(height: screenWidth * 0.05),
            const CircularProgressIndicator(color: AppColors.dark_green),
          ],
        ),
      ),
    );
  }
}
