import 'package:get/get.dart';
import '../models/account_model.dart';
import '../models/transaction_model.dart';
import '../services/account_service.dart';
import '../services/transaction_service.dart';
import '../../../data/services/storage_service.dart';
import 'transactions_controller.dart';
import 'accounts_controller.dart';
import 'objectives_controller.dart';
import 'categories_controller.dart';
import 'budgets_controller.dart';

class FinanceController extends GetxController {
  final AccountService _accountService = AccountService();
  final TransactionService _transactionService = TransactionService();

  // Observables for dashboard overview only
  final _isLoading = false.obs;
  final _hasError = false.obs;
  final _errorMessage = ''.obs;
  final _accounts = <AccountModel>[].obs;
  final _recentTransactions = <TransactionModel>[].obs;
  final _totalWealth = 0.0.obs;

  // Entity ID
  String? _currentEntityId;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;
  String get errorMessage => _errorMessage.value;
  List<AccountModel> get accounts => _accounts;
  List<TransactionModel> get recentTransactions => _recentTransactions;
  double get totalWealth => _totalWealth.value;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      _isLoading.value = true;
      _hasError.value = false;

      final storageService = await StorageService.getInstance();
      _currentEntityId = storageService.getPersonalEntityId();

      if (_currentEntityId == null || _currentEntityId!.isEmpty) {
        throw Exception('Entity ID not found');
      }

      await Future.wait([
        loadAccounts(),
        loadRecentTransactions(),
      ]);

      _calculateTotalWealth();
    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadAccounts() async {
    try {
      if (_currentEntityId == null) return;
      final accounts = await _accountService.getAccountsByEntity(_currentEntityId!);
      _accounts.assignAll(accounts);
    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = 'Erreur lors du chargement des comptes: $e';
    }
  }

  Future<void> loadRecentTransactions() async {
    try {
      if (_currentEntityId == null) return;
      final transactions = await _transactionService.getTransactionsByEntity(_currentEntityId!);

      // Keep only the 5 most recent transactions
      transactions.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
      _recentTransactions.assignAll(transactions.take(5).toList());
    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = 'Erreur lors du chargement des transactions: $e';
    }
  }

  void _calculateTotalWealth() {
    double total = 0.0;
    for (final account in _accounts) {
      total += account.currentBalance;
    }
    _totalWealth.value = total;
  }

  // Refresh all data (used by dashboard)
  Future<void> refreshAllData() async {
    await _initializeData();
  }

  // Retry initialization method (used by error handling)
  Future<void> retryInitialization() async {
    await _initializeData();
  }

  // Statistics getters (delegate to TransactionsController for current data)
  double get monthlyIncome {
    final transactionsController = Get.find<TransactionsController>();
    return transactionsController.monthlyIncome;
  }

  double get monthlyExpense {
    final transactionsController = Get.find<TransactionsController>();
    return transactionsController.monthlyExpense;
  }

  double get netFlow {
    return monthlyIncome - monthlyExpense;
  }

  // Initialize all specialized controllers
  void initializeSpecializedControllers() {
    // Initialize all specialized controllers if not already done
    if (!Get.isRegistered<TransactionsController>()) {
      Get.put(TransactionsController());
    }
    if (!Get.isRegistered<AccountsController>()) {
      Get.put(AccountsController());
    }
    if (!Get.isRegistered<ObjectivesController>()) {
      Get.put(ObjectivesController());
    }
    if (!Get.isRegistered<CategoriesController>()) {
      Get.put(CategoriesController());
    }
    if (!Get.isRegistered<BudgetsController>()) {
      Get.put(BudgetsController());
    }
  }

  @override
  void onReady() {
    super.onReady();
    initializeSpecializedControllers();
  }

  @override
  void onClose() {
    super.onClose();
  }
}