import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF6B73FF);
  static const Color primaryLight = Color(0xFF9BA3FF);
  static const Color primaryDark = Color(0xFF4C52CC);

  // Secondary colors
  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryLight = Color(0xFF66FFF9);
  static const Color secondaryDark = Color(0xFF00A693);

  // Accent colors
  static const Color accent = Color(0xFFFF6B6B);
  static const Color accentLight = Color(0xFFFF9E9E);
  static const Color accentDark = Color(0xFFCC3838);

  // Success, Warning, Error
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Light theme colors
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightOnBackground = Color(0xFF212121);
  static const Color lightOnSurface = Color(0xFF424242);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);

  // Dark theme colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkOnBackground = Color(0xFFE0E0E0);
  static const Color darkOnSurface = Color(0xFFBDBDBD);
  static const Color darkOnPrimary = Color(0xFFFFFFFF);

  // Neutral colors
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Transparent colors
  static const Color transparent = Colors.transparent;
  static Color primaryWithOpacity(double opacity) => primary.withOpacity(opacity);
  static Color blackWithOpacity(double opacity) => Colors.black.withOpacity(opacity);
  static Color whiteWithOpacity(double opacity) => Colors.white.withOpacity(opacity);

  // Couleurs adaptatives pour le mode sombre
  static Color adaptiveBackground(context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBackground
        : lightBackground;
  }

  static Color adaptiveSurface(context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurface
        : lightSurface;
  }

  static Color adaptiveEmptyStateBackground(context) {
    return Theme.of(context).brightness == Brightness.dark
        ? grey800.withValues(alpha: 0.3)
        : grey100;
  }

  static Color adaptiveEmptyStateBorder(context) {
    return Theme.of(context).brightness == Brightness.dark
        ? grey600.withValues(alpha: 0.3)
        : grey300;
  }

  static Color adaptiveShadow(context) {
    return Theme.of(context).brightness == Brightness.dark
        ? blackWithOpacity(0.3)
        : blackWithOpacity(0.05);
  }
}