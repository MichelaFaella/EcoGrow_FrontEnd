import 'package:flutter/material.dart';
import '../../utility/app_colors.dart';

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
      active ? AppColors.green : Colors.white;

  Color _circleBorder(bool active) =>
      active ? AppColors.green : Colors.black.withOpacity(0.3);

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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (i) {
            final active = level != null && level == (i + 1);
            return Container(
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
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTemperatureBar(int min, int max) {
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

        // BAR
        LayoutBuilder(
          builder: (context, constraints) {
            final fullWidth = constraints.maxWidth;

            return Column(
              children: [
                Row(
                  children: [
                    // Linea sinistra
                    Container(
                      width: 2,
                      height: 20,
                      color: Colors.black,
                    ),

                    // Barra verde
                    Expanded(
                      child: Container(
                        height: 2,
                        color: AppColors.green,
                      ),
                    ),

                    // Linea destra
                    Container(
                      width: 2,
                      height: 20,
                      color: Colors.black,
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "$min",
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.light_black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "$max",
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.light_black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              ],
            );
          },
        ),
      ],
    );
  }

  @override
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
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.green,
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
