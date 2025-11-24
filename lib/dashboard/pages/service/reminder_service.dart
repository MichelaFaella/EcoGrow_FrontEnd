import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../authentication/service/auth_service.dart';
import '../../../utility/storage_service.dart';

class ReminderService {
  // Riutilizziamo la stessa baseUrl dell'AuthService
  final String baseUrl = AuthService().baseUrl;

  String _normalizeBearer(String token) {
    final t = token.trim();
    return t.startsWith('Bearer ') ? t : 'Bearer $t';
  }

  /// Scarica tutti i watering plan dell'utente loggato
  /// in formato adatto al calendario.
  ///
  /// Ritorna:
  /// (ok, message, events)
  ///   - ok: true/false
  ///   - message: eventuale errore
  ///   - events: List<Map<String, dynamic>> con campi:
  ///       id, plant_id, plant_name, title, start, interval_days, notes
  Future<(bool ok, String? message, List<Map<String, dynamic>>?)>
  fetchWateringPlansForCalendar() async {
    try {
      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) {
        return (false, 'Not authenticated', null);
      }

      final uri =
      Uri.parse('$baseUrl/watering_plan/calendar-export');

      final res = await http.get(
        uri,
        headers: {
          'Authorization': _normalizeBearer(token),
          'Accept': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        if (body is List) {
          final events = body
              .whereType<Map<String, dynamic>>()
              .toList();
          return (true, null, events);
        } else {
          return (false, 'Invalid response format from server', null);
        }
      }

      // Provo a estrarre un messaggio "error" dal body
      try {
        final body = json.decode(res.body);
        if (body is Map && body['error'] is String) {
          return (false, body['error'] as String, null);
        }
      } catch (_) {}

      return (
      false,
      'Server error: ${res.statusCode}',
      null,
      );
    } catch (e) {
      return (false, 'Network error: $e', null);
    }
  }

  /// Overview settimanale per la pagina di innaffiatura
  ///
  /// Chiama: GET /watering/overview
  ///
  /// Ritorna:
  ///   (ok, message, days)
  /// dove `days` è una lista di mappe:
  ///   {
  ///     "date": "2025-11-29",
  ///     "plants_count": 4,
  ///     "plants": [ { .. per-card .. }, ... ]
  ///   }
  Future<(bool ok, String? message, List<Map<String, dynamic>>?)>
  fetchWeeklyWateringOverview() async {
    try {
      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) {
        return (false, 'Not authenticated', null);
      }

      final uri = Uri.parse('$baseUrl/watering/overview');

      final res = await http.get(
        uri,
        headers: {
          'Authorization': _normalizeBearer(token),
          'Accept': 'application/json',
        },
      );

      print("→ Status: ${res.statusCode}");
      print("→ Raw response START");
      print(res.body);
      print("→ Raw response END");

      // --------------------------
      // DEBUG FOTO BASE64
      // --------------------------
      try {
        final decoded = json.decode(res.body);
        if (decoded is List) {
          print("→ DEBUG FOTO BASE64:");
          for (final day in decoded) {
            final plants = day["plants"] ?? [];
            for (final p in plants) {
              final name = p["plant_name"];
              final base64 = p["photo_base64"];

              print("  • Pianta: $name");
              print("    photo_base64 exists? ${base64 != null}");
              if (base64 != null) {
                print("    length: ${base64.length}");
                final preview = base64.length > 50 ? base64.substring(0, 50) : base64;
                print("    preview: $preview");
              }
            }
          }
        }
      } catch (e) {
        print("Errore debug base64: $e");
      }

      // --------------------------

      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        if (body is List) {
          final days = body
              .whereType<Map>()
              .map((e) => e.cast<String, dynamic>())
              .toList();
          return (true, null, days);
        } else {
          return (false, 'Invalid response format from server', null);
        }
      }

      try {
        final body = json.decode(res.body);
        if (body is Map && body['error'] is String) {
          return (false, body['error'] as String, null);
        }
      } catch (_) {}

      return (false, 'Server error: ${res.statusCode}', null);
    } catch (e) {
      return (false, 'Network error: $e', null);
    }
  }

  Future<(bool ok, String?)> undoWatering(String plantId) async {
    try {
      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) {
        return (false, "Not authenticated");
      }

      final uri = Uri.parse("$baseUrl/plant/$plantId/watering/undo");

      final res = await http.post(
        uri,
        headers: {
          "Authorization": _normalizeBearer(token),
          "Content-Type": "application/json",
        },
      );

      if (res.statusCode == 200) {
        return (true, null);
      }

      final body = jsonDecode(res.body);
      final String? msg = (body is Map && body["error"] is String)
          ? body["error"] as String
          : "Server error";

      return (false, msg);
    } catch (e) {
      return (false, "Network error: $e");
    }
  }


  Future<(bool ok, String? message, Map<String, dynamic>?)> doWatering({
    required String plantId,
    required int amountMl,
    String? note,
  }) async {
    try {
      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) {
        return (false, "Not authenticated", null);
      }

      final uri = Uri.parse("$baseUrl/plant/$plantId/watering/do");

      final res = await http.post(
        uri,
        headers: {
          "Authorization": _normalizeBearer(token),
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "amount_ml": amountMl,
          if (note != null) "note": note,
          "done_at": DateTime.now().toIso8601String(),
        }),
      );

      print("→ watering/do STATUS: ${res.statusCode}");
      print("→ watering/do RAW: ${res.body}");

      if (res.statusCode == 200) {
        return (true, null, jsonDecode(res.body) as Map<String, dynamic>);
      } else {
        final decoded = jsonDecode(res.body);

        final String? errorMsg =
        (decoded is Map && decoded["error"] is String)
            ? decoded["error"] as String
            : "Server error";

        return (false, errorMsg, null);
      }
    } catch (e) {
      return (false, "Network error: $e", null);
    }
  }


}
