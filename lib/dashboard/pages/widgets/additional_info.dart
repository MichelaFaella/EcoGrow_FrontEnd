import 'package:flutter/material.dart';

import '../../../utility/app_colors.dart';

class AdditionalInfoSection extends StatelessWidget {
  final int? waterLevel;  // 1–4
  final int? lightLevel;  // 1–4
  final String? size;     // small, medium, large, giant
  final int? minTemp;     // °C
  final int? maxTemp;     // °C

  const AdditionalInfoSection({
    super.key,
    required this.waterLevel,
    required this.lightLevel,
    required this.size,
    required this.minTemp,
    required this.maxTemp,
  });

  Color _circleColor(bool active) =>
      active ? AppColors.dark_green : AppColors.white;

  Color _circleBorder(bool active) =>
      active ? AppColors.white : Colors.black.withOpacity(0.3);

  Widget _buildLevelBar(String label, int? level) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.light_black,
          ),
        ),
        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final active = level != null && level == (i + 1);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _circleColor(active),
                  border: Border.all(color: _circleBorder(active)),
                ),
                child: Center(
                  child: Text(
                    "${i + 1}",
                    style: TextStyle(
                      color: active ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTemperatureBar(int min, int max) {
    const int globalMin = 0;
    const int globalMax = 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "TEMPERATURE (°C)",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.light_black,
          ),
        ),
        const SizedBox(height: 10),

        LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;

            // Posizioni in pixel per le barrette
            final minPos = ((min - globalMin) / (globalMax - globalMin)) * totalWidth;
            final maxPos = ((max - globalMin) / (globalMax - globalMin)) * totalWidth;

            return Column(
              children: [
                // ----------------- BARRA + BARRETTE -----------------
                SizedBox(
                  height: 22,
                  child: Stack(
                    children: [
                      // Barra nera intera
                      Positioned(
                        top: 10,
                        child: Container(
                          width: totalWidth,
                          height: 2,
                          color: Colors.black,
                        ),
                      ),

                      // Barretta min
                      Positioned(
                        left: minPos - 1,
                        child: Container(
                          width: 2,
                          height: 20,
                          color: Colors.black,
                        ),
                      ),

                      // Barretta max
                      Positioned(
                        left: maxPos - 1,
                        child: Container(
                          width: 2,
                          height: 20,
                          color: Colors.black,
                        ),
                      ),

                      // Barra verde tra min e max
                      Positioned(
                        top: 10,
                        left: minPos,
                        child: Container(
                          width: maxPos - minPos,
                          height: 2,
                          color: AppColors.dark_green,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // -------------- NUMERI ESATTAMENTE SOTTO LE BARRETTE --------------
                SizedBox(
                  height: 16,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Numero min centrato alla barretta min
                      Positioned(
                        left: minPos - 10, // valore perfetto per centrare testo
                        child: Text(
                          "$min",
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.light_black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      // Numero max centrato alla barretta max
                      Positioned(
                        left: maxPos - 10,
                        child: Text(
                          "$max",
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.light_black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            );
          },
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Center( // 👈 centra tutto
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380), // 👈 larghezza perfetta
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.light_gray,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Additional Info.",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),

            const SizedBox(height: 20),

            // SIZE
            if (size != null) ...[
              const Text(
                "SIZE",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.light_black,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                size!.toUpperCase(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.dark_green,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // WATER LEVEL
            if (waterLevel != null) ...[
              _buildLevelBar("Watering Level", waterLevel),
              const SizedBox(height: 20),
            ],

            // LIGHT LEVEL
            if (lightLevel != null) ...[
              _buildLevelBar("Light Exposure", lightLevel),
              const SizedBox(height: 20),
            ],

            // TEMPERATURE RANGE
            if (minTemp != null && maxTemp != null)
              _buildTemperatureBar(minTemp!, maxTemp!),
          ],
        ),
      ),
    );
  }

}
