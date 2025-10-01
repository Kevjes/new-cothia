import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../../../features/finance/controllers/finance_controller.dart';
import '../../../features/tasks/controllers/tasks_controller.dart';
import '../../../features/entities/controllers/entities_controller.dart';
import '../../../features/habits/controllers/habits_controller.dart';
import '../../../features/suggestions/controllers/suggestions_controller.dart';
import '../../../core/services/suggestions_service.dart';
import '../../../core/services/synchronization_service.dart';
import '../../../features/tasks/services/task_service.dart';
import '../../../features/habits/services/habit_service.dart';
import '../../../core/gamification/services/gamification_service.dart';
import '../../../core/gamification/services/gamification_integration_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../features/finance/services/advanced_automation_service.dart';
import '../../../features/finance/services/automation_execution_engine.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );

    // Initialize core services first
    Get.putAsync<StorageService>(
      () => StorageService().init(),
      permanent: true,
    );

    Get.lazyPut<TaskService>(
      () => TaskService(),
      fenix: true,
    );
    Get.lazyPut<HabitService>(
      () => HabitService(),
      fenix: true,
    );

    // Initialize all module controllers for the dashboard
    Get.lazyPut<FinanceController>(
      () => FinanceController(),
    );
    Get.lazyPut<TasksController>(
      () => TasksController(),
    );
    Get.lazyPut<EntitiesController>(
      () => EntitiesController(),
    );
    Get.lazyPut<HabitsController>(
      () => HabitsController(),
    );

    // Initialize suggestions service and controller
    Get.lazyPut<SuggestionsService>(
      () => SuggestionsService(),
      fenix: true,
    );
    Get.lazyPut<SuggestionsController>(
      () => SuggestionsController(),
    );

    // Initialize synchronization service
    Get.lazyPut<SynchronizationService>(
      () => SynchronizationService(),
      fenix: true,
    );

    // Initialize gamification services
    Get.lazyPut<GamificationService>(
      () => GamificationService(),
      fenix: true,
    );
    Get.lazyPut<GamificationIntegrationService>(
      () => GamificationIntegrationService(),
      fenix: true,
    );

    // Initialize automation services
    Get.lazyPut<AdvancedAutomationService>(
      () => AdvancedAutomationService(),
      fenix: true,
    );
    Get.put<AutomationExecutionEngine>(
      AutomationExecutionEngine(),
      permanent: true,
    );

    // L'AuthController est maintenant géré par le SplashController
    // Ne plus le créer ici pour éviter les boucles infinies
  }
}
