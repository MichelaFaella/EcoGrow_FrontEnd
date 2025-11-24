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

  List<Plant> plants = [];
  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  Future<void> _loadPlants() async {
    final (ok, msg, data) = await plantService.getAllUserPlants();

    if (!ok) {
      setState(() {
        errorMessage = msg ?? "Error loading plants";
        loading = false;
      });
      return;
    }

    setState(() {
      plants = data!
          .map((x) => Plant.fromJson(x as Map<String, dynamic>))
          .toList();
      loading = false;
    });
  }

  List<Plant> _applyFilter() {
    List<Plant> filtered = [...plants];

    // ORDER BY SIZE (logico, non alfabetico)
    if (widget.filter == 'SIZE') {
      const sizeOrder = {
        "small": 0,
        "medium": 1,
        "large": 2,
        "giant": 3,
      };

      filtered.sort((a, b) {
        return sizeOrder[a.size]!.compareTo(sizeOrder[b.size]!);
      });
    }

    // ORDER BY DIFFICULTY
    else if (widget.filter == 'DIFFICULTY') {
      filtered.sort((a, b) {
        return int.parse(a.difficulty).compareTo(int.parse(b.difficulty));
      });
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }

    final filtered = _applyFilter();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
        childAspectRatio: 0.6,
      ),
      itemBuilder: (context, index) {
        return PlantCard(plant: filtered[index]);
      },
    );
  }
}
