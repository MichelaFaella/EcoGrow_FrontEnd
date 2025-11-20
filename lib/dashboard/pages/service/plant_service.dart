import 'dart:convert';
import 'dart:io';

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
}
