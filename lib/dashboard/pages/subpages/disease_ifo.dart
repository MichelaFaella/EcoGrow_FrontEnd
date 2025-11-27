import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../utility/app_colors.dart';

class DiseaseInfoPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const DiseaseInfoPage({super.key, required this.data});

  // 🔥 Funzione per convertire snake_case → Human Readable
  String humanize(String? snake) {
    if (snake == null) return "Unknown";
    return snake
        .replaceAll("_", " ")
        .split(" ")
        .map((w) =>
    w.isNotEmpty ? "${w[0].toUpperCase()}${w.substring(1)}" : w)
        .join(" ");
  }

  @override
  Widget build(BuildContext context) {
    final model = data["model"] ?? {};
    final disease = data["disease"] ?? {};

    bool isSnakeCase(String s) {
      return s.contains("_");
    }

    // 🔥 NAME OK
    final String rawName =
        disease["name"] ?? model["disease_name"] ?? "Unknown disease";
    final String name = humanize(rawName);

    // DESCRIPTION OK
    final String? description =
        disease["description"] ?? model["description"];

    // 🔥 SYMPTOMS humanizzati
    final List symptoms = (disease["symptoms"] ?? model["symptoms"] ?? [])
        .map((s) {
      final str = s.toString();
      return isSnakeCase(str) ? humanize(str) : str;
    }).toList();


    // 🔥 CURE TIPS humanizzati
    final List cureTips = (
        disease["cure_tips"] ??
            disease["treatments"] ??
            disease["treatment_tips"] ??
            model["treatments"] ??
            []
    ).map((c) {
      final str = c.toString();
      return isSnakeCase(str) ? humanize(str) : str;
    }).toList();


    // FOTO
    Uint8List? imageBytes;
    if (disease["photo_base64"] != null) {
      try {
        imageBytes = base64Decode(disease["photo_base64"]);
      } catch (_) {}
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: imageBytes != null
                    ? Image.memory(
                  imageBytes,
                  width: double.infinity,
                  height: 450,
                  fit: BoxFit.cover,
                )
                    : Container(
                  height: 450,
                  color: Colors.grey[300],
                ),
              ),
              Container(
                height: 200,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black54,
                      Colors.black87,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              Positioned(
                top: 35,
                left: 0,
                right: 0,
                child: Row(
                  children: [
                    const SizedBox(width: 5),
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                margin: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (description != null)
                      _infoBlock("Description", description),
                    const SizedBox(height: 20),
                    if (symptoms.isNotEmpty)
                      _listBlock("Symptoms", symptoms),
                    const SizedBox(height: 20),
                    if (cureTips.isNotEmpty)
                      _listBlock("Cure Tips", cureTips),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBlock(String title, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          textAlign: TextAlign.justify,
          style: const TextStyle(fontSize: 16, height: 1.35),
        ),
      ],
    );
  }

  Widget _listBlock(String title, List items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: items.map<Widget>((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("• ", style: TextStyle(fontSize: 18)),
                  Expanded(
                    child: Text(
                      item.toString(),
                      textAlign: TextAlign.justify,
                      style: const TextStyle(fontSize: 16, height: 1.35),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        )
      ],
    );
  }
}
