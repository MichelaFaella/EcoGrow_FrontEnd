import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _tokenKey = "auth_token";
  static const _firstNameKey = "first_name";
  static const _lastNameKey = "last_name";
  static const _userIdKey = "current_user_id";

  // =====================================================================
  //                           USER ID
  // =====================================================================

  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  static Future<void> clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
  }

  // =====================================================================
  //                             TOKEN
  // =====================================================================

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // =====================================================================
  //                           USER INFO
  // =====================================================================

  static Future<void> saveUserInfo({
    required String firstName,
    required String lastName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_firstNameKey, firstName);
    await prefs.setString(_lastNameKey, lastName);
  }

  static Future<String?> getFirstName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_firstNameKey);
  }

  static Future<String?> getLastName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastNameKey);
  }

  // =====================================================================
  //                     QUESTIONNAIRE FLAG PER UTENTE
  // =====================================================================

  static Future<void> setQuestionnaireDoneForUser(String userId, bool done) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("questionnaire_done_user_$userId", done);
  }

  static Future<bool> isQuestionnaireDoneForUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("questionnaire_done_user_$userId") ?? false;
  }

  // Cancella SOLO i flag questionari di tutti gli utenti
  static Future<void> clearAllQuestionnaireFlags() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    for (final key in keys) {
      if (key.startsWith("questionnaire_done_user_")) {
        await prefs.remove(key);
      }
    }
  }

  // =====================================================================
  //                         CLEAR (Logout)
  // =====================================================================

  static Future<void> clearUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_firstNameKey);
    await prefs.remove(_lastNameKey);
    await prefs.remove(_userIdKey);
  }

  // =====================================================================
  //                         CLEAR ALL (Delete account)
  // =====================================================================

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
