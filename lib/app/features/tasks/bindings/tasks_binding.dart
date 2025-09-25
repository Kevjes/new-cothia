import 'package:get/get.dart';
import '../services/task_service.dart';
import '../services/task_category_service.dart';
import '../services/project_service.dart';
import '../controllers/tasks_controller.dart';
import '../controllers/projects_controller.dart';
import '../controllers/task_categories_controller.dart';
import '../../entities/controllers/entities_controller.dart';

class TasksBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure EntitiesController is available
    if (!Get.isRegistered<EntitiesController>()) {
      Get.lazyPut<EntitiesController>(() => EntitiesController());
    }

    // Services
    Get.lazyPut<TaskService>(() => TaskService());
    Get.lazyPut<TaskCategoryService>(() => TaskCategoryService());
    Get.lazyPut<ProjectService>(() => ProjectService());

    // Controllers
    Get.lazyPut<TasksController>(() => TasksController());
    Get.lazyPut<ProjectsController>(() => ProjectsController());
    Get.lazyPut<TaskCategoriesController>(() => TaskCategoriesController());
  }
}