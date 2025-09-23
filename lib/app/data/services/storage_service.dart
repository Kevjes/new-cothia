import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _preferences;

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // Authentication
  Future<bool> setIsLoggedIn(bool value) async {
    return await _preferences!.setBool(AppConstants.keyIsLoggedIn, value);
  }

  bool getIsLoggedIn() {
    return _preferences!.getBool(AppConstants.keyIsLoggedIn) ?? false;
  }

  Future<bool> setUserId(String userId) async {
    return await _preferences!.setString(AppConstants.keyUserId, userId);
  }

  String? getUserId() {
    return _preferences!.getString(AppConstants.keyUserId);
  }

  Future<bool> setUserEmail(String email) async {
    return await _preferences!.setString(AppConstants.keyUserEmail, email);
  }

  String? getUserEmail() {
    return _preferences!.getString(AppConstants.keyUserEmail);
  }

  Future<bool> setPersonalEntityId(String entityId) async {
    return await _preferences!.setString(AppConstants.keyPersonalEntityId, entityId);
  }

  String? getPersonalEntityId() {
    return _preferences!.getString(AppConstants.keyPersonalEntityId);
  }

  // First time app launch
  Future<bool> setIsFirstTime(bool value) async {
    return await _preferences!.setBool(AppConstants.keyIsFirstTime, value);
  }

  bool getIsFirstTime() {
    return _preferences!.getBool(AppConstants.keyIsFirstTime) ?? true;
  }

  // Clear all data (logout)
  Future<bool> clearAll() async {
    return await _preferences!.clear();
  }

  // Clear authentication data only
  Future<void> clearAuthData() async {
    await _preferences!.remove(AppConstants.keyIsLoggedIn);
    await _preferences!.remove(AppConstants.keyUserId);
    await _preferences!.remove(AppConstants.keyUserEmail);
    await _preferences!.remove(AppConstants.keyPersonalEntityId);
  }

  // Save user session
  Future<void> saveUserSession({
    required String userId,
    required String email,
    required String personalEntityId,
  }) async {
    await setIsLoggedIn(true);
    await setUserId(userId);
    await setUserEmail(email);
    await setPersonalEntityId(personalEntityId);
  }

  // Get saved user session
  Map<String, String?> getUserSession() {
    return {
      'userId': getUserId(),
      'email': getUserEmail(),
      'personalEntityId': getPersonalEntityId(),
    };
  }

  // Check if user session exists
  bool hasValidSession() {
    final userId = getUserId();
    final email = getUserEmail();
    final personalEntityId = getPersonalEntityId();

    return getIsLoggedIn() &&
           userId != null &&
           email != null &&
           personalEntityId != null;
  }
}