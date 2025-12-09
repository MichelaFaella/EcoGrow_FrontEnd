import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../utility/app_colors.dart';
import '../widgets/additional_info.dart';
import '../widgets/plant_info_section.dart';
import '../widgets/tips_info.dart';

class InfoPlantPage extends StatelessWidget {
  final Map<String, dynamic> plant;

  const InfoPlantPage({
    super.key,
    required this.plant,
  });

  @override
  Widget build(BuildContext context) {
    // ---------- TITLE ----------
    final title = (plant["common_name"] != null && plant["common_name"].trim().isNotEmpty)
        ? plant["common_name"]
        : plant["scientific_name"];

    // ---------- TIPS PROCESSING ----------
    List<dynamic>? tipsList;
    if (plant["tips"] != null) {
      final t = plant["tips"];
      tipsList = t is List ? t : [t];
    }

    // ---------- IMAGE HANDLING ----------
    Uint8List? imageBytes;

    if (plant["imageBytes"] != null && plant["imageBytes"] is Uint8List) {
      imageBytes = plant["imageBytes"];
    } else if (plant["photo_base64"] != null) {
      try {
        imageBytes = base64Decode(plant["photo_base64"]);
      } catch (_) {}
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          // ============================
          //   IMAGE + GRADIENT + HEADER
          // ============================
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: imageBytes != null
                    ? Image.memory(
                  imageBytes,
                  width: double.infinity,
                  height: 450,
                  fit: BoxFit.cover,
                )
                    : Container(
                  width: double.infinity,
                  height: 400,
                  color: Colors.grey[300],
                ),
              ),

              Container(
                height: 200,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black54,
                      Colors.black87,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),

              Positioned(
                top: 30,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: 60,
                  child: Row(
                    children: [
                      const SizedBox(width: 5),
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Poppins",
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ============================
          //       SCROLLABLE CONTENT
          // ============================
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (plant["scientific_name"] != null)
                    PlantInfoSection(title: "Scientific Name", description: plant["scientific_name"]),

                  if (plant["family_name"] != null)
                    PlantInfoSection(
                      title: "Family",
                      description: plant["family_description"] ?? "",
                      family: plant["family_name"],
                    ),

                  if (tipsList != null)
                    PlantTipsSection(tips: tipsList),

                  if (plant["climate"] != null)
                    PlantInfoSection(title: "Climate", description: plant["climate"]),

                  if (plant["category"] != null)
                    PlantInfoSection(title: "Category", description: plant["category"]),

                  if (plant["origin"] != null)
                    PlantInfoSection(title: "Origin", description: plant["origin"]),

                  if (plant["use"] != null)
                    PlantInfoSection(title: "Use", description: plant["use"]),


                  const SizedBox(height: 20),

                  // ============================
                  //     ADDITIONAL INFO (NEW)
                  // ============================
                  AdditionalInfoSection(
                    size: plant["size"],
                    waterLevel: plant["water_level"],
                    lightLevel: plant["light_level"],
                    minTemp: plant["min_temp_c"],
                    maxTemp: plant["max_temp_c"],
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
