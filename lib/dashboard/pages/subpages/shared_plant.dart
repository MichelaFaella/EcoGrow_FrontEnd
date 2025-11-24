import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:Ecogrow/utility/app_colors.dart';
import '../../../utility/toast.dart';
import '../service/plant_service.dart';
import '../widgets/bottom_shared_friends.dart';
import '../widgets/friends_card.dart';

class SharedPlantPage extends StatefulWidget {
  const SharedPlantPage({super.key});

  @override
  State<SharedPlantPage> createState() => _SharedPlantPageState();
}

class _SharedPlantPageState extends State<SharedPlantPage> {
  bool loading = true;

  List<Map<String, dynamic>> sharedPlants = [];
  List<Map<String, dynamic>> privatePlants = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ============================================================
  // CARICA SHARED + PRIVATE
  // ============================================================
  Future<void> _loadData() async {
    setState(() => loading = true);

    final service = PlantService();

    // SHARED PLANTS
    final sharedRes = await service.getSharedPlants();
    if (!sharedRes.$1 || sharedRes.$3 == null) {
      showToastWrong(context, sharedRes.$2 ?? "Load error");
      setState(() => loading = false);
      return;
    }

    // PRIVATE PLANTS
    final privateRes = await service.getNonSharedPlants();
    if (!privateRes.$1 || privateRes.$3 == null) {
      showToastWrong(context, privateRes.$2 ?? "Load error");
      setState(() => loading = false);
      return;
    }

    setState(() {
      sharedPlants = sharedRes.$3!;
      privatePlants = privateRes.$3!;
      loading = false;
    });
  }

  // ============================================================
  // RIMOZIONE CONDIVISIONE
  // ============================================================
  Future<void> _removeShare(String sharedId) async {
    final (ok, msg) = await PlantService().unsharePlant(sharedId);

    if (!mounted) return;

    if (ok) {
      showToastCorrect(context, "Sharing removed");
      _loadData();
    } else {
      showToastWrong(context, msg ?? "Error removing sharing");
    }
  }

  // ============================================================
  // CONDIVISIONE PIANTA
  // ============================================================
  Future<void> _sharePlant(String plantId) async {
    // Apri il bottom sheet per selezionare l'amico
    final shortId = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SelectFriendForSharingSheet(),
    );

    if (shortId == null || shortId.isEmpty) return;

    final (ok, msg) = await PlantService().sharePlant(
      plantId: plantId,
      shortId: shortId,
    );

    if (!mounted) return;

    if (ok) {
      showToastCorrect(context, "Plant shared!");
      _loadData();
    } else {
      showToastWrong(context, msg ?? "Could not share plant");
    }
  }

  // ============================================================
  // UI
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                iconSize: 40,     // <-- ingrandisce il bottone
                padding: EdgeInsets.all(12),
                icon: const Icon(
                  Icons.close,
                  color: AppColors.black,
                  size: 35,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            Expanded(
              child: loading
                  ? const Center(
                child: CircularProgressIndicator(color: AppColors.green),
              )
                  : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // -------------------------------------------------
                    // SHARED PLANTS
                    // -------------------------------------------------
                    const Text(
                      "Shared plants",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (sharedPlants.isEmpty)
                      const Text(
                        "No shared plants yet.",
                        style: TextStyle(
                            fontSize: 14, color: AppColors.dark_gray),
                      )
                    else
                      Column(
                        children: sharedPlants.map((p) {
                          // --- immagine ---
                          Uint8List? bytes = p["image_bytes"];
                          ImageProvider<Object> img = bytes != null
                              ? MemoryImage(bytes)
                              : const AssetImage("images/plant1.jpg");

                          return Padding(
                            padding:
                            const EdgeInsets.symmetric(vertical: 10),
                            child: FriendsCard(
                              title: p["name"] ?? "Unknown plant",
                              subtitle: p["nickname"] ?? "",
                              ownerName:
                              p["friend_full_name"] ?? "Unknown",
                              image: img,
                              onTap: () => _removeShare(p["shared_id"]),
                            ),
                          );
                        }).toList(),
                      ),

                    const SizedBox(height: 30),

                    // -------------------------------------------------
                    // PRIVATE PLANTS
                    // -------------------------------------------------
                    const Text(
                      "Private plants",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (privatePlants.isEmpty)
                      const Text(
                        "No private plants.",
                        style: TextStyle(
                            fontSize: 14, color: AppColors.dark_gray),
                      )
                    else
                      Column(
                        children: privatePlants.map((p) {
                          // --- immagine ---
                          Uint8List? bytes = p["image_bytes"];
                          ImageProvider<Object> img = bytes != null
                              ? MemoryImage(bytes)
                              : const AssetImage("images/plant1.jpg");

                          return Padding(
                            padding:
                            const EdgeInsets.symmetric(vertical: 10),
                            child: FriendsCard(
                              title: p["name"] ?? "Unknown",
                              subtitle: p["nickname"] ?? "",
                              ownerName: "", // non mostra owner
                              image: img,
                              onTap: () =>
                                  _sharePlant(p["plant_id"]),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
