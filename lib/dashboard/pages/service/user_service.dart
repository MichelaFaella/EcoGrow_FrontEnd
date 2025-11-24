import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../utility/storage_service.dart';
import '../models/user.dart';

class UserService {
  final String baseUrl = 'https://ecogrow.loca.lt/api';

  // ======================
  // Helpers
  // ======================

  String _normalizeBearer(String token) {
    final t = token.trim();
    return t.startsWith('Bearer ') ? t : 'Bearer $t';
  }

  String? _extractError(String body) {
    try {
      final Map<String, dynamic> m = jsonDecode(body);
      final e = m['error'];
      return e == null ? null : e.toString();
    } catch (_) {
      return null;
    }
  }

  // ======================
  // Get utente corrente
  // ======================

  Future<(bool ok, String? message, User? user)> getCurrentUser() async {
    try {
      final token = await StorageService.getToken();
      if (token == null || token.trim().isEmpty) {
        return (false, "User not authenticated.", null);
      }

      final bearer = _normalizeBearer(token);
      final uri = Uri.parse("$baseUrl/user/me");

      final res = await http.get(
        uri,
        headers: {
          "Authorization": bearer,
          "Accept": "application/json",
          "Bypass-Tunnel-Reminder": "true",
        },
      );

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        return (true, null, User.fromJson(decoded));
      }

      final extracted = _extractError(res.body);
      return (false, extracted ?? "Error ${res.statusCode}", null);
    } catch (e) {
      return (false, "Exception: $e", null);
    }
  }

  // ======================
  // Delete utente corrente
  // ======================

  Future<bool> removeUser() async {
    print('[UserService.removeUser] Deleting user via API');

    // recupero il token salvato
    final raw = await StorageService.getToken();
    if (raw == null || raw.trim().isEmpty) {
      print('[UserService.removeUser] Nessun token, non chiamo il backend');
      await StorageService.clearAll();
      return true; // lato client risulta comunque "pulito"
    }

    // Assicuro il formato "Bearer <token>"
    final authHeader = _normalizeBearer(raw);

    try {
      final uri = Uri.parse('$baseUrl/user/delete-me');
      print('[UserService.removeUser] DELETE $uri');

      final res = await http.delete(
        uri,
        headers: {
          'Authorization': authHeader,
          'Accept': 'application/json',
          'Bypass-Tunnel-Reminder': 'true',
        },
      );

      print('[UserService.removeUser] status: ${res.statusCode}');
      print('[UserService.removeUser] body: ${res.body}');

      if (res.statusCode == 204 || res.statusCode == 200) {
        print('[UserService.removeUser] Utente eliminato lato backend, pulisco storage');
        await StorageService.clearAll();
        return true;
      } else if (res.statusCode == 401 || res.statusCode == 403) {
        print('[UserService.removeUser] Non autorizzato, pulisco storage lo stesso');
        await StorageService.clearAll();
        return true;
      } else {
        final extracted = _extractError(res.body);
        if (extracted != null) {
          print('[UserService.removeUser] ERRORE backend: $extracted');
        } else {
          print(
            '[UserService.removeUser] ERRORE generico. '
                'status: ${res.statusCode}, body: ${res.body}',
          );
        }
        return false;
      }
    } catch (e) {
      print('[UserService.removeUser] Eccezione di rete: $e');
      // errore di rete -> NON cancello lo storage, così l'utente può riprovare
      return false;
    }
  }

  // ======================
  // Update utente
  // ======================

  Future<(bool ok, String? message)> updateUser({
    String? firstName,
    String? lastName,
    String? email,
    String? password,
  }) async {
    try {
      final token = await StorageService.getToken();
      if (token == null || token.trim().isEmpty) {
        return (false, "User not authenticated.");
      }

      final uri = Uri.parse("$baseUrl/user/update");
      final bearer = _normalizeBearer(token);

      final Map<String, dynamic> body = {};

      if (firstName != null) body["first_name"] = firstName;
      if (lastName != null) body["last_name"] = lastName;
      if (email != null) body["email"] = email;

      if (password != null && password.isNotEmpty) {
        body["password"] = password;
      }

      final res = await http.patch(
        uri,
        headers: {
          "Authorization": bearer,
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Bypass-Tunnel-Reminder": "true",
        },
        body: jsonEncode(body),
      );

      if (res.statusCode == 200) return (true, null);

      // errors
      try {
        final decoded = jsonDecode(res.body);
        final msg = decoded["error"]?.toString();
        return (false, msg ?? "Error ${res.statusCode}");
      } catch (e) {
        return (false, "Error ${res.statusCode}");
      }
    } catch (e) {
      return (false, "Exception: $e");
    }
  }

  // ======================
// Ottieni short_id + lista amici
// ======================

  Future<(bool ok, String? error, String? shortId, List<dynamic>? friends)>
  getFriendshipSummary() async {
    try {
      final token = await StorageService.getToken();
      if (token == null || token.trim().isEmpty) {
        return (false, "User not authenticated.", null, null);
      }

      final bearer = _normalizeBearer(token);
      final uri = Uri.parse("$baseUrl/friendship/summary");

      final res = await http.get(
        uri,
        headers: {
          "Authorization": bearer,
          "Accept": "application/json",
          "Bypass-Tunnel-Reminder": "true",
        },
      );

      print("[UserService.getFriendshipSummary] status=${res.statusCode}");
      print("[UserService.getFriendshipSummary] body=${res.body}");

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final shortId = decoded["short_id"]?.toString();
        final friends = decoded["my_friends"] as List<dynamic>;
        return (true, null, shortId, friends);
      }

      final extracted = _extractError(res.body);
      return (false, extracted ?? "Error ${res.statusCode}", null, null);
    } catch (e) {
      return (false, "Exception: $e", null, null);
    }
  }


  Future<(bool ok, String? error)> addFriendByShortId(String shortId) async {
    try {
      if (shortId.trim().isEmpty) {
        return (false, "Short ID cannot be empty");
      }

      final token = await StorageService.getToken();
      if (token == null || token.trim().isEmpty) {
        return (false, "Not authenticated");
      }

      final uri = Uri.parse("$baseUrl/friendship/add-by-short");
      final auth = _normalizeBearer(token);

      print("[UserService.addFriendByShortId] POST → $uri  short_id=$shortId");

      final res = await http.post(
        uri,
        headers: {
          "Authorization": auth,
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Bypass-Tunnel-Reminder": "true",
        },
        body: jsonEncode({"short_id": shortId.trim()}),
      );

      print("[UserService.addFriendByShortId] status=${res.statusCode}");
      print("[UserService.addFriendByShortId] body=${res.body}");

      // -------- SUCCESS --------
      if (res.statusCode == 201) {
        return (true, null);
      }

      // -------- PARSE ERROR --------
      try {
        final decoded = jsonDecode(res.body);
        final msg = decoded["error"]?.toString();
        return (false, msg ?? "Error ${res.statusCode}");
      } catch (_) {
        return (false, "Error ${res.statusCode}: ${res.reasonPhrase}");
      }
    } catch (e) {
      print("[UserService.addFriendByShortId] Exception → $e");
      return (false, "Exception: $e");
    }
  }

  // ======================
// DELETE FRIENDSHIP
// ======================
  Future<(bool ok, String? error)> deleteFriendship(String fid) async {
    try {
      final token = await StorageService.getToken();
      if (token == null || token.trim().isEmpty) {
        return (false, "Not authenticated");
      }

      final uri = Uri.parse("$baseUrl/friendship/delete/$fid");
      final auth = _normalizeBearer(token);

      final res = await http.delete(
        uri,
        headers: {
          "Authorization": auth,
          "Accept": "application/json",
          "Bypass-Tunnel-Reminder": "true",
        },
      );

      if (res.statusCode == 204) return (true, null);

      final decoded = jsonDecode(res.body);
      return (false, decoded["error"]?.toString() ?? "Error ${res.statusCode}");
    } catch (e) {
      return (false, "Exception: $e");
    }
  }
}
