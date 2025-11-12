import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utility/storage_service.dart';

class AuthService {

  final String baseUrl = "http://127.0.0.1:8000";

  String _normalizeBearer(String token) {
    final t = token.trim();
    return t.startsWith('Bearer ') ? t : 'Bearer $t';
  }

// Prova a leggere "error" dal JSON di risposta
  String? _extractError(String body) {
    try {
      final Map<String, dynamic> m = jsonDecode(body);
      final e = m['error'];
      return e == null ? null : e.toString();
    } catch (_) {
      return null; // non è JSON o non c'è "error"
    }
  }

  /// Do the login and save the backend token
  Future<(bool ok, String? message)> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email.trim(), 'password': password}),
      );

      if (res.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(res.body);
        final String? token = body['access_token'] ?? body['token'];
        if (token == null) return (false, 'Token mancante nella risposta.');
        await StorageService.saveToken(_normalizeBearer(token));
        return (true, null);
      } else {
        return (false, _extractError(res.body) ?? 'Login fallito (${res.statusCode}).');
      }
    } catch (e) {
      return (false, 'Errore di rete: $e');
    }
  }

  /// Check if the user is authenticated by querying the backend
  Future<bool> isAuthenticated() async {
    final raw = await StorageService.getToken();
    if (raw == null || raw.trim().isEmpty) return false;

    // Assicura "Bearer <token>"
    final authHeader = raw.trim().startsWith('Bearer ')
        ? raw.trim()
        : 'Bearer ${raw.trim()}';

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/check-auth'),
        headers: {
          'Authorization': authHeader,
          'Accept': 'application/json',
        },
      );

      if (res.statusCode == 200) return true;

      // opzionale: se il token è scaduto/invalidato, lo puliamo
      if (res.statusCode == 401 || res.statusCode == 403) {
        await StorageService.clearToken();
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<(bool ok, String? message)> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/user/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
        }),
      );

      if (res.statusCode == 201) {
        final Map<String, dynamic> body = jsonDecode(res.body);
        final String? token = body['access_token'] ?? body['token'];
        if (token == null) {
          // fallback: se la register non restituisce token, fai login
          final (ok, msg) = await login(email: email, password: password);
          return (ok, msg);
        }
        await StorageService.saveToken(_normalizeBearer(token));
        return (true, null);
      } else {
        return (false, _extractError(res.body) ?? 'Registrazione fallita (${res.statusCode}).');
      }
    } catch (e) {
      return (false, 'Errore di rete: $e');
    }
  }

  /// Remove token locally
  Future<void> logout() async{
    await StorageService.clearToken();
  }

}
