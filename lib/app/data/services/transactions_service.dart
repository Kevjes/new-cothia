import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../features/finance/models/transaction_model.dart';
import '../../features/finance/models/account_model.dart';
import '../../features/finance/models/budget_model.dart';
import 'auth_service.dart';
import '../../../core/utils/logger.dart';

class TransactionsService extends GetxService {
  static TransactionsService get to => Get.find<TransactionsService>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService.to;

  final _transactions = <TransactionModel>[].obs;
  final _isLoading = false.obs;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading.value;

  String get _userId => _authService.currentUser?.id ?? '';

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users').doc(_userId).collection('transactions');

  @override
  void onInit() {
    super.onInit();
    if (_userId.isNotEmpty) {
      loadTransactions();
    }
  }

  // ==================== CRUD OPERATIONS ====================

  Future<String?> createTransaction(TransactionModel transaction) async {
    try {
      _isLoading.value = true;

      final now = DateTime.now();
      final newTransaction = transaction.copyWith(
        id: '', // Firestore will generate the ID
        userId: _userId,
        createdAt: now,
        updatedAt: now,
      );

      // Create the transaction document
      final docRef = await _collection.add(newTransaction.toJson());
      final transactionId = docRef.id;

      // Update with the generated ID
      await docRef.update({'id': transactionId});

      // Update the transaction with the ID
      final finalTransaction = newTransaction.copyWith(id: transactionId);

      // Update account balance if transaction is completed
      if (finalTransaction.status == TransactionStatus.completed) {
        await _updateAccountBalance(finalTransaction);

        // Update budget if linked
        if (finalTransaction.isLinkedToBudget) {
          await _updateBudgetSpent(finalTransaction);
        }
      }

      // Add to local list
      _transactions.add(finalTransaction);
      _sortTransactions();
      return transactionId;

    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de créer la transaction');
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> updateTransaction(TransactionModel transaction) async {
    try {
      _isLoading.value = true;

      final updatedTransaction = transaction.copyWith(
        updatedAt: DateTime.now(),
      );

      await _collection.doc(transaction.id).update(updatedTransaction.toJson());

      // Update local list
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = updatedTransaction;
        _sortTransactions();
      }
      return true;

    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de modifier la transaction');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> deleteTransaction(String transactionId) async {
    try {
      _isLoading.value = true;

      final transaction = _transactions.firstWhereOrNull((t) => t.id == transactionId);
      if (transaction == null) return false;

      // Reverse account balance changes if completed
      if (transaction.status == TransactionStatus.completed) {
        await _reverseAccountBalance(transaction);

        // Reverse budget if linked
        if (transaction.isLinkedToBudget) {
          await _reverseBudgetSpent(transaction);
        }
      }

      await _collection.doc(transactionId).delete();

      // Remove from local list
      _transactions.removeWhere((t) => t.id == transactionId);
      return true;

    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de supprimer la transaction');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> updateTransactionStatus(String transactionId, TransactionStatus newStatus) async {
    try {
      final transaction = _transactions.firstWhereOrNull((t) => t.id == transactionId);
      if (transaction == null) return false;

      final oldStatus = transaction.status;
      final updatedTransaction = transaction.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );

      await _collection.doc(transactionId).update({
        'status': newStatus.code,
        'updatedAt': updatedTransaction.updatedAt.toIso8601String(),
      });

      // Handle balance changes based on status change
      if (oldStatus != newStatus) {
        await _handleStatusChange(transaction, oldStatus, newStatus);
      }

      // Update local list
      final index = _transactions.indexWhere((t) => t.id == transactionId);
      if (index != -1) {
        _transactions[index] = updatedTransaction;
      }

      return true;

    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de modifier le statut de la transaction');
      return false;
    }
  }

  // ==================== LOADING & STREAMING ====================

  Future<void> loadTransactions({int? limit}) async {
    try {
      _isLoading.value = true;
      Query<Map<String, dynamic>> query = _collection.orderBy('date', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      final transactions = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return TransactionModel.fromJson(data);
      }).toList();

      _transactions.value = transactions;
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les transactions');
    } finally {
      _isLoading.value = false;
    }
  }

  Stream<List<TransactionModel>> getTransactionsStream({int? limit}) {
    Query<Map<String, dynamic>> query = _collection.orderBy('date', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      final transactions = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return TransactionModel.fromJson(data);
      }).toList();

      _transactions.value = transactions;
      return transactions;
    });
  }

  // ==================== FILTERS & QUERIES ====================

  List<TransactionModel> getTransactionsByType(TransactionType type) {
    return _transactions.where((t) => t.type == type).toList();
  }

  List<TransactionModel> getTransactionsByStatus(TransactionStatus status) {
    return _transactions.where((t) => t.status == status).toList();
  }

  List<TransactionModel> getTransactionsByAccount(String accountId) {
    return _transactions.where((t) =>
        t.accountId == accountId || t.toAccountId == accountId).toList();
  }

  List<TransactionModel> getTransactionsByBudget(String budgetId) {
    return _transactions.where((t) => t.budgetId == budgetId).toList();
  }

  List<TransactionModel> getTransactionsByDateRange(DateTime start, DateTime end) {
    return _transactions.where((t) =>
        t.date.isAfter(start) && t.date.isBefore(end)).toList();
  }

  List<TransactionModel> getRecentTransactions({int limit = 10}) {
    final sorted = List<TransactionModel>.from(_transactions);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(limit).toList();
  }

  List<TransactionModel> getPendingTransactions() {
    return getTransactionsByStatus(TransactionStatus.pending);
  }

  // ==================== STATISTICS ====================

  double getTotalIncome({DateTime? start, DateTime? end}) {
    var incomeTransactions = getTransactionsByType(TransactionType.income)
        .where((t) => t.status == TransactionStatus.completed);

    if (start != null && end != null) {
      incomeTransactions = incomeTransactions.where((t) =>
          t.date.isAfter(start) && t.date.isBefore(end));
    }

    return incomeTransactions.fold(0.0, (sum, t) => sum + t.amount);
  }

  double getTotalExpenses({DateTime? start, DateTime? end}) {
    var expenseTransactions = getTransactionsByType(TransactionType.expense)
        .where((t) => t.status == TransactionStatus.completed);

    if (start != null && end != null) {
      expenseTransactions = expenseTransactions.where((t) =>
          t.date.isAfter(start) && t.date.isBefore(end));
    }

    return expenseTransactions.fold(0.0, (sum, t) => sum + t.amount);
  }

  Map<String, double> getCategoryExpenses({DateTime? start, DateTime? end}) {
    var expenseTransactions = getTransactionsByType(TransactionType.expense)
        .where((t) => t.status == TransactionStatus.completed && t.categoryId != null);

    if (start != null && end != null) {
      expenseTransactions = expenseTransactions.where((t) =>
          t.date.isAfter(start) && t.date.isBefore(end));
    }

    final categoryTotals = <String, double>{};
    for (final transaction in expenseTransactions) {
      final categoryId = transaction.categoryId!;
      categoryTotals[categoryId] = (categoryTotals[categoryId] ?? 0) + transaction.amount;
    }

    return categoryTotals;
  }

  // ==================== BALANCE MANAGEMENT ====================

  Future<void> _updateAccountBalance(TransactionModel transaction) async {
    try {
      final accountsCollection = _firestore
          .collection('users')
          .doc(_userId)
          .collection('accounts');

      switch (transaction.type) {
        case TransactionType.income:
          await accountsCollection.doc(transaction.accountId).update({
            'balance': FieldValue.increment(transaction.amount),
            'updatedAt': DateTime.now().toIso8601String(),
          });
          break;

        case TransactionType.expense:
          await accountsCollection.doc(transaction.accountId).update({
            'balance': FieldValue.increment(-transaction.amount),
            'updatedAt': DateTime.now().toIso8601String(),
          });
          break;

        case TransactionType.transfer:
          if (transaction.toAccountId != null) {
            // Deduct from source account
            await accountsCollection.doc(transaction.accountId).update({
              'balance': FieldValue.increment(-transaction.amount),
              'updatedAt': DateTime.now().toIso8601String(),
            });

            // Add to destination account
            await accountsCollection.doc(transaction.toAccountId!).update({
              'balance': FieldValue.increment(transaction.amount),
              'updatedAt': DateTime.now().toIso8601String(),
            });
          }
          break;
      }

    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de mettre à jour le solde du compte');
    }
  }

  Future<void> _reverseAccountBalance(TransactionModel transaction) async {
    try {
      final accountsCollection = _firestore
          .collection('users')
          .doc(_userId)
          .collection('accounts');

      switch (transaction.type) {
        case TransactionType.income:
          await accountsCollection.doc(transaction.accountId).update({
            'balance': FieldValue.increment(-transaction.amount),
            'updatedAt': DateTime.now().toIso8601String(),
          });
          break;

        case TransactionType.expense:
          await accountsCollection.doc(transaction.accountId).update({
            'balance': FieldValue.increment(transaction.amount),
            'updatedAt': DateTime.now().toIso8601String(),
          });
          break;

        case TransactionType.transfer:
          if (transaction.toAccountId != null) {
            // Reverse: Add back to source account
            await accountsCollection.doc(transaction.accountId).update({
              'balance': FieldValue.increment(transaction.amount),
              'updatedAt': DateTime.now().toIso8601String(),
            });

            // Reverse: Deduct from destination account
            await accountsCollection.doc(transaction.toAccountId!).update({
              'balance': FieldValue.increment(-transaction.amount),
              'updatedAt': DateTime.now().toIso8601String(),
            });
          }
          break;
      }

    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de mettre à jour le solde du compte');
    }
  }

  Future<void> _updateBudgetSpent(TransactionModel transaction) async {
    if (transaction.budgetId == null || transaction.type != TransactionType.expense) return;

    try {
      final budgetsCollection = _firestore
          .collection('users')
          .doc(_userId)
          .collection('budgets');

      await budgetsCollection.doc(transaction.budgetId!).update({
        'spent': FieldValue.increment(transaction.amount),
        'updatedAt': DateTime.now().toIso8601String(),
      });

    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de mettre à jour le budget dépensé');
    }
  }

  Future<void> _reverseBudgetSpent(TransactionModel transaction) async {
    if (transaction.budgetId == null || transaction.type != TransactionType.expense) return;

    try {
      final budgetsCollection = _firestore
          .collection('users')
          .doc(_userId)
          .collection('budgets');

      await budgetsCollection.doc(transaction.budgetId!).update({
        'spent': FieldValue.increment(-transaction.amount),
        'updatedAt': DateTime.now().toIso8601String(),
      });

    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de mettre à jour le budget dépensé');
    }
  }

  Future<void> _handleStatusChange(TransactionModel transaction, TransactionStatus oldStatus, TransactionStatus newStatus) async {
    // If changing from completed to pending/cancelled/failed, reverse balance
    if (oldStatus == TransactionStatus.completed && newStatus != TransactionStatus.completed) {
      await _reverseAccountBalance(transaction);
      if (transaction.isLinkedToBudget) {
        await _reverseBudgetSpent(transaction);
      }
    }

    // If changing from pending/cancelled/failed to completed, apply balance
    if (oldStatus != TransactionStatus.completed && newStatus == TransactionStatus.completed) {
      await _updateAccountBalance(transaction);
      if (transaction.isLinkedToBudget) {
        await _updateBudgetSpent(transaction);
      }
    }
  }

  // ==================== UTILITY METHODS ====================

  void _sortTransactions() {
    _transactions.sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> refreshTransactions() async {
    await loadTransactions();
  }

  void clearTransactions() {
    _transactions.clear();
  }
}