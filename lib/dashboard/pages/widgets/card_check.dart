import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../utility/app_colors.dart';

class CardCheck extends StatelessWidget {
  final String name;
  final Uint8List? imageBytes;
  final VoidCallback onTap;
  final Color buttonColor;

  const CardCheck({
    super.key,
    required this.name,
    required this.imageBytes,
    required this.onTap,
    required this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.light_gray,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20),
            blurRadius: 6,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // IMAGE
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: imageBytes == null
                ? _placeholder()
                : Image.memory(
              imageBytes!,
              height: 158,
              fit: BoxFit.cover,
            ),
          ),

          // NAME
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),

          // BUTTON
          Material(
            color: buttonColor,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
            child: InkWell(
              onTap: onTap,  // <- CORRETTO
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
              child: Container(
                height: 38,
                alignment: Alignment.center,
                child: const Text(
                  "CHECK",
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 140,
      color: Colors.grey[200],
      child: const Icon(Icons.local_florist, size: 48, color: Colors.grey),
    );
  }
}
