import 'package:flutter/material.dart';

import '../utility/app_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_florist,
              color: AppColors.green,
              size: screenWidth * 0.25,
            ),
            SizedBox(height: screenWidth * 0.05),
            Text(
              'EcoGrow',
              style: TextStyle(
                color: AppColors.green,
                fontSize: screenWidth * 0.08,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenWidth * 0.1),
            const CircularProgressIndicator(color: AppColors.green),
          ],
        ),
      ),
    );
  }
}
