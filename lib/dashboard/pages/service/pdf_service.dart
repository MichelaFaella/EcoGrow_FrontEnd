import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class PdfPlantExporter {
  static Future<Uint8List> generatePlantPdf(
      List<Map<String, dynamic>> plants) async {
    final pdf = pw.Document();

    final logo = await _loadEcoGrowLogo();
    final pageWidth = PdfPageFormat.a4.availableWidth;

    // -----------------------------------------------------------
    // 1 — COPERTINA FULL PAGE
    // -----------------------------------------------------------
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (_) {
          return pw.Container(
            width: PdfPageFormat.a4.width,
            height: PdfPageFormat.a4.height,
            color: PdfColor.fromHex("#322f30"),
            child: pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  if (logo != null)
                    pw.Container(
                      width: 300,
                      height: 300,
                      child: pw.Image(logo),
                    ),
                  pw.SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );

    // -----------------------------------------------------------
    // 2 — PAGINE DELLE PIANTE
    // -----------------------------------------------------------
    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(20),
        pageFormat: PdfPageFormat.a4,
        build: (ctx) {
          return plants.map((plant) {
            final Uint8List? img = _extractImage(plant);
            final List<String> tips = _extractTips(plant);

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // NOME PIANTA
                pw.Text(
                  plant["common_name"] ?? plant["scientific_name"],
                  style: pw.TextStyle(
                    fontSize: 30,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 16),

                // FOTO SOTTO NOME — COME COVER
                if (img != null)
                  pw.Center(
                    child: pw.Container(
                      width: pageWidth,
                      height: 260,
                      child: pw.ClipRRect(
                        horizontalRadius: 16,
                        verticalRadius: 16,
                        child: pw.FittedBox(
                          fit: pw.BoxFit.cover,
                          child: pw.Image(pw.MemoryImage(img)),
                        ),
                      ),
                    ),
                  ),

                pw.SizedBox(height: 20),

                if (plant["scientific_name"] != null)
                  _section("Scientific Name", plant["scientific_name"]),

                if (plant["family_name"] != null)
                  _section(
                    "Family",
                    "This plant belongs to the ${plant["family_name"]}. "
                        "${plant["family_description"] ?? ""}",
                  ),

                // TIPS (COME NELLA UI)
                if (tips.isNotEmpty) _tipsSectionPdf(tips),

                if (plant["climate"] != null)
                  _section("Climate", plant["climate"]),

                if (plant["category"] != null)
                  _section("Category", plant["category"]),

                if (plant["origin"] != null) _section("Origin", plant["origin"]),

                if (plant["use"] != null) _section("Use", plant["use"]),

                pw.SizedBox(height: 20),

                pw.Text(
                  "Additional Info.",
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 14),

                if (plant["size"] != null)
                  _keyValue("Size", plant["size"].toString().toUpperCase()),

                if (plant["water_level"] != null)
                  _levelRow("Watering Level", plant["water_level"], 5),

                if (plant["light_level"] != null)
                  _levelRow("Light Exposure", plant["light_level"], 5),

                if (plant["min_temp_c"] != null && plant["max_temp_c"] != null)
                  _temperatureBarPdf(
                      plant["min_temp_c"], plant["max_temp_c"], pageWidth),

                pw.SizedBox(height: 40),
                pw.Divider(thickness: 1, color: PdfColors.grey600),
                pw.SizedBox(height: 40),
              ],
            );
          }).toList();
        },
      ),
    );

    return pdf.save();
  }

  // =====================================================================
  // LOGO
  // =====================================================================
  static Future<pw.MemoryImage?> _loadEcoGrowLogo() async {
    try {
      final bytes = await rootBundle.load("images/EcoGrow.png");
      return pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (_) {
      return null;
    }
  }

  // =====================================================================
  // IMMAGINE
  // =====================================================================
  static Uint8List? _extractImage(Map<String, dynamic> plant) {
    try {
      if (plant["imageBytes"] is Uint8List) return plant["imageBytes"];
      if (plant["photo_base64"] != null) {
        return base64Decode(plant["photo_base64"]);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // =====================================================================
  // TIPS
  // =====================================================================
  static List<String> _extractTips(Map<String, dynamic> plant) {
    if (plant["tips"] == null) return [];

    dynamic t = plant["tips"];

    // Caso: stringa JSON oppure stringa semplice
    if (t is String) {
      final s = t.trim();
      if (s.isEmpty) return [];
      try {
        t = jsonDecode(s);
      } catch (_) {
        return [s];
      }
    }

    // Caso: oggetto con chiave tips
    if (t is Map && t["tips"] != null) {
      t = t["tips"];
    }

    // Caso: lista
    if (t is List) {
      final out = <String>[];
      for (final e in t) {
        if (e == null) continue;

        if (e is String) {
          final v = e.trim();
          if (v.isNotEmpty) out.add(v);
          continue;
        }

        if (e is Map) {
          final candidates = [
            e["tip"],
            e["text"],
            e["description"],
            e["title"],
            e["value"],
          ];

          final first = candidates.firstWhere(
                (x) => x is String && (x as String).trim().isNotEmpty,
            orElse: () => null,
          );

          if (first is String) out.add(first.trim());
        } else {
          final v = e.toString().trim();
          if (v.isNotEmpty) out.add(v);
        }
      }
      return out;
    }

    // Fallback
    final v = t.toString().trim();
    return v.isEmpty ? [] : [v];
  }

  static pw.Widget _tipsSectionPdf(List<String> tips) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "Tips",
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex("#F3F8EF"),
              borderRadius: pw.BorderRadius.circular(12),
              border:
              pw.Border.all(color: PdfColor.fromHex("#55AA33"), width: 1),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: tips.map((t) => _tipBulletRowPdf(t)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _tipBulletRowPdf(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 8,
            height: 8,
            margin: const pw.EdgeInsets.only(top: 4, right: 10),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex("#55AA33"),
              shape: pw.BoxShape.circle,
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              text,
              style: const pw.TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================================
  // SEZIONI TESTUALI
  // =====================================================================
  static pw.Widget _section(String title, String description) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title,
              style:
              pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(description, style: const pw.TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  static pw.Widget _keyValue(String key, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(key.toUpperCase(),
              style:
              pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 3),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 15,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex("#55AA33"),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================================
  // CERCHI LIVELLO
  // =====================================================================
  static pw.Widget _levelRow(String label, int level, int max) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 14),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label.toUpperCase(),
              style:
              pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Row(
            children: List.generate(max, (i) {
              final active = (i + 1) == level;
              return pw.Container(
                width: 22,
                height: 22,
                margin: const pw.EdgeInsets.only(right: 10),
                decoration: pw.BoxDecoration(
                  shape: pw.BoxShape.circle,
                  border: pw.Border.all(color: PdfColor.fromHex("#333333")),
                  color:
                  active ? PdfColor.fromHex("#55AA33") : PdfColors.white,
                ),
                alignment: pw.Alignment.center,
                child: pw.Text(
                  "${i + 1}",
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: active ? PdfColors.white : PdfColors.black,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // =====================================================================
  // TEMPERATURE BAR — versione PDF identica alla UI Flutter
  // =====================================================================
  static pw.Widget _temperatureBarPdf(int min, int max, double totalWidth) {
    const int globalMin = 0;
    const int globalMax = 100;

    final minPos = ((min - globalMin) / (globalMax - globalMin)) * totalWidth;
    final maxPos = ((max - globalMin) / (globalMax - globalMin)) * totalWidth;

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "TEMPERATURE (°C)",
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex("#222222"),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            height: 22,
            child: pw.Stack(
              children: [
                pw.Positioned(
                  top: 10,
                  child: pw.Container(
                    width: totalWidth,
                    height: 2,
                    color: PdfColors.black,
                  ),
                ),
                pw.Positioned(
                  left: minPos - 1,
                  child:
                  pw.Container(width: 2, height: 20, color: PdfColors.black),
                ),
                pw.Positioned(
                  left: maxPos - 1,
                  child:
                  pw.Container(width: 2, height: 20, color: PdfColors.black),
                ),
                pw.Positioned(
                  top: 10,
                  left: minPos,
                  child: pw.Container(
                    width: (maxPos - minPos).clamp(0, totalWidth),
                    height: 2,
                    color: PdfColor.fromHex("#55AA33"),
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Container(
            height: 16,
            child: pw.Stack(
              children: [
                pw.Positioned(
                  left: minPos - 10,
                  child: pw.Text(
                    "$min",
                    style: pw.TextStyle(
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex("#222222"),
                    ),
                  ),
                ),
                pw.Positioned(
                  left: maxPos - 10,
                  child: pw.Text(
                    "$max",
                    style: pw.TextStyle(
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex("#222222"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
