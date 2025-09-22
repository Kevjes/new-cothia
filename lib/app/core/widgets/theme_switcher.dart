import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/services/theme_service.dart';
import '../theme/app_colors.dart';

class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final themeService = ThemeService.to;
      return PopupMenuButton<ThemeMode>(
        icon: Icon(
          themeService.isDarkMode ? Icons.dark_mode : Icons.light_mode,
          color: AppColors.primary,
        ),
        onSelected: (ThemeMode mode) {
          themeService.setThemeMode(mode);
        },
        itemBuilder: (BuildContext context) => [
          PopupMenuItem(
            value: ThemeMode.light,
            child: Row(
              children: [
                Icon(
                  Icons.light_mode,
                  color: themeService.themeMode == ThemeMode.light
                      ? AppColors.primary
                      : AppColors.grey600,
                ),
                const SizedBox(width: 12),
                Text('Clair'),
              ],
            ),
          ),
          PopupMenuItem(
            value: ThemeMode.dark,
            child: Row(
              children: [
                Icon(
                  Icons.dark_mode,
                  color: themeService.themeMode == ThemeMode.dark
                      ? AppColors.primary
                      : AppColors.grey600,
                ),
                const SizedBox(width: 12),
                Text('Sombre'),
              ],
            ),
          ),
          PopupMenuItem(
            value: ThemeMode.system,
            child: Row(
              children: [
                Icon(
                  Icons.settings_suggest,
                  color: themeService.themeMode == ThemeMode.system
                      ? AppColors.primary
                      : AppColors.grey600,
                ),
                const SizedBox(width: 12),
                Text('Système'),
              ],
            ),
          ),
        ],
      );
    });
  }
}