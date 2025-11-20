import 'package:flutter/material.dart';
import '../pages/models/plant.dart';
import '../pages/service/plant_service.dart';
import 'plant_card.dart';

class PlantGrid extends StatefulWidget {
  final String filter;
  const PlantGrid({Key? key, required this.filter}) : super(key: key);

  @override
  State<PlantGrid> createState() => _PlantGridState();
}

class _PlantGridState extends State<PlantGrid> {
  final PlantService plantService = PlantService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: plantService.getAllUserPlants(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final (ok, msg, data) = snapshot.data!;

        if (!ok) {
          return Center(child: Text(msg ?? "Error"));
        }

        // Convert JSON to List<Plant>
        List<Plant> plants = data!
            .map((x) => Plant.fromJson(x as Map<String, dynamic>))
            .toList();

        // 🔥 FILTERING
        if (widget.filter == 'SIZE') {
          plants.sort((a, b) => a.size.compareTo(b.size));
        } else if (widget.filter == 'DIFFICULTY') {
          plants.sort((a, b) => a.difficulty.compareTo(b.difficulty));
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: plants.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            childAspectRatio: 0.55,
          ),
          itemBuilder: (context, index) {
            return PlantCard(plant: plants[index]);
          },
        );
      },
    );
  }
}
