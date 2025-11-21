import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../utility/storage_service.dart';
import '../models/user.dart';

class UserService {
  final String baseUrl = 'https://ecogrow.loca.lt/api';

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

  Future<(bool ok, String? message)> updateUser({
    String? firstName,
    String? lastName,
    String? email,
    String? password,
  }) async {
    try {
      final token = await StorageService.getToken();
      if (token == null || token
          .trim()
          .isEmpty) {
        return (false, "User not authenticated.");
      }

      final uri = Uri.parse("$baseUrl/user/update");

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
          "Authorization": token.startsWith("Bearer ")
              ? token
              : "Bearer $token",
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
        return (false, decoded["error"]?.toString());
      } catch (e) {
        return (false, "Error ${res.statusCode}");
      }
    } catch (e) {
      return (false, "Exception: $e");
    }
  }
}
