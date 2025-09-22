import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/auth_service.dart';
import '../../routes/app_pages.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();

    // Si l'utilisateur est connecté et essaie d'accéder à la page d'auth
    if (authService.isLoggedIn && route == Routes.AUTH) {
      return RouteSettings(name: Routes.HOME);
    }

    // Si l'utilisateur n'est pas connecté et essaie d'accéder à une page protégée
    if (!authService.isLoggedIn && route != Routes.AUTH) {
      return RouteSettings(name: Routes.AUTH);
    }

    return null;
  }
}

class HomeMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();

    // Rediriger vers auth si pas connecté
    if (!authService.isLoggedIn) {
      return RouteSettings(name: Routes.AUTH);
    }

    return null;
  }
}