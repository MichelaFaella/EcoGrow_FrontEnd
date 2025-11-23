import 'package:flutter/material.dart';

import '../../utility/app_colors.dart';

class WateringPage extends StatelessWidget {
  const WateringPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          SizedBox(height: 70,),
          Center(
            child: Text(
              "WATERING",
              style: TextStyle(
                fontSize: 32,
                fontFamily: "Poppins",
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 30,),
          SingleChildScrollView(
            child: Column(),
          )
        ],
      ),
    );
  }
}
