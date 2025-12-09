import 'package:flutter/material.dart';
import '../../../utility/app_colors.dart';

class PlantTipsSection extends StatelessWidget {
  final List<dynamic> tips;

  const PlantTipsSection({
    super.key,
    required this.tips,
  });

  InlineSpan _formatTip(String tip) {
    final parts = tip.split(":");
    final hasTitle = parts.length > 1;

    return TextSpan(
      children: [
        // Bullet
        const WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Text(
            "• ",
            style: TextStyle(
              fontSize: 16,
              color: AppColors.black,
            ),
          ),
        ),

        // Titolo (prima dei due punti) → in grassetto
        TextSpan(
          text: hasTitle ? "${parts[0]}:" : tip,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
            fontSize: 16,
            fontFamily: "Poppins",
          ),
        ),

        // Corpo del testo
        if (hasTitle)
          TextSpan(
            text: " ${parts.sublist(1).join(":").trim()}",
            style: const TextStyle(
              color: AppColors.black,
              fontSize: 16,
              fontFamily: "Poppins",
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Title ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                "Tips",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
            ),

            // --- List of tips ---
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: tips.map((t) {
                  final tipStr = t.toString();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: RichText(
                      text: _formatTip(tipStr),
                    ),
                  );
                }).toList(),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFE0E0E0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
