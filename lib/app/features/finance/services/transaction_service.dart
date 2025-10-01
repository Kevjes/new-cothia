import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/transaction_model.dart';
import '../models/account_model.dart';
import '../models/budget_model.dart';
import 'account_service.dart';
import 'budget_service.dart';
import 'automation_execution_engine.dart';
import '../../../core/constants/app_constants.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AccountService _accountService = AccountService();
  final BudgetService _budgetService = BudgetService();

  // Automation engine (lazy loaded to avoid circular dependencies)
  AutomationExecutionEngine? get _automationEngine {
    try {
      return Get.find<AutomationExecutionEngine>();
    } catch (e) {
      print('AutomationExecutionEngine not found: $e');
      return null;
    }
  }

  // Obtenir les transactions d'une entité
  Future<List<TransactionModel>> getTransactionsByEntity(
    String entityId, {
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
    TransactionStatus? status,
    TransactionType? type,
  }) async {
    try {
      Query query = _firestore
          .collection(AppConstants.transactionsCollection)
          .where('entityId', isEqualTo: entityId);

      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      if (type != null) {
        query = query.where('type', isEqualTo: type.name);
      }

      if (startDate != null) {
        query = query.where('transactionDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('transactionDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      query = query.orderBy('transactionDate', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des transactions: ${e.toString()}');
    }
  }

  // Obtenir une transaction par ID
  Future<TransactionModel?> getTransactionById(String transactionId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.transactionsCollection)
          .doc(transactionId)
          .get();

      if (doc.exists) {
        return TransactionModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la transaction: ${e.toString()}');
    }
  }

  // Créer une nouvelle transaction
  Future<TransactionModel> createTransaction(TransactionModel transaction) async {
    try {
      // Valider la transaction avant création
      if (!transaction.isValid) {
        throw Exception('Transaction invalide: comptes source/destination manquants');
      }

      // Valider les limites budgétaires si applicable
      final budgetValidation = await validateBudgetLimits(transaction);
      if (!budgetValidation['valid']) {
        throw Exception(budgetValidation['message']);
      }

      final docRef = await _firestore
          .collection(AppConstants.transactionsCollection)
          .add(transaction.toFirestore());

      final createdTransaction = transaction.copyWith(id: docRef.id);

      // Si la transaction est validée, mettre à jour les soldes des comptes et budgets
      if (transaction.status == TransactionStatus.validated) {
        await _updateAccountBalances(createdTransaction);
        await _updateBudgetAmounts(createdTransaction);

        // Déclencher les règles d'automatisation
        await _triggerAutomationRules(createdTransaction);
      }

      return createdTransaction;
    } catch (e) {
      throw Exception('Erreur lors de la création de la transaction: ${e.toString()}');
    }
  }

  // Mettre à jour une transaction
  Future<TransactionModel> updateTransaction(TransactionModel transaction) async {
    try {
      final updatedTransaction = transaction.copyWith(updatedAt: DateTime.now());

      await _firestore
          .collection(AppConstants.transactionsCollection)
          .doc(transaction.id)
          .update(updatedTransaction.toFirestore());

      return updatedTransaction;
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la transaction: ${e.toString()}');
    }
  }

  // Valider une transaction (changer le statut et mettre à jour les comptes)
  Future<TransactionModel> validateTransaction(String transactionId) async {
    try {
      final transaction = await getTransactionById(transactionId);
      if (transaction == null) {
        throw Exception('Transaction non trouvée');
      }

      if (transaction.status == TransactionStatus.validated) {
        throw Exception('Transaction déjà validée');
      }

      // Mettre à jour le statut
      final validatedTransaction = transaction.copyWith(
        status: TransactionStatus.validated,
        updatedAt: DateTime.now(),
      );

      await updateTransaction(validatedTransaction);

      // Mettre à jour les soldes des comptes et budgets
      await _updateAccountBalances(validatedTransaction);
      await _updateBudgetAmounts(validatedTransaction);

      // Déclencher les règles d'automatisation
      await _triggerAutomationRules(validatedTransaction);

      return validatedTransaction;
    } catch (e) {
      throw Exception('Erreur lors de la validation de la transaction: ${e.toString()}');
    }
  }

  // Annuler une transaction
  Future<TransactionModel> cancelTransaction(String transactionId) async {
    try {
      final transaction = await getTransactionById(transactionId);
      if (transaction == null) {
        throw Exception('Transaction non trouvée');
      }

      if (transaction.status == TransactionStatus.cancelled) {
        throw Exception('Transaction déjà annulée');
      }

      // Si la transaction était validée, restaurer les soldes des comptes et budgets
      if (transaction.status == TransactionStatus.validated) {
        await _revertAccountBalances(transaction);
        await _revertBudgetAmounts(transaction);
      }

      // Mettre à jour le statut
      final cancelledTransaction = transaction.copyWith(
        status: TransactionStatus.cancelled,
        updatedAt: DateTime.now(),
      );

      await updateTransaction(cancelledTransaction);

      return cancelledTransaction;
    } catch (e) {
      throw Exception('Erreur lors de l\'annulation de la transaction: ${e.toString()}');
    }
  }

  // Supprimer une transaction
  Future<void> deleteTransaction(String transactionId) async {
    try {
      final transaction = await getTransactionById(transactionId);
      if (transaction == null) {
        throw Exception('Transaction non trouvée');
      }

      // Si la transaction était validée, restaurer les soldes des comptes et budgets
      if (transaction.status == TransactionStatus.validated) {
        await _revertAccountBalances(transaction);
        await _revertBudgetAmounts(transaction);
      }

      await _firestore
          .collection(AppConstants.transactionsCollection)
          .doc(transactionId)
          .delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la transaction: ${e.toString()}');
    }
  }

  // Mettre à jour les soldes des comptes après validation d'une transaction
  Future<void> _updateAccountBalances(TransactionModel transaction) async {
    switch (transaction.type) {
      case TransactionType.income:
        if (transaction.destinationAccountId != null) {
          await _adjustAccountBalance(transaction.destinationAccountId!, transaction.amount);
        }
        break;

      case TransactionType.expense:
        if (transaction.sourceAccountId != null) {
          await _adjustAccountBalance(transaction.sourceAccountId!, -transaction.amount);
        }
        break;

      case TransactionType.transfer:
        if (transaction.sourceAccountId != null && transaction.destinationAccountId != null) {
          await _adjustAccountBalance(transaction.sourceAccountId!, -transaction.amount);
          await _adjustAccountBalance(transaction.destinationAccountId!, transaction.amount);
        }
        break;
    }
  }

  // Restaurer les soldes des comptes après annulation d'une transaction
  Future<void> _revertAccountBalances(TransactionModel transaction) async {
    switch (transaction.type) {
      case TransactionType.income:
        if (transaction.destinationAccountId != null) {
          await _adjustAccountBalance(transaction.destinationAccountId!, -transaction.amount);
        }
        break;

      case TransactionType.expense:
        if (transaction.sourceAccountId != null) {
          await _adjustAccountBalance(transaction.sourceAccountId!, transaction.amount);
        }
        break;

      case TransactionType.transfer:
        if (transaction.sourceAccountId != null && transaction.destinationAccountId != null) {
          await _adjustAccountBalance(transaction.sourceAccountId!, transaction.amount);
          await _adjustAccountBalance(transaction.destinationAccountId!, -transaction.amount);
        }
        break;
    }
  }

  // Ajuster le solde d'un compte
  Future<void> _adjustAccountBalance(String accountId, double amount) async {
    final account = await _accountService.getAccountById(accountId);
    if (account != null) {
      final newBalance = account.currentBalance + amount;
      await _accountService.updateAccountBalance(
        accountId: accountId,
        newBalance: newBalance,
      );
    }
  }

  // Mettre à jour les montants des budgets après une transaction
  Future<void> _updateBudgetAmounts(TransactionModel transaction) async {
    // Si la transaction n'est pas liée à un budget, ne rien faire
    if (transaction.budgetId == null) return;

    try {
      final budget = await _budgetService.getBudgetById(transaction.budgetId!);
      if (budget == null) return;

      // Pour les budgets de dépense (expense), ajouter le montant au spentAmount
      if (budget.type == BudgetType.expense &&
          (transaction.type == TransactionType.expense ||
           (transaction.type == TransactionType.transfer && transaction.sourceAccountId != null))) {
        await _budgetService.addExpenseToBudget(transaction.budgetId!, transaction.amount);
      }

      // Pour les budgets d'épargne (saving), ajouter au currentAmount si c'est un revenu ou un transfert vers épargne
      else if (budget.type == BudgetType.saving &&
               (transaction.type == TransactionType.income ||
                (transaction.type == TransactionType.transfer && transaction.destinationAccountId != null))) {
        await _budgetService.addExpenseToBudget(transaction.budgetId!, transaction.amount);
      }
    } catch (e) {
      // Log l'erreur mais ne pas faire échouer la transaction
      print('Erreur lors de la mise à jour du budget: $e');
    }
  }

  // Restaurer les montants des budgets après annulation d'une transaction
  Future<void> _revertBudgetAmounts(TransactionModel transaction) async {
    // Si la transaction n'est pas liée à un budget, ne rien faire
    if (transaction.budgetId == null) return;

    try {
      final budget = await _budgetService.getBudgetById(transaction.budgetId!);
      if (budget == null) return;

      // Pour les budgets de dépense, retirer le montant du spentAmount
      if (budget.type == BudgetType.expense &&
          (transaction.type == TransactionType.expense ||
           (transaction.type == TransactionType.transfer && transaction.sourceAccountId != null))) {
        await _budgetService.removeExpenseFromBudget(transaction.budgetId!, transaction.amount);
      }

      // Pour les budgets d'épargne, retirer du currentAmount
      else if (budget.type == BudgetType.saving &&
               (transaction.type == TransactionType.income ||
                (transaction.type == TransactionType.transfer && transaction.destinationAccountId != null))) {
        await _budgetService.removeExpenseFromBudget(transaction.budgetId!, transaction.amount);
      }
    } catch (e) {
      // Log l'erreur mais ne pas faire échouer l'annulation
      print('Erreur lors de la restauration du budget: $e');
    }
  }

  // Valider les limites budgétaires avant création/validation d'une transaction
  Future<Map<String, dynamic>> validateBudgetLimits(TransactionModel transaction) async {
    // Si pas de budget associé, autoriser
    if (transaction.budgetId == null) {
      return {'valid': true, 'message': 'Aucun budget associé'};
    }

    try {
      final budget = await _budgetService.getBudgetById(transaction.budgetId!);
      if (budget == null) {
        return {'valid': true, 'message': 'Budget non trouvé'};
      }

      // Pour les budgets de dépense, vérifier qu'on ne dépasse pas la limite
      if (budget.type == BudgetType.expense &&
          (transaction.type == TransactionType.expense ||
           (transaction.type == TransactionType.transfer && transaction.sourceAccountId != null))) {

        final newSpentAmount = budget.spentAmount + transaction.amount;
        if (newSpentAmount > budget.targetAmount) {
          final overAmount = newSpentAmount - budget.targetAmount;
          return {
            'valid': false,
            'message': 'Budget "${budget.name}" sera dépassé de ${overAmount.toStringAsFixed(0)} FCFA',
            'budgetName': budget.name,
            'currentSpent': budget.spentAmount,
            'limit': budget.targetAmount,
            'transactionAmount': transaction.amount,
            'overAmount': overAmount,
          };
        }
      }

      return {'valid': true, 'message': 'Limites respectées'};
    } catch (e) {
      return {'valid': true, 'message': 'Erreur validation: $e'};
    }
  }

  // Obtenir les transactions par compte
  Future<List<TransactionModel>> getTransactionsByAccount(
    String accountId, {
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore
          .collection(AppConstants.transactionsCollection)
          .where('sourceAccountId', isEqualTo: accountId);

      // Aussi chercher les transactions où ce compte est la destination
      final query2 = _firestore
          .collection(AppConstants.transactionsCollection)
          .where('destinationAccountId', isEqualTo: accountId);

      if (startDate != null) {
        query = query.where('transactionDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
        // query2 = query2.where('transactionDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('transactionDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
        // query2 = query2.where('transactionDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final [sourceTransactions, destinationTransactions] = await Future.wait([
        query.orderBy('transactionDate', descending: true).get(),
        query2.orderBy('transactionDate', descending: true).get(),
      ]);

      final allTransactions = <TransactionModel>[];

      allTransactions.addAll(
        sourceTransactions.docs.map((doc) => TransactionModel.fromFirestore(doc))
      );

      allTransactions.addAll(
        destinationTransactions.docs.map((doc) => TransactionModel.fromFirestore(doc))
      );

      // Supprimer les doublons et trier par date
      final uniqueTransactions = <String, TransactionModel>{};
      for (final transaction in allTransactions) {
        uniqueTransactions[transaction.id] = transaction;
      }

      final sortedTransactions = uniqueTransactions.values.toList()
        ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

      if (limit != null && sortedTransactions.length > limit) {
        return sortedTransactions.take(limit).toList();
      }

      return sortedTransactions;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des transactions du compte: ${e.toString()}');
    }
  }

  // Stream des transactions en temps réel
  Stream<List<TransactionModel>> streamTransactionsByEntity(String entityId) {
    return _firestore
        .collection(AppConstants.transactionsCollection)
        .where('entityId', isEqualTo: entityId)
        .orderBy('transactionDate', descending: true)
        .limit(50) // Limiter pour les performances
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromFirestore(doc))
            .toList());
  }

  // Obtenir les statistiques des transactions
  Future<Map<String, dynamic>> getTransactionStats(
    String entityId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final transactions = await getTransactionsByEntity(
        entityId,
        startDate: startDate,
        endDate: endDate,
        status: TransactionStatus.validated,
      );

      final totalTransactions = transactions.length;
      final totalIncome = transactions
          .where((t) => t.type == TransactionType.income)
          .fold<double>(0.0, (sum, t) => sum + t.amount);

      final totalExpense = transactions
          .where((t) => t.type == TransactionType.expense)
          .fold<double>(0.0, (sum, t) => sum + t.amount);

      final totalTransfer = transactions
          .where((t) => t.type == TransactionType.transfer)
          .fold<double>(0.0, (sum, t) => sum + t.amount);

      final netFlow = totalIncome - totalExpense;

      return {
        'totalTransactions': totalTransactions,
        'totalIncome': totalIncome,
        'totalExpense': totalExpense,
        'totalTransfer': totalTransfer,
        'netFlow': netFlow,
        'averageTransaction': totalTransactions > 0
            ? (totalIncome + totalExpense) / totalTransactions
            : 0.0,
      };
    } catch (e) {
      throw Exception('Erreur lors du calcul des statistiques: ${e.toString()}');
    }
  }

  // ================================
  // Méthodes d'automatisation
  // ================================

  /// Déclencher les règles d'automatisation pour une transaction
  Future<void> _triggerAutomationRules(TransactionModel transaction) async {
    try {
      final automationEngine = _automationEngine;
      if (automationEngine == null) {
        print('Moteur d\'automatisation non disponible');
        return;
      }

      print('Déclenchement des règles d\'automatisation pour transaction: ${transaction.id}');

      // Déclencher les règles basées sur la transaction
      await automationEngine.triggerRulesForTransaction(transaction);

      // Déclenchements spéciaux selon le contexte
      await _handleSpecialTriggers(transaction);

    } catch (e) {
      print('Erreur lors du déclenchement des règles d\'automatisation: $e');
      // Ne pas faire échouer la transaction pour une erreur d'automatisation
    }
  }

  /// Gérer les déclenchements spéciaux selon le contexte de la transaction
  Future<void> _handleSpecialTriggers(TransactionModel transaction) async {
    try {
      final automationEngine = _automationEngine;
      if (automationEngine == null) return;

      // Vérifier si c'est la première entrée du mois
      if (transaction.type == TransactionType.income) {
        final isFirstEntry = await _isFirstIncomeOfMonth(transaction);
        if (isFirstEntry) {
          print('Première entrée du mois détectée');
          await automationEngine.triggerFirstEntryOfMonthRules(transaction.entityId);
        }
      }

      // Vérifier les seuils de solde des comptes
      await _checkAccountBalanceThresholds(transaction);

      // Vérifier les dépassements de budget
      await _checkBudgetLimits(transaction);

    } catch (e) {
      print('Erreur lors des déclenchements spéciaux: $e');
    }
  }

  /// Vérifier si c'est la première transaction de revenus du mois
  Future<bool> _isFirstIncomeOfMonth(TransactionModel transaction) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      final previousIncomes = await _firestore
          .collection(AppConstants.transactionsCollection)
          .where('entityId', isEqualTo: transaction.entityId)
          .where('type', isEqualTo: TransactionType.income.name)
          .where('status', isEqualTo: TransactionStatus.validated.name)
          .where('transactionDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('transactionDate', isLessThan: Timestamp.fromDate(transaction.transactionDate))
          .get();

      return previousIncomes.docs.isEmpty;
    } catch (e) {
      print('Erreur lors de la vérification de première entrée: $e');
      return false;
    }
  }

  /// Vérifier les seuils de solde des comptes
  Future<void> _checkAccountBalanceThresholds(TransactionModel transaction) async {
    try {
      final automationEngine = _automationEngine;
      if (automationEngine == null) return;

      // Vérifier le compte source
      if (transaction.sourceAccountId != null) {
        final sourceAccount = await _accountService.getAccountById(transaction.sourceAccountId!);
        if (sourceAccount != null) {
          await automationEngine.triggerBalanceThresholdRules(
            transaction.entityId,
            sourceAccount.id,
            sourceAccount.currentBalance,
          );
        }
      }

      // Vérifier le compte destination
      if (transaction.destinationAccountId != null) {
        final destAccount = await _accountService.getAccountById(transaction.destinationAccountId!);
        if (destAccount != null) {
          await automationEngine.triggerBalanceThresholdRules(
            transaction.entityId,
            destAccount.id,
            destAccount.currentBalance,
          );
        }
      }
    } catch (e) {
      print('Erreur lors de la vérification des seuils de solde: $e');
    }
  }

  /// Vérifier les dépassements de budget
  Future<void> _checkBudgetLimits(TransactionModel transaction) async {
    try {
      final automationEngine = _automationEngine;
      if (automationEngine == null) return;

      if (transaction.budgetId != null) {
        final budget = await _budgetService.getBudgetById(transaction.budgetId!);
        if (budget != null && budget.isOverBudget) {
          print('Budget dépassé détecté: ${budget.name}');
          await automationEngine.triggerBudgetExceededRules(
            transaction.entityId,
            budget.id,
          );
        }
      }
    } catch (e) {
      print('Erreur lors de la vérification des limites de budget: $e');
    }
  }
}