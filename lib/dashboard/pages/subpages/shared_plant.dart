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
  // CONDIVISIONE PIANTA (MULTI-FRIEND)
  // ============================================================
  Future<void> _sharePlant(String plantId) async {
    // ora ritorna List<String>
    final List<String>? selectedFriends =
    await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SelectFriendForSharingSheet(),
    );

    if (selectedFriends == null || selectedFriends.isEmpty) return;

    // Condivisione multipla → una richiesta per ogni shortId
    for (final sid in selectedFriends) {
      final (ok, msg) = await PlantService().sharePlant(
        plantId: plantId,
        shortId: sid,
      );

      if (!mounted) return;

      if (!ok) {
        showToastWrong(context, msg ?? "Could not share plant");
        return;
      }
    }

    showToastCorrect(context, "Plant shared!");
    _loadData();
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
                iconSize: 40,
                padding: const EdgeInsets.all(12),
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
                child:
                CircularProgressIndicator(color: AppColors.green),
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
                          fontSize: 14,
                          color: AppColors.dark_gray,
                        ),
                      )
                    else
                      Column(
                        children: sharedPlants.map((p) {
                          Uint8List? bytes = p["image_bytes"];
                          ImageProvider<Object> img = bytes != null
                              ? MemoryImage(bytes)
                              : const AssetImage("images/plant1.jpg");

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10),
                            child: FriendsCard(
                              title: p["name"] ?? "Unknown plant",
                              subtitle: p["nickname"] ?? "",
                              ownerName:
                              p["friend_full_name"] ?? "Unknown",
                              image: img,
                              onTap: () async {
                                final bool? confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (_) {
                                    return AlertDialog(
                                      backgroundColor: AppColors.white,
                                      elevation: 12,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      title: const Text(
                                        "Remove sharing?",
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      content: const Text(
                                        "This plant will no longer be shared with this friend.",
                                        textAlign: TextAlign.justify,
                                        style: TextStyle(
                                          color: AppColors.black,
                                          fontFamily: 'Poppins',
                                          fontSize: 15,
                                        ),
                                      ),
                                      actionsPadding: const EdgeInsets.only(right: 15, bottom: 10),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text(
                                            "Cancel",
                                            style: TextStyle(
                                              color: AppColors.black,
                                              fontFamily: 'Poppins',
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            backgroundColor: AppColors.red,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                          ),
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text(
                                            "Delete",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Poppins',
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (confirm == true) {
                                  _removeShare(p["shared_id"]);
                                }
                              },

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
                          fontSize: 14,
                          color: AppColors.dark_gray,
                        ),
                      )
                    else
                      Column(
                        children: privatePlants.map((p) {
                          Uint8List? bytes = p["image_bytes"];
                          ImageProvider<Object> img = bytes != null
                              ? MemoryImage(bytes)
                              : const AssetImage("images/plant1.jpg");

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10),
                            child: FriendsCard(
                              title: p["name"] ?? "Unknown",
                              subtitle: p["nickname"] ?? "",
                              ownerName: "",
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
            ),
          ],
        ),
      ),
    );
  }
}
