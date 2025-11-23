import 'package:flutter/material.dart';

import '../../utility/app_colors.dart';

class AddFriendsPage extends StatelessWidget {
  const AddFriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          children: [
            const SizedBox(height: 30,),
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: AppColors.white,
                    size: 28,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 30),
                const Text(
                  "Your id: d2b805fd",
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
            const SizedBox(height: 30,),
            Center(
              child: Container(
                width: 300,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    SizedBox(width: 12),
                    Icon(Icons.search,color: AppColors.dark_gray,),

                    Expanded(child: TextField(
                      cursorWidth: 0,
                      showCursor: false,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Add a new friend...',
                        hintStyle: TextStyle(
                          color: AppColors.dark_gray,
                          fontFamily: 'Poppins',
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                      ),
                    ),),
                  ],
                ),
              ),
            ),


          ],
        ),
      ),
    );
  }
}
