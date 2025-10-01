import 'package:get/get.dart';
import '../controllers/automation_controller.dart';
import '../services/automation_service.dart';
import '../services/advanced_automation_service.dart';
import '../services/automation_execution_engine.dart';

class AutomationBinding extends Bindings {
  @override
  void dependencies() {
    // Legacy automation service (pour compatibilité)
    Get.lazyPut<AutomationService>(() => AutomationService());

    // Nouveau système d'automatisation avancé
    Get.lazyPut<AdvancedAutomationService>(() => AdvancedAutomationService());
    Get.lazyPut<AutomationExecutionEngine>(() => AutomationExecutionEngine());

    // Controller principal
    Get.lazyPut<AutomationController>(() => AutomationController());
  }
}