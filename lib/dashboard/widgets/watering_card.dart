import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../utility/app_colors.dart';

class WateringCard extends StatelessWidget {
  final String plantName;
  final int? amountMl;
  final bool overdue;
  final Uint8List? imageBytes;
  final VoidCallback onTap;
  final VoidCallback? onUndo;       // <-- AGGIUNTO
  final bool isToday;
  final bool wasWatered;

  const WateringCard({
    super.key,
    required this.plantName,
    required this.amountMl,
    required this.overdue,
    required this.onTap,
    required this.isToday,
    required this.wasWatered,
    this.onUndo,                   // <-- AGGIUNTO
    this.imageBytes,
  });

  @override
  Widget build(BuildContext context) {
    final amountText = amountMl != null ? "~ $amountMl ml" : "Amount not set";

    final cardColor = wasWatered ? AppColors.water : AppColors.light_gray;
    final textColor = wasWatered ? AppColors.white : AppColors.dark_green;
    final titleColor = wasWatered ? AppColors.white : AppColors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            // Foto
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(24),
              ),
              child: SizedBox(
                width: 90,
                height: double.infinity,
                child: imageBytes != null
                    ? Image.memory(imageBytes!, fit: BoxFit.cover)
                    : Image.asset("images/placeholder_plant.jpg", fit: BoxFit.cover),
              ),
            ),

            const SizedBox(width: 14),

            // Testo
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plantName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Symbols.water_full, size: 20, color: textColor),
                      const SizedBox(width: 6),
                      Text(
                        amountText,
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 13,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Se è già annaffiata → mostra bottone UNDO
            if (isToday && wasWatered)
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: InkWell(
                  onTap: onUndo,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.remove, size: 26, color: AppColors.red),
                  ),
                ),
              ),

            // Se NON è annaffiata → mostra goccia
            if (isToday && !wasWatered)
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: InkWell(
                  onTap: onTap,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.water_drop,
                      size: 26,
                      color: overdue ? AppColors.water : AppColors.water,
                    ),
                  ),
                ),
              ),

            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}
