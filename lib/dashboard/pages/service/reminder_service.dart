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
      print("→ Raw response:");
      print(res.body);

      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        if (body is List) {
          final days = body
              .whereType<Map>() // List<Map>
              .map((e) => e.cast<String, dynamic>())
              .toList();
          return (true, null, days);
        } else {
          return (false, 'Invalid response format from server', null);
        }
      }

      // provo a leggere un error dal server
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
}
