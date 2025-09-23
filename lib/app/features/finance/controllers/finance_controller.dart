import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/account_model.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/objective_model.dart';
import '../services/account_service.dart';
import '../services/transaction_service.dart';
import '../services/category_service.dart';
import '../../../data/services/storage_service.dart';
import '../../../data/services/entity_service.dart';

class FinanceController extends GetxController {
  final AccountService _accountService = AccountService();
  final TransactionService _transactionService = TransactionService();
  final CategoryService _categoryService = CategoryService();

  // Observables
  final _isLoading = false.obs;
  final _hasError = false.obs;
  final _errorMessage = ''.obs;
  final _accounts = <AccountModel>[].obs;
  final _recentTransactions = <TransactionModel>[].obs;
  final _categories = <CategoryModel>[].obs;
  final _objectives = <ObjectiveModel>[].obs;

  // Stats observables
  final _totalWealth = 0.0.obs;
  final _monthlyIncome = 0.0.obs;
  final _monthlyExpense = 0.0.obs;
  final _accountStats = <String, dynamic>{}.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;
  String get errorMessage => _errorMessage.value;
  List<AccountModel> get accounts => _accounts;
  List<TransactionModel> get recentTransactions => _recentTransactions;
  List<CategoryModel> get categories => _categories;
  List<ObjectiveModel> get objectives => _objectives;
  double get totalWealth => _totalWealth.value;
  double get monthlyIncome => _monthlyIncome.value;
  double get monthlyExpense => _monthlyExpense.value;
  Map<String, dynamic> get accountStats => _accountStats;

  // Filtered getters
  List<AccountModel> get activeAccounts => _accounts.where((a) => a.isActive).toList();
  List<AccountModel> get bankAccounts => _accounts.where((a) => a.isBankAccount).toList();
  List<TransactionModel> get validatedTransactions =>
      _recentTransactions.where((t) => t.isValidated).toList();

  double get netFlow => monthlyIncome - monthlyExpense;

  String? _currentEntityId;

  @override
  void onInit() {
    super.onInit();
    // Initialiser avec un délai pour éviter les problèmes de navigation
    Future.delayed(const Duration(milliseconds: 100), () {
      _initializeFinanceData();
    });
  }

  Future<void> _initializeFinanceData() async {
    try {
      _isLoading.value = true;
      _hasError.value = false;
      _errorMessage.value = '';

      // Récupérer l'entité personnelle de l'utilisateur
      final storageService = await StorageService.getInstance();
      _currentEntityId = storageService.getPersonalEntityId();

      if (_currentEntityId == null || _currentEntityId!.isEmpty) {
        // Essayer de récupérer l'entité depuis Firestore
        final userId = storageService.getUserId();
        if (userId != null) {
          final entityService = EntityService();
          final personalEntity = await entityService.getPersonalEntity(userId);
          if (personalEntity != null) {
            _currentEntityId = personalEntity.id;
            // Sauvegarder l'ID pour les prochaines fois
            await storageService.setPersonalEntityId(personalEntity.id);
          } else {
            throw Exception('Entité personnelle non trouvée dans la base de données');
          }
        } else {
          throw Exception('Utilisateur non connecté');
        }
      }

      // Charger toutes les données en parallèle
      await Future.wait([
        loadAccounts(),
        loadRecentTransactions(),
        loadCategories(),
        loadDashboardStats(),
      ]);

      // Créer les données par défaut si nécessaire
      await _createDefaultDataIfNeeded();

    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = e.toString();

      Get.snackbar(
        'Erreur Finance',
        'Erreur lors du chargement des données financières: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Méthode pour réessayer l'initialisation
  Future<void> retryInitialization() async {
    await _initializeFinanceData();
  }

  // Charger les comptes
  Future<void> loadAccounts() async {
    try {
      if (_currentEntityId == null) return;

      final accounts = await _accountService.getAccountsByEntity(_currentEntityId!);
      _accounts.value = accounts;

      // Calculer le patrimoine total
      _totalWealth.value = accounts.fold<double>(
        0.0,
        (sum, account) => sum + account.currentBalance,
      );
    } catch (e) {
      throw Exception('Erreur lors du chargement des comptes: ${e.toString()}');
    }
  }

  // Charger les transactions récentes
  Future<void> loadRecentTransactions() async {
    try {
      if (_currentEntityId == null) return;

      final transactions = await _transactionService.getTransactionsByEntity(
        _currentEntityId!,
        limit: 20,
      );
      _recentTransactions.value = transactions;
    } catch (e) {
      throw Exception('Erreur lors du chargement des transactions: ${e.toString()}');
    }
  }

  // Charger les catégories
  Future<void> loadCategories() async {
    try {
      if (_currentEntityId == null) return;

      final categories = await _categoryService.getCategoriesByEntity(_currentEntityId!);
      _categories.value = categories;
    } catch (e) {
      throw Exception('Erreur lors du chargement des catégories: ${e.toString()}');
    }
  }

  // Charger les statistiques du tableau de bord
  Future<void> loadDashboardStats() async {
    try {
      if (_currentEntityId == null) return;

      // Période actuelle (ce mois)
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));

      final [accountStatsResult, transactionStatsResult] = await Future.wait([
        _accountService.getAccountStats(_currentEntityId!),
        _transactionService.getTransactionStats(
          _currentEntityId!,
          startDate: startOfMonth,
          endDate: endOfMonth,
        ),
      ]);

      _accountStats.value = accountStatsResult;
      _monthlyIncome.value = transactionStatsResult['totalIncome'] ?? 0.0;
      _monthlyExpense.value = transactionStatsResult['totalExpense'] ?? 0.0;
    } catch (e) {
      throw Exception('Erreur lors du chargement des statistiques: ${e.toString()}');
    }
  }

  // Créer les données par défaut si nécessaire
  Future<void> _createDefaultDataIfNeeded() async {
    try {
      if (_currentEntityId == null) return;

      // Créer des comptes par défaut si aucun compte n'existe
      if (_accounts.isEmpty) {
        await _accountService.createDefaultAccounts(_currentEntityId!);
        await loadAccounts();
      }

      // Créer des catégories par défaut si aucune catégorie n'existe
      if (_categories.isEmpty) {
        await _categoryService.createDefaultCategories(_currentEntityId!);
        await loadCategories();
      }
    } catch (e) {
      // Ne pas bloquer l'application si la création des données par défaut échoue
      // Ignorer silencieusement l'erreur
    }
  }

  // Rafraîchir toutes les données
  Future<void> refreshAllData() async {
    await _initializeFinanceData();
  }

  // Créer un nouveau compte
  Future<void> createAccount(AccountModel account) async {
    try {
      _isLoading.value = true;

      final newAccount = account.copyWith(entityId: _currentEntityId);
      await _accountService.createAccount(newAccount);
      await loadAccounts();

      Get.snackbar(
        'Succès',
        'Compte créé avec succès',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de la création du compte: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Créer une nouvelle transaction
  Future<void> createTransaction(TransactionModel transaction) async {
    try {
      _isLoading.value = true;

      final newTransaction = transaction.copyWith(entityId: _currentEntityId);
      await _transactionService.createTransaction(newTransaction);

      await Future.wait([
        loadRecentTransactions(),
        loadAccounts(), // Recharger les comptes car les soldes peuvent avoir changé
        loadDashboardStats(),
      ]);

      Get.snackbar(
        'Succès',
        'Transaction créée avec succès',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de la création de la transaction: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Valider une transaction
  Future<void> validateTransaction(String transactionId) async {
    try {
      _isLoading.value = true;

      await _transactionService.validateTransaction(transactionId);

      await Future.wait([
        loadRecentTransactions(),
        loadAccounts(),
        loadDashboardStats(),
      ]);

      Get.snackbar(
        'Succès',
        'Transaction validée avec succès',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de la validation: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Obtenir les comptes par type
  List<AccountModel> getAccountsByType(AccountType type) {
    return _accounts.where((account) => account.type == type).toList();
  }

  // Obtenir les transactions par statut
  List<TransactionModel> getTransactionsByStatus(TransactionStatus status) {
    return _recentTransactions.where((transaction) => transaction.status == status).toList();
  }

  // Obtenir les catégories par type
  List<CategoryModel> getCategoriesByType(CategoryType type) {
    return _categories.where((category) => category.type == type || category.type == CategoryType.both).toList();
  }

  // Rechercher un compte par nom
  AccountModel? findAccountByName(String name) {
    try {
      return _accounts.firstWhere((account) => account.name.toLowerCase() == name.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  // Rechercher une catégorie par nom
  CategoryModel? findCategoryByName(String name) {
    try {
      return _categories.firstWhere((category) => category.name.toLowerCase() == name.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  // Obtenir le solde d'un compte spécifique
  double getAccountBalance(String accountId) {
    try {
      final account = _accounts.firstWhere((account) => account.id == accountId);
      return account.currentBalance;
    } catch (e) {
      return 0.0;
    }
  }

  // Vérifier si l'utilisateur peut créer une transaction
  bool canCreateTransaction({
    required TransactionType type,
    required double amount,
    String? sourceAccountId,
  }) {
    if (amount <= 0) return false;

    switch (type) {
      case TransactionType.expense:
      case TransactionType.transfer:
        if (sourceAccountId == null) return false;
        final sourceBalance = getAccountBalance(sourceAccountId);
        return sourceBalance >= amount;
      case TransactionType.income:
        return true; // Toujours possible d'ajouter des revenus
    }
  }

  @override
  void onClose() {
    // Nettoyer les ressources si nécessaire
    super.onClose();
  }
}