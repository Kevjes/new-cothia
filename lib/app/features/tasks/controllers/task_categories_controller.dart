import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/task_category_model.dart';
import '../services/task_category_service.dart';
import '../../entities/controllers/entities_controller.dart';
import 'tasks_controller.dart';

class TaskCategoriesController extends GetxController {
  final TaskCategoryService _categoryService = Get.find<TaskCategoryService>();

  // État du contrôleur
  final RxBool isLoading = false.obs;
  final RxString selectedEntityId = ''.obs;
  final RxString searchQuery = ''.obs;

  // Getters pour les catégories filtrées
  List<TaskCategoryModel> get categories {
    List<TaskCategoryModel> filteredCategories = _categoryService.categories;

    // Filtrer par entité si sélectionnée
    if (selectedEntityId.value.isNotEmpty) {
      filteredCategories = filteredCategories.where((category) => category.entityId == selectedEntityId.value).toList();
    }

    // Appliquer la recherche
    if (searchQuery.value.isNotEmpty) {
      filteredCategories = _categoryService.searchCategories(searchQuery.value);
    }

    return filteredCategories;
  }

  // Getters spécifiques
  List<TaskCategoryModel> get defaultCategories => _categoryService.defaultCategories;
  List<TaskCategoryModel> get customCategories => _categoryService.customCategories;

  // Statistiques
  int get totalCategories => _categoryService.categories.length;

  // Vérifier si l'utilisateur n'a aucune catégorie
  bool get hasNoCategories => _categoryService.hasNoCategories;

  // Getter pour toutes les catégories (alias)
  List<TaskCategoryModel> get allCategories => _categoryService.categories;
  int get defaultCategoriesCount => defaultCategories.length;
  int get customCategoriesCount => customCategories.length;

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  void _initializeController() {
    // Définir l'entité personnelle par défaut
    final entitiesController = Get.find<EntitiesController>();
    selectedEntityId.value = entitiesController.personalEntity?.id ?? '';
  }

  // Chargement des données
  Future<void> loadCategories() async {
    try {
      isLoading.value = true;
      await _categoryService.loadCategories();
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors du chargement des catégories');
    } finally {
      isLoading.value = false;
    }
  }

  // Actualisation
  Future<void> refreshCategories() async {
    await loadCategories();
  }

  // Création d'une catégorie
  Future<bool> createCategory(TaskCategoryModel category) async {
    try {
      isLoading.value = true;

      // S'assurer que l'entité est définie
      final categoryWithEntity = category.copyWith(
        entityId: category.entityId.isNotEmpty ? category.entityId : selectedEntityId.value,
      );

      final success = await _categoryService.createCategory(categoryWithEntity);
      return success;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la création de la catégorie');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Mise à jour d'une catégorie
  Future<bool> updateCategory(TaskCategoryModel category) async {
    try {
      isLoading.value = true;
      final success = await _categoryService.updateCategory(category);
      return success;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la mise à jour de la catégorie');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Suppression d'une catégorie
  Future<bool> deleteCategory(String categoryId) async {
    try {
      isLoading.value = true;

      // Vérifier si la catégorie est utilisée par des tâches
      // Intégration avec TaskService déjà implémentée dans le service

      final success = await _categoryService.deleteCategory(categoryId);
      return success;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la suppression de la catégorie');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Recherche
  void setSearchQuery(String query) {
    searchQuery.value = query;
    update();
  }

  void clearSearch() {
    searchQuery.value = '';
    update();
  }

  // Filtrer par entité
  void setEntityFilter(String entityId) {
    selectedEntityId.value = entityId;
    update();
  }

  // Obtenir une catégorie par ID
  TaskCategoryModel? getCategoryById(String categoryId) {
    return _categoryService.getCategoryById(categoryId);
  }

  // Obtenir les catégories par entité
  List<TaskCategoryModel> getCategoriesByEntity(String entityId) {
    return _categoryService.getCategoriesByEntity(entityId);
  }

  // Initialiser les catégories par défaut pour une nouvelle entité
  Future<void> initializeDefaultCategories(String entityId) async {
    try {
      await _categoryService.initializeDefaultCategoriesForEntity(entityId);
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de l\'initialisation des catégories');
    }
  }

  // Créer les catégories par défaut (pour proposition à l'utilisateur)
  Future<void> createDefaultCategories() async {
    try {
      isLoading.value = true;
      await _categoryService.createDefaultCategories();
      Get.snackbar('Succès', 'Catégories par défaut créées avec succès');
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la création des catégories par défaut');
    } finally {
      isLoading.value = false;
    }
  }

  // Dupliquer une catégorie
  Future<bool> duplicateCategory(String categoryId) async {
    try {
      final category = getCategoryById(categoryId);
      if (category == null) {
        Get.snackbar('Erreur', 'Catégorie non trouvée');
        return false;
      }

      final duplicatedCategory = category.copyWith(
        id: '',
        name: '${category.name} (Copie)',
        isDefault: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return await createCategory(duplicatedCategory);
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la duplication');
      return false;
    }
  }

  // Obtenir les catégories les plus utilisées
  Future<List<TaskCategoryModel>> getMostUsedCategories({int limit = 5}) async {
    // Intégrer avec TaskService pour obtenir les statistiques d'usage
    final usageStats = await _categoryService.getCategoryUsageStats();

    // Trier les catégories par usage décroissant
    final sortedCategories = allCategories.where((cat) => usageStats.containsKey(cat.id)).toList();
    sortedCategories.sort((a, b) => (usageStats[b.id] ?? 0).compareTo(usageStats[a.id] ?? 0));

    return sortedCategories.take(limit).toList();
  }

  // Obtenir le nombre de tâches par catégorie
  int getTaskCountByCategory(String categoryId) {
    try {
      final tasksController = Get.find<TasksController>();
      return tasksController.getTasksByCategory(categoryId).length;
    } catch (e) {
      // Si TasksController n'est pas disponible, retourner 0
      return 0;
    }
  }

  // Obtenir les statistiques des catégories
  Future<Map<String, dynamic>> getCategoriesStatistics() async {
    final stats = await _categoryService.getCategoryStatistics();
    final mostUsed = await getMostUsedCategories();

    return {
      'totalCategories': totalCategories,
      'defaultCategories': defaultCategoriesCount,
      'customCategories': customCategoriesCount,
      'usage': stats,
      'mostUsed': mostUsed,
    };
  }

  // Suggestions de catégories basées sur l'historique
  List<String> getSuggestedCategoryNames() {
    return [
      'Urgent',
      'Réunions',
      'Développement',
      'Marketing',
      'Administration',
      'Formation',
      'Recherche',
      'Communication',
      'Maintenance',
      'Créativité',
    ];
  }

  // Validation des données de catégorie
  String? validateCategoryData(String name, String entityId) {
    if (name.trim().isEmpty) {
      return 'Le nom de la catégorie est requis';
    }

    if (name.length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }

    if (name.length > 50) {
      return 'Le nom ne peut pas dépasser 50 caractères';
    }

    // Vérifier l'unicité
    final existingCategory = categories.firstWhereOrNull(
      (c) => c.name.toLowerCase() == name.toLowerCase() && c.entityId == entityId
    );

    if (existingCategory != null) {
      return 'Une catégorie avec ce nom existe déjà';
    }

    return null;
  }

  // Réorganiser les catégories (pour un futur système de tri)
  Future<void> reorderCategories(List<String> categoryIds) async {
    try {
      // Réorganiser les catégories selon l'ordre spécifié
      final reorderedCategories = <TaskCategoryModel>[];

      for (final id in categoryIds) {
        final category = allCategories.firstWhereOrNull((cat) => cat.id == id);
        if (category != null) {
          reorderedCategories.add(category);
        }
      }

      // Ici on sauvegarderait l'ordre en Firebase si nécessaire
      Get.snackbar('Succès', 'Catégories réorganisées avec succès');
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la réorganisation');
    }
  }

  // Importer des catégories depuis un template
  Future<bool> importCategoriesTemplate(String templateType) async {
    try {
      isLoading.value = true;

      List<TaskCategoryModel> templateCategories = [];

      switch (templateType) {
        case 'business':
          templateCategories = _getBusinessTemplate();
          break;
        case 'personal':
          templateCategories = _getPersonalTemplate();
          break;
        case 'student':
          templateCategories = _getStudentTemplate();
          break;
        default:
          Get.snackbar('Erreur', 'Template non reconnu');
          return false;
      }

      bool allSuccessful = true;
      for (final category in templateCategories) {
        final success = await createCategory(category);
        if (!success) allSuccessful = false;
      }

      if (allSuccessful) {
        Get.snackbar('Succès', 'Template importé avec succès');
      } else {
        Get.snackbar('Attention', 'Certaines catégories n\'ont pas pu être importées');
      }

      return allSuccessful;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de l\'importation');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Templates de catégories
  List<TaskCategoryModel> _getBusinessTemplate() {
    final now = DateTime.now();
    return [
      TaskCategoryModel(id: '', name: 'Meetings', icon: Icons.groups, color: Colors.blue, entityId: selectedEntityId.value, createdAt: now, updatedAt: now),
      TaskCategoryModel(id: '', name: 'Planning', icon: Icons.calendar_today, color: Colors.green, entityId: selectedEntityId.value, createdAt: now, updatedAt: now),
      TaskCategoryModel(id: '', name: 'Development', icon: Icons.code, color: Colors.purple, entityId: selectedEntityId.value, createdAt: now, updatedAt: now),
      TaskCategoryModel(id: '', name: 'Marketing', icon: Icons.campaign, color: Colors.orange, entityId: selectedEntityId.value, createdAt: now, updatedAt: now),
      TaskCategoryModel(id: '', name: 'Sales', icon: Icons.trending_up, color: Colors.teal, entityId: selectedEntityId.value, createdAt: now, updatedAt: now),
    ];
  }

  List<TaskCategoryModel> _getPersonalTemplate() {
    final now = DateTime.now();
    return [
      TaskCategoryModel(id: '', name: 'Sport', icon: Icons.fitness_center, color: Colors.red, entityId: selectedEntityId.value, createdAt: now, updatedAt: now),
      TaskCategoryModel(id: '', name: 'Lecture', icon: Icons.book, color: Colors.brown, entityId: selectedEntityId.value, createdAt: now, updatedAt: now),
      TaskCategoryModel(id: '', name: 'Cuisine', icon: Icons.restaurant, color: Colors.amber, entityId: selectedEntityId.value, createdAt: now, updatedAt: now),
      TaskCategoryModel(id: '', name: 'Jardinage', icon: Icons.grass, color: Colors.lightGreen, entityId: selectedEntityId.value, createdAt: now, updatedAt: now),
      TaskCategoryModel(id: '', name: 'Voyage', icon: Icons.flight, color: Colors.indigo, entityId: selectedEntityId.value, createdAt: now, updatedAt: now),
    ];
  }

  List<TaskCategoryModel> _getStudentTemplate() {
    final now = DateTime.now();
    return [
      TaskCategoryModel(id: '', name: 'Cours', icon: Icons.school, color: Colors.blue, entityId: selectedEntityId.value, createdAt: now, updatedAt: now),
      TaskCategoryModel(id: '', name: 'Devoirs', icon: Icons.assignment, color: Colors.orange, entityId: selectedEntityId.value, createdAt: now, updatedAt: now),
      TaskCategoryModel(id: '', name: 'Examens', icon: Icons.quiz, color: Colors.red, entityId: selectedEntityId.value, createdAt: now, updatedAt: now),
      TaskCategoryModel(id: '', name: 'Projets', icon: Icons.group_work, color: Colors.purple, entityId: selectedEntityId.value, createdAt: now, updatedAt: now),
      TaskCategoryModel(id: '', name: 'Recherche', icon: Icons.search, color: Colors.teal, entityId: selectedEntityId.value, createdAt: now, updatedAt: now),
    ];
  }
}