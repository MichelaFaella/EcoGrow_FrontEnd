import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../../../utility/storage_service.dart';

class PlantService {
  final String baseUrl = 'https://ecogrow.loca.lt/api';

  /// Ritorna:
  /// - ok: true/false
  /// - message: messaggio di errore (se presente)
  /// - plants: lista di piante (se ok == true)
  Future<(bool ok, String? message, List<Map<String, dynamic>>? plants)>
  getAllUserPlants() async {
    try {
      final token = await StorageService.getToken();
      if (token == null || token.trim().isEmpty) {
        return (false, 'User not authenticated.', null);
      }

      final bearer = token.startsWith('Bearer ') ? token : 'Bearer $token';
      final uri = Uri.parse('$baseUrl/user_plant/all');

      final res = await http.get(
        uri,
        headers: {
          'Authorization': bearer,
          'Accept': 'application/json',
          'Bypass-Tunnel-Reminder': 'true',
        },
      );

      print('[PlantService] GET /user_plant/all Status: ${res.statusCode}');
      print('[PlantService] Response: ${res.body}');

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);

        if (decoded is List) {
          final list = decoded
              .whereType<Map<String, dynamic>>()
              .toList(growable: false);
          return (true, null, list);
        }

        return (false, 'Invalid response format.', null);
      } else {
        try {
          final err = jsonDecode(res.body);
          if (err is Map<String, dynamic>) {
            return (false, err['error']?.toString(), null);
          }
          return (false, 'Error ${res.statusCode}', null);
        } catch (_) {
          return (false, 'Error ${res.statusCode}', null);
        }
      }
    } catch (e) {
      print('[PlantService] Exception GET /user_plant/all: $e');
      return (false, 'Exception: $e', null);
    }
  }

  /// Crea una pianta inviando l'immagine compressa in WebP e codificata in Base64.
  ///
  /// Ritorna:
  /// - ok: true/false
  /// - message: messaggio di errore (se presente)
  /// - data: risposta del backend (se ok == true)
  Future<(bool ok, String? message, Map<String, dynamic>? data)> createPlant({
    required File imageFile,
  }) async {
    try {
      final token = await StorageService.getToken();
      if (token == null || token.trim().isEmpty) {
        return (false, 'User not authenticated.', null);
      }

      final bearer = token.startsWith('Bearer ') ? token : 'Bearer $token';

      // Compressione immagine in WebP
      print('[PlantService] Original size: ${await imageFile.length()} bytes');

      final compressed = await FlutterImageCompress.compressWithFile(
        imageFile.path,
        format: CompressFormat.webp,
        minWidth: 1280,
        minHeight: 1280,
        quality: 70,
      );

      if (compressed == null) {
        return (false, 'Image compression failed.', null);
      }

      print('[PlantService] Compressed size: ${compressed.length} bytes');

      // Base64
      final imageB64 = base64Encode(compressed);
      print('[PlantService] Base64 length: ${imageB64.length}');

      final uri = Uri.parse('$baseUrl/plant/add');

      final res = await http.post(
        uri,
        headers: {
          'Authorization': bearer,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Bypass-Tunnel-Reminder': 'true',
        },
        body: jsonEncode({'image': imageB64}),
      );

      print('[PlantService] Status: ${res.statusCode}');
      print('[PlantService] Body: ${res.body}');

      if (res.statusCode == 201) {
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic>) {
          return (true, null, decoded);
        }
        return (false, 'Invalid response format.', null);
      }

      try {
        final err = jsonDecode(res.body);
        if (err is Map<String, dynamic>) {
          return (false, err['error']?.toString(), null);
        }
        return (false, 'Error ${res.statusCode}', null);
      } catch (_) {
        return (false, 'Error ${res.statusCode}', null);
      }
    } catch (e) {
      print('[PlantService] Exception: $e');
      return (false, 'Exception: $e', null);
    }
  }

  /// Ottiene tutte le informazioni complete della pianta,
  /// inclusa la foto compressa in Base64.
  ///
  /// Ritorna:
  /// (ok, message, plant)
  Future<(bool ok, String? message, Map<String, dynamic>? plant)>
  getFullPlantInfo(String plantId) async {
    try {
      final token = await StorageService.getToken();
      if (token == null || token.trim().isEmpty) {
        return (false, 'User not authenticated.', null);
      }

      final bearer = token.startsWith('Bearer ') ? token : 'Bearer $token';

      final uri = Uri.parse('$baseUrl/plant/full/$plantId');

      final res = await http.get(
        uri,
        headers: {
          'Authorization': bearer,
          'Accept': 'application/json',
          'Bypass-Tunnel-Reminder': 'true',
        },
      );

      print('[PlantService] GET /plant/full/$plantId Status: ${res.statusCode}');
      print('[PlantService] Body: ${res.body}');

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic>) {
          return (true, null, decoded);
        }
        return (false, 'Invalid response format.', null);
      }

      // gestione errori
      try {
        final err = jsonDecode(res.body);
        if (err is Map<String, dynamic>) {
          return (false, err['error']?.toString(), null);
        }
        return (false, 'Error ${res.statusCode}', null);
      } catch (_) {
        return (false, 'Error ${res.statusCode}', null);
      }
    } catch (e) {
      print('[PlantService] Exception GET /plant/full: $e');
      return (false, 'Exception: $e', null);
    }
  }

  Future<(bool ok, String? message, List<Map<String, dynamic>>? shared)>
  getSharedPlants() async {
    try {
      final token = await StorageService.getToken();
      if (token == null || token.trim().isEmpty) {
        return (false, "User not authenticated.", null);
      }

      final bearer = token.startsWith("Bearer ") ? token : "Bearer $token";
      final uri = Uri.parse("$baseUrl/shared_plant/all");

      final res = await http.get(
        uri,
        headers: {
          "Authorization": bearer,
          "Accept": "application/json",
          "Bypass-Tunnel-Reminder": "true",
        },
      );

      print("[PlantService] GET /shared_plant/all status: ${res.statusCode}");

      if (res.statusCode != 200) {
        try {
          final err = jsonDecode(res.body);
          return (false, err["error"]?.toString(), null);
        } catch (_) {
          return (false, "Error ${res.statusCode}", null);
        }
      }

      final decoded = jsonDecode(res.body);
      if (decoded is! List) return (false, "Invalid response format.", null);

      final List<Map<String, dynamic>> list = [];

      for (final item in decoded) {
        if (item is! Map<String, dynamic>) continue;

        Uint8List? bytes;
        final b64 = item["photo_base64"] as String?;
        if (b64 != null && b64.isNotEmpty) {
          try {
            bytes = base64Decode(b64);
          } catch (_) {}
        }

        final first = item["friend_first_name"]?.toString() ?? "";
        final last  = item["friend_last_name"]?.toString() ?? "";
        final full  = "$first $last".trim();

        list.add({
          "shared_id": item["shared_id"]?.toString(),
          "plant_id": item["plant_id"]?.toString(),
          "name": item["plant_name"]?.toString() ?? "",
          "nickname": item["nickname"]?.toString() ?? "",
          "friend_full_name": full,
          "image_bytes": bytes,       // <--- coerente con tutto il resto
        });
      }

      return (true, null, list);
    } catch (e) {
      return (false, "Exception: $e", null);
    }
  }



  Future<(bool ok, String? message, List<Map<String, dynamic>>? plants)>
  getNonSharedPlants() async {
    final (okAll, msgAll, allPlants) = await getAllUserPlants();
    if (!okAll || allPlants == null) {
      return (false, msgAll, null);
    }

    final (okShared, msgShared, shared) = await getSharedPlants();
    if (!okShared || shared == null) {
      return (false, msgShared, null);
    }

    final sharedIds = shared
        .map((m) => m["plant_id"])
        .where((id) => id != null)
        .toSet();

    final List<Map<String, dynamic>> out = [];

    for (final item in allPlants) {
      if (item is! Map<String, dynamic>) continue;

      final plant = item["plant"] as Map<String, dynamic>?;
      final plantId = plant?["id"]?.toString() ??
          item["plant_id"]?.toString();

      if (plantId == null) continue;
      if (sharedIds.contains(plantId)) continue;

      final name =
          plant?["common_name"]?.toString() ??
              plant?["scientific_name"]?.toString() ??
              "";

      final nickname = item["nickname"]?.toString() ?? "";

      // ---- FOTO BASE64 → Uint8List ----
      Uint8List? bytes;
      final photos = plant?["photos"];
      if (photos is List && photos.isNotEmpty && photos.first is Map) {
        final imgB64 = (photos.first as Map)["image"] as String?;
        if (imgB64 != null && imgB64.isNotEmpty) {
          try {
            bytes = base64Decode(imgB64);
          } catch (_) {}
        }
      }

      out.add({
        "plant_id": plantId,
        "name": name,
        "nickname": nickname,
        "image_bytes": bytes,     // <--- stessa struttura delle shared
      });
    }

    return (true, null, out);
  }

  Future<(bool ok, String? message)> sharePlant({
    required String plantId,
    required String shortId,
  }) async {
    try {
      // Recupera token
      final token = await StorageService.getToken();
      if (token == null || token.trim().isEmpty) {
        return (false, "User not authenticated.");
      }

      final bearer = token.startsWith("Bearer ") ? token : "Bearer $token";

      // Endpoint
      final uri = Uri.parse("$baseUrl/shared_plant/add");

      print("[PlantService] → POST /shared_plant/add");
      print("[PlantService]   plant_id: $plantId");
      print("[PlantService]   short_id: $shortId");

      // Richiesta
      final res = await http.post(
        uri,
        headers: {
          "Authorization": bearer,
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Bypass-Tunnel-Reminder": "true",
        },
        body: jsonEncode({
          "plant_id": plantId,
          "short_id": shortId, // 👈 singolo short-id
        }),
      );

      print("[PlantService] ← Status: ${res.statusCode}");
      print("[PlantService] ← Body: ${res.body}");

      // SUCCESSO (201)
      if (res.statusCode == 201) {
        return (true, null);
      }

      // ERRORE dal backend
      try {
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic>) {
          final msg = decoded["error"]?.toString();
          return (false, msg ?? "Error ${res.statusCode}");
        }
      } catch (_) {}

      return (false, "Error ${res.statusCode}");
    } catch (e) {
      print("[PlantService] Exception: $e");
      return (false, "Exception: $e");
    }
  }


  Future<(bool ok, String? message)> unsharePlant(String sharedPlantId) async {
    try {
      final token = await StorageService.getToken();
      if (token == null || token.trim().isEmpty) {
        return (false, "User not authenticated.");
      }

      final bearer = token.startsWith("Bearer ") ? token : "Bearer $token";
      final uri = Uri.parse("$baseUrl/shared_plant/delete/$sharedPlantId");

      final res = await http.delete(
        uri,
        headers: {
          "Authorization": bearer,
          "Accept": "application/json",
          "Bypass-Tunnel-Reminder": "true",
        },
      );

      print("[PlantService] DELETE /shared_plant/delete status: ${res.statusCode}");

      if (res.statusCode == 204) return (true, null);

      try {
        final err = jsonDecode(res.body);
        return (false, err["error"]?.toString());
      } catch (_) {
        return (false, "Error ${res.statusCode}");
      }
    } catch (e) {
      return (false, "Exception: $e");
    }
  }
}
