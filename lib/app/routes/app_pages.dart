import 'package:get/get.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../features/auth/bindings/auth_binding.dart';
import '../features/auth/views/pages/login_page.dart';
import '../features/auth/views/pages/signup_page.dart';
import '../features/splash/bindings/splash_binding.dart';
import '../features/splash/views/pages/splash_page.dart';
import '../features/entities/bindings/entities_binding.dart';
import '../features/entities/views/pages/entities_main_page.dart';
import '../features/finance/bindings/finance_binding.dart';
import '../features/finance/views/pages/finance_main_page.dart';
import '../features/finance/views/pages/transactions/transactions_list_page.dart';
import '../features/finance/views/pages/transactions/transaction_create_page.dart';
import '../features/finance/views/pages/transactions/transaction_details_page.dart';
import '../features/finance/views/pages/accounts/accounts_list_page.dart';
import '../features/finance/views/pages/accounts/account_create_page.dart';
import '../features/finance/views/pages/accounts/account_details_page.dart';
import '../features/finance/views/pages/budgets/budgets_list_page.dart';
import '../features/finance/views/pages/budgets/budget_create_page.dart';
import '../features/finance/views/pages/budgets/budget_details_page.dart';
import '../features/finance/views/pages/categories/categories_list_page.dart';
import '../features/finance/views/pages/objectives/objectives_list_page.dart';
import '../features/finance/views/pages/analytics/finance_analytics_page.dart';
import '../features/finance/views/pages/automation/automation_dashboard_page.dart';
import '../features/finance/bindings/automation_binding.dart';
import '../features/tasks/bindings/tasks_binding.dart';
import '../features/tasks/views/pages/tasks_main_page.dart';
import '../features/tasks/views/pages/tasks_list_page.dart';
import '../features/tasks/views/pages/task_create_page.dart';
import '../features/tasks/views/pages/task_details_page.dart';
import '../features/tasks/views/pages/projects/projects_list_page.dart';
import '../features/tasks/views/pages/projects/project_create_page.dart';
import '../features/tasks/views/pages/projects/project_details_page.dart';
import '../features/tasks/views/pages/projects/project_edit_page.dart';
import '../features/tasks/views/pages/categories/categories_list_page.dart';
import '../features/tasks/views/pages/categories/category_create_page.dart';
import '../features/tasks/views/pages/categories/category_edit_page.dart';
import '../features/tasks/views/pages/categories/category_details_page.dart';
import '../features/tasks/views/pages/tags/tags_list_page.dart';
import '../features/tasks/views/pages/recurring/recurring_tasks_page.dart';
import '../features/tasks/views/pages/analytics/tasks_analytics_page.dart';
import '../features/habits/bindings/habits_binding.dart';
import '../features/habits/views/pages/habits_main_page.dart';
import '../features/habits/views/pages/habits_list_page.dart';
import '../features/habits/views/pages/habit_form_page.dart';
import '../features/habits/views/pages/habit_details_page.dart';
import '../features/habits/views/pages/routines_list_page.dart';
import '../features/habits/views/pages/routine_form_page.dart';
import '../features/habits/views/pages/routine_details_page.dart';
import '../features/habits/views/pages/routine_start_page.dart';
import '../features/suggestions/bindings/suggestions_binding.dart';
import '../features/suggestions/views/pages/suggestions_page.dart';
import '../features/gamification/bindings/gamification_binding.dart';
import '../features/gamification/views/pages/gamification_main_page.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.SIGNUP,
      page: () => const SignupPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.ENTITIES,
      page: () => const EntitiesMainPage(),
      binding: EntitiesBinding(),
    ),
    GetPage(
      name: _Paths.FINANCE,
      page: () => const FinanceMainPage(),
      binding: FinanceBinding(),
    ),

    // Finance sub-pages
    GetPage(
      name: _Paths.FINANCE_TRANSACTIONS,
      page: () => const TransactionsListPage(),
      binding: FinanceBinding(),
    ),
    GetPage(
      name: _Paths.FINANCE_TRANSACTION_CREATE,
      page: () => const TransactionCreatePage(),
      binding: FinanceBinding(),
    ),
    GetPage(
      name: _Paths.FINANCE_TRANSACTION_DETAILS,
      page: () => const TransactionDetailsPage(transaction: null),
      binding: FinanceBinding(),
    ),
    GetPage(
      name: _Paths.FINANCE_ACCOUNTS,
      page: () => const AccountsListPage(),
      binding: FinanceBinding(),
    ),
    GetPage(
      name: _Paths.FINANCE_ACCOUNT_CREATE,
      page: () => const AccountCreatePage(),
      binding: FinanceBinding(),
    ),
    GetPage(
      name: _Paths.FINANCE_ACCOUNT_DETAILS,
      page: () => const AccountDetailsPage(account: null),
      binding: FinanceBinding(),
    ),
    GetPage(
      name: _Paths.FINANCE_BUDGETS,
      page: () => const BudgetsListPage(),
      binding: FinanceBinding(),
    ),
    GetPage(
      name: _Paths.FINANCE_BUDGET_CREATE,
      page: () => const BudgetCreatePage(),
      binding: FinanceBinding(),
    ),
    GetPage(
      name: _Paths.FINANCE_BUDGET_DETAILS,
      page: () => const BudgetDetailsPage(budget: null),
      binding: FinanceBinding(),
    ),
    GetPage(
      name: _Paths.FINANCE_CATEGORIES,
      page: () => const CategoriesListPage(),
      binding: FinanceBinding(),
    ),
    GetPage(
      name: _Paths.FINANCE_OBJECTIVES,
      page: () => const ObjectivesListPage(),
      binding: FinanceBinding(),
    ),
    GetPage(
      name: _Paths.FINANCE_ANALYTICS,
      page: () => const FinanceAnalyticsPage(),
      binding: FinanceBinding(),
    ),
    GetPage(
      name: _Paths.FINANCE_AUTOMATION,
      page: () => const AutomationDashboardPage(),
      binding: AutomationBinding(),
    ),

    // Tasks module routes
    GetPage(
      name: _Paths.TASKS,
      page: () => const TasksMainPage(),
      binding: TasksBinding(),
    ),
    GetPage(
      name: _Paths.TASKS_LIST,
      page: () => const TasksListPage(),
      binding: TasksBinding(),
    ),
    GetPage(
      name: _Paths.TASKS_CREATE,
      page: () => const TaskCreatePage(),
      binding: TasksBinding(),
    ),
    GetPage(
      name: _Paths.TASKS_DETAILS,
      page: () => const TaskDetailsPage(),
      binding: TasksBinding(),
    ),

    // Projects routes
    GetPage(
      name: _Paths.TASKS_PROJECTS,
      page: () => const ProjectsListPage(),
      binding: TasksBinding(),
    ),
    GetPage(
      name: _Paths.TASKS_PROJECT_CREATE,
      page: () => const ProjectCreatePage(),
      binding: TasksBinding(),
    ),
    GetPage(
      name: _Paths.TASKS_PROJECT_DETAILS,
      page: () => const ProjectDetailsPage(),
      binding: TasksBinding(),
    ),
    GetPage(
      name: _Paths.TASKS_PROJECT_EDIT,
      page: () => const ProjectEditPage(),
      binding: TasksBinding(),
    ),

    // Categories routes
    GetPage(
      name: _Paths.TASKS_CATEGORIES,
      page: () => const TaskCategoriesListPage(),
      binding: TasksBinding(),
    ),
    GetPage(
      name: _Paths.TASKS_CATEGORY_CREATE,
      page: () => const TaskCategoryCreatePage(),
      binding: TasksBinding(),
    ),
    GetPage(
      name: _Paths.TASKS_CATEGORY_EDIT,
      page: () => const TaskCategoryEditPage(),
      binding: TasksBinding(),
    ),
    GetPage(
      name: _Paths.TASKS_CATEGORY_DETAILS,
      page: () => const TaskCategoryDetailsPage(),
      binding: TasksBinding(),
    ),

    // Tags and Recurring Tasks routes
    GetPage(
      name: _Paths.TASKS_TAGS,
      page: () => const TagsListPage(),
      binding: TasksBinding(),
    ),
    GetPage(
      name: _Paths.TASKS_RECURRING,
      page: () => const RecurringTasksPage(),
      binding: TasksBinding(),
    ),
    GetPage(
      name: _Paths.TASKS_ANALYTICS,
      page: () => const TasksAnalyticsPage(),
      binding: TasksBinding(),
    ),

    // Habits module routes
    GetPage(
      name: _Paths.HABITS,
      page: () => const HabitsMainPage(),
      binding: HabitsBinding(),
    ),
    GetPage(
      name: _Paths.HABITS_LIST,
      page: () => const HabitsListPage(),
      binding: HabitsBinding(),
    ),
    GetPage(
      name: _Paths.HABITS_CREATE,
      page: () => const HabitFormPage(),
      binding: HabitsBinding(),
    ),
    GetPage(
      name: _Paths.HABITS_EDIT,
      page: () => const HabitFormPage(),
      binding: HabitsDetailBinding(),
    ),
    GetPage(
      name: _Paths.HABITS_DETAILS,
      page: () => const HabitDetailsPage(),
      binding: HabitsDetailBinding(),
    ),
    GetPage(
      name: _Paths.HABITS_ROUTINES,
      page: () => const RoutinesListPage(),
      binding: HabitsBinding(),
    ),
    GetPage(
      name: _Paths.HABITS_ROUTINES_CREATE,
      page: () => const RoutineFormPage(),
      binding: HabitsBinding(),
    ),
    GetPage(
      name: _Paths.HABITS_ROUTINES_EDIT,
      page: () => const RoutineFormPage(),
      binding: RoutinesDetailBinding(),
    ),
    GetPage(
      name: _Paths.HABITS_ROUTINES_DETAILS,
      page: () => const RoutineDetailsPage(),
      binding: RoutinesDetailBinding(),
    ),
    GetPage(
      name: _Paths.HABITS_ROUTINES_START,
      page: () => const RoutineStartPage(),
      binding: RoutinesDetailBinding(),
    ),

    // Suggestions routes
    GetPage(
      name: _Paths.SUGGESTIONS,
      page: () => const SuggestionsPage(),
      binding: SuggestionsBinding(),
    ),

    // Gamification routes
    GetPage(
      name: _Paths.GAMIFICATION,
      page: () => const GamificationMainPage(),
      binding: GamificationBinding(),
    ),
  ];
}
