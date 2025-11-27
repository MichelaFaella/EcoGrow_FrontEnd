import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../utility/app_colors.dart';

class CardCheck extends StatelessWidget {
  final String name;
  final Uint8List? imageBytes;
  final VoidCallback onTap;       // CHECK button
  final VoidCallback? onBadgeTap; // Bug tap
  final Color buttonColor;
  final bool isSick;
  final Widget? badge;

  const CardCheck({
    super.key,
    required this.name,
    required this.imageBytes,
    required this.onTap,
    this.onBadgeTap,
    required this.buttonColor,
    this.isSick = false,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // IMAGE + BADGE
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.0,
                  child: imageBytes == null
                      ? _placeholder()
                      : Image.memory(imageBytes!, fit: BoxFit.cover),
                ),

                // BUG BADGE
                if (isSick && badge != null)
                  Positioned(
                    right: 12,
                    top: 12,
                    child: GestureDetector(
                      onTap: onBadgeTap,
                      child: badge!,
                    ),
                  ),
              ],
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

          // BUTTON CHECK
          SizedBox(
            height: 41,
            child: Material(
              color: buttonColor,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: InkWell(
                onTap: onTap,
                child: const Center(
                  child: Text(
                    "CHECK",
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
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
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.local_florist, size: 48, color: Colors.grey),
      ),
    );
  }
}
