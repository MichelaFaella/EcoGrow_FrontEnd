import 'dart:convert'; // 👈 aggiungi questo
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../utility/app_colors.dart';
import '../models/plant.dart';
import '../service/plant_service.dart';
import '../subpages/info_plant.dart';

class PlantCard extends StatelessWidget {
  final Plant plant;

  const PlantCard({Key? key, required this.plant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    final String plantId = plant.id;

    if (plant.imageBase64 != null && plant.imageBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(plant.imageBase64!);
        imageWidget = Image.memory(
          bytes,
          width: double.infinity,
          height: 162,
          fit: BoxFit.cover,
        );
      } catch (e) {
        // se il base64 è corrotto, metti un semplice colore di fallback
        imageWidget = Container(
          width: double.infinity,
          height: 162,
          color: Colors.grey.shade300,
        );
      }
    } else {
      // nessuna immagine -> solo sfondo grigio
      imageWidget = Container(
        width: double.infinity,
        height: 162,
        color: Colors.grey.shade300,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.light_gray,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
                child: SizedBox(
                  width: double.infinity,
                  height: 165,
                  child: imageWidget,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () async {
                    final service = PlantService();

                    // chiama il backend
                    final (ok, message, plantData) = await service.getFullPlantInfo(plantId);

                    if (!ok || plantData == null) {
                      print("Errore: $message");
                      return;
                    }

                    // aggiungi l'immagine ai dati completi
                    Uint8List? bytes;
                    if (plant.imageBase64 != null && plant.imageBase64!.isNotEmpty) {
                      try {
                        bytes = base64Decode(plant.imageBase64!);
                      } catch (_) {}
                    }

                    plantData["imageBytes"] = bytes;

                    // vai alla pagina
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InfoPlantPage(plant: plantData),
                      ),
                    );
                  },
                  child:  Container(
                    height: 28,
                    width: 28,
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: AppColors.green,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              plant.commonName,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 5),
            child: Text(
              '"${plant.name ?? ""}"',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: AppColors.light_black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
