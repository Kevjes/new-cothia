import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../features/finance/models/account_model.dart';
import '../../features/finance/models/transaction_model.dart';
import '../../features/finance/models/budget_model.dart';
import '../../features/finance/models/transfer_rule_model.dart';
import '../../features/finance/models/category_model.dart';
import '../../features/finance/models/currency.dart';
import '../../core/constants/app_constants.dart';
import 'auth_service.dart';

class FinanceService extends GetxService {
  static FinanceService get to => Get.find<FinanceService>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService.to;

  final _accounts = <AccountModel>[].obs;
  final _transactions = <TransactionModel>[].obs;
  final _budgets = <BudgetModel>[].obs;
  final _categories = <CategoryModel>[].obs;
  final _transferRules = <TransferRuleModel>[].obs;
  final _isLoading = false.obs;

  List<AccountModel> get accounts => _accounts;
  List<TransactionModel> get transactions => _transactions;
  List<BudgetModel> get budgets => _budgets;
  List<CategoryModel> get categories => _categories;
  List<TransferRuleModel> get transferRules => _transferRules;
  bool get isLoading => _isLoading.value;

  String get _userId => _authService.currentUser?.id ?? '';

  @override
  Future<void> onInit() async {
    super.onInit();
    if (_userId.isNotEmpty) {
      await _initializeFinanceData();
    }
  }

  Future<void> _initializeFinanceData() async {
    try {
      _isLoading.value = true;
      await Future.wait([
        loadAccounts(),
        loadCategories(),
        loadTransactions(),
        loadBudgets(),
        loadTransferRules(),
      ]);
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors du chargement des données financières');
    } finally {
      _isLoading.value = false;
    }
  }

  // ==================== COMPTES ====================

  Future<void> loadAccounts() async {
    try {
      final querySnapshot = await _firestore
          .collection('accounts')
          .where('userId', isEqualTo: _userId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: false)
          .get();

      _accounts.value = querySnapshot.docs
          .map((doc) => AccountModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();

      // Créer un compte par défaut si aucun compte existe
      if (_accounts.isEmpty) {
        await createDefaultAccount();
      }
    } catch (e) {
      print('Erreur lors du chargement des comptes: $e');
    }
  }

  Future<AccountModel> createAccount(AccountModel account) async {
    try {
      final accountData = account.toJson()..remove('id');
      accountData['userId'] = _userId;
      accountData['createdAt'] = DateTime.now().toIso8601String();
      accountData['updatedAt'] = DateTime.now().toIso8601String();

      final docRef = await _firestore.collection('accounts').add(accountData);

      final newAccount = account.copyWith(
        id: docRef.id,
        userId: _userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _accounts.add(newAccount);
      return newAccount;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la création du compte');
      rethrow;
    }
  }

  Future<void> createDefaultAccount() async {
    final defaultAccount = AccountModel(
      id: '',
      name: 'Compte Principal',
      description: 'Mon compte principal',
      balance: 0.0,
      currency: Currency.defaultCurrency,
      color: '6B73FF',
      icon: 'account_balance_wallet',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      userId: _userId,
    );

    await createAccount(defaultAccount);
  }

  Future<void> updateAccountBalance(String accountId, double newBalance) async {
    try {
      await _firestore.collection('accounts').doc(accountId).update({
        'balance': newBalance,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      final index = _accounts.indexWhere((account) => account.id == accountId);
      if (index != -1) {
        _accounts[index] = _accounts[index].copyWith(
          balance: newBalance,
          updatedAt: DateTime.now(),
        );
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la mise à jour du solde');
      rethrow;
    }
  }

  // ==================== CATÉGORIES ====================

  Future<void> loadCategories() async {
    try {
      final querySnapshot = await _firestore
          .collection('categories')
          .where('userId', isEqualTo: _userId)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      _categories.value = querySnapshot.docs
          .map((doc) => CategoryModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();

      // Créer les catégories par défaut si aucune existe
      if (_categories.isEmpty) {
        await _createDefaultCategories();
      }
    } catch (e) {
      print('Erreur lors du chargement des catégories: $e');
    }
  }

  Future<void> _createDefaultCategories() async {
    try {
      final defaultCategories = [
        ...CategoryModel.defaultIncomeCategories,
        ...CategoryModel.defaultExpenseCategories,
      ];

      for (final category in defaultCategories) {
        final categoryData = category.toJson()..remove('id');
        categoryData['userId'] = _userId;

        final docRef = await _firestore.collection('categories').add(categoryData);

        _categories.add(category.copyWith(
          id: docRef.id,
          userId: _userId,
        ));
      }
    } catch (e) {
      print('Erreur lors de la création des catégories par défaut: $e');
    }
  }

  // ==================== TRANSACTIONS ====================

  Future<void> loadTransactions({int limit = 50}) async {
    try {
      final querySnapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: _userId)
          .orderBy('date', descending: true)
          .limit(limit)
          .get();

      _transactions.value = querySnapshot.docs
          .map((doc) => TransactionModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      print('Erreur lors du chargement des transactions: $e');
    }
  }

  Future<TransactionModel> createTransaction(TransactionModel transaction) async {
    try {
      final transactionData = transaction.toJson()..remove('id');
      transactionData['userId'] = _userId;
      transactionData['createdAt'] = DateTime.now().toIso8601String();
      transactionData['updatedAt'] = DateTime.now().toIso8601String();

      final docRef = await _firestore.collection('transactions').add(transactionData);

      final newTransaction = transaction.copyWith(
        id: docRef.id,
        userId: _userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _transactions.insert(0, newTransaction);

      // Mettre à jour les soldes des comptes
      await _updateAccountBalanceForTransaction(newTransaction);

      // Exécuter les règles de transfert automatique
      await _executeTransferRules(newTransaction);

      return newTransaction;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la création de la transaction');
      rethrow;
    }
  }

  Future<void> _updateAccountBalanceForTransaction(TransactionModel transaction) async {
    final account = _accounts.firstWhereOrNull((a) => a.id == transaction.accountId);
    if (account == null) return;

    double newBalance = account.balance;

    switch (transaction.type) {
      case TransactionType.income:
        newBalance += transaction.amount;
        break;
      case TransactionType.expense:
        newBalance -= transaction.amount;
        break;
      case TransactionType.transfer:
        // Pour les transferts, on met à jour les deux comptes
        newBalance -= transaction.amount;
        if (transaction.toAccountId != null) {
          final toAccount = _accounts.firstWhereOrNull((a) => a.id == transaction.toAccountId);
          if (toAccount != null) {
            await updateAccountBalance(transaction.toAccountId!, toAccount.balance + transaction.amount);
          }
        }
        break;
    }

    await updateAccountBalance(transaction.accountId, newBalance);
  }

  // ==================== BUDGETS ====================

  Future<void> loadBudgets() async {
    try {
      final querySnapshot = await _firestore
          .collection('budgets')
          .where('userId', isEqualTo: _userId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: false)
          .get();

      _budgets.value = querySnapshot.docs
          .map((doc) => BudgetModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      print('Erreur lors du chargement des budgets: $e');
    }
  }

  Future<BudgetModel> createBudget(BudgetModel budget) async {
    try {
      final budgetData = budget.toJson()..remove('id');
      budgetData['userId'] = _userId;
      budgetData['createdAt'] = DateTime.now().toIso8601String();
      budgetData['updatedAt'] = DateTime.now().toIso8601String();

      final docRef = await _firestore.collection('budgets').add(budgetData);

      final newBudget = budget.copyWith(
        id: docRef.id,
        userId: _userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _budgets.add(newBudget);
      return newBudget;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la création du budget');
      rethrow;
    }
  }

  // ==================== RÈGLES DE TRANSFERT ====================

  Future<void> loadTransferRules() async {
    try {
      final querySnapshot = await _firestore
          .collection('transferRules')
          .where('userId', isEqualTo: _userId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: false)
          .get();

      _transferRules.value = querySnapshot.docs
          .map((doc) => TransferRuleModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      print('Erreur lors du chargement des règles de transfert: $e');
    }
  }

  Future<TransferRuleModel> createTransferRule(TransferRuleModel rule) async {
    try {
      final ruleData = rule.toJson()..remove('id');
      ruleData['userId'] = _userId;
      ruleData['createdAt'] = DateTime.now().toIso8601String();
      ruleData['updatedAt'] = DateTime.now().toIso8601String();

      final docRef = await _firestore.collection('transferRules').add(ruleData);

      final newRule = rule.copyWith(
        id: docRef.id,
        userId: _userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _transferRules.add(newRule);
      return newRule;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la création de la règle de transfert');
      rethrow;
    }
  }

  Future<void> _executeTransferRules(TransactionModel transaction) async {
    try {
      for (final rule in _transferRules.where((r) => r.isActive)) {
        if (rule.frequency == RuleFrequency.onEachTransaction &&
            rule.shouldExecuteForTransaction(transaction.amount, transaction.categoryId)) {

          final transferAmount = rule.calculateTransferAmount(transaction.amount);

          // Créer la transaction de transfert
          final transferTransaction = TransactionModel(
            id: '',
            title: 'Transfert automatique: ${rule.name}',
            description: 'Transfert automatique basé sur la règle "${rule.name}"',
            amount: transferAmount,
            currency: rule.currency,
            type: TransactionType.transfer,
            accountId: rule.fromAccountId,
            toAccountId: rule.toAccountId,
            date: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            userId: _userId,
            metadata: {
              'ruleId': rule.id,
              'originalTransactionId': transaction.id,
            },
          );

          await createTransaction(transferTransaction);
        }
      }
    } catch (e) {
      print('Erreur lors de l\'exécution des règles de transfert: $e');
    }
  }

  // ==================== MÉTHODES UTILITAIRES ====================

  double getTotalBalance() {
    return _accounts.fold(0.0, (sum, account) => sum + account.balance);
  }

  double getMonthlyIncome() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return _transactions
        .where((t) => t.type == TransactionType.income &&
                     t.date.isAfter(startOfMonth) &&
                     t.date.isBefore(endOfMonth))
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  double getMonthlyExpenses() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return _transactions
        .where((t) => t.type == TransactionType.expense &&
                     t.date.isAfter(startOfMonth) &&
                     t.date.isBefore(endOfMonth))
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  List<TransactionModel> getRecentTransactions({int limit = 10}) {
    return _transactions.take(limit).toList();
  }
}