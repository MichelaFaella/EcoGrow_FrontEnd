import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../utility/app_colors.dart';
import '../../utility/toast.dart';
import '../widgets/watering_card.dart';
import 'service/reminder_service.dart';

class WateringPage extends StatefulWidget {
  const WateringPage({super.key});

  @override
  State<WateringPage> createState() => _WateringPageState();
}

class _WateringPageState extends State<WateringPage> {
  bool _loading = true;
  String? _error;
  List<_DayGroup> _days = [];

  @override
  void initState() {
    super.initState();
    _loadOverview();
  }

  // --------------------------------------------------
  // DETERMINA SE È STATA ANNAFFIATA
  // --------------------------------------------------
  bool _isWateredFromDoneAt(String? doneAtStr) {
    if (doneAtStr == null || doneAtStr.isEmpty) return false;

    try {
      final dt = DateTime.parse(doneAtStr);

      if (dt.hour == 0 && dt.minute == 0 && dt.second == 0) {
        return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  // --------------------------------------------------
  // CARICA SETTIMANA
  // --------------------------------------------------
  Future<void> _loadOverview() async {
    print("=== LOAD OVERVIEW ===");

    setState(() {
      _loading = true;
      _error = null;
    });

    final service = ReminderService();
    final (ok, message, data) =
    await service.fetchWeeklyWateringOverview();

    if (!mounted) return;

    if (!ok || data == null) {
      setState(() {
        _loading = false;
        _error = message ?? "Unable to load watering overview";
      });
      return;
    }

    final List<_DayGroup> days = [];

    for (final dayMap in data) {
      final dateStr = dayMap["date"];
      if (dateStr == null || dateStr is! String) continue;

      DateTime date;
      try {
        date = DateTime.parse(dateStr);
      } catch (_) {
        continue;
      }

      final plants = (dayMap["plants"] as List?)
          ?.whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList() ??
          [];

      print("DAY $dateStr → ${plants.length} plants");

      days.add(
        _DayGroup(
          date: date,
          plants: plants,
        ),
      );
    }

    days.sort((a, b) => a.date.compareTo(b.date));

    setState(() {
      _days = days;
      _loading = false;
    });
  }

  // --------------------------------------------------
  // LABEL GIORNI
  // --------------------------------------------------
  String _dayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final d = DateTime(date.year, date.month, date.day);

    if (d == today) return "Today";
    if (d == today.add(const Duration(days: 1))) return "Tomorrow";

    const days = [
      "",
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];

    return days[d.weekday];
  }

  String _plantsCountLabel(int count) =>
      count == 1 ? "1 PLANT" : "$count PLANTS";

  // --------------------------------------------------
  // UI
  // --------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: _loading
            ? const Center(
          child:
          CircularProgressIndicator(color: AppColors.green),
        )
            : _error != null
            ? _buildError(context)
            : _buildContent(context),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: "Poppins",
                fontSize: 16,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOverview,
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // CONTENT
  // --------------------------------------------------
  Widget _buildContent(BuildContext context) {
    if (_days.isEmpty) {
      return const Center(
        child: Text(
          "No watering tasks for this week",
          style:
          TextStyle(fontFamily: "Poppins", fontSize: 16),
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 30),

        const Center(
          child: Text(
            "WATERING",
            style: TextStyle(
              fontSize: 32,
              fontFamily: "Poppins",
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 10),

        const Center(
          child: Text(
            "This is your weekly watering schedule",
            style: TextStyle(
              fontSize: 14,
              fontFamily: "Poppins",
              color: AppColors.dark_gray,
            ),
          ),
        ),

        const SizedBox(height: 30),

        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadOverview,
            child: ListView.builder(
              padding: const EdgeInsets.only(
                  left: 16, right: 16, bottom: 100),
              itemCount: _days.length,
              itemBuilder: (context, index) {
                final day = _days[index];
                return _buildDaySection(day);
              },
            ),
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------
  // DAY + CARDS
  // --------------------------------------------------
  Widget _buildDaySection(_DayGroup day) {
    final List<Map<String, dynamic>> plants = day.plants;
    final String label = _dayLabel(day.date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 24,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              Text(
                _plantsCountLabel(plants.length),
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w500,
                  color: AppColors.green,
                ),
              ),
            ],
          ),
        ),

        // LISTA DELLE PIANTE DEL GIORNO
        for (final p in plants) _buildPlantCard(p, day),

        const SizedBox(height: 20),
        Container(height: 1, color: AppColors.light_gray),
        const SizedBox(height: 15),
      ],
    );
  }

  // --------------------------------------------------
  // CARD PIANTA — LOG CORRETTAMENTE USATI
  // --------------------------------------------------
  Widget _buildPlantCard(Map<String, dynamic> p, _DayGroup day) {
    final plantId = p["plant_id"] as String?;
    final plantName = p["plant_name"] as String? ?? "Your plant";

    // -----------------------------
    // LOG DAL BACKEND
    // -----------------------------
    final logs = p["logs"] as List<dynamic>?;

    String? doneAtStr;
    int? ml;

    if (logs != null && logs.isNotEmpty) {
      final firstLog = logs.first as Map<String, dynamic>;
      doneAtStr = firstLog["done_at"] as String?;
      final amt = firstLog["amount_ml"];
      if (amt is num) ml = amt.toInt();

      print("LOG → plant=$plantName | done_at=$doneAtStr | ml=$ml");
    }

    // -----------------------------
    // FOTO
    // -----------------------------
    Uint8List? img;
    final b64 = p["photo_base64"] as String?;
    if (b64 != null && b64.isNotEmpty) {
      try {
        img = base64Decode(b64);
      } catch (_) {}
    }

    // -----------------------------
    // DETERMINA SE È OGGI
    // -----------------------------
    final now = DateTime.now();
    final isToday = DateTime(
      day.date.year,
      day.date.month,
      day.date.day,
    ) ==
        DateTime(now.year, now.month, now.day);

    // -----------------------------
    // DETERMINA SE È GIORNO FUTURO
    // -----------------------------
    final isFuture = DateTime(
      day.date.year,
      day.date.month,
      day.date.day,
    ).isAfter(DateTime(now.year, now.month, now.day));

    // -----------------------------
    // DETERMINA SE LA PIANTA È STATA ANNAFFIATA
    // (solo in base al timestamp del log)
    // -----------------------------
    final bool wateredByLog =
        doneAtStr != null && _isWateredFromDoneAt(doneAtStr);

    // -----------------------------
    // STATO FINALE
    // -----------------------------
    late bool wasWatered;

    if (isToday) {
      // solo oggi segue la logica del "real log"
      wasWatered = wateredByLog;
    } else if (isFuture) {
      // domani e giorni futuri → non annaffiata
      wasWatered = false;
    } else {
      // giorni passati → mostra lo stato reale del passato
      wasWatered = wateredByLog;
    }

    return WateringCard(
      plantName: plantName,
      amountMl: ml,
      overdue: false,
      imageBytes: img,
      isToday: isToday,
      wasWatered: wasWatered,

      onTap: () async {
        if (!isToday) return;          // solo oggi è permesso cliccare

        if (plantId == null) {
          showToastWrong(context, "Missing plant id");
          return;
        }

        if (wasWatered) {
          showToastInfo(context, "Already watered today");
          return;
        }

        final service = ReminderService();
        final (ok, message, _) = await service.doWatering(
          plantId: plantId,
          amountMl: ml ?? 100,
        );

        if (!ok) {
          showToastWrong(context, message ?? "Unable to water");
          return;
        }

        showToastCorrect(context, "Watered $plantName!");
        await _loadOverview();
      },

      onUndo: () async {
        if (!isToday) return;      // undo solo oggi è logico
        if (plantId == null) return;

        final service = ReminderService();
        final (ok, msg) = await service.undoWatering(plantId);

        if (!ok) {
          showToastWrong(context, msg ?? "Unable to undo");
          return;
        }

        showToastInfo(context, "Undo: restored!");
        await _loadOverview();
      },
    );
  }

}

class _DayGroup {
  final DateTime date;
  final List<Map<String, dynamic>> plants;

  _DayGroup({
    required this.date,
    required this.plants,
  });
}
