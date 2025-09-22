import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../routes/app_pages.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    // Utiliser onReady pour s'assurer que tout est initialisé
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    try {
      // Attendre que Firebase soit prêt
      await Future.delayed(const Duration(milliseconds: 1500));

      // Vérifier l'état de connexion
      await _checkAuthAndNavigate();
    } catch (e) {
      print('Erreur dans splash: $e');
      // En cas d'erreur, aller vers auth par défaut
      _navigateToAuth();
    }
  }

  Future<void> _checkAuthAndNavigate() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        print('Utilisateur connecté: ${currentUser.uid}');
        _navigateToHome();
      } else {
        print('Aucun utilisateur connecté');
        _navigateToAuth();
      }
    } catch (e) {
      print('Erreur vérification auth: $e');
      _navigateToAuth();
    }
  }

  void _navigateToHome() {
    Get.offAllNamed(Routes.HOME);
  }

  void _navigateToAuth() {
    Get.offAllNamed(Routes.AUTH);
  }
}