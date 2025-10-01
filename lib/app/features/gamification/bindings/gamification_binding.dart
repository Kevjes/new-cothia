import 'package:get/get.dart';
import '../controllers/gamification_controller.dart';
import '../../../core/gamification/services/gamification_service.dart';
import '../../../core/gamification/services/gamification_integration_service.dart';

class GamificationBinding extends Bindings {
  @override
  void dependencies() {
    // Service de gamification
    Get.lazyPut<GamificationService>(() => GamificationService());

    // Service d'intégration
    Get.lazyPut<GamificationIntegrationService>(() => GamificationIntegrationService());

    // Contrôleur principal
    Get.lazyPut<GamificationController>(() => GamificationController());
  }
}