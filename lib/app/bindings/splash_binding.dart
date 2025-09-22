import 'package:get/get.dart';
import '../controllers/splash_controller.dart';
import '../data/services/auth_service.dart';
import '../data/services/theme_service.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // S'assurer que les services sont initialisés
    Get.put<ThemeService>(ThemeService(), permanent: true);
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.put<SplashController>(SplashController());
  }
}