import 'package:get/get.dart';
import '../controllers/finance_controller.dart';
import '../controllers/transactions_controller.dart';
import '../controllers/accounts_controller.dart';
import '../controllers/budgets_controller.dart';
import '../controllers/categories_controller.dart';
import '../services/transaction_service.dart';
import '../services/account_service.dart';
import '../services/budget_service.dart';
import '../services/category_service.dart';
import '../../entities/controllers/entities_controller.dart';
import '../../tasks/controllers/tasks_controller.dart';
import '../../tasks/controllers/projects_controller.dart';
import '../../tasks/controllers/task_categories_controller.dart';
import '../../tasks/services/task_service.dart';
import '../../tasks/services/project_service.dart';
import '../../tasks/services/task_category_service.dart';

class FinanceBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure EntitiesController is available
    if (!Get.isRegistered<EntitiesController>()) {
      Get.lazyPut<EntitiesController>(() => EntitiesController());
    }

    // Services de finance
    Get.lazyPut<TransactionService>(() => TransactionService());
    Get.lazyPut<AccountService>(() => AccountService());
    Get.lazyPut<BudgetService>(() => BudgetService());
    Get.lazyPut<CategoryService>(() => CategoryService());

    // Services des tâches (si pas déjà enregistrés)
    if (!Get.isRegistered<TaskService>()) {
      Get.lazyPut<TaskService>(() => TaskService());
    }
    if (!Get.isRegistered<ProjectService>()) {
      Get.lazyPut<ProjectService>(() => ProjectService());
    }
    if (!Get.isRegistered<TaskCategoryService>()) {
      Get.lazyPut<TaskCategoryService>(() => TaskCategoryService());
    }

    // Controllers principaux de finance
    Get.lazyPut<FinanceController>(() => FinanceController());
    Get.lazyPut<TransactionsController>(() => TransactionsController());
    Get.lazyPut<AccountsController>(() => AccountsController());
    Get.lazyPut<BudgetsController>(() => BudgetsController());
    Get.lazyPut<CategoriesController>(() => CategoriesController());

    // Controllers des tâches (si pas déjà enregistrés)
    if (!Get.isRegistered<TasksController>()) {
      Get.lazyPut<TasksController>(() => TasksController());
    }
    if (!Get.isRegistered<ProjectsController>()) {
      Get.lazyPut<ProjectsController>(() => ProjectsController());
    }
    if (!Get.isRegistered<TaskCategoriesController>()) {
      Get.lazyPut<TaskCategoriesController>(() => TaskCategoriesController());
    }
  }
}