import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';
import '../models/account_model.dart';
import 'account_service.dart';
import '../../../core/constants/app_constants.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AccountService _accountService = AccountService();

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

      final docRef = await _firestore
          .collection(AppConstants.transactionsCollection)
          .add(transaction.toFirestore());

      final createdTransaction = transaction.copyWith(id: docRef.id);

      // Si la transaction est validée, mettre à jour les soldes des comptes
      if (transaction.status == TransactionStatus.validated) {
        await _updateAccountBalances(createdTransaction);
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

      // Mettre à jour les soldes des comptes
      await _updateAccountBalances(validatedTransaction);

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

      // Si la transaction était validée, restaurer les soldes
      if (transaction.status == TransactionStatus.validated) {
        await _revertAccountBalances(transaction);
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

      // Si la transaction était validée, restaurer les soldes
      if (transaction.status == TransactionStatus.validated) {
        await _revertAccountBalances(transaction);
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
}