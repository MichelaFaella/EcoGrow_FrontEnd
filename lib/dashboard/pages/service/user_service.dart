import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../utility/storage_service.dart';
import '../models/user.dart';

class UserService {
  final String baseUrl = 'https://ecogrow.loca.lt/api';

  /// ===============================================================
  ///   GET /user/me
  ///   Ritorna:
  ///     - ok: true/false
  ///     - message: errore (se presente)
  ///     - user: User (se ok == true)
  /// ===============================================================
  Future<(bool ok, String? message, User? user)> getCurrentUser() async {
    try {
      final token = await StorageService.getToken();
      if (token == null || token.trim().isEmpty) {
        return (false, "User not authenticated.", null);
      }

      final bearer = token.startsWith("Bearer ") ? token : "Bearer $token";

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

      return (false, "Error ${res.statusCode}", null);
    } catch (e) {
      return (false, "Exception: $e", null);
    }
  }

  /// ===============================================================
  ///   UPDATE USER
  ///   PUT /user/update/<id>
  ///   Ritorna:
  ///     - ok: true/false
  ///     - message: eventuale errore
  /// ===============================================================
  Future<(bool ok, String? message)> updateUser({
    required String userId,
    String? firstName,
    String? lastName,
    String? email,
    String? password, // opzionale
  }) async {
    try {
      final token = await StorageService.getToken();
      if (token == null || token.trim().isEmpty) {
        return (false, "User not authenticated.");
      }

      final bearer = token.startsWith("Bearer ") ? token : "Bearer $token";

      final uri = Uri.parse("$baseUrl/user/update/$userId");

      final Map<String, dynamic> body = {};

      if (firstName != null) body["first_name"] = firstName;
      if (lastName != null) body["last_name"] = lastName;
      if (email != null) body["email"] = email;

      // la password va inviata solo se l'utente l'ha cambiata
      if (password != null && password.isNotEmpty) {
        body["password"] = password;
      }

      print("[UserService] PUT /user/update/$userId");
      print("[UserService] Body: $body");

      final res = await http.put(
        uri,
        headers: {
          "Authorization": bearer,
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Bypass-Tunnel-Reminder": "true",
        },
        body: jsonEncode(body),
      );

      print("[UserService] Status: ${res.statusCode}");
      print("[UserService] Response: ${res.body}");

      if (res.statusCode == 200) {
        return (true, null);
      }

      try {
        final err = jsonDecode(res.body);
        if (err is Map<String, dynamic>) {
          return (false, err["error"]?.toString());
        }
        return (false, "Error ${res.statusCode}");
      } catch (_) {
        return (false, "Error ${res.statusCode}");
      }
    } catch (e) {
      print("[UserService] Exception PUT /user/update: $e");
      return (false, "Exception: $e");
    }
  }
}
