import 'package:Ecogrow/dashboard/pages/service/plant_service.dart';
import 'package:Ecogrow/dashboard/pages/subpages/symptoms_camera.dart';
import 'package:Ecogrow/dashboard/pages/widgets/card_check.dart';
import 'package:Ecogrow/dashboard/pages/widgets/pop_up_symptoms.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

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

  // ================================================================
  // LOAD USER PLANTS
  // ================================================================
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

  // ================================================================
  // POPUP → CAMERA → DIAGNOSIS → REFRESH
  // ================================================================
  Future<void> _openSymptomsPopup(Map<String, dynamic> item) async {
    final plant = (item["plant"] is Map) ? item["plant"] : item;

    final plantId = plant["id"]?.toString() ??
        plant["plant_id"]?.toString() ??
        item["plant_id"]?.toString();

    if (plantId == null || plantId.isEmpty) {
      showToastWrong(context, "Plant ID not found.");
      return;
    }

    final familyId = plant["family_id"]?.toString();
    if (familyId == null || familyId.isEmpty) {
      showToastWrong(context, "This plant has no family.");
      return;
    }

    final (ok, msg, symptoms) = await plantService.getFamilySymptoms(familyId);
    if (!ok || symptoms == null) {
      showToastWrong(context, msg ?? "Error loading symptoms");
      return;
    }

    final selectedSymptoms = await showSymptomsPopup(
      context,
      symptoms: symptoms,
      familyId: familyId,
    );

    if (selectedSymptoms == null || selectedSymptoms.isEmpty) return;

    final diagnosisResult = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SymptomCameraPage(
          symptoms: selectedSymptoms,
          familyId: familyId,
          plantId: plantId,
        ),
      ),
    );

    if (diagnosisResult != null) {
      await loadData();
      if (mounted) setState(() {});
    }
  }

  // ================================================================
  @override
  Widget build(BuildContext context) {
    final sickBadge = Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
          )
        ],
      ),
      child: const Icon(
        Symbols.bug_report,
        fill: 1,        // 1 = pieno, 0 = outline
        weight: 700,    // più alto = più bold
        grade: 200,
        opticalSize: 48,
        color: Colors.orange,
        size: 30,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.white,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text("Error: $error"))
          : RefreshIndicator(
        onRefresh: loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ======================================================
                // SICK PLANTS
                // ======================================================
                const Text(
                  "Sick plants",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                if (sick.isEmpty)
                  const Text(
                    "No sick plants found.",
                    style: TextStyle(fontSize: 14),
                  ),

                if (sick.isNotEmpty)
                  GridView.builder(
                    itemCount: sick.length,
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
                      final item = sick[i];
                      final plant = item["plant"] ?? item;

                      return CardCheck(
                        name: plant["common_name"] ??
                            plant["scientific_name"] ??
                            "Unknown",
                        imageBytes: item["image_bytes"],
                        buttonColor: AppColors.orange,
                        isSick: true,
                        badge: sickBadge,
                        onTap: () => _openSymptomsPopup(item),
                      );
                    },
                  ),

                const SizedBox(height: 30),

                // ======================================================
                // HEALTHY PLANTS
                // ======================================================
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
                      isSick: false,
                      badge: null,
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
