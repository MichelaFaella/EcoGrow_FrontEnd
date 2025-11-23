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

  const WateringCard({
    super.key,
    required this.plantName,
    required this.amountMl,
    required this.overdue,
    required this.onTap,
    this.imageBytes,
  });

  @override
  Widget build(BuildContext context) {
    final amountText =
    amountMl != null ? "~ $amountMl ml" : "Amount not set";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            color: AppColors.light_gray,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // FOTO PIANTA
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(24),
                ),
                child: SizedBox(
                  width: 90,
                  height: double.infinity,
                  child: imageBytes != null
                      ? Image.memory(
                    imageBytes!,
                    fit: BoxFit.cover,
                  )
                      : Image.asset(
                    "images/placeholder_plant.jpg",
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // TESTO
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      plantName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Symbols.water_full,
                          size: 20,
                          color: AppColors.green,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          amountText,
                          style: const TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 13,
                            color: AppColors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ICONA GOCCIA / OVERDUE
              Padding(
                padding:
                const EdgeInsets.only(right: 16.0),
                child: Container(
                  width: 48,
                  height: 48,
                  child: Icon(
                    Icons.water_drop,
                    size: 26,
                    color:
                    overdue ? AppColors.light_gray : AppColors.water,
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}
