import 'dart:typed_data';
import 'package:Ecogrow/dashboard/pages/service/plant_service.dart';
import 'package:Ecogrow/dashboard/pages/widgets/card_check.dart';
import 'package:Ecogrow/dashboard/pages/widgets/pop_up_symptoms.dart';
import 'package:flutter/material.dart';

import '../../utility/app_colors.dart';
import '../../utility/toast.dart';


class DiseasePage extends StatefulWidget {
  const DiseasePage({super.key});

  @override
  State<DiseasePage> createState() => _DiseasePageState();
}

class _DiseasePageState extends State<DiseasePage> {
  final plantService = PlantService();

  List<Map<String, dynamic>> sick = [];
  List<Map<String, dynamic>> healthy = [];

  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => loading = true);

    final (ok1, msg1, sickPlants) = await plantService.getUserSickPlants();
    final (ok2, msg2, healthyPlants) = await plantService.getUserHealthyPlants();

    if (!ok1) {
      setState(() {
        error = msg1;
        loading = false;
      });
      return;
    }

    if (!ok2) {
      setState(() {
        error = msg2;
        loading = false;
      });
      return;
    }

    setState(() {
      sick = sickPlants ?? [];
      healthy = healthyPlants ?? [];
      loading = false;
    });
  }

  // ---------------------------
  // POPUP SINTOMI
  // ---------------------------
  Future<void> _openSymptomsPopup(Map<String, dynamic> item) async {
    final plant = item["plant"] ?? item;
    final familyId = plant["family_id"];

    if (familyId == null) {
      showToastWrong(context, "Family ID missing");
      return;
    }

    final (ok, msg, symptoms) = await plantService.getFamilySymptoms(familyId);

    if (!ok || symptoms == null) {
      showToastWrong(context, msg ?? "Error loading symptoms");
      return;
    }

    final selected = await showSymptomsPopup(context, symptoms);

    if (selected != null && selected.isNotEmpty) {
      print("Sintomi selezionati: $selected");
      showToastCorrect(context, "Symptoms selected!");
    } else {
      showToastInfo(context, "No symptoms selected");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text("Error: $error"))
          : RefreshIndicator(
        onRefresh: loadData,
        child: Container(
          margin:
          const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ----------------------
                // SICK PLANTS
                // ----------------------
                const Text(
                  "Sick plants",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                if (sick.isEmpty)
                  const Text("No sick plants found.",
                      style: TextStyle(fontSize: 14)),
                if (sick.isNotEmpty)
                  SizedBox(
                    height: 230,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      separatorBuilder: (_, __) =>
                      const SizedBox(width: 18),
                      itemCount: sick.length,
                      itemBuilder: (context, i) {
                        final item = sick[i];
                        return CardCheck(
                          name: item["plant"]["common_name"] ??
                              item["plant"]["scientific_name"] ??
                              "Unknown",
                          imageBytes: item["image_bytes"],
                          buttonColor: AppColors.orange,
                          onTap: () => _openSymptomsPopup(item),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 50),

                // ----------------------
                // HEALTHY PLANTS
                // ----------------------
                const Text(
                  "Healthy plants",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                if (healthy.isEmpty)
                  const Text("No healthy plants found."),

                GridView.builder(
                  itemCount: healthy.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.65,
                  ),
                  itemBuilder: (_, i) {
                    final item = healthy[i];
                    return CardCheck(
                      name: item["common_name"] ??
                          item["scientific_name"] ??
                          "Unknown",
                      imageBytes: item["image_bytes"],
                      buttonColor: AppColors.green,
                      onTap: () => _openSymptomsPopup(item),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
