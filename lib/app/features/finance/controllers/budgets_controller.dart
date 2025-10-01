import 'package:get/get.dart';
import '../models/budget_model.dart';
import '../services/budget_service.dart';
import '../../../data/services/storage_service.dart';

class BudgetsController extends GetxController {
  final BudgetService _budgetService = BudgetService();

  // Observable lists
  final RxList<BudgetModel> _budgets = <BudgetModel>[].obs;
  final RxList<BudgetModel> _filteredBudgets = <BudgetModel>[].obs;

  // Loading and error states
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  // Filters and search
  final RxString _searchTerm = ''.obs;
  final Rx<BudgetType?> _selectedBudgetType = Rx<BudgetType?>(null);
  final RxString _selectedStatus = 'all'.obs; // all, active, exceeded, completed
  final RxString _selectedPeriod = 'all'.obs; // all, monthly, weekly, yearly
  final RxBool _showOnlyActive = true.obs;

  // Statistics
  final RxMap<String, dynamic> _budgetStats = <String, dynamic>{}.obs;

  // Getters
  List<BudgetModel> get budgets => _budgets;
  List<BudgetModel> get filteredBudgets => _filteredBudgets;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  bool get hasError => _error.value.isNotEmpty;
  String get errorMessage => _error.value;
  bool get hasBudgets => _budgets.isNotEmpty;
  Map<String, dynamic> get budgetStats => _budgetStats;

  // Filter getters
  Rx<BudgetType?> get selectedBudgetType => _selectedBudgetType;
  Rx<String> get selectedBudgetPeriod => _selectedPeriod;
  Rx<String> get selectedBudgetStatus => _selectedStatus;

  // Additional methods for compatibility
  Future<void> refreshAllData() async {
    await loadBudgets();
  }

  Future<void> retryInitialization() async {
    await loadBudgets();
  }

  // Current entity ID getter
  String? get currentEntityId => _currentEntityId;

  // Current entity ID (should come from a global state/user service)
  String? _currentEntityId;

  @override
  void onInit() {
    super.onInit();
    _initializeController();
    _setupSearchListener();
  }

  Future<void> _initializeController() async {
    try {
      final storageService = await StorageService.getInstance();
      _currentEntityId = storageService.getPersonalEntityId();

      if (_currentEntityId == null || _currentEntityId!.isEmpty) {
        throw Exception('Entity ID not found');
      }

      await loadBudgets();
    } catch (e) {
      _error.value = 'Erreur d\'initialisation: $e';
    }
  }

  void _setupSearchListener() {
    // Update filtered list when search term or filters change
    ever(_searchTerm, (_) => _applyFilters());
    ever(_selectedStatus, (_) => _applyFilters());
    ever(_selectedPeriod, (_) => _applyFilters());
    ever(_showOnlyActive, (_) => _applyFilters());
    ever(_budgets, (_) => _applyFilters());
  }

  // Load budgets from service
  Future<void> loadBudgets() async {
    if (_currentEntityId == null) return;

    try {
      _isLoading.value = true;
      _error.value = '';

      final budgets = await _budgetService.getBudgetsByEntity(_currentEntityId!);
      _budgets.assignAll(budgets);
      await _calculateStats();
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Erreur', 'Impossible de charger les budgets: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // Create a new budget
  Future<bool> createBudget(BudgetModel budget) async {
    if (_currentEntityId == null) return false;

    try {
      _isLoading.value = true;

      final budgetWithEntityId = budget.copyWith(entityId: _currentEntityId!);
      final budgetId = await _budgetService.createBudget(budgetWithEntityId);

      // Add to local list with the new ID
      final newBudget = budgetWithEntityId.copyWith(id: budgetId);
      _budgets.add(newBudget);

      await _calculateStats();
      Get.snackbar('Succès', 'Budget créé avec succès');
      return true;
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de créer le budget: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Update an existing budget
  Future<bool> updateBudget(BudgetModel budget) async {
    try {
      _isLoading.value = true;

      await _budgetService.updateBudget(budget.id, budget);

      // Update local list
      final index = _budgets.indexWhere((b) => b.id == budget.id);
      if (index != -1) {
        _budgets[index] = budget;
        _budgets.refresh();
      }

      await _calculateStats();
      Get.snackbar('Succès', 'Budget modifié avec succès');
      return true;
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de modifier le budget: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Delete a budget
  Future<bool> deleteBudget(String budgetId) async {
    try {
      _isLoading.value = true;

      await _budgetService.deleteBudget(budgetId);

      // Remove from local list
      _budgets.removeWhere((b) => b.id == budgetId);

      await _calculateStats();
      Get.snackbar('Succès', 'Budget supprimé avec succès');
      return true;
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de supprimer le budget: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Toggle budget active status
  Future<bool> toggleBudgetStatus(String budgetId) async {
    try {
      final budget = _budgets.firstWhere((b) => b.id == budgetId);
      final updatedBudget = budget.copyWith(isActive: !budget.isActive);

      return await updateBudget(updatedBudget);
    } catch (e) {
      Get.snackbar('Erreur', 'Budget non trouvé');
      return false;
    }
  }

  // Reset budget spent amount
  Future<bool> resetBudget(String budgetId) async {
    try {
      final budget = _budgets.firstWhere((b) => b.id == budgetId);
      final updatedBudget = budget.copyWith(
        spentAmount: 0.0,
        updatedAt: DateTime.now(),
      );

      return await updateBudget(updatedBudget);
    } catch (e) {
      Get.snackbar('Erreur', 'Budget non trouvé');
      return false;
    }
  }

  // Add expense to budget
  Future<bool> addExpenseToBudget(String budgetId, double amount) async {
    try {
      await _budgetService.addExpenseToBudget(budgetId, amount);

      // Update local budget
      final index = _budgets.indexWhere((b) => b.id == budgetId);
      if (index != -1) {
        final budget = _budgets[index];
        final updatedBudget = budget.copyWith(
          spentAmount: budget.spentAmount + amount,
          updatedAt: DateTime.now(),
        );
        _budgets[index] = updatedBudget;
        _budgets.refresh();
      }

      await _calculateStats();
      return true;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de l\'ajout de la dépense: $e');
      return false;
    }
  }

  // Remove expense from budget
  Future<bool> removeExpenseFromBudget(String budgetId, double amount) async {
    try {
      await _budgetService.removeExpenseFromBudget(budgetId, amount);

      // Update local budget
      final index = _budgets.indexWhere((b) => b.id == budgetId);
      if (index != -1) {
        final budget = _budgets[index];
        final newSpentAmount = (budget.spentAmount - amount).clamp(0.0, double.infinity);
        final updatedBudget = budget.copyWith(
          spentAmount: newSpentAmount,
          updatedAt: DateTime.now(),
        );
        _budgets[index] = updatedBudget;
        _budgets.refresh();
      }

      await _calculateStats();
      return true;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la suppression de la dépense: $e');
      return false;
    }
  }

  // Update budget automation rule
  Future<bool> updateBudgetAutomation(String budgetId, AutomationRule automationRule) async {
    try {
      await _budgetService.updateBudgetAutomation(budgetId, automationRule);

      // Update local budget
      final index = _budgets.indexWhere((b) => b.id == budgetId);
      if (index != -1) {
        final budget = _budgets[index];
        final updatedBudget = budget.copyWith(
          automationRule: automationRule,
          updatedAt: DateTime.now(),
        );
        _budgets[index] = updatedBudget;
        _budgets.refresh();
      }

      await _calculateStats();
      return true;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la suppression de la dépense: $e');
      return false;
    }
  }

  // Search and filter methods
  void setSearchTerm(String term) {
    _searchTerm.value = term;
  }

  void setStatusFilter(String status) {
    _selectedStatus.value = status;
  }

  void setPeriodFilter(String period) {
    _selectedPeriod.value = period;
  }

  void toggleShowOnlyActive() {
    _showOnlyActive.value = !_showOnlyActive.value;
  }

  void clearFilters() {
    _searchTerm.value = '';
    _selectedStatus.value = 'all';
    _selectedPeriod.value = 'all';
    _showOnlyActive.value = true;
  }

  void _applyFilters() {
    var filtered = _budgets.where((budget) {
      // Search term filter
      final searchMatch = _searchTerm.value.isEmpty ||
          budget.name.toLowerCase().contains(_searchTerm.value.toLowerCase()) ||
          (budget.description?.toLowerCase().contains(_searchTerm.value.toLowerCase()) ?? false);

      // Status filter
      bool statusMatch = true;
      if (_selectedStatus.value != 'all') {
        switch (_selectedStatus.value) {
          case 'active':
            statusMatch = budget.isActive;
            break;
          case 'exceeded':
            statusMatch = budget.isExceeded;
            break;
          case 'completed':
            statusMatch = budget.progressPercentage >= 100;
            break;
        }
      }

      // Period filter
      bool periodMatch = true;
      if (_selectedPeriod.value != 'all') {
        periodMatch = budget.period.name == _selectedPeriod.value;
      }

      // Active status filter
      final activeMatch = !_showOnlyActive.value || budget.isActive;

      return searchMatch && statusMatch && periodMatch && activeMatch;
    }).toList();

    // Sort by name
    filtered.sort((a, b) => a.name.compareTo(b.name));

    _filteredBudgets.assignAll(filtered);
  }

  // Get budget by ID
  BudgetModel? getBudgetById(String budgetId) {
    try {
      return _budgets.firstWhere((b) => b.id == budgetId);
    } catch (e) {
      return null;
    }
  }

  // Get budgets by category
  List<BudgetModel> getBudgetsByCategory(String categoryId) {
    return _budgets.where((b) => b.categoryIds.contains(categoryId) && b.isActive).toList();
  }

  // Get budgets by period
  List<BudgetModel> getBudgetsByPeriod(BudgetPeriod period) {
    return _budgets.where((b) => b.period == period && b.isActive).toList();
  }

  // Get exceeded budgets
  List<BudgetModel> get exceededBudgets {
    return _budgets.where((b) => b.isExceeded && b.isActive).toList();
  }

  // Get budgets close to limit
  List<BudgetModel> get budgetsCloseToLimit {
    return _budgets.where((b) =>
      b.progressPercentage >= 80 &&
      b.progressPercentage < 100 &&
      b.isActive
    ).toList();
  }

  // Get active budgets
  List<BudgetModel> get activeBudgets {
    return _budgets.where((b) => b.isActive).toList();
  }

  // Get inactive budgets
  List<BudgetModel> get inactiveBudgets {
    return _budgets.where((b) => !b.isActive).toList();
  }

  // Calculate and update statistics
  Future<void> _calculateStats() async {
    if (_currentEntityId == null) return;

    try {
      final stats = await _budgetService.getBudgetStats(_currentEntityId!);
      _budgetStats.assignAll(stats);
    } catch (e) {
      // Silent fail for stats
    }
  }

  // Bulk operations
  Future<bool> deleteMultipleBudgets(List<String> budgetIds) async {
    try {
      _isLoading.value = true;

      for (final budgetId in budgetIds) {
        await _budgetService.deleteBudget(budgetId);
        _budgets.removeWhere((b) => b.id == budgetId);
      }

      await _calculateStats();
      Get.snackbar('Succès', 'Budgets supprimés');
      return true;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la suppression: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> toggleMultipleBudgetsStatus(List<String> budgetIds, bool isActive) async {
    try {
      _isLoading.value = true;

      for (final budgetId in budgetIds) {
        final index = _budgets.indexWhere((b) => b.id == budgetId);
        if (index != -1) {
          final budget = _budgets[index];
          final updatedBudget = budget.copyWith(isActive: isActive);
          await _budgetService.updateBudget(budgetId, updatedBudget);
          _budgets[index] = updatedBudget;
        }
      }

      _budgets.refresh();
      await _calculateStats();
      Get.snackbar('Succès', isActive ? 'Budgets activés' : 'Budgets désactivés');
      return true;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la mise à jour: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Check if any budget is exceeded and show notifications
  void checkBudgetExceeded() {
    final exceeded = exceededBudgets;
    final closeToLimit = budgetsCloseToLimit;

    if (exceeded.isNotEmpty) {
      Get.snackbar(
        'Budget dépassé!',
        '${exceeded.length} budget(s) dépassé(s)',
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        colorText: Get.theme.colorScheme.error,
      );
    } else if (closeToLimit.isNotEmpty) {
      Get.snackbar(
        'Attention!',
        '${closeToLimit.length} budget(s) proche(s) de la limite',
        backgroundColor: Get.theme.colorScheme.secondary.withOpacity(0.1),
      );
    }
  }

  // Refresh data
  Future<void> refreshBudgets() async {
    await loadBudgets();
  }

  @override
  void onClose() {
    super.onClose();
  }
}