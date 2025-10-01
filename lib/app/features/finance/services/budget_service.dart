import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/budget_model.dart';

class BudgetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'budgets';

  // Créer un nouveau budget
  Future<String> createBudget(BudgetModel budget) async {
    try {
      final docRef = await _firestore.collection(_collection).add(budget.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Erreur lors de la création du budget: $e');
    }
  }

  // Mettre à jour un budget existant
  Future<void> updateBudget(String budgetId, BudgetModel budget) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(budgetId)
          .update(budget.toFirestore());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du budget: $e');
    }
  }

  // Supprimer un budget
  Future<void> deleteBudget(String budgetId) async {
    try {
      await _firestore.collection(_collection).doc(budgetId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression du budget: $e');
    }
  }

  // Obtenir un budget par ID
  Future<BudgetModel?> getBudgetById(String budgetId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(budgetId).get();
      if (doc.exists) {
        return BudgetModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération du budget: $e');
    }
  }

  // Obtenir tous les budgets d'une entité
  Future<List<BudgetModel>> getBudgetsByEntity(String entityId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('entityId', isEqualTo: entityId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => BudgetModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des budgets: $e');
    }
  }

  // Obtenir les budgets par type
  Future<List<BudgetModel>> getBudgetsByType(String entityId, BudgetType type) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('entityId', isEqualTo: entityId)
          .where('type', isEqualTo: type.name)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => BudgetModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des budgets par type: $e');
    }
  }

  // Obtenir les budgets actifs d'une entité
  Future<List<BudgetModel>> getActiveBudgets(String entityId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('entityId', isEqualTo: entityId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => BudgetModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des budgets actifs: $e');
    }
  }

  // Obtenir les budgets avec automatisation
  Future<List<BudgetModel>> getBudgetsWithAutomation(String entityId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('entityId', isEqualTo: entityId)
          .where('automationRule.isEnabled', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => BudgetModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des budgets automatisés: $e');
    }
  }

  // Mettre à jour le montant actuel d'un budget
  Future<void> updateBudgetCurrentAmount(String budgetId, double newAmount) async {
    try {
      await _firestore.collection(_collection).doc(budgetId).update({
        'currentAmount': newAmount,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du montant du budget: $e');
    }
  }

  // Ajouter un montant au budget actuel
  Future<void> addToBudgetAmount(String budgetId, double amount) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final budgetRef = _firestore.collection(_collection).doc(budgetId);
        final budgetDoc = await transaction.get(budgetRef);

        if (!budgetDoc.exists) {
          throw Exception('Budget non trouvé');
        }

        final currentAmount = (budgetDoc.data()?['currentAmount'] ?? 0.0).toDouble();
        final newAmount = currentAmount + amount;

        transaction.update(budgetRef, {
          'currentAmount': newAmount,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      });
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout au budget: $e');
    }
  }

  // Soustraire un montant du budget actuel
  Future<void> subtractFromBudgetAmount(String budgetId, double amount) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final budgetRef = _firestore.collection(_collection).doc(budgetId);
        final budgetDoc = await transaction.get(budgetRef);

        if (!budgetDoc.exists) {
          throw Exception('Budget non trouvé');
        }

        final currentAmount = (budgetDoc.data()?['currentAmount'] ?? 0.0).toDouble();
        final newAmount = (currentAmount - amount).clamp(0.0, double.infinity);

        transaction.update(budgetRef, {
          'currentAmount': newAmount,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      });
    } catch (e) {
      throw Exception('Erreur lors de la soustraction du budget: $e');
    }
  }

  // Obtenir les statistiques des budgets
  Future<Map<String, dynamic>> getBudgetStats(String entityId) async {
    try {
      final budgets = await getBudgetsByEntity(entityId);
      final activeBudgets = budgets.where((b) => b.isActive).toList();

      final expenseBudgets = activeBudgets.where((b) => b.isExpenseBudget).toList();
      final savingBudgets = activeBudgets.where((b) => b.isSavingBudget).toList();
      final overBudgets = expenseBudgets.where((b) => b.isOverBudget).length;
      final underTargetBudgets = savingBudgets.where((b) => b.isUnderTarget).length;
      final automatedBudgets = activeBudgets.where((b) => b.hasAutomation).length;

      final totalTargetExpense = expenseBudgets.fold(0.0, (sum, b) => sum + b.targetAmount);
      final totalCurrentExpense = expenseBudgets.fold(0.0, (sum, b) => sum + b.currentAmount);
      final totalTargetSaving = savingBudgets.fold(0.0, (sum, b) => sum + b.targetAmount);
      final totalCurrentSaving = savingBudgets.fold(0.0, (sum, b) => sum + b.currentAmount);

      return {
        'totalBudgets': activeBudgets.length,
        'expenseBudgets': expenseBudgets.length,
        'savingBudgets': savingBudgets.length,
        'overBudgets': overBudgets,
        'underTargetBudgets': underTargetBudgets,
        'automatedBudgets': automatedBudgets,
        'totalTargetExpense': totalTargetExpense,
        'totalCurrentExpense': totalCurrentExpense,
        'totalTargetSaving': totalTargetSaving,
        'totalCurrentSaving': totalCurrentSaving,
        'expenseProgress': totalTargetExpense > 0 ? (totalCurrentExpense / totalTargetExpense * 100) : 0.0,
        'savingProgress': totalTargetSaving > 0 ? (totalCurrentSaving / totalTargetSaving * 100) : 0.0,
      };
    } catch (e) {
      throw Exception('Erreur lors du calcul des statistiques des budgets: $e');
    }
  }

  // Rechercher des budgets
  Future<List<BudgetModel>> searchBudgets(String entityId, String searchTerm) async {
    try {
      final allBudgets = await getBudgetsByEntity(entityId);
      final searchTermLower = searchTerm.toLowerCase();

      return allBudgets.where((budget) {
        return budget.name.toLowerCase().contains(searchTermLower) ||
               (budget.description?.toLowerCase().contains(searchTermLower) ?? false);
      }).toList();
    } catch (e) {
      throw Exception('Erreur lors de la recherche de budgets: $e');
    }
  }

  // Obtenir les budgets d'une période spécifique
  Future<List<BudgetModel>> getBudgetsByPeriod(String entityId, BudgetPeriod period) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('entityId', isEqualTo: entityId)
          .where('period', isEqualTo: period.name)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => BudgetModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des budgets par période: $e');
    }
  }

  // Archiver/désarchiver un budget
  Future<void> toggleBudgetStatus(String budgetId, bool isActive) async {
    try {
      await _firestore.collection(_collection).doc(budgetId).update({
        'isActive': isActive,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Erreur lors du changement de statut du budget: $e');
    }
  }

  // Écouter les changements des budgets en temps réel
  Stream<List<BudgetModel>> watchBudgetsByEntity(String entityId) {
    return _firestore
        .collection(_collection)
        .where('entityId', isEqualTo: entityId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BudgetModel.fromFirestore(doc))
            .toList());
  }

  // Dupliquer un budget
  Future<String> duplicateBudget(String budgetId, String newName) async {
    try {
      final originalBudget = await getBudgetById(budgetId);
      if (originalBudget == null) {
        throw Exception('Budget original non trouvé');
      }

      final duplicatedBudget = originalBudget.copyWith(
        id: '',
        name: newName,
        currentAmount: 0.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return await createBudget(duplicatedBudget);
    } catch (e) {
      throw Exception('Erreur lors de la duplication du budget: $e');
    }
  }

  // Réinitialiser les montants des budgets pour une nouvelle période
  Future<void> resetBudgetAmounts(String entityId, BudgetPeriod period) async {
    try {
      final budgets = await getBudgetsByPeriod(entityId, period);
      final batch = _firestore.batch();

      for (final budget in budgets) {
        final budgetRef = _firestore.collection(_collection).doc(budget.id);
        batch.update(budgetRef, {
          'currentAmount': 0.0,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Erreur lors de la réinitialisation des budgets: $e');
    }
  }

  // Obtenir les budgets en alerte (dépassés ou sous objectif)
  Future<List<BudgetModel>> getBudgetsInAlert(String entityId) async {
    try {
      final budgets = await getActiveBudgets(entityId);
      return budgets.where((budget) => budget.isOverBudget || budget.isUnderTarget).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des budgets en alerte: $e');
    }
  }

  // Calculer l'impact d'une transaction sur les budgets
  Future<List<BudgetModel>> getAffectedBudgets(String entityId, String? categoryId, double amount, BudgetType budgetType) async {
    try {
      final budgets = await getBudgetsByType(entityId, budgetType);

      if (categoryId != null) {
        return budgets.where((budget) => budget.categoryId == categoryId).toList();
      }

      return budgets;
    } catch (e) {
      throw Exception('Erreur lors du calcul des budgets affectés: $e');
    }
  }

  // Ajouter une dépense à un budget (alias pour addToBudgetAmount)
  Future<void> addExpenseToBudget(String budgetId, double amount) async {
    await addToBudgetAmount(budgetId, amount);
  }

  // Retirer une dépense d'un budget (alias pour subtractFromBudgetAmount)
  Future<void> removeExpenseFromBudget(String budgetId, double amount) async {
    await subtractFromBudgetAmount(budgetId, amount);
  }

  // Mettre à jour la règle d'automatisation d'un budget
  Future<void> updateBudgetAutomation(String budgetId, AutomationRule automationRule) async {
    try {
      await _firestore.collection(_collection).doc(budgetId).update({
        'automationRule': automationRule.toJson(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de l\'automatisation du budget: $e');
    }
  }
}