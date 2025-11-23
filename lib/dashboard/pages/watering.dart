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

  Future<void> _loadOverview() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final reminderService = ReminderService();
    final (ok, message, data) =
    await reminderService.fetchWeeklyWateringOverview();

    if (!mounted) return;

    if (!ok || data == null) {
      setState(() {
        _loading = false;
        _error = message ?? 'Unable to load watering overview';
      });
      return;
    }

    // data = [ { date, plants: [...] }, ... ]
    final List<_DayGroup> days = [];

    for (final dayMap in data) {
      final dateStr = dayMap['date'] as String?;
      if (dateStr == null) continue;

      DateTime dayDate;
      try {
        dayDate = DateTime.parse(dateStr);
      } catch (_) {
        continue;
      }

      final plantsList = (dayMap['plants'] as List?) ?? const [];
      final plants = plantsList
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList();

      days.add(
        _DayGroup(
          date: dayDate,
          plants: plants,
        ),
      );
    }

    days.sort((a, b) => a.date.compareTo(b.date));

    setState(() {
      _days = days;
      _loading = false;
      _error = null;
    });
  }

  String _dayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);

    if (d == today) {
      return "Today";
    }
    if (d == today.add(const Duration(days: 1))) {
      return "Tomorrow";
    }

    const names = [
      "", // dummy per index 0
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];

    return names[d.weekday];
  }

  String _plantsCountLabel(int count) {
    if (count == 1) return "1 PLANT";
    return "$count PLANTS";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: _loading
            ? const Center(
          child: CircularProgressIndicator(
            color: AppColors.green,
          ),
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
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
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

  Widget _buildContent(BuildContext context) {
    if (_days.isEmpty) {
      return const Center(
        child: Text(
          "No watering tasks for this week",
          style: TextStyle(
            fontFamily: "Poppins",
            fontSize: 16,
            color: AppColors.black,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),

        // titolo
        const Center(
          child: Text(
            "WATERING",
            style: TextStyle(
              fontSize: 32,
              fontFamily: "Poppins",
              fontWeight: FontWeight.bold,
              color: AppColors.black,
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

        // lista scrollabile
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadOverview,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _days.length,
              itemBuilder: (context, index) {
                final day = _days[index];
                final label = _dayLabel(day.date);
                final plants = day.plants;
                final plantsCount = plants.length;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // header del giorno
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                          ),
                          Text(
                            _plantsCountLabel(plantsCount),
                            style: const TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.green,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // cards del giorno
                    ...plants.map((p) {
                      final plantId = p['plant_id'] as String?;
                      final planId = p['plan_id'] as String?;
                      final plantName = (p['plant_name'] as String?) ?? "Your plant";

                      final ml = (p['last_log_amount_ml'] as num?)?.toInt();
                      final overdue = (p['overdue'] as bool?) ?? false;

                      // ---- FOTO BASE64 COMPRESSA ----
                      Uint8List? imageBytes;
                      final photoBase64 = p['photo_base64'] as String?;

                      if (photoBase64 != null && photoBase64.isNotEmpty) {
                        try {
                          imageBytes = base64Decode(photoBase64);
                        } catch (e) {
                          print("⚠️ Errore decodifica foto base64: $e");
                          imageBytes = null;
                        }
                      }

                      return WateringCard(
                        plantName: plantName,
                        amountMl: ml,
                        overdue: overdue,
                        imageBytes: imageBytes,  // <<===== ORA LA PASSIAMO VERAMENTE
                        onTap: () {
                          if (plantId == null || planId == null) {
                            showToastWrong(
                              context,
                              "Missing plan/plant id for watering",
                            );
                            return;
                          }

                          showToastInfo(context, "TODO: register watering for $plantName");
                        },
                      );
                    }).toList(),

                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      height: 1,
                      color: AppColors.light_gray,
                    ),
                    const SizedBox(height: 20),

                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Gruppo di piante per un singolo giorno
class _DayGroup {
  final DateTime date;
  final List<Map<String, dynamic>> plants;

  _DayGroup({
    required this.date,
    required this.plants,
  });
}
