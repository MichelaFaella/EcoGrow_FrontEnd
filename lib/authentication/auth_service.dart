import 'dart:convert';
import 'package:ecogrow_frontend/utility/storage_service.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {

  final String baseUrl = "http://127.0.0.1:5000";

  /// Do the login and save the backend token
  Future<bool> login(String email, String password) async{
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data ["token"];
      if (token != null) {
        await StorageService.saveToken(token);
        return true;
      }
    }
    return false;
  }

  /// Check if the user is authenticated by querying the backend
  Future<bool> isAuthenticated() async{
    final token = await StorageService.getToken();
    if (token == null)
      return false;

    try{
      final response = await http.get(
        Uri.parse("$baseUrl/check-auth"),
        headers: {'Authorization': token}
      );
      return response.statusCode == 200;
    }catch(_){
      return false;
    }
  }

  /// Remove token locally
  Future<void> logout() async{
    await StorageService.clearToken();
  }

}
