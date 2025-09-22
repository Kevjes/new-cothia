part of 'app_pages.dart';

abstract class AppRoutes {
  AppRoutes._();
  static const SPLASH = _Paths.SPLASH;
  static const HOME = _Paths.HOME;
  static const AUTH = _Paths.AUTH;
  static const PROFILE = _Paths.PROFILE;
  static const HABITS = _Paths.HABITS;
  static const TASKS = _Paths.TASKS;
  static const FINANCE = _Paths.FINANCE;
  static const PROJECTS = _Paths.PROJECTS;

  // Finance sub-routes
  static const FINANCE_ADD_TRANSACTION = _Paths.FINANCE_ADD_TRANSACTION;
  static const FINANCE_TRANSACTIONS = _Paths.FINANCE_TRANSACTIONS;
  static const FINANCE_ACCOUNTS = _Paths.FINANCE_ACCOUNTS;
  static const FINANCE_ACCOUNTS_LIST = _Paths.FINANCE_ACCOUNTS_LIST;
  static const FINANCE_ACCOUNTS_CREATE = _Paths.FINANCE_ACCOUNTS_CREATE;
  static const FINANCE_ACCOUNTS_EDIT = _Paths.FINANCE_ACCOUNTS_EDIT;
  static const FINANCE_ACCOUNTS_DETAILS = _Paths.FINANCE_ACCOUNTS_DETAILS;
  static const FINANCE_CURRENCIES = _Paths.FINANCE_CURRENCIES;
  static const FINANCE_BUDGETS = _Paths.FINANCE_BUDGETS;
  static const FINANCE_BUDGETS_LIST = _Paths.FINANCE_BUDGETS_LIST;
  static const FINANCE_BUDGETS_CREATE = _Paths.FINANCE_BUDGETS_CREATE;
  static const FINANCE_BUDGETS_EDIT = _Paths.FINANCE_BUDGETS_EDIT;
  static const FINANCE_BUDGETS_DETAILS = _Paths.FINANCE_BUDGETS_DETAILS;
  static const FINANCE_BUDGETS_STATS = _Paths.FINANCE_BUDGETS_STATS;
  static const FINANCE_TRANSFERS_CREATE = _Paths.FINANCE_TRANSFERS_CREATE;
  static const FINANCE_STATS = _Paths.FINANCE_STATS;
}

// Keeping Routes for backward compatibility
abstract class Routes {
  Routes._();
  static const SPLASH = _Paths.SPLASH;
  static const HOME = _Paths.HOME;
  static const AUTH = _Paths.AUTH;
  static const PROFILE = _Paths.PROFILE;
  static const HABITS = _Paths.HABITS;
  static const TASKS = _Paths.TASKS;
  static const FINANCE = _Paths.FINANCE;
  static const PROJECTS = _Paths.PROJECTS;

  // Finance sub-routes
  static const FINANCE_ADD_TRANSACTION = _Paths.FINANCE_ADD_TRANSACTION;
  static const FINANCE_TRANSACTIONS = _Paths.FINANCE_TRANSACTIONS;
  static const FINANCE_ACCOUNTS = _Paths.FINANCE_ACCOUNTS;
  static const FINANCE_ACCOUNTS_LIST = _Paths.FINANCE_ACCOUNTS_LIST;
  static const FINANCE_ACCOUNTS_CREATE = _Paths.FINANCE_ACCOUNTS_CREATE;
  static const FINANCE_ACCOUNTS_EDIT = _Paths.FINANCE_ACCOUNTS_EDIT;
  static const FINANCE_ACCOUNTS_DETAILS = _Paths.FINANCE_ACCOUNTS_DETAILS;
  static const FINANCE_CURRENCIES = _Paths.FINANCE_CURRENCIES;
  static const FINANCE_BUDGETS = _Paths.FINANCE_BUDGETS;
  static const FINANCE_BUDGETS_LIST = _Paths.FINANCE_BUDGETS_LIST;
  static const FINANCE_BUDGETS_CREATE = _Paths.FINANCE_BUDGETS_CREATE;
  static const FINANCE_BUDGETS_EDIT = _Paths.FINANCE_BUDGETS_EDIT;
  static const FINANCE_BUDGETS_DETAILS = _Paths.FINANCE_BUDGETS_DETAILS;
  static const FINANCE_BUDGETS_STATS = _Paths.FINANCE_BUDGETS_STATS;
  static const FINANCE_TRANSFERS_CREATE = _Paths.FINANCE_TRANSFERS_CREATE;
  static const FINANCE_STATS = _Paths.FINANCE_STATS;
}

abstract class _Paths {
  _Paths._();
  static const SPLASH = '/splash';
  static const HOME = '/home';
  static const AUTH = '/auth';
  static const PROFILE = '/profile';
  static const HABITS = '/habits';
  static const TASKS = '/tasks';
  static const FINANCE = '/finance';
  static const PROJECTS = '/projects';

  // Finance sub-paths
  static const FINANCE_ADD_TRANSACTION = '/finance/add-transaction';
  static const FINANCE_TRANSACTIONS = '/finance/transactions';
  static const FINANCE_ACCOUNTS = '/finance/accounts';
  static const FINANCE_ACCOUNTS_LIST = '/finance/accounts/list';
  static const FINANCE_ACCOUNTS_CREATE = '/finance/accounts/create';
  static const FINANCE_ACCOUNTS_EDIT = '/finance/accounts/edit';
  static const FINANCE_ACCOUNTS_DETAILS = '/finance/accounts/details';
  static const FINANCE_CURRENCIES = '/finance/currencies';
  static const FINANCE_BUDGETS = '/finance/budgets';
  static const FINANCE_BUDGETS_LIST = '/finance/budgets/list';
  static const FINANCE_BUDGETS_CREATE = '/finance/budgets/create';
  static const FINANCE_BUDGETS_EDIT = '/finance/budgets/edit';
  static const FINANCE_BUDGETS_DETAILS = '/finance/budgets/details';
  static const FINANCE_BUDGETS_STATS = '/finance/budgets/stats';
  static const FINANCE_TRANSFERS_CREATE = '/finance/transfers/create';
  static const FINANCE_STATS = '/finance/stats';
}
