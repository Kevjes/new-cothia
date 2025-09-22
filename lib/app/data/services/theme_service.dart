import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class ThemeService extends GetxService {
  static ThemeService get to => Get.find<ThemeService>();

  final _themeMode = ThemeMode.system.obs;
  late SharedPreferences _prefs;

  ThemeMode get themeMode => _themeMode.value;
  bool get isDarkMode => _themeMode.value == ThemeMode.dark ||
      (_themeMode.value == ThemeMode.system &&
       Get.isPlatformDarkMode);

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initPrefs();
    _loadTheme();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  void _loadTheme() {
    final savedTheme = _prefs.getString(AppConstants.themeKey);
    if (savedTheme != null) {
      _themeMode.value = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == savedTheme,
        orElse: () => ThemeMode.system,
      );
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode.value = mode;
    await _prefs.setString(AppConstants.themeKey, mode.toString());
    Get.changeThemeMode(mode);
  }

  Future<void> toggleTheme() async {
    if (_themeMode.value == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else if (_themeMode.value == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      // Si c'est system, on bascule vers le contraire du thème actuel
      final newMode = Get.isPlatformDarkMode ? ThemeMode.light : ThemeMode.dark;
      await setThemeMode(newMode);
    }
  }

  Future<void> setSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }

  String get currentThemeName {
    switch (_themeMode.value) {
      case ThemeMode.light:
        return 'Clair';
      case ThemeMode.dark:
        return 'Sombre';
      case ThemeMode.system:
        return 'Système';
    }
  }
}