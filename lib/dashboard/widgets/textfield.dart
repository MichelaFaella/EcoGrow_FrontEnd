import 'package:flutter/material.dart';
import '../../utility/app_colors.dart';

class LabeledTextField extends StatelessWidget {
  final String label;
  final String hint;
  final bool obscure;
  final TextEditingController? controller;
  final Widget? suffixIcon; // <-- aggiunto

  const LabeledTextField({
    super.key,
    required this.label,
    required this.hint,
    this.obscure = false,
    this.controller,
    this.suffixIcon, // <-- aggiunto
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // LABEL
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppColors.green,
              fontSize: 12,
              letterSpacing: 1,
              fontWeight: FontWeight.bold,
              fontFamily: "Poppins",
            ),
          ),
        ),

        // TEXTFIELD
        TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: "Poppins",
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

            // aggiunto suffixIcon
            suffixIcon: suffixIcon,

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.light_gray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white),
            ),
          ),
        )
      ],
    );
  }
}
