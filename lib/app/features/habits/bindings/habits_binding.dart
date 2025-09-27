import 'package:get/get.dart';
import '../controllers/habits_controller.dart';
import '../controllers/routines_controller.dart';
import '../services/habit_service.dart';
import '../services/routine_service.dart';

class HabitsBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.lazyPut<HabitService>(() => HabitService());
    Get.lazyPut<RoutineService>(() => RoutineService());

    // Controllers
    Get.lazyPut<HabitsController>(() => HabitsController());
    Get.lazyPut<RoutinesController>(() => RoutinesController());
  }
}

class HabitsDetailBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure habits controller is available for details page
    if (!Get.isRegistered<HabitsController>()) {
      Get.lazyPut<HabitService>(() => HabitService());
      Get.lazyPut<HabitsController>(() => HabitsController());
    }
  }
}

class RoutinesDetailBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure routines controller is available for details page
    if (!Get.isRegistered<RoutinesController>()) {
      Get.lazyPut<RoutineService>(() => RoutineService());
      Get.lazyPut<RoutinesController>(() => RoutinesController());
    }
  }
}