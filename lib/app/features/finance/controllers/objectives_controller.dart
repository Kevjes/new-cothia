import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/objective_model.dart';
import '../models/account_model.dart';
import '../models/category_model.dart';
import '../services/objective_service.dart';
import '../services/account_service.dart';
import '../services/category_service.dart';
import '../../../data/services/storage_service.dart';

class ObjectivesController extends GetxController {
  final ObjectiveService _objectiveService = ObjectiveService();
  final AccountService _accountService = AccountService();
  final CategoryService _categoryService = CategoryService();

  // Observables
  final _isLoading = false.obs;
  final _hasError = false.obs;
  final _errorMessage = ''.obs;
  final _objectives = <ObjectiveModel>[].obs;
  final _accounts = <AccountModel>[].obs;
  final _categories = <CategoryModel>[].obs;

  // Filters
  final _selectedStatus = Rx<ObjectiveStatus?>(null);
  final _selectedPriority = Rx<ObjectivePriority?>(null);
  final _selectedCategory = Rx<CategoryModel?>(null);
  final _selectedAccount = Rx<AccountModel?>(null);
  final _showCompleted = false.obs;
  final _searchQuery = RxString('');

  // Getters
  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;
  String get errorMessage => _errorMessage.value;
  List<ObjectiveModel> get objectives => _objectives;
  List<AccountModel> get accounts => _accounts;
  List<CategoryModel> get categories => _categories;

  // Filter getters
  Rx<ObjectiveStatus?> get selectedStatus => _selectedStatus;
  Rx<ObjectivePriority?> get selectedPriority => _selectedPriority;
  Rx<CategoryModel?> get selectedCategory => _selectedCategory;
  Rx<AccountModel?> get selectedAccount => _selectedAccount;
  RxBool get showCompleted => _showCompleted;
  RxString get searchQuery => _searchQuery;

  // Filtered objectives
  List<ObjectiveModel> get filteredObjectives {
    var filtered = List<ObjectiveModel>.from(_objectives);

    // Filter by status
    if (_selectedStatus.value != null) {
      filtered = filtered.where((o) => o.status == _selectedStatus.value).toList();
    } else if (!_showCompleted.value) {
      filtered = filtered.where((o) => !o.isCompleted).toList();
    }

    // Filter by priority
    if (_selectedPriority.value != null) {
      filtered = filtered.where((o) => o.priority == _selectedPriority.value).toList();
    }

    // Filter by category
    if (_selectedCategory.value != null) {
      filtered = filtered.where((o) => o.categoryId == _selectedCategory.value!.id).toList();
    }

    // Filter by account
    if (_selectedAccount.value != null) {
      filtered = filtered.where((o) => o.linkedAccountId == _selectedAccount.value!.id).toList();
    }

    // Filter by search query
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      filtered = filtered.where((o) =>
        o.name.toLowerCase().contains(query) ||
        (o.description?.toLowerCase().contains(query) ?? false) ||
        o.tags.any((tag) => tag.toLowerCase().contains(query))
      ).toList();
    }

    return filtered..sort((a, b) {
      // Sort by priority first, then by creation date
      final priorityComparison = b.priority.index.compareTo(a.priority.index);
      if (priorityComparison != 0) return priorityComparison;
      return b.createdAt.compareTo(a.createdAt);
    });
  }

  // Grouped objectives
  Map<ObjectiveStatus, List<ObjectiveModel>> get groupedObjectives {
    final groups = <ObjectiveStatus, List<ObjectiveModel>>{};
    for (final objective in filteredObjectives) {
      groups[objective.status] ??= [];
      groups[objective.status]!.add(objective);
    }
    return groups;
  }

  Map<ObjectivePriority, List<ObjectiveModel>> get objectivesByPriority {
    final groups = <ObjectivePriority, List<ObjectiveModel>>{};
    for (final objective in filteredObjectives.where((o) => o.isActive)) {
      groups[objective.priority] ??= [];
      groups[objective.priority]!.add(objective);
    }
    return groups;
  }

  // Additional methods for compatibility
  Future<void> refreshAllData() async {
    await _initializeData();
  }

  Future<void> retryInitialization() async {
    await _initializeData();
  }

  // Current entity ID getter
  String? get currentEntityId => _currentEntityId;

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

      await Future.wait([
        loadObjectives(),
        loadAccounts(),
        loadCategories(),
      ]);
    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadObjectives() async {
    try {
      if (_currentEntityId == null) return;
      final objectives = await _objectiveService.getObjectivesByEntity(_currentEntityId!);
      _objectives.assignAll(objectives);
    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = 'Erreur lors du chargement des objectifs: $e';
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

  Future<void> loadCategories() async {
    try {
      if (_currentEntityId == null) return;
      final categories = await _categoryService.getCategoriesByEntity(_currentEntityId!);
      _categories.assignAll(categories);
    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = 'Erreur lors du chargement des catégories: $e';
    }
  }

  Future<void> refreshData() async {
    await _initializeData();
  }

  // Objective CRUD operations
  Future<bool> createObjective(ObjectiveModel objective) async {
    try {
      _isLoading.value = true;

      // Injecter le bon entityId
      if (_currentEntityId == null) {
        throw Exception('Entity ID non initialisé');
      }

      final objectiveWithEntityId = objective.copyWith(entityId: _currentEntityId!);
      await _objectiveService.createObjective(objectiveWithEntityId);
      await loadObjectives();

      Get.snackbar(
        'Succès',
        'Objectif "${objective.name}" créé avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de créer l\'objectif: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> updateObjective(ObjectiveModel objective) async {
    try {
      _isLoading.value = true;
      await _objectiveService.updateObjective(objective.id, objective);
      await loadObjectives();

      Get.snackbar(
        'Succès',
        'Objectif "${objective.name}" modifié avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de modifier l\'objectif: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Ajouter un montant à un objectif
  Future<void> addToObjectiveAmount(String objectiveId, double amount) async {
    try {
      await _objectiveService.addToObjectiveAmount(objectiveId, amount);
      await loadObjectives();

      Get.snackbar(
        'Succès',
        'Montant ajouté à l\'objectif',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'ajouter le montant: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Retirer un montant d'un objectif
  Future<void> subtractFromObjectiveAmount(String objectiveId, double amount) async {
    try {
      await _objectiveService.subtractFromObjectiveAmount(objectiveId, amount);
      await loadObjectives();

      Get.snackbar(
        'Succès',
        'Montant retiré de l\'objectif',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de retirer le montant: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<bool> deleteObjective(String objectiveId) async {
    try {
      _isLoading.value = true;
      final objective = _objectives.firstWhere((o) => o.id == objectiveId);
      await _objectiveService.deleteObjective(objectiveId);
      await loadObjectives();

      Get.snackbar(
        'Succès',
        'Objectif "${objective.name}" supprimé avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de supprimer l\'objectif: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> duplicateObjectiveFromModel(ObjectiveModel objective) async {
    try {
      if (_currentEntityId == null) {
        throw Exception('Entity ID non initialisé');
      }

      final duplicated = objective.copyWith(
        id: '',
        name: '${objective.name} (Copie)',
        currentAmount: 0.0,
        status: ObjectiveStatus.active,
        entityId: _currentEntityId!,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      return await createObjective(duplicated);
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de dupliquer l\'objectif: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // Dupliquer un objectif avec un nouveau nom
  Future<void> duplicateObjective(String objectiveId, String newName) async {
    try {
      await _objectiveService.duplicateObjective(objectiveId, newName);
      await loadObjectives();

      Get.snackbar(
        'Succès',
        'Objectif dupliqué avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de dupliquer l\'objectif: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Objective status operations
  Future<bool> completeObjective(String objectiveId) async {
    try {
      await _objectiveService.completeObjective(objectiveId);
      await loadObjectives();

      Get.snackbar(
        'Succès',
        'Objectif marqué comme terminé',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de terminer l\'objectif: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  Future<bool> pauseObjective(String objectiveId) async {
    try {
      await _objectiveService.pauseObjective(objectiveId);
      await loadObjectives();

      Get.snackbar(
        'Succès',
        'Objectif mis en pause',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de mettre en pause l\'objectif: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  Future<bool> resumeObjective(String objectiveId) async {
    try {
      await _objectiveService.resumeObjective(objectiveId);
      await loadObjectives();

      Get.snackbar(
        'Succès',
        'Objectif repris',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de reprendre l\'objectif: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  Future<bool> cancelObjective(String objectiveId) async {
    try {
      await _objectiveService.cancelObjective(objectiveId);
      await loadObjectives();

      Get.snackbar(
        'Succès',
        'Objectif annulé',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'annuler l\'objectif: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // Amount operations
  Future<bool> updateObjectiveAmount(String objectiveId, double newAmount) async {
    try {
      await _objectiveService.updateObjectiveCurrentAmount(objectiveId, newAmount);
      await loadObjectives();

      Get.snackbar(
        'Succès',
        'Montant mis à jour',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour le montant: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  Future<bool> addToObjective(String objectiveId, double amount) async {
    try {
      await _objectiveService.addToObjectiveAmount(objectiveId, amount);
      await loadObjectives();

      Get.snackbar(
        'Succès',
        '${amount.toStringAsFixed(0)} FCFA ajoutés à l\'objectif',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'ajouter le montant: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  Future<bool> subtractFromObjective(String objectiveId, double amount) async {
    try {
      await _objectiveService.subtractFromObjectiveAmount(objectiveId, amount);
      await loadObjectives();

      Get.snackbar(
        'Succès',
        '${amount.toStringAsFixed(0)} FCFA retirés de l\'objectif',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de retirer le montant: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // Auto allocation
  Future<void> executeMonthlyAutoAllocation() async {
    try {
      _isLoading.value = true;
      final results = await _objectiveService.executeMonthlyAutoAllocation(_currentEntityId!);
      await loadObjectives();

      final successCount = results.where((r) => r['success'] == true).length;
      final totalCount = results.length;

      Get.snackbar(
        'Allocation automatique',
        'Allocation réussie pour $successCount/$totalCount objectifs',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: successCount == totalCount ? Colors.green : Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de l\'allocation automatique: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Filter methods
  void setStatusFilter(ObjectiveStatus? status) {
    _selectedStatus.value = status;
  }

  void setPriorityFilter(ObjectivePriority? priority) {
    _selectedPriority.value = priority;
  }

  void setCategoryFilter(CategoryModel? category) {
    _selectedCategory.value = category;
  }

  void setAccountFilter(AccountModel? account) {
    _selectedAccount.value = account;
  }

  void toggleShowCompleted() {
    _showCompleted.value = !_showCompleted.value;
  }

  void setSearchQuery(String query) {
    _searchQuery.value = query;
  }

  void clearAllFilters() {
    _selectedStatus.value = null;
    _selectedPriority.value = null;
    _selectedCategory.value = null;
    _selectedAccount.value = null;
    _showCompleted.value = false;
    _searchQuery.value = '';
  }

  // Statistics
  double get totalTargetAmount {
    return filteredObjectives
        .where((o) => o.isActive)
        .fold(0.0, (sum, o) => sum + o.targetAmount);
  }

  double get totalCurrentAmount {
    return filteredObjectives
        .where((o) => o.isActive)
        .fold(0.0, (sum, o) => sum + o.currentAmount);
  }

  double get totalProgress {
    return totalTargetAmount > 0 ? (totalCurrentAmount / totalTargetAmount * 100) : 0.0;
  }

  int get activeObjectivesCount {
    return filteredObjectives.where((o) => o.isActive).length;
  }

  int get completedObjectivesCount {
    return filteredObjectives.where((o) => o.isCompleted).length;
  }

  int get behindScheduleCount {
    return filteredObjectives.where((o) => o.isActive && o.isBehindSchedule).length;
  }

  List<ObjectiveModel> get nearTargetObjectives {
    return filteredObjectives
        .where((o) => o.isActive && o.progressPercentage >= 80)
        .toList();
  }

  List<ObjectiveModel> get behindScheduleObjectives {
    return filteredObjectives
        .where((o) => o.isActive && o.isBehindSchedule)
        .toList();
  }

  // Helper methods
  ObjectiveModel? findObjectiveById(String objectiveId) {
    return _objectives.where((o) => o.id == objectiveId).firstOrNull;
  }

  AccountModel? findAccountById(String? accountId) {
    if (accountId == null) return null;
    return _accounts.where((a) => a.id == accountId).firstOrNull;
  }

  CategoryModel? findCategoryById(String? categoryId) {
    if (categoryId == null) return null;
    return _categories.where((c) => c.id == categoryId).firstOrNull;
  }

  // Export functionality
  Future<void> exportObjectives() async {
    try {
      final objectives = filteredObjectives;
      if (objectives.isEmpty) {
        Get.snackbar(
          'Info',
          'Aucun objectif à exporter',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Format CSV simple
      final csvData = StringBuffer();
      csvData.writeln('Nom,Montant Cible,Montant Actuel,Progression %,Priorité,Statut,Échéance');

      for (final objective in objectives) {
        final name = objective.name.replaceAll(',', ';');
        final deadline = objective.targetDate != null
            ? '${objective.targetDate!.day}/${objective.targetDate!.month}/${objective.targetDate!.year}'
            : 'Non définie';

        csvData.writeln('$name,${objective.targetAmount},${objective.currentAmount},${objective.progressPercentage.toStringAsFixed(1)},${objective.priority.name},${objective.status.name},$deadline');
      }

      Get.snackbar(
        'Succès',
        '${objectives.length} objectifs exportés (format CSV)',
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

  // Objectives stats for analytics
  Map<String, dynamic> get objectivesStats {
    final completed = _objectives.where((obj) => obj.isCompleted).length;
    final active = _objectives.where((obj) => obj.isActive).length;
    final paused = _objectives.where((obj) => obj.isPaused).length;
    final totalSaved = _objectives.fold(0.0, (sum, obj) => sum + obj.currentAmount);
    final totalTarget = _objectives.fold(0.0, (sum, obj) => sum + obj.targetAmount);

    return {
      'total': _objectives.length,
      'completed': completed,
      'active': active,
      'paused': paused,
      'totalSaved': totalSaved,
      'totalTarget': totalTarget,
      'completion': totalTarget > 0 ? (totalSaved / totalTarget * 100) : 0.0,
    };
  }
}