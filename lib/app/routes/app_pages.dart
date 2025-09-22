import 'package:get/get.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../features/auth/bindings/auth_binding.dart';
import '../features/auth/views/auth_view.dart';
import '../features/finance/bindings/finance_binding.dart';
import '../features/finance/views/finance_view.dart';
import '../features/finance/bindings/add_transaction_binding.dart';
import '../features/finance/views/add_transaction_view.dart';
import '../features/finance/views/pages/accounts/accounts_main.dart';
import '../features/finance/views/pages/accounts/accounts_list.dart';
import '../features/finance/views/pages/accounts/account_create.dart';
import '../features/finance/views/pages/accounts/account_edit.dart';
import '../features/finance/views/pages/accounts/account_details.dart';
import '../features/finance/views/pages/currencies/currencies_list.dart';
import '../features/finance/views/pages/budgets/budgets_main.dart';
import '../features/finance/views/pages/budgets/budgets_list.dart';
import '../features/finance/views/pages/budgets/budget_create.dart';
import '../views/splash_view.dart';
import '../bindings/splash_binding.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.AUTH,
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.FINANCE,
      page: () => const FinanceView(),
      binding: FinanceBinding(),
    ),
    GetPage(
      name: _Paths.FINANCE_ADD_TRANSACTION,
      page: () => const AddTransactionView(),
      binding: AddTransactionBinding(),
    ),
    GetPage(
      name: _Paths.FINANCE_ACCOUNTS,
      page: () => const AccountsMain(),
      binding: FinanceBinding(),
    ),
    GetPage(
      name: _Paths.FINANCE_ACCOUNTS_LIST,
      page: () => const AccountsList(),
      binding: FinanceBinding(),
    ),
    GetPage(
      name: _Paths.FINANCE_ACCOUNTS_CREATE,
      page: () => const AccountCreate(),
      binding: FinanceBinding(),
    ),
    GetPage(
      name: _Paths.FINANCE_ACCOUNTS_EDIT,
      page: () => const AccountEdit(),
      binding: FinanceBinding(),
    ),
    GetPage(
      name: _Paths.FINANCE_ACCOUNTS_DETAILS,
      page: () => const AccountDetails(),
      binding: FinanceBinding(),
    ),
    GetPage(
      name: _Paths.FINANCE_CURRENCIES,
      page: () => const CurrenciesList(),
      binding: FinanceBinding(),
    ),
    GetPage(
      name: _Paths.FINANCE_BUDGETS,
      page: () => const BudgetsMain(),
      binding: FinanceBinding(),
    ),
    GetPage(
      name: _Paths.FINANCE_BUDGETS_LIST,
      page: () => const BudgetsList(),
      binding: FinanceBinding(),
    ),
    GetPage(
      name: _Paths.FINANCE_BUDGETS_CREATE,
      page: () => const BudgetCreate(),
      binding: FinanceBinding(),
    ),
  ];
}
