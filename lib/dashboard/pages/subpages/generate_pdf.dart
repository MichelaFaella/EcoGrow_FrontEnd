import 'dart:convert';
import 'dart:typed_data';
import 'package:Ecogrow/dashboard/pages/service/pdf_service.dart';
import 'package:Ecogrow/utility/app_colors.dart';
import 'package:flutter/material.dart';


import 'package:printing/printing.dart';import '../service/plant_service.dart';
import '../widgets/plant_grid_pdf.dart';

class GeneratePdfPage extends StatefulWidget {
  const GeneratePdfPage({super.key});

  @override
  State<GeneratePdfPage> createState() => _GeneratePdfPageState();
}

class _GeneratePdfPageState extends State<GeneratePdfPage> {
  final PlantService _plantService = PlantService();

  List<String> _selectedIds = [];
  Map<String, Uint8List?> _selectedImages = {};

  bool _isGenerating = false;

  Future<void> _generatePdf() async {
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select at least one plant.")),
      );
      return;
    }

    setState(() => _isGenerating = true);

    final List<Map<String, dynamic>> fullPlants = [];

    try {
      for (final id in _selectedIds) {
        final (ok, msg, plantData) = await _plantService.getFullPlantInfo(id);

        if (ok && plantData != null) {
          // se hai salvato le immagini dalla grid
          if (_selectedImages[id] != null) {
            plantData["imageBytes"] = _selectedImages[id];
          } else if (plantData["photo_base64"] != null) {
            try {
              plantData["imageBytes"] =
                  base64Decode(plantData["photo_base64"]);
            } catch (_) {}
          }

          fullPlants.add(plantData);
        } else {
          debugPrint("Error loading plant $id: $msg");
        }
      }

      if (fullPlants.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error loading plants data.")),
        );
        return;
      }

      final bytes = await PdfPlantExporter.generatePlantPdf(fullPlants);

      // QUI: invece di layoutPdf usi sharePdf per far “scaricare” il file
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'ecogrow_plants.pdf',
      );
    } catch (e) {
      debugPrint('Error generating PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating PDF: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          children: [
            const SizedBox(height: 10),

            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: AppColors.white,
                    size: 28,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 20),
                const Text(
                  "Select your plants",
                  style: TextStyle(
                    color: AppColors.white,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            Expanded(
              child: SingleChildScrollView(
                child: PlantGridPdf(
                  onSelectionChanged: (ids, images) {
                    setState(() {
                      _selectedIds = ids;
                      _selectedImages = images;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: 350,
              height: 55,
              child: GestureDetector(
                onTap: _isGenerating ? null : _generatePdf,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.green,
                        AppColors.orange,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Center(
                    child: _isGenerating
                        ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text(
                      "Generate PDF",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
