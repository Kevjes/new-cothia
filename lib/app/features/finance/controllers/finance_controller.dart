import 'package:get/get.dart';
import '../../../data/services/finance_service.dart';
import '../../../data/services/accounts_service.dart';
import '../models/account_model.dart';
import '../models/transaction_model.dart';
import '../models/budget_model.dart';
import '../models/transfer_rule_model.dart';
import '../models/category_model.dart';
import '../models/currency.dart';
import 'dart:async';

class FinanceController extends GetxController {
  static FinanceController get to => Get.find<FinanceController>();

  final FinanceService _financeService = FinanceService.to;
  final AccountsService _accountsService = AccountsService.to;

  final _currentPageIndex = 0.obs;
  final _selectedAccount = Rxn<AccountModel>();
  final _accounts = <AccountModel>[].obs;
  final _isLoading = false.obs;
  StreamSubscription<List<AccountModel>>? _accountsSubscription;

  int get currentPageIndex => _currentPageIndex.value;
  AccountModel? get selectedAccount => _selectedAccount.value;
  List<AccountModel> get accounts => _accounts;
  bool get isLoading => _isLoading.value;

  // Getters pour accéder aux données du service (autres que comptes)
  List<TransactionModel> get transactions => _financeService.transactions;
  List<BudgetModel> get budgets => _financeService.budgets;
  List<CategoryModel> get categories => _financeService.categories;
  List<TransferRuleModel> get transferRules => _financeService.transferRules;

  @override
  void onInit() {
    super.onInit();
    _initializeFinanceData();
  }

  @override
  void onClose() {
    _accountsSubscription?.cancel();
    super.onClose();
  }

  Future<void> _initializeFinanceData() async {
    _isLoading.value = true;

    // Charger toutes les données financières au démarrage
    await refreshData();

    // Écouter les changements des comptes en temps réel
    _accountsSubscription = _accountsService.getAccountsStream().listen((accounts) {
      _accounts.value = accounts;
      _isLoading.value = false;

      // Sélectionner le compte par défaut si aucun n'est sélectionné
      if (_selectedAccount.value == null && accounts.isNotEmpty) {
        final defaultAccount = accounts.firstWhereOrNull((account) => account.isActive);
        if (defaultAccount != null) {
          _selectedAccount.value = defaultAccount;
        }
      }
    });
  }

  void changePageIndex(int index) {
    _currentPageIndex.value = index;
  }

  void selectAccount(AccountModel account) {
    _selectedAccount.value = account;
    // Optionnel: définir comme compte par défaut
    _accountsService.setDefaultAccount(account.id);
  }

  // ==================== MÉTHODES CRUD COMPTES ====================

  Future<bool> createAccount({
    required String name,
    required String description,
    required Currency currency,
    required double balance,
    required String icon,
    required String color,
  }) async {
    try {
      _isLoading.value = true;

      // Vérifier si le nom existe déjà
      final nameExists = await _accountsService.accountNameExists(name);
      if (nameExists) {
        Get.snackbar(
          'Erreur',
          'Un compte avec ce nom existe déjà',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      final accountId = await _accountsService.createAccount(
        name: name,
        description: description,
        currency: currency,
        balance: balance,
        icon: icon,
        color: color,
      );

      if (accountId != null) {
        Get.snackbar(
          'Succès',
          'Compte "$name" créé avec succès',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de créer le compte: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> updateAccount({
    required String accountId,
    required String name,
    required String description,
    required Currency currency,
    required String icon,
    required String color,
  }) async {
    try {
      _isLoading.value = true;

      // Vérifier si le nom existe déjà (excluant le compte actuel)
      final nameExists = await _accountsService.accountNameExists(name, excludeId: accountId);
      if (nameExists) {
        Get.snackbar(
          'Erreur',
          'Un autre compte avec ce nom existe déjà',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      final success = await _accountsService.updateAccount(
        accountId: accountId,
        name: name,
        description: description,
        currency: currency,
        icon: icon,
        color: color,
      );

      if (success) {
        Get.snackbar(
          'Succès',
          'Compte "$name" modifié avec succès',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de modifier le compte: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> deleteAccount(String accountId) async {
    try {
      _isLoading.value = true;

      final success = await _accountsService.deleteAccount(accountId);

      if (success) {
        // Si le compte supprimé était sélectionné, sélectionner un autre
        if (_selectedAccount.value?.id == accountId) {
          if (accounts.isNotEmpty) {
            final otherAccount = accounts.firstWhereOrNull((acc) => acc.id != accountId);
            _selectedAccount.value = otherAccount;
          } else {
            _selectedAccount.value = null;
          }
        }

        Get.snackbar(
          'Succès',
          'Compte supprimé avec succès',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de supprimer le compte: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<AccountModel?> getAccountById(String accountId) async {
    return await _accountsService.getAccountById(accountId);
  }

  Future<Map<String, dynamic>> getAccountsStats() async {
    return await _accountsService.getAccountsStats();
  }

  // ==================== MÉTHODES RAPIDES ====================

  String get totalBalanceFormatted {
    final total = _financeService.getTotalBalance();
    return Currency.defaultCurrency.formatAmount(total);
  }

  String get monthlyIncomeFormatted {
    final income = _financeService.getMonthlyIncome();
    return Currency.defaultCurrency.formatAmount(income);
  }

  String get monthlyExpensesFormatted {
    final expenses = _financeService.getMonthlyExpenses();
    return Currency.defaultCurrency.formatAmount(expenses);
  }

  String get monthlyNetFormatted {
    final net = _financeService.getMonthlyIncome() - _financeService.getMonthlyExpenses();
    return Currency.defaultCurrency.formatAmount(net);
  }

  List<TransactionModel> get recentTransactions => _financeService.getRecentTransactions(limit: 5);

  List<AccountModel> get activeAccounts => accounts.where((account) => account.isActive).toList();

  List<CategoryModel> get incomeCategories =>
      categories.where((cat) => cat.type == CategoryType.income).toList();

  List<CategoryModel> get expenseCategories =>
      categories.where((cat) => cat.type == CategoryType.expense).toList();

  // ==================== NAVIGATION ====================

  void goToAccounts() {
    Get.toNamed('/finance/accounts');
  }

  void goToBudgets() {
    Get.toNamed('/finance/budgets');
  }

  void goToTransferRules() {
    Get.toNamed('/finance/transfer-rules');
  }

  void goToAddTransaction() {
    Get.toNamed('/finance/add-transaction');
  }

  void goToAddAccount() {
    Get.toNamed('/finance/add-account');
  }

  void goToAddBudget() {
    Get.toNamed('/finance/add-budget');
  }

  void goToTransfer() {
    Get.toNamed('/finance/transfer');
  }

  // ==================== ACTIONS RAPIDES ====================

  Future<void> quickIncome(double amount, String title, {String? categoryId}) async {
    try {
      if (activeAccounts.isEmpty) {
        Get.snackbar('Erreur', 'Aucun compte disponible');
        return;
      }

      final transaction = TransactionModel(
        id: '',
        title: title,
        amount: amount,
        currency: Currency.defaultCurrency,
        type: TransactionType.income,
        accountId: selectedAccount?.id ?? activeAccounts.first.id,
        categoryId: categoryId,
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: '',
      );

      await _financeService.createTransaction(transaction);
      Get.snackbar('Succès', 'Revenu ajouté avec succès');
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de l\'ajout du revenu');
    }
  }

  Future<void> quickExpense(double amount, String title, {String? categoryId}) async {
    try {
      if (activeAccounts.isEmpty) {
        Get.snackbar('Erreur', 'Aucun compte disponible');
        return;
      }

      final transaction = TransactionModel(
        id: '',
        title: title,
        amount: amount,
        currency: Currency.defaultCurrency,
        type: TransactionType.expense,
        accountId: selectedAccount?.id ?? activeAccounts.first.id,
        categoryId: categoryId,
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: '',
      );

      await _financeService.createTransaction(transaction);
      Get.snackbar('Succès', 'Dépense ajoutée avec succès');
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de l\'ajout de la dépense');
    }
  }

  Future<void> quickTransfer(
    String fromAccountId,
    String toAccountId,
    double amount,
    String title,
  ) async {
    try {
      final transaction = TransactionModel(
        id: '',
        title: title,
        amount: amount,
        currency: Currency.defaultCurrency,
        type: TransactionType.transfer,
        accountId: fromAccountId,
        toAccountId: toAccountId,
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: '',
      );

      await _financeService.createTransaction(transaction);
      Get.snackbar('Succès', 'Transfert effectué avec succès');
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors du transfert');
    }
  }

  // ==================== STATISTIQUES ====================

  Map<String, double> getCategoryExpenses() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final monthlyExpenses = transactions.where((t) =>
        t.type == TransactionType.expense &&
        t.date.isAfter(startOfMonth) &&
        t.date.isBefore(endOfMonth));

    final categoryTotals = <String, double>{};

    for (final transaction in monthlyExpenses) {
      final category = categories.firstWhereOrNull((c) => c.id == transaction.categoryId);
      final categoryName = category?.name ?? 'Non catégorisé';
      categoryTotals[categoryName] = (categoryTotals[categoryName] ?? 0) + transaction.amount;
    }

    return categoryTotals;
  }

  List<BudgetModel> getActiveBudgets() {
    final now = DateTime.now();
    return budgets.where((budget) =>
        budget.isActive &&
        now.isAfter(budget.startDate) &&
        now.isBefore(budget.endDate)).toList();
  }

  double getBudgetProgress(String budgetId) {
    final budget = budgets.firstWhereOrNull((b) => b.id == budgetId);
    if (budget == null) return 0.0;

    return budget.spentPercentage;
  }

  // ==================== REFRESH ====================

  Future<void> refreshData() async {
    await _financeService.loadAccounts();
    await _financeService.loadTransactions();
    await _financeService.loadBudgets();
    await _financeService.loadCategories();
    await _financeService.loadTransferRules();
  }
}