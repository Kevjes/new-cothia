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
import '../features/finance/models/transaction_model.dart';
import '../features/finance/models/account_model.dart';
import '../features/finance/models/budget_model.dart';

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
      page: () {
        final args = Get.arguments;
        TransactionModel? transaction;
        if (args is TransactionModel) {
          transaction = args;
        } else if (args is Map && args['transaction'] is TransactionModel) {
          transaction = args['transaction'] as TransactionModel;
        }
        return TransactionDetailsPage(transaction: transaction);
      },
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
      page: () {
        final args = Get.arguments;
        AccountModel? account;
        if (args is AccountModel) {
          account = args;
        } else if (args is Map && args['account'] is AccountModel) {
          account = args['account'] as AccountModel;
        }
        return AccountDetailsPage(account: account);
      },
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
      page: () {
        final args = Get.arguments;
        BudgetModel? budget;
        if (args is BudgetModel) {
          budget = args;
        } else if (args is Map && args['budget'] is BudgetModel) {
          budget = args['budget'] as BudgetModel;
        }
        return BudgetDetailsPage(budget: budget);
      },
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
      binding: FinanceBinding(),
    ),
  ];
}
