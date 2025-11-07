import 'package:flutter/material.dart';
import '../pages/models/plant.dart';
import 'plant_card.dart';

class PlantGrid extends StatelessWidget {
  final String filter;
  const PlantGrid({Key? key, required this.filter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Plant> allPlants = [
      Plant(
        name: 'Adiantum hispidulum',
        commonName: 'Bronze Venus',
        imagePath: 'images/a.jpg',
        size: 'small',
        difficulty: 'medium',
      ),
      Plant(
        name: 'Aglaonema',
        commonName: 'Maria',
        imagePath: 'images/images.jpeg',
        size: 'medium',
        difficulty: 'easy',
      ),
      Plant(
        name: 'Adiantum raddianum',
        commonName: 'Fragrans',
        imagePath: 'images/adiantum_fragrans_v1.jpg',
        size: 'small',
        difficulty: 'hard',
      ),
      Plant(
        name: 'Pothos',
        commonName: 'Aureus',
        imagePath: 'images/adiantum_fragrans_v1.jpg',
        size: 'large',
        difficulty: 'easy',
      ),
      Plant(
        name: 'Monstera deliciosa',
        commonName: 'Swiss Cheese Plant',
        imagePath: 'images/Monstera_deliciosa2.jpg',
        size: 'large',
        difficulty: 'medium',
      ),
      Plant(
        name: 'Sansevieria trifasciata',
        commonName: 'Snake Plant',
        imagePath: 'images/adiantum_fragrans_v1.jpg',
        size: 'medium',
        difficulty: 'easy',
      ),
    ];


    List<Plant> filteredPlants = List.from(allPlants); // 👈 copia, non modifica l’originale

    if (filter == 'SIZE') {
      filteredPlants.sort((a, b) => a.size.compareTo(b.size));
    } else if (filter == 'DIFFICULTY') {
      filteredPlants.sort((a, b) => a.difficulty.compareTo(b.difficulty));
    } else if (filter == 'ALL') {
      filteredPlants = List.from(allPlants); // ✅ ripristina lista originale
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredPlants.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
        childAspectRatio: 0.55,
      ),
      itemBuilder: (context, index) {
        return PlantCard(plant: filteredPlants[index]);
      },
    );
  }
}
