import 'package:flutter/material.dart';
import '../../utility/app_colors.dart';

class LoginSheet extends StatefulWidget {
  const LoginSheet({super.key});

  @override
  State<LoginSheet> createState() => _LoginSheetState();
}

class _LoginSheetState extends State<LoginSheet> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 22),
              const Text(
                "Create Your Account",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  fontFamily: "Poppins",
                ),
              ),
              const SizedBox(height: 8),
              const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Welcome back! We miss you so much.\n",
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: 13,
                        fontFamily: "Poppins",
                      ),
                    ),
                    TextSpan(
                      text:
                      "Are you ready to continue to take care of your\n digital garden?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                        fontSize: 13,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),

              // NAME FIELD
              const SizedBox(
                width: 318,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Enter name",
                    hintStyle:
                    TextStyle(color: AppColors.dark_gray, fontSize: 14),
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                      BorderSide(color: AppColors.dark_gray, width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                      BorderSide(color: AppColors.dark_gray, width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // PASSWORD FIELD with eye icon
              SizedBox(
                width: 318,
                child: TextField(
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    hintText: "Enter password",
                    hintStyle:
                    const TextStyle(color: AppColors.dark_gray, fontSize: 14),
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                      BorderSide(color: AppColors.dark_gray, width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide:
                      BorderSide(color: AppColors.dark_gray, width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.dark_gray,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // BUTTON
              SizedBox(
                width: 318,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {},
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.green, AppColors.orange],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      child: const Text(
                        "LOG IN",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "I HAVE ALREADY AN ACCOUNT",
                  style: TextStyle(
                    fontFamily: "Poppins_Semibold",
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
