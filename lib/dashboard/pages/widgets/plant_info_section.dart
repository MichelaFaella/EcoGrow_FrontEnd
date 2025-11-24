import 'package:flutter/material.dart';

import '../../../utility/app_colors.dart';


class PlantInfoSection extends StatelessWidget {
  final String title;
  final String description;
  final String? family;

  const PlantInfoSection({
    super.key,
    required this.title,
    required this.description,
    this.family,
  });

  @override
  Widget build(BuildContext context) {
    final String finalDescription =
    title.toLowerCase() == "family"
        ? "This plant belongs to the $family. $description"
        : description;

    return Center(   //restringe la larghezza centrando il blocco
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380), // larghezza perfetta
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titolo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
            ),

            // Descrizione
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: Text(
                finalDescription,
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.black,
                ),
              ),
            ),

            // Divider accorciato
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
