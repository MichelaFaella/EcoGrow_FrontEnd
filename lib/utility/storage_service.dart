import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _tokenKey = "auth_token";
  static const _firstNameKey = "first_name";
  static const _lastNameKey = "last_name";

  // 🔥 il flag originario che NON cambiamo
  static const _questionnaireDoneKey = "questionnaire_done";


  // ========== TOKEN ==========
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


  // ========== USER INFO ==========
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


  // ========== QUESTIONNAIRE FLAG ==========
  // NON cambiamo nome alla funzione!
  static Future<void> setQuestionnaireDone(bool done) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_questionnaireDoneKey, done);
  }

  // NON cambiamo nome alla funzione!
  static Future<bool> isQuestionnaireDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_questionnaireDoneKey) ?? false;
  }

  // NON cambiamo nome alla funzione!
  static Future<void> clearQuestionnaireFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_questionnaireDoneKey);
  }


  // ========== CLEAR ==========
  // NON cambiamo nome, ma qui NON dobbiamo toccare il flag
  static Future<void> clearUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_firstNameKey);
    await prefs.remove(_lastNameKey);
  }

  // NON cambiamo nome, ma qui dobbiamo cancellare TUTTO (delete account)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();  // 🔥 reset totale
  }
}
