import 'package:get/get.dart';
import '../../../data/services/budgets_service.dart';
import '../models/budget_model.dart';
import '../models/currency.dart';
import 'dart:async';

class BudgetsController extends GetxController {
  static BudgetsController get to => Get.find<BudgetsController>();

  final BudgetsService _budgetsService = BudgetsService.to;

  final _budgets = <BudgetModel>[].obs;
  final _objectives = <BudgetModel>[].obs;
  final _isLoading = false.obs;
  final _selectedType = BudgetType.budget.obs;
  StreamSubscription<List<BudgetModel>>? _budgetsSubscription;
  StreamSubscription<List<BudgetModel>>? _objectivesSubscription;

  List<BudgetModel> get budgets => _budgets;
  List<BudgetModel> get objectives => _objectives;
  List<BudgetModel> get allItems => [..._budgets, ..._objectives];
  bool get isLoading => _isLoading.value;
  BudgetType get selectedType => _selectedType.value;

  List<BudgetModel> get activeBudgets => _budgets.where((b) => b.isCurrentlyActive).toList();
  List<BudgetModel> get activeObjectives => _objectives.where((o) => o.isCurrentlyActive).toList();

  @override
  void onInit() {
    super.onInit();
    _initializeBudgetsData();
  }

  @override
  void onClose() {
    _budgetsSubscription?.cancel();
    _objectivesSubscription?.cancel();
    super.onClose();
  }

  Future<void> _initializeBudgetsData() async {
    _isLoading.value = true;

    // Écouter les budgets en temps réel
    _budgetsSubscription = _budgetsService.getBudgetsOnlyStream().listen((budgets) {
      _budgets.value = budgets;
      _isLoading.value = false;
    });

    // Écouter les objectifs en temps réel
    _objectivesSubscription = _budgetsService.getObjectivesStream().listen((objectives) {
      _objectives.value = objectives;
    });
  }

  void changeSelectedType(BudgetType type) {
    _selectedType.value = type;
  }

  // ==================== MÉTHODES CRUD ====================

  Future<bool> createBudget({
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
      _isLoading.value = true;

      // Vérifier si le nom existe déjà
      final nameExists = await _budgetsService.budgetNameExists(name);
      if (nameExists) {
        Get.snackbar(
          'Erreur',
          'Un ${type.label.toLowerCase()} avec ce nom existe déjà',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      final budgetId = await _budgetsService.createBudget(
        name: name,
        description: description,
        type: type,
        amount: amount,
        currency: currency,
        period: period,
        startDate: startDate,
        endDate: endDate,
        categoryIds: categoryIds,
        accountId: accountId,
        isRecurrent: isRecurrent,
        icon: icon,
        color: color,
      );

      if (budgetId != null) {
        Get.snackbar(
          'Succès',
          '${type.label} "$name" créé${type == BudgetType.budget ? '' : 'e'} avec succès',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de créer ${type.label.toLowerCase()}: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

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
      _isLoading.value = true;

      // Vérifier si le nom existe déjà (excluant l'élément actuel)
      final nameExists = await _budgetsService.budgetNameExists(name, excludeId: budgetId);
      if (nameExists) {
        Get.snackbar(
          'Erreur',
          'Un autre ${type.label.toLowerCase()} avec ce nom existe déjà',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      final success = await _budgetsService.updateBudget(
        budgetId: budgetId,
        name: name,
        description: description,
        type: type,
        amount: amount,
        currency: currency,
        period: period,
        startDate: startDate,
        endDate: endDate,
        categoryIds: categoryIds,
        accountId: accountId,
        isRecurrent: isRecurrent,
        icon: icon,
        color: color,
      );

      if (success) {
        Get.snackbar(
          'Succès',
          '${type.label} "$name" modifié${type == BudgetType.budget ? '' : 'e'} avec succès',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de modifier ${type.label.toLowerCase()}: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> deleteBudget(String budgetId, BudgetType type) async {
    try {
      _isLoading.value = true;

      final success = await _budgetsService.deleteBudget(budgetId);

      if (success) {
        Get.snackbar(
          'Succès',
          '${type.label} supprimé${type == BudgetType.budget ? '' : 'e'} avec succès',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de supprimer ${type.label.toLowerCase()}: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> updateSpentAmount(String budgetId, double spentAmount) async {
    try {
      return await _budgetsService.updateSpentAmount(
        budgetId: budgetId,
        spentAmount: spentAmount,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour le montant: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<BudgetModel?> getBudgetById(String budgetId) async {
    return await _budgetsService.getBudgetById(budgetId);
  }

  Future<Map<String, dynamic>> getBudgetsStats() async {
    return await _budgetsService.getBudgetsStats();
  }

  // ==================== FONCTIONNALITÉS SPÉCIALES ====================

  Future<void> renewExpiredBudgets() async {
    final expiredBudgets = allItems.where((item) =>
      item.isRecurrent &&
      DateTime.now().isAfter(item.endDate)
    ).toList();

    for (final budget in expiredBudgets) {
      await _budgetsService.renewBudget(budget);
    }
  }

  List<BudgetModel> getOverBudgets() {
    return _budgets.where((budget) => budget.isOverBudget).toList();
  }

  List<BudgetModel> getNearingDeadline({int days = 7}) {
    return allItems.where((item) =>
      item.daysRemaining <= days &&
      item.daysRemaining > 0
    ).toList();
  }

  double getTotalBudgetAmount() {
    return _budgets.fold(0.0, (sum, budget) => sum + budget.amount);
  }

  double getTotalSpent() {
    return _budgets.fold(0.0, (sum, budget) => sum + budget.spent);
  }

  double getTotalObjectivesAmount() {
    return _objectives.fold(0.0, (sum, obj) => sum + obj.amount);
  }

  double getTotalObjectivesSaved() {
    return _objectives.fold(0.0, (sum, obj) => sum + obj.spent);
  }

  // ==================== MÉTHODES UTILITAIRES ====================

  List<BudgetModel> filterByPeriod(BudgetPeriod period) {
    return allItems.where((item) => item.period == period).toList();
  }

  List<BudgetModel> filterByAccount(String accountId) {
    return allItems.where((item) => item.accountId == accountId).toList();
  }

  List<BudgetModel> searchItems(String query) {
    final lowercaseQuery = query.toLowerCase();
    return allItems.where((item) =>
      item.name.toLowerCase().contains(lowercaseQuery) ||
      (item.description?.toLowerCase().contains(lowercaseQuery) ?? false)
    ).toList();
  }

  // ==================== NAVIGATION ====================

  void goToBudgetCreate() {
    Get.toNamed('/finance/budgets/create');
  }

  void goToBudgetEdit(BudgetModel budget) {
    Get.toNamed('/finance/budgets/edit', arguments: budget);
  }

  void goToBudgetDetails(BudgetModel budget) {
    Get.toNamed('/finance/budgets/details', arguments: budget);
  }

  // ==================== REFRESH ====================

  Future<void> refreshData() async {
    // Les streams se rechargent automatiquement
    _isLoading.value = true;
    await Future.delayed(Duration(milliseconds: 500));
    _isLoading.value = false;
  }
}