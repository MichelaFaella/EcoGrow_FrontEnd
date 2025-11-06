import 'package:flutter/material.dart';
import 'app_colors.dart';

Widget buildSettingsCardProfile(
    BuildContext context, {
      required List<Map<String, dynamic>> items,
    }) {
  return Container(
    width: 330,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < items.length; i++) ...[
            buildItemProfile(
              icon: items[i]['icon'] as IconData,
              text: items[i]['text'] as String,
              onTap: (items[i]['onTap'] as VoidCallback?) ?? () {},
              color: items[i]['color'] as Color?,
            ),
            if (i < items.length - 1)
              const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
          ],
        ],
      ),
    ),
  );
}

Widget buildItemProfile({
  required IconData icon,
  required String text,
  required VoidCallback onTap,
  Color? color,
}) {
  final textColor = color ?? Colors.black87;
  final iconColor = color ?? Colors.grey[700];

  return GestureDetector(
    behavior: HitTestBehavior.opaque, // importantissimo: cattura i tocchi
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: textColor,
                fontWeight: FontWeight.w500,
                fontFamily: "Poppins",
              ),
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    ),
  );
}

