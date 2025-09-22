import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../features/finance/models/budget_model.dart';
import '../../features/finance/models/currency.dart';
import 'auth_service.dart';
import 'accounts_service.dart';

class BudgetsService extends GetxService {
  static BudgetsService get to => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService.to;
  final AccountsService _accountsService = AccountsService.to;

  String get _userId => _authService.currentUser?.id ?? '';
  String get _budgetsCollection => 'users/$_userId/budgets';

  // Créer un budget ou objectif
  Future<String?> createBudget({
    required String name,
    required String description,
    required BudgetType type,
    required double amount,
    required Currency currency,
    required BudgetPeriod period,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> categoryIds,
    String? accountId,
    required bool isRecurrent,
    String? icon,
    String? color,
  }) async {
    try {
      if (_userId.isEmpty) throw Exception('Utilisateur non connecté');

      // Si aucun compte spécifié, créer un compte automatiquement pour l'objectif
      String? finalAccountId = accountId;
      if (finalAccountId == null && type == BudgetType.objective) {
        finalAccountId = await _createAutomaticAccount(name, currency, icon, color);
      }

      final budget = BudgetModel(
        id: '', // Sera généré par Firestore
        name: name,
        description: description,
        type: type,
        amount: amount,
        currency: currency,
        period: period,
        startDate: startDate,
        endDate: endDate,
        categoryIds: categoryIds,
        accountId: finalAccountId,
        isRecurrent: isRecurrent,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: _userId,
        icon: icon,
        color: color,
      );

      final docRef = await _firestore
          .collection(_budgetsCollection)
          .add(budget.toMap());

      return docRef.id;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de créer ${type.label.toLowerCase()}: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // Créer un compte automatique pour un objectif
  Future<String?> _createAutomaticAccount(String objectiveName, Currency currency, String? icon, String? color) async {
    try {
      return await _accountsService.createAccount(
        name: 'Compte - $objectiveName',
        description: 'Compte automatiquement créé pour l\'objectif: $objectiveName',
        currency: currency,
        balance: 0.0,
        icon: icon ?? 'savings',
        color: color ?? 'success',
      );
    } catch (e) {
      print('Erreur lors de la création du compte automatique: $e');
      return null;
    }
  }

  // Récupérer tous les budgets et objectifs
  Stream<List<BudgetModel>> getBudgetsStream() {
    if (_userId.isEmpty) return Stream.value([]);

    return _firestore
        .collection(_budgetsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BudgetModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Récupérer les budgets seulement
  Stream<List<BudgetModel>> getBudgetsOnlyStream() {
    if (_userId.isEmpty) return Stream.value([]);

    return _firestore
        .collection(_budgetsCollection)
        .where('type', isEqualTo: 'budget')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BudgetModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Récupérer les objectifs seulement
  Stream<List<BudgetModel>> getObjectivesStream() {
    if (_userId.isEmpty) return Stream.value([]);

    return _firestore
        .collection(_budgetsCollection)
        .where('type', isEqualTo: 'objective')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BudgetModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Récupérer un budget par ID
  Future<BudgetModel?> getBudgetById(String budgetId) async {
    try {
      if (_userId.isEmpty) return null;

      final doc = await _firestore
          .collection(_budgetsCollection)
          .doc(budgetId)
          .get();

      if (doc.exists && doc.data() != null) {
        return BudgetModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de récupérer le budget: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // Mettre à jour un budget
  Future<bool> updateBudget({
    required String budgetId,
    required String name,
    required String description,
    required BudgetType type,
    required double amount,
    required Currency currency,
    required BudgetPeriod period,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> categoryIds,
    String? accountId,
    required bool isRecurrent,
    String? icon,
    String? color,
  }) async {
    try {
      if (_userId.isEmpty) throw Exception('Utilisateur non connecté');

      await _firestore
          .collection(_budgetsCollection)
          .doc(budgetId)
          .update({
        'name': name,
        'description': description,
        'type': type.code,
        'amount': amount,
        'currency': currency.toMap(),
        'period': period.code,
        'startDate': startDate,
        'endDate': endDate,
        'categoryIds': categoryIds,
        'accountId': accountId,
        'isRecurrent': isRecurrent,
        'icon': icon,
        'color': color,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour le budget: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // Mettre à jour le montant dépensé
  Future<bool> updateSpentAmount({
    required String budgetId,
    required double spentAmount,
  }) async {
    try {
      if (_userId.isEmpty) throw Exception('Utilisateur non connecté');

      await _firestore
          .collection(_budgetsCollection)
          .doc(budgetId)
          .update({
        'spent': spentAmount,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour le montant: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // Supprimer un budget
  Future<bool> deleteBudget(String budgetId) async {
    try {
      if (_userId.isEmpty) throw Exception('Utilisateur non connecté');

      await _firestore
          .collection(_budgetsCollection)
          .doc(budgetId)
          .delete();

      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de supprimer le budget: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // Renouveler un budget récurrent
  Future<String?> renewBudget(BudgetModel budget) async {
    if (!budget.isRecurrent || budget.nextRenewalDate == null) return null;

    final newStartDate = budget.endDate.add(Duration(days: 1));
    final newEndDate = budget.nextRenewalDate!;

    return await createBudget(
      name: budget.name,
      description: budget.description ?? '',
      type: budget.type,
      amount: budget.amount,
      currency: budget.currency,
      period: budget.period,
      startDate: newStartDate,
      endDate: newEndDate,
      categoryIds: budget.categoryIds,
      accountId: budget.accountId,
      isRecurrent: budget.isRecurrent,
      icon: budget.icon,
      color: budget.color,
    );
  }

  // Vérifier si un nom de budget existe déjà
  Future<bool> budgetNameExists(String name, {String? excludeId}) async {
    try {
      if (_userId.isEmpty) return false;

      var query = _firestore
          .collection(_budgetsCollection)
          .where('name', isEqualTo: name);

      final snapshot = await query.get();

      if (excludeId != null) {
        return snapshot.docs.any((doc) => doc.id != excludeId);
      }

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Obtenir les statistiques des budgets
  Future<Map<String, dynamic>> getBudgetsStats() async {
    try {
      if (_userId.isEmpty) return {};

      final snapshot = await _firestore
          .collection(_budgetsCollection)
          .where('isActive', isEqualTo: true)
          .get();

      final budgets = snapshot.docs
          .map((doc) => BudgetModel.fromMap(doc.data(), doc.id))
          .toList();

      int totalBudgets = 0;
      int totalObjectives = 0;
      int activeBudgets = 0;
      int activeObjectives = 0;
      int overBudgetCount = 0;
      double totalBudgetAmount = 0;
      double totalSpent = 0;

      for (final budget in budgets) {
        if (budget.isBudget) {
          totalBudgets++;
          totalBudgetAmount += budget.amount;
          totalSpent += budget.spent;
          if (budget.isCurrentlyActive) activeBudgets++;
          if (budget.isOverBudget) overBudgetCount++;
        } else {
          totalObjectives++;
          if (budget.isCurrentlyActive) activeObjectives++;
        }
      }

      return {
        'totalBudgets': totalBudgets,
        'totalObjectives': totalObjectives,
        'activeBudgets': activeBudgets,
        'activeObjectives': activeObjectives,
        'overBudgetCount': overBudgetCount,
        'totalBudgetAmount': totalBudgetAmount,
        'totalSpent': totalSpent,
        'averageSpentPercentage': totalBudgetAmount > 0 ? (totalSpent / totalBudgetAmount * 100) : 0,
      };
    } catch (e) {
      return {};
    }
  }
}