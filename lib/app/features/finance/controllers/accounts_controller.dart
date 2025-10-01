import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/account_model.dart';
import '../models/transaction_model.dart';
import '../services/account_service.dart';
import '../services/transaction_service.dart';
import '../../../data/services/storage_service.dart';

class AccountsController extends GetxController {
  final AccountService _accountService = AccountService();
  final TransactionService _transactionService = TransactionService();

  // Observables
  final _isLoading = false.obs;
  final _hasError = false.obs;
  final _errorMessage = ''.obs;
  final _accounts = <AccountModel>[].obs;
  final _accountTransactions = <String, List<TransactionModel>>{}.obs;

  // Filters
  final _selectedType = Rx<AccountType?>(null);
  final _showInactive = false.obs;
  final _searchQuery = RxString('');

  // Getters
  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;
  String get errorMessage => _errorMessage.value;
  List<AccountModel> get accounts => _accounts;

  // Filter getters
  Rx<AccountType?> get selectedType => _selectedType;
  RxBool get showInactive => _showInactive;
  RxString get searchQuery => _searchQuery;

  // Filtered accounts
  List<AccountModel> get filteredAccounts {
    var filtered = List<AccountModel>.from(_accounts);

    // Filter by active status
    if (!_showInactive.value) {
      filtered = filtered.where((a) => a.isActive).toList();
    }

    // Filter by type
    if (_selectedType.value != null) {
      filtered = filtered.where((a) => a.type == _selectedType.value).toList();
    }

    // Filter by search query
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      filtered = filtered.where((a) =>
        a.name.toLowerCase().contains(query) ||
        (a.description?.toLowerCase().contains(query) ?? false)
      ).toList();
    }

    return filtered..sort((a, b) => a.name.compareTo(b.name));
  }

  // Grouped accounts
  Map<AccountType, List<AccountModel>> get groupedAccounts {
    final groups = <AccountType, List<AccountModel>>{};
    for (final account in filteredAccounts) {
      groups[account.type] ??= [];
      groups[account.type]!.add(account);
    }
    return groups;
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

      await loadAccounts();
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

  Future<void> loadAccountTransactions(String accountId) async {
    try {
      final transactions = await _transactionService.getTransactionsByAccount(accountId);
      _accountTransactions[accountId] = transactions;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger les transactions du compte: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> refreshData() async {
    await _initializeData();
  }

  // Account CRUD operations
  Future<bool> createAccount(AccountModel account) async {
    try {
      _isLoading.value = true;

      // Injecter le bon entityId
      if (_currentEntityId == null) {
        throw Exception('Entity ID non initialisé');
      }

      final accountWithEntityId = account.copyWith(entityId: _currentEntityId!);
      await _accountService.createAccount(accountWithEntityId);
      await loadAccounts();

      Get.snackbar(
        'Succès',
        'Compte "${account.name}" créé avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de créer le compte: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> updateAccount(AccountModel account) async {
    try {
      _isLoading.value = true;
      await _accountService.updateAccount(account);
      await loadAccounts();

      Get.snackbar(
        'Succès',
        'Compte "${account.name}" modifié avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de modifier le compte: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> deleteAccount(String accountId) async {
    try {
      _isLoading.value = true;
      final account = _accounts.firstWhere((a) => a.id == accountId);
      await _accountService.deleteAccount(accountId);
      await loadAccounts();

      Get.snackbar(
        'Succès',
        'Compte "${account.name}" supprimé avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de supprimer le compte: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> duplicateAccount(AccountModel account) async {
    final duplicated = account.copyWith(
      id: '',
      name: '${account.name} (Copie)',
      currentBalance: 0.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return await createAccount(duplicated);
  }

  Future<bool> toggleFavorite(String accountId) async {
    try {
      final account = _accounts.firstWhere((a) => a.id == accountId);
      final updatedAccount = account.copyWith(
        isFavorite: !account.isFavorite,
        updatedAt: DateTime.now(),
      );

      await _accountService.updateAccount(updatedAccount);
      await loadAccounts();

      Get.snackbar(
        'Succès',
        updatedAccount.isFavorite
            ? 'Compte ajouté aux favoris'
            : 'Compte retiré des favoris',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de modifier le statut favori: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // Balance operations
  Future<bool> adjustBalance(String accountId, double newBalance, String reason) async {
    try {
      _isLoading.value = true;

      final account = _accounts.firstWhere((a) => a.id == accountId);
      final difference = newBalance - account.currentBalance;

      // Create adjustment transaction
      final adjustmentTransaction = TransactionModel(
        id: '',
        title: 'Ajustement de solde: $reason',
        description: 'Ajustement automatique du solde du compte ${account.name}',
        amount: difference.abs(),
        type: difference >= 0 ? TransactionType.income : TransactionType.expense,
        status: TransactionStatus.validated,
        sourceAccountId: difference < 0 ? accountId : null,
        destinationAccountId: difference >= 0 ? accountId : null,
        entityId: _currentEntityId!,
        transactionDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _transactionService.createTransaction(adjustmentTransaction);
      await loadAccounts();

      Get.snackbar(
        'Succès',
        'Solde du compte ajusté avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'ajuster le solde: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> transferMoney(String fromAccountId, String toAccountId, double amount, String description) async {
    try {
      _isLoading.value = true;

      final fromAccount = _accounts.firstWhere((a) => a.id == fromAccountId);
      final toAccount = _accounts.firstWhere((a) => a.id == toAccountId);

      if (fromAccount.currentBalance < amount) {
        Get.snackbar(
          'Erreur',
          'Solde insuffisant dans le compte ${fromAccount.name}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      final transferTransaction = TransactionModel(
        id: '',
        title: 'Transfert: ${fromAccount.name} → ${toAccount.name}',
        description: description.isEmpty ? 'Transfert entre comptes' : description,
        amount: amount,
        type: TransactionType.transfer,
        status: TransactionStatus.validated,
        sourceAccountId: fromAccountId,
        destinationAccountId: toAccountId,
        entityId: _currentEntityId!,
        transactionDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _transactionService.createTransaction(transferTransaction);
      await loadAccounts();

      Get.snackbar(
        'Succès',
        'Transfert effectué avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'effectuer le transfert: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Quick transaction creation
  Future<bool> addQuickTransaction(String accountId, double amount, String title, bool isIncome) async {
    try {
      final account = _accounts.firstWhere((a) => a.id == accountId);

      if (!isIncome && account.currentBalance < amount) {
        Get.snackbar(
          'Erreur',
          'Solde insuffisant dans le compte ${account.name}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      final transaction = TransactionModel(
        id: '',
        title: title,
        amount: amount,
        type: isIncome ? TransactionType.income : TransactionType.expense,
        status: TransactionStatus.validated,
        sourceAccountId: isIncome ? null : accountId,
        destinationAccountId: isIncome ? accountId : null,
        entityId: _currentEntityId!,
        transactionDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _transactionService.createTransaction(transaction);
      await loadAccounts();

      Get.snackbar(
        'Succès',
        '${isIncome ? 'Revenu' : 'Dépense'} ajouté avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'ajouter la transaction: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // Filter methods
  void setTypeFilter(AccountType? type) {
    _selectedType.value = type;
  }

  void toggleInactiveAccounts() {
    _showInactive.value = !_showInactive.value;
  }

  void setSearchQuery(String query) {
    _searchQuery.value = query;
  }

  void clearAllFilters() {
    _selectedType.value = null;
    _showInactive.value = false;
    _searchQuery.value = '';
  }

  // Statistics
  double get totalWealth {
    return filteredAccounts
        .where((a) => a.isActive)
        .fold(0.0, (sum, a) => sum + a.currentBalance);
  }

  double get totalAssets {
    return filteredAccounts
        .where((a) => a.isActive && a.currentBalance > 0)
        .fold(0.0, (sum, a) => sum + a.currentBalance);
  }

  double get totalLiabilities {
    return filteredAccounts
        .where((a) => a.isActive && a.currentBalance < 0)
        .fold(0.0, (sum, a) => sum + a.currentBalance.abs());
  }

  Map<AccountType, double> get balancesByType {
    final balances = <AccountType, double>{};
    for (final account in filteredAccounts.where((a) => a.isActive)) {
      balances[account.type] = (balances[account.type] ?? 0.0) + account.currentBalance;
    }
    return balances;
  }

  List<AccountModel> get positiveBalanceAccounts {
    return filteredAccounts.where((a) => a.currentBalance > 0).toList();
  }

  List<AccountModel> get negativeBalanceAccounts {
    return filteredAccounts.where((a) => a.currentBalance < 0).toList();
  }

  // Account operations
  AccountModel? findAccountById(String accountId) {
    return _accounts.where((a) => a.id == accountId).firstOrNull;
  }

  AccountModel? findAccountByName(String name) {
    return _accounts.where((a) => a.name.toLowerCase() == name.toLowerCase()).firstOrNull;
  }

  List<AccountModel> getAccountsByType(AccountType type) {
    return _accounts.where((a) => a.type == type).toList();
  }

  List<TransactionModel> getAccountTransactions(String accountId) {
    return _accountTransactions[accountId] ?? [];
  }

  // Export functionality
  Future<void> exportAccounts() async {
    try {
      final accounts = filteredAccounts;
      if (accounts.isEmpty) {
        Get.snackbar(
          'Info',
          'Aucun compte à exporter',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Format CSV simple
      final csvData = StringBuffer();
      csvData.writeln('Nom,Type,Solde Actuel,Devise,Actif,Description');

      for (final account in accounts) {
        final name = account.name.replaceAll(',', ';');
        final description = (account.description ?? '').replaceAll(',', ';');

        csvData.writeln('$name,${account.type.name},${account.currentBalance},${account.currency},${account.isActive ? 'Oui' : 'Non'},$description');
      }

      Get.snackbar(
        'Succès',
        '${accounts.length} comptes exportés (format CSV)',
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

  // Account history
  Future<List<Map<String, dynamic>>> getAccountHistory(String accountId) async {
    try {
      final transactions = await _transactionService.getTransactionsByAccount(accountId);
      final history = <Map<String, dynamic>>[];

      double runningBalance = 0.0;
      final account = findAccountById(accountId);
      if (account != null) {
        runningBalance = account.currentBalance;
      }

      // Sort transactions by date (newest first)
      transactions.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

      for (final transaction in transactions.reversed) {
        final isIncoming = transaction.destinationAccountId == accountId;
        final amount = isIncoming ? transaction.amount : -transaction.amount;

        history.add({
          'transaction': transaction,
          'balanceAfter': runningBalance,
          'amount': amount,
        });

        runningBalance -= amount;
      }

      return history.reversed.toList();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger l\'historique: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return [];
    }
  }
}