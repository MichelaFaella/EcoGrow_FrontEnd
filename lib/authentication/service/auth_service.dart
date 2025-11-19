import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../utility/storage_service.dart';

class AuthService {
  // Localtunnel (ricordati di tenerlo attivo)
  final String baseUrl = "https://ecogrow.loca.lt/api";

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

  /// Do the login and save the backend token + user info
  Future<(bool ok, String? message)> login({
    required String email,
    required String password,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/auth/login');
      print('[AuthService.login] POST $uri');
      print('[AuthService.login] body req: ${jsonEncode({'email': email.trim(), 'password': '***'})}');

      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email.trim(), 'password': password}),
      );

      print('[AuthService.login] status: ${res.statusCode}');
      print('[AuthService.login] body res: ${res.body}');

      if (res.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(res.body);
        final String? token = body['access_token'] ?? body['token'];
        if (token == null) {
          print('[AuthService.login] ERRORE: token mancante nella risposta');
          return (false, 'Token mancante nella risposta.');
        }

        // Salvo token
        await StorageService.saveToken(_normalizeBearer(token));

        // Provo a salvare anche nome e cognome (se il backend li manda)
        String? firstName;
        String? lastName;

        final user = body['user'];
        if (user is Map<String, dynamic>) {
          firstName = user['first_name']?.toString();
          lastName = user['last_name']?.toString();
        } else {
          firstName = body['first_name']?.toString();
          lastName = body['last_name']?.toString();
        }

        if (firstName != null && lastName != null) {
          await StorageService.saveUserInfo(
            firstName: firstName,
            lastName: lastName,
          );
          print('[AuthService.login] User info salvate: $firstName $lastName');
        } else {
          print('[AuthService.login] Nessun nome/cognome nella risposta');
        }

        print('[AuthService.login] Token salvato correttamente');
        return (true, null);
      } else {
        final extracted = _extractError(res.body);
        if (extracted != null) {
          print('[AuthService.login] ERRORE backend: $extracted');
        } else {
          print(
              '[AuthService.login] ERRORE generico. status: ${res.statusCode}, body: ${res.body}');
        }
        return (false, extracted ?? 'Login fallito (${res.statusCode}).');
      }
    } catch (e) {
      print('[AuthService.login] Eccezione di rete: $e');
      return (false, 'Errore di rete: $e');
    }
  }

  /// Check if the user is authenticated by querying the backend
  Future<bool> isAuthenticated() async {
    final raw = await StorageService.getToken();
    if (raw == null || raw.trim().isEmpty) {
      print('[AuthService.isAuthenticated] Nessun token salvato');
      return false;
    }

    // Assicura "Bearer <token>"
    final authHeader =
    raw.trim().startsWith('Bearer ') ? raw.trim() : 'Bearer ${raw.trim()}';

    try {
      final uri = Uri.parse('$baseUrl/check-auth');
      print('[AuthService.isAuthenticated] GET $uri');
      print('[AuthService.isAuthenticated] Authorization: $authHeader');

      final res = await http.get(
        uri,
        headers: {
          'Authorization': authHeader,
          'Accept': 'application/json',
        },
      );

      print('[AuthService.isAuthenticated] status: ${res.statusCode}');
      print('[AuthService.isAuthenticated] body: ${res.body}');

      if (res.statusCode == 200) {
        print('[AuthService.isAuthenticated] Token valido');
        return true;
      }

      if (res.statusCode == 401 || res.statusCode == 403) {
        print('[AuthService.isAuthenticated] Token non valido/scaduto, lo cancello');
        await StorageService.clearAll();
      }

      return false;
    } catch (e) {
      print('[AuthService.isAuthenticated] Eccezione di rete: $e');
      return false;
    }
  }

  /// Register user, save token + user info
  Future<(bool ok, String? message)> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/user/add');
      print('[AuthService.register] POST $uri');
      print('[AuthService.register] body req: ${jsonEncode({
        'email': email.trim(),
        'password': '***',
        'first_name': firstName,
        'last_name': lastName,
      })}');

      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
        }),
      );

      print('[AuthService.register] status: ${res.statusCode}');
      print('[AuthService.register] body res: ${res.body}');

      if (res.statusCode == 201) {
        final Map<String, dynamic> body = jsonDecode(res.body);
        final String? token = body['access_token'] ?? body['token'];

        if (token == null) {
          print('[AuthService.register] Nessun token in risposta, provo login di fallback');
          final (ok, msg) = await login(email: email, password: password);
          return (ok, msg);
        }

        // Salvo token
        await StorageService.saveToken(_normalizeBearer(token));

        // Nome/cognome: se il backend li rimanda, li uso; altrimenti uso quelli del form
        String? firstNameResp;
        String? lastNameResp;

        final user = body['user'];
        if (user is Map<String, dynamic>) {
          firstNameResp = user['first_name']?.toString();
          lastNameResp = user['last_name']?.toString();
        } else {
          firstNameResp = body['first_name']?.toString();
          lastNameResp = body['last_name']?.toString();
        }

        final String finalFirstName = firstNameResp ?? firstName;
        final String finalLastName = lastNameResp ?? lastName;

        await StorageService.saveUserInfo(
          firstName: finalFirstName,
          lastName: finalLastName,
        );
        print('[AuthService.register] User info salvate: $finalFirstName $finalLastName');

        print('[AuthService.register] Registrazione OK, token salvato');
        return (true, null);
      } else {
        final extracted = _extractError(res.body);
        if (extracted != null) {
          print('[AuthService.register] ERRORE backend: $extracted');
        } else {
          print(
              '[AuthService.register] ERRORE generico. status: ${res.statusCode}, body: ${res.body}');
        }
        return (false, extracted ?? 'Registrazione fallita (${res.statusCode}).');
      }
    } catch (e) {
      print('[AuthService.register] Eccezione di rete: $e');
      return (false, 'Errore di rete: $e');
    }
  }

  /// Remove token + user info locally
  Future<void> logout() async {
    print('[AuthService.logout] Clearing token and user info');
    await StorageService.clearAll();
  }

  /// Delete user via API + clear local storage
  Future<bool> removeUser() async {
    print('[AuthService.removeUser] Deleting user via API');

    // recupero il token salvato
    final raw = await StorageService.getToken();
    if (raw == null || raw.trim().isEmpty) {
      print('[AuthService.removeUser] Nessun token, non chiamo il backend');
      await StorageService.clearAll();
      return true; // lato client risulta comunque "pulito"
    }

    // Assicuro il formato "Bearer <token>"
    final authHeader =
    raw.trim().startsWith('Bearer ') ? raw.trim() : 'Bearer ${raw.trim()}';

    try {
      final uri = Uri.parse('$baseUrl/user/delete');
      print('[AuthService.removeUser] DELETE $uri');

      final res = await http.delete(
        uri,
        headers: {
          'Authorization': authHeader,
          'Accept': 'application/json',
        },
      );

      print('[AuthService.removeUser] status: ${res.statusCode}');
      print('[AuthService.removeUser] body: ${res.body}');

      if (res.statusCode == 204 || res.statusCode == 200) {
        print('[AuthService.removeUser] Utente eliminato lato backend, pulisco storage');
        await StorageService.clearAll();
        return true;
      } else if (res.statusCode == 401 || res.statusCode == 403) {
        print('[AuthService.removeUser] Non autorizzato, pulisco storage lo stesso');
        await StorageService.clearAll();
        return true;
      } else {
        final extracted = _extractError(res.body);
        if (extracted != null) {
          print('[AuthService.removeUser] ERRORE backend: $extracted');
        } else {
          print(
            '[AuthService.removeUser] ERRORE generico. status: ${res.statusCode}, body: ${res.body}',
          );
        }
        return false;
      }
    } catch (e) {
      print('[AuthService.removeUser] Eccezione di rete: $e');
      // errore di rete -> NON cancello lo storage, così l'utente può riprovare
      return false;
    }
  }

}
