import 'dart:typed_data';
import 'package:Ecogrow/dashboard/pages/widgets/plant_card_pdf.dart';
import 'package:flutter/material.dart';

import '../models/plant.dart';
import '../service/plant_service.dart';


class PlantGridPdf extends StatefulWidget {
  /// Callback verso GeneratePdfPage: lista ID selezionati + immagini (per id)
  final void Function(List<String> selectedIds, Map<String, Uint8List?> images)?
  onSelectionChanged;

  const PlantGridPdf({
    Key? key,
    this.onSelectionChanged,
  }) : super(key: key);

  @override
  State<PlantGridPdf> createState() => _PlantGridPdfState();
}

class _PlantGridPdfState extends State<PlantGridPdf> {
  final PlantService plantService = PlantService();

  final List<String> _selectedIds = [];
  final Map<String, Uint8List?> _selectedImages = {};

  void _toggleSelection(String id, bool isSelected, Uint8List? img) {
    setState(() {
      if (isSelected) {
        if (!_selectedIds.contains(id)) {
          _selectedIds.add(id);
        }
        _selectedImages[id] = img;
      } else {
        _selectedIds.remove(id);
        _selectedImages.remove(id);
      }
    });

    widget.onSelectionChanged
        ?.call(List.unmodifiable(_selectedIds), Map.unmodifiable(_selectedImages));
  }

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

        final List<Plant> plants = data!
            .map((x) => Plant.fromJson(x as Map<String, dynamic>))
            .toList();

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: plants.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            childAspectRatio: 0.8,
          ),
          itemBuilder: (context, index) {
            final plant = plants[index];

            return PlantCardPdf(
              plant: plant,
              onSelected: (isSelected, imageBytes) {
                _toggleSelection(plant.id, isSelected, imageBytes);
              },
            );
          },
        );
      },
    );
  }
}
