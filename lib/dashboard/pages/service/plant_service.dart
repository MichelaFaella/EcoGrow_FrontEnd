import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../../../utility/storage_service.dart';

class PlantService {
  final String baseUrl = "https://ecogrow.loca.lt/api";

  Future<(bool ok, String? message, Map<String, dynamic>? data)> createPlant({
    required File imageFile,
  }) async {
    try {
      final token = await StorageService.getToken();
      if (token == null || token.trim().isEmpty) {
        return (false, "User not authenticated.", null as Map<String, dynamic>?);
      }

      final bearer = token.startsWith("Bearer ") ? token : "Bearer $token";

      // ====================================================
      // COMPRESSIONE IMMAGINE (WebP → migliore qualità/peso)
      // ====================================================
      print("[PlantService] Original size: ${await imageFile.length()} bytes");

      final compressed = await FlutterImageCompress.compressWithFile(
        imageFile.path,
        format: CompressFormat.webp,
        minWidth: 1280,
        minHeight: 1280,
        quality: 70,
      );

      if (compressed == null) {
        return (false, "Image compression failed.", null as Map<String, dynamic>?);
      }

      print("[PlantService] Compressed size: ${compressed.length} bytes");

      // ====================================================
      // Converto in Base64
      // ====================================================
      final imageB64 = base64Encode(compressed);
      print("[PlantService] Base64 length: ${imageB64.length}");

      final uri = Uri.parse("$baseUrl/plant/add");

      final res = await http.post(
        uri,
        headers: {
          "Authorization": bearer,
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Bypass-Tunnel-Reminder": "true",
        },
        body: jsonEncode({"image": imageB64}),
      );

      print("[PlantService] Status: ${res.statusCode}");
      print("[PlantService] Body: ${res.body}");

      if (res.statusCode == 201) {
        final decoded =
        jsonDecode(res.body) as Map<String, dynamic>; // 👈 cast esplicito
        return (true, null, decoded);
      }

      try {
        final err =
        jsonDecode(res.body) as Map<String, dynamic>; // 👈 cast esplicito
        return (false, err["error"]?.toString(), null as Map<String, dynamic>?);
      } catch (_) {
        return (false, "Error ${res.statusCode}", null as Map<String, dynamic>?);
      }
    } catch (e) {
      print("[PlantService] Exception: $e");
      return (false, "Exception: $e", null as Map<String, dynamic>?);
    }
  }
}
