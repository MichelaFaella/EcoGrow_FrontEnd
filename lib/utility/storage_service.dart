import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // Token e info utente
  static const _tokenKey = "auth_token";
  static const _firstNameKey = "first_name";
  static const _lastNameKey = "last_name";

  // Flag globale questionario (NON più per utente)
  static const _questionnaireDoneKey = "questionnaire_done";

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
  //                      USER INFO (nome/cognome)
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
  //                     QUESTIONNAIRE FLAG GLOBALE
  // =====================================================================

  /// Imposta se il questionario è stato completato su QUESTO device
  static Future<void> setQuestionnaireDone(bool done) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_questionnaireDoneKey, done);
  }

  /// Ritorna true se il questionario risulta completato su questo device
  static Future<bool> isQuestionnaireDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_questionnaireDoneKey) ?? false;
  }

  /// Pulisce SOLO tutti i flag questionario
  static Future<void> clearQuestionnaireFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_questionnaireDoneKey);
  }

  // =====================================================================
  //                         CLEAR (Logout)
  // =====================================================================

  static Future<void> clearUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_firstNameKey);
    await prefs.remove(_lastNameKey);

    // Se vuoi, puoi anche azzerare il questionario al logout
    // await prefs.remove(_questionnaireDoneKey);
  }

  // =====================================================================
  //                         CLEAR ALL (Delete account)
  // =====================================================================

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
