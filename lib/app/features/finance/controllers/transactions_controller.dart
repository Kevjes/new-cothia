import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/transaction_model.dart';
import '../models/account_model.dart';
import '../models/category_model.dart';
import '../services/transaction_service.dart';
import '../services/account_service.dart';
import '../services/category_service.dart';
import '../../../data/services/storage_service.dart';

class TransactionsController extends GetxController {
  final TransactionService _transactionService = TransactionService();
  final AccountService _accountService = AccountService();
  final CategoryService _categoryService = CategoryService();

  // Observables
  final _isLoading = false.obs;
  final _hasError = false.obs;
  final _errorMessage = ''.obs;
  final _transactions = <TransactionModel>[].obs;
  final _accounts = <AccountModel>[].obs;
  final _categories = <CategoryModel>[].obs;

  // Filters
  final _selectedType = Rx<TransactionType?>(null);
  final _selectedStatus = Rx<TransactionStatus?>(null);
  final _selectedCategory = Rx<CategoryModel?>(null);
  final _selectedAccount = Rx<AccountModel?>(null);
  final _selectedPeriod = RxString('all');
  final _searchQuery = RxString('');

  // Getters
  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;
  String get errorMessage => _errorMessage.value;
  List<TransactionModel> get transactions => _transactions;
  List<AccountModel> get accounts => _accounts;
  List<CategoryModel> get categories => _categories;

  // Filter getters
  Rx<TransactionType?> get selectedType => _selectedType;
  Rx<TransactionType?> get selectedTransactionType => _selectedType; // Alias pour compatibilité
  Rx<TransactionStatus?> get selectedStatus => _selectedStatus;
  Rx<TransactionStatus?> get selectedTransactionStatus => _selectedStatus; // Alias pour compatibilité
  Rx<CategoryModel?> get selectedCategory => _selectedCategory;
  Rx<AccountModel?> get selectedAccount => _selectedAccount;
  RxString get selectedPeriod => _selectedPeriod;
  RxString get searchQuery => _searchQuery;

  // Recent transactions getter (compatibility)
  List<TransactionModel> get recentTransactions => filteredTransactions.take(10).toList();

  // Filtered transactions
  List<TransactionModel> get filteredTransactions {
    var filtered = List<TransactionModel>.from(_transactions);

    // Filter by type
    if (_selectedType.value != null) {
      filtered = filtered.where((t) => t.type == _selectedType.value).toList();
    }

    // Filter by status
    if (_selectedStatus.value != null) {
      filtered = filtered.where((t) => t.status == _selectedStatus.value).toList();
    }

    // Filter by category
    if (_selectedCategory.value != null) {
      filtered = filtered.where((t) => t.categoryId == _selectedCategory.value!.id).toList();
    }

    // Filter by account
    if (_selectedAccount.value != null) {
      filtered = filtered.where((t) =>
        t.sourceAccountId == _selectedAccount.value!.id ||
        t.destinationAccountId == _selectedAccount.value!.id
      ).toList();
    }

    // Filter by search query
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      filtered = filtered.where((t) =>
        t.title.toLowerCase().contains(query) ||
        (t.description?.toLowerCase().contains(query) ?? false)
      ).toList();
    }

    // Filter by period
    if (_selectedPeriod.value != 'all') {
      final now = DateTime.now();
      switch (_selectedPeriod.value) {
        case 'today':
          filtered = filtered.where((t) =>
            t.transactionDate.year == now.year &&
            t.transactionDate.month == now.month &&
            t.transactionDate.day == now.day
          ).toList();
          break;
        case 'week':
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          filtered = filtered.where((t) =>
            t.transactionDate.isAfter(weekStart.subtract(const Duration(days: 1)))
          ).toList();
          break;
        case 'month':
          filtered = filtered.where((t) =>
            t.transactionDate.year == now.year &&
            t.transactionDate.month == now.month
          ).toList();
          break;
        case 'year':
          filtered = filtered.where((t) =>
            t.transactionDate.year == now.year
          ).toList();
          break;
      }
    }

    return filtered..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
  }

  String? _currentEntityId;

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
        loadTransactions(),
        loadAccounts(),
        loadCategories(),
      ]);
    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadTransactions() async {
    try {
      if (_currentEntityId == null) return;
      final transactions = await _transactionService.getTransactionsByEntity(_currentEntityId!);
      _transactions.assignAll(transactions);
    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = 'Erreur lors du chargement des transactions: $e';
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

  Future<void> loadCategories() async {
    try {
      if (_currentEntityId == null) return;
      final categories = await _categoryService.getCategoriesByEntity(_currentEntityId!);
      _categories.assignAll(categories);
    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = 'Erreur lors du chargement des catégories: $e';
    }
  }

  Future<void> refreshData() async {
    await _initializeData();
  }

  // Transaction CRUD operations
  Future<bool> createTransaction(TransactionModel transaction) async {
    try {
      _isLoading.value = true;

      // Injecter le bon entityId
      if (_currentEntityId == null) {
        throw Exception('Entity ID non initialisé');
      }

      final transactionWithEntityId = transaction.copyWith(entityId: _currentEntityId!);
      await _transactionService.createTransaction(transactionWithEntityId);
      await loadTransactions();
      await loadAccounts(); // Refresh accounts as balances may have changed

      Get.snackbar(
        'Succès',
        'Transaction créée avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de créer la transaction: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> updateTransaction(String transactionId, TransactionModel transaction) async {
    try {
      _isLoading.value = true;
      await _transactionService.updateTransaction(transaction);
      await loadTransactions();
      await loadAccounts();

      Get.snackbar(
        'Succès',
        'Transaction modifiée avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de modifier la transaction: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> deleteTransaction(String transactionId) async {
    try {
      _isLoading.value = true;
      await _transactionService.deleteTransaction(transactionId);
      await loadTransactions();
      await loadAccounts();

      Get.snackbar(
        'Succès',
        'Transaction supprimée avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de supprimer la transaction: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> validateTransaction(String transactionId) async {
    try {
      _isLoading.value = true;
      await _transactionService.validateTransaction(transactionId);
      await loadTransactions();
      await loadAccounts();

      Get.snackbar(
        'Succès',
        'Transaction validée avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de valider la transaction: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Confirmer une transaction (pour la synchronisation avec les tâches)
  Future<bool> confirmTransaction(String transactionId) async {
    try {
      _isLoading.value = true;

      // Récupérer la transaction
      final transaction = _transactions.firstWhereOrNull((t) => t.id == transactionId);
      if (transaction == null) {
        throw Exception('Transaction introuvable');
      }

      // Confirmer la transaction en changeant son statut
      final confirmedTransaction = transaction.copyWith(
        status: TransactionStatus.validated,
        updatedAt: DateTime.now(),
      );

      await _transactionService.updateTransaction(confirmedTransaction);
      await loadTransactions();
      await loadAccounts();

      return true;
    } catch (e) {
      // Log error silently
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> duplicateTransaction(TransactionModel transaction) async {
    final duplicated = transaction.copyWith(
      id: '',
      title: '${transaction.title} (Copie)',
      status: TransactionStatus.pending,
      transactionDate: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return await createTransaction(duplicated);
  }

  // Filter methods
  void setTypeFilter(TransactionType? type) {
    _selectedType.value = type;
  }

  void setTransactionTypeFilter(TransactionType? type) {
    setTypeFilter(type);
  }

  void setTransactionStatusFilter(TransactionStatus? status) {
    setStatusFilter(status);
  }

  void setStatusFilter(TransactionStatus? status) {
    _selectedStatus.value = status;
  }

  void setCategoryFilter(CategoryModel? category) {
    _selectedCategory.value = category;
  }

  void setAccountFilter(AccountModel? account) {
    _selectedAccount.value = account;
  }

  void setPeriodFilter(String period) {
    _selectedPeriod.value = period;
  }

  void setSearchQuery(String query) {
    _searchQuery.value = query;
  }

  void clearAllFilters() {
    _selectedType.value = null;
    _selectedStatus.value = null;
    _selectedCategory.value = null;
    _selectedAccount.value = null;
    _selectedPeriod.value = 'all';
    _searchQuery.value = '';
  }

  // Statistics
  double get totalIncome {
    return filteredTransactions
        .where((t) => t.type == TransactionType.income && t.isValidated)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpense {
    return filteredTransactions
        .where((t) => t.type == TransactionType.expense && t.isValidated)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get netFlow => totalIncome - totalExpense;

  // Monthly statistics
  double get monthlyIncome {
    final now = DateTime.now();
    return _transactions
        .where((t) => t.type == TransactionType.income &&
                      t.transactionDate.year == now.year &&
                      t.transactionDate.month == now.month)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get monthlyExpense {
    final now = DateTime.now();
    return _transactions
        .where((t) => t.type == TransactionType.expense &&
                      t.transactionDate.year == now.year &&
                      t.transactionDate.month == now.month)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Refresh and retry methods
  Future<void> refreshAllData() async {
    await _initializeData();
  }

  Future<void> retryInitialization() async {
    await _initializeData();
  }

  int get pendingCount {
    return filteredTransactions
        .where((t) => t.status == TransactionStatus.pending)
        .length;
  }

  // Account operations
  AccountModel? getAccountById(String? accountId) {
    if (accountId == null) return null;
    return _accounts.where((a) => a.id == accountId).firstOrNull;
  }

  // Category operations
  CategoryModel? getCategoryById(String? categoryId) {
    if (categoryId == null) return null;
    return _categories.where((c) => c.id == categoryId).firstOrNull;
  }

  // Export functionality
  Future<void> exportTransactions() async {
    try {
      final transactions = filteredTransactions;
      if (transactions.isEmpty) {
        Get.snackbar(
          'Info',
          'Aucune transaction à exporter',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Format CSV simple
      final csvData = StringBuffer();
      csvData.writeln('Date,Titre,Montant,Type,Statut,Description');

      for (final transaction in transactions) {
        final date = '${transaction.transactionDate.day}/${transaction.transactionDate.month}/${transaction.transactionDate.year}';
        final title = transaction.title.replaceAll(',', ';');
        final description = (transaction.description ?? '').replaceAll(',', ';');

        csvData.writeln('$date,$title,${transaction.amount},${transaction.type.displayName},${transaction.status.displayName},$description');
      }

      Get.snackbar(
        'Succès',
        '${transactions.length} transactions exportées (format CSV)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de l\'export: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Bulk operations
  Future<bool> bulkValidateTransactions(List<String> transactionIds) async {
    try {
      _isLoading.value = true;
      for (final id in transactionIds) {
        await _transactionService.validateTransaction(id);
      }
      await loadTransactions();
      await loadAccounts();

      Get.snackbar(
        'Succès',
        '${transactionIds.length} transactions validées',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de la validation en masse: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> bulkDeleteTransactions(List<String> transactionIds) async {
    try {
      _isLoading.value = true;
      for (final id in transactionIds) {
        await _transactionService.deleteTransaction(id);
      }
      await loadTransactions();
      await loadAccounts();

      Get.snackbar(
        'Succès',
        '${transactionIds.length} transactions supprimées',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de la suppression en masse: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
}