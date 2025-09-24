import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';
import '../../../data/services/storage_service.dart';

class CategoriesController extends GetxController {
  final CategoryService _categoryService = CategoryService();

  // Observable lists
  final RxList<CategoryModel> _categories = <CategoryModel>[].obs;
  final RxList<CategoryModel> _filteredCategories = <CategoryModel>[].obs;

  // Loading and error states
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  // Filters and search
  final RxString _searchTerm = ''.obs;
  final Rx<CategoryType?> _selectedCategoryType = Rx<CategoryType?>(null);
  final RxString _selectedType = 'all'.obs; // all, expense, income
  final RxBool _showOnlyActive = true.obs;

  // Getters
  List<CategoryModel> get categories => _categories;
  List<CategoryModel> get filteredCategories => _filteredCategories;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  bool get hasError => _error.value.isNotEmpty;
  String get errorMessage => _error.value;
  bool get hasCategories => _categories.isNotEmpty;

  // Additional getters for compatibility
  Future<void> refreshAllData() async {
    await loadCategories();
  }

  Future<void> retryInitialization() async {
    await loadCategories();
  }

  // Type filter getter
  Rx<CategoryType?> get selectedCategoryType => _selectedCategoryType;

  // Alias for createDefaultCategories
  Future<void> addDefaultCategories() async {
    await createDefaultCategories();
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

      await loadCategories();
    } catch (e) {
      _error.value = 'Erreur d\'initialisation: $e';
    }
  }

  void _setupSearchListener() {
    // Update filtered list when search term or filters change
    ever(_searchTerm, (_) => _applyFilters());
    ever(_selectedType, (_) => _applyFilters());
    ever(_showOnlyActive, (_) => _applyFilters());
    ever(_categories, (_) => _applyFilters());
  }

  // Load categories from service
  Future<void> loadCategories() async {
    if (_currentEntityId == null) return;

    try {
      _isLoading.value = true;
      _error.value = '';

      final categories = await _categoryService.getCategoriesByEntity(_currentEntityId!);
      _categories.assignAll(categories);
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Erreur', 'Impossible de charger les catégories: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // Create a new category
  Future<bool> createCategory(CategoryModel category) async {
    if (_currentEntityId == null) return false;

    try {
      _isLoading.value = true;

      final categoryWithEntityId = category.copyWith(entityId: _currentEntityId!);
      final categoryId = await _categoryService.createCategory(categoryWithEntityId);

      // Add to local list with the new ID
      final newCategory = categoryWithEntityId.copyWith(id: categoryId);
      _categories.add(newCategory);

      Get.snackbar('Succès', 'Catégorie créée avec succès');
      return true;
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de créer la catégorie: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Update an existing category
  Future<bool> updateCategory(CategoryModel category) async {
    try {
      _isLoading.value = true;

      await _categoryService.updateCategory(category.id, category);

      // Update local list
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
        _categories.refresh();
      }

      Get.snackbar('Succès', 'Catégorie modifiée avec succès');
      return true;
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de modifier la catégorie: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Delete a category
  Future<bool> deleteCategory(String categoryId) async {
    try {
      _isLoading.value = true;

      // Check if category is used in transactions
      final isUsed = await _categoryService.isCategoryUsed(categoryId);
      if (isUsed) {
        Get.snackbar(
          'Impossible de supprimer',
          'Cette catégorie est utilisée dans des transactions. Désactivez-la plutôt.',
        );
        return false;
      }

      await _categoryService.deleteCategory(categoryId);

      // Remove from local list
      _categories.removeWhere((c) => c.id == categoryId);

      Get.snackbar('Succès', 'Catégorie supprimée avec succès');
      return true;
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de supprimer la catégorie: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Toggle category active status
  Future<bool> toggleCategoryStatus(String categoryId) async {
    try {
      final category = _categories.firstWhere((c) => c.id == categoryId);
      final updatedCategory = category.copyWith(isActive: !category.isActive);

      return await updateCategory(updatedCategory);
    } catch (e) {
      Get.snackbar('Erreur', 'Catégorie non trouvée');
      return false;
    }
  }

  // Search and filter methods
  void setSearchTerm(String term) {
    _searchTerm.value = term;
  }

  void setTypeFilter(String type) {
    _selectedType.value = type;
  }

  void toggleShowOnlyActive() {
    _showOnlyActive.value = !_showOnlyActive.value;
  }

  void clearFilters() {
    _searchTerm.value = '';
    _selectedType.value = 'all';
    _showOnlyActive.value = true;
  }

  void _applyFilters() {
    var filtered = _categories.where((category) {
      // Search term filter
      final searchMatch = _searchTerm.value.isEmpty ||
          category.name.toLowerCase().contains(_searchTerm.value.toLowerCase()) ||
          (category.description?.toLowerCase().contains(_searchTerm.value.toLowerCase()) ?? false);

      // Type filter
      final typeMatch = _selectedType.value == 'all' ||
          category.type.name == _selectedType.value;

      // Active status filter
      final activeMatch = !_showOnlyActive.value || category.isActive;

      return searchMatch && typeMatch && activeMatch;
    }).toList();

    // Sort by name
    filtered.sort((a, b) => a.name.compareTo(b.name));

    _filteredCategories.assignAll(filtered);
  }

  // Get category by ID
  CategoryModel? getCategoryById(String categoryId) {
    try {
      return _categories.firstWhere((c) => c.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  // Get categories by type
  List<CategoryModel> getCategoriesByType(CategoryType type) {
    return _categories.where((c) => c.type == type && c.isActive).toList();
  }

  // Get expense categories
  List<CategoryModel> get expenseCategories {
    return getCategoriesByType(CategoryType.expense);
  }

  // Get income categories
  List<CategoryModel> get incomeCategories {
    return getCategoriesByType(CategoryType.income);
  }

  // Get active categories
  List<CategoryModel> get activeCategories {
    return _categories.where((c) => c.isActive).toList();
  }

  // Get inactive categories
  List<CategoryModel> get inactiveCategories {
    return _categories.where((c) => !c.isActive).toList();
  }

  // Statistics
  Map<String, dynamic> get categoryStats {
    final total = _categories.length;
    final active = activeCategories.length;
    final inactive = inactiveCategories.length;
    final expense = expenseCategories.length;
    final income = incomeCategories.length;

    return {
      'total': total,
      'active': active,
      'inactive': inactive,
      'expense': expense,
      'income': income,
    };
  }

  // Create default categories
  Future<void> createDefaultCategories() async {
    if (_currentEntityId == null) return;

    final defaultCategories = [
      // Expense categories
      CategoryModel(
        id: '',
        entityId: _currentEntityId!,
        name: 'Alimentation',
        description: 'Courses, restaurants, nourriture',
        type: CategoryType.expense,
        color: Colors.deepOrange,
        icon: Icons.restaurant,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CategoryModel(
        id: '',
        entityId: _currentEntityId!,
        name: 'Transport',
        description: 'Essence, transport public, taxi',
        type: CategoryType.expense,
        color: Colors.blue,
        icon: Icons.directions_car,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CategoryModel(
        id: '',
        entityId: _currentEntityId!,
        name: 'Logement',
        description: 'Loyer, électricité, eau, internet',
        type: CategoryType.expense,
        color: Colors.green,
        icon: Icons.home,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CategoryModel(
        id: '',
        entityId: _currentEntityId!,
        name: 'Santé',
        description: 'Médecin, pharmacie, assurance santé',
        type: CategoryType.expense,
        color: Colors.pink,
        icon: Icons.local_hospital,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CategoryModel(
        id: '',
        entityId: _currentEntityId!,
        name: 'Loisirs',
        description: 'Cinéma, sorties, hobbies',
        type: CategoryType.expense,
        color: Colors.purple,
        icon: Icons.movie,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      // Income categories
      CategoryModel(
        id: '',
        entityId: _currentEntityId!,
        name: 'Salaire',
        description: 'Revenus du travail',
        type: CategoryType.income,
        color: Colors.green,
        icon: Icons.work,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CategoryModel(
        id: '',
        entityId: _currentEntityId!,
        name: 'Freelance',
        description: 'Revenus indépendants',
        type: CategoryType.income,
        color: Colors.orange,
        icon: Icons.business,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CategoryModel(
        id: '',
        entityId: _currentEntityId!,
        name: 'Investissements',
        description: 'Dividendes, plus-values',
        type: CategoryType.income,
        color: Colors.indigo,
        icon: Icons.trending_up,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    try {
      for (final category in defaultCategories) {
        await createCategory(category);
      }
      Get.snackbar('Succès', 'Catégories par défaut créées');
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la création des catégories par défaut');
    }
  }

  // Bulk operations
  Future<bool> deleteMultipleCategories(List<String> categoryIds) async {
    try {
      _isLoading.value = true;

      for (final categoryId in categoryIds) {
        final isUsed = await _categoryService.isCategoryUsed(categoryId);
        if (!isUsed) {
          await _categoryService.deleteCategory(categoryId);
          _categories.removeWhere((c) => c.id == categoryId);
        }
      }

      Get.snackbar('Succès', 'Catégories supprimées');
      return true;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la suppression: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> toggleMultipleCategoriesStatus(List<String> categoryIds, bool isActive) async {
    try {
      _isLoading.value = true;

      for (final categoryId in categoryIds) {
        final index = _categories.indexWhere((c) => c.id == categoryId);
        if (index != -1) {
          final category = _categories[index];
          final updatedCategory = category.copyWith(isActive: isActive);
          await _categoryService.updateCategory(categoryId, updatedCategory);
          _categories[index] = updatedCategory;
        }
      }

      _categories.refresh();
      Get.snackbar('Succès', isActive ? 'Catégories activées' : 'Catégories désactivées');
      return true;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la mise à jour: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Refresh data
  Future<void> refreshCategories() async {
    await loadCategories();
  }

  @override
  void onClose() {
    super.onClose();
  }
}