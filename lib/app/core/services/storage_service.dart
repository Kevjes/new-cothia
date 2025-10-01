import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService {
  late SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  /// Sauvegarde une chaîne de caractères
  Future<bool> writeString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  /// Lit une chaîne de caractères
  String? readString(String key) {
    return _prefs.getString(key);
  }

  /// Sauvegarde un entier
  Future<bool> writeInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  /// Lit un entier
  int? readInt(String key) {
    return _prefs.getInt(key);
  }

  /// Sauvegarde un double
  Future<bool> writeDouble(String key, double value) async {
    return await _prefs.setDouble(key, value);
  }

  /// Lit un double
  double? readDouble(String key) {
    return _prefs.getDouble(key);
  }

  /// Sauvegarde un booléen
  Future<bool> writeBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  /// Lit un booléen
  bool? readBool(String key) {
    return _prefs.getBool(key);
  }

  /// Sauvegarde une liste de chaînes
  Future<bool> writeStringList(String key, List<String> value) async {
    return await _prefs.setStringList(key, value);
  }

  /// Lit une liste de chaînes
  List<String>? readStringList(String key) {
    return _prefs.getStringList(key);
  }

  /// Supprime une clé
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  /// Vérifie si une clé existe
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  /// Efface toutes les données
  Future<bool> clear() async {
    return await _prefs.clear();
  }

  /// Récupère toutes les clés
  Set<String> getKeys() {
    return _prefs.getKeys();
  }

  /// Récupère l'ID utilisateur actuel
  String? getUserId() {
    return readString('current_user_id');
  }

  /// Sauvegarde l'ID utilisateur actuel
  Future<bool> setUserId(String userId) async {
    return await writeString('current_user_id', userId);
  }

  /// Supprime l'ID utilisateur actuel
  Future<bool> clearUserId() async {
    return await remove('current_user_id');
  }
}