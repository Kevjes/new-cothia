import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/task_category_model.dart';
import '../../entities/controllers/entities_controller.dart';

class TaskCategoryService extends GetxService {
  static TaskCategoryService get to => Get.find();

  // Liste réactive des catégories
  final RxList<TaskCategoryModel> _categories = <TaskCategoryModel>[].obs;

  // Getters
  List<TaskCategoryModel> get categories => _categories;

  List<TaskCategoryModel> get defaultCategories =>
    _categories.where((category) => category.isDefault).toList();

  List<TaskCategoryModel> get customCategories =>
    _categories.where((category) => !category.isDefault).toList();

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  // Chargement des catégories
  Future<void> loadCategories() async {
    try {
      // Charger les catégories par défaut pour l'entité personnelle
      final entitiesController = Get.find<EntitiesController>();
      final personalEntityId = entitiesController.personalEntity?.id ?? 'personal';

      // Ici on chargerait depuis Firebase
      // Pour l'instant, on utilise les catégories par défaut
      final defaultCategories = TaskCategoryModel.getDefaultCategories(personalEntityId);
      _categories.assignAll(defaultCategories);

    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors du chargement des catégories: $e');
    }
  }

  // Création d'une catégorie
  Future<bool> createCategory(TaskCategoryModel category) async {
    try {
      // Validation
      if (category.name.trim().isEmpty) {
        Get.snackbar('Erreur', 'Le nom de la catégorie est requis');
        return false;
      }

      // Vérifier si une catégorie avec le même nom existe déjà
      final existingCategory = _categories.firstWhereOrNull(
        (c) => c.name.toLowerCase() == category.name.toLowerCase() && c.entityId == category.entityId
      );

      if (existingCategory != null) {
        Get.snackbar('Erreur', 'Une catégorie avec ce nom existe déjà');
        return false;
      }

      // Génération d'un ID unique
      final newCategory = category.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Ici on sauvegarderait dans Firebase
      _categories.add(newCategory);

      Get.snackbar('Succès', 'Catégorie créée avec succès');
      return true;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la création: $e');
      return false;
    }
  }

  // Mise à jour d'une catégorie
  Future<bool> updateCategory(TaskCategoryModel updatedCategory) async {
    try {
      final index = _categories.indexWhere((c) => c.id == updatedCategory.id);
      if (index == -1) {
        Get.snackbar('Erreur', 'Catégorie non trouvée');
        return false;
      }

      // Ne pas permettre la modification des catégories par défaut
      if (_categories[index].isDefault) {
        Get.snackbar('Erreur', 'Impossible de modifier une catégorie par défaut');
        return false;
      }

      // Vérifier les doublons
      final existingCategory = _categories.firstWhereOrNull(
        (c) => c.name.toLowerCase() == updatedCategory.name.toLowerCase() &&
               c.entityId == updatedCategory.entityId &&
               c.id != updatedCategory.id
      );

      if (existingCategory != null) {
        Get.snackbar('Erreur', 'Une catégorie avec ce nom existe déjà');
        return false;
      }

      final categoryWithUpdatedTime = updatedCategory.copyWith(updatedAt: DateTime.now());

      // Ici on sauvegarderait dans Firebase
      _categories[index] = categoryWithUpdatedTime;

      Get.snackbar('Succès', 'Catégorie mise à jour avec succès');
      return true;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la mise à jour: $e');
      return false;
    }
  }

  // Suppression d'une catégorie
  Future<bool> deleteCategory(String categoryId) async {
    try {
      final category = _categories.firstWhereOrNull((c) => c.id == categoryId);
      if (category == null) {
        Get.snackbar('Erreur', 'Catégorie non trouvée');
        return false;
      }

      // Ne pas permettre la suppression des catégories par défaut
      if (category.isDefault) {
        Get.snackbar('Erreur', 'Impossible de supprimer une catégorie par défaut');
        return false;
      }

      // TODO: Vérifier si des tâches utilisent cette catégorie
      // Si oui, demander confirmation ou proposer de réassigner

      // Ici on supprimerait de Firebase
      _categories.removeWhere((c) => c.id == categoryId);

      Get.snackbar('Succès', 'Catégorie supprimée avec succès');
      return true;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la suppression: $e');
      return false;
    }
  }

  // Obtenir les catégories par entité
  List<TaskCategoryModel> getCategoriesByEntity(String entityId) {
    return _categories.where((category) => category.entityId == entityId).toList();
  }

  // Obtenir une catégorie par ID
  TaskCategoryModel? getCategoryById(String categoryId) {
    return _categories.firstWhereOrNull((c) => c.id == categoryId);
  }

  // Recherche de catégories
  List<TaskCategoryModel> searchCategories(String query) {
    if (query.trim().isEmpty) return _categories;

    final lowercaseQuery = query.toLowerCase();
    return _categories.where((category) =>
      category.name.toLowerCase().contains(lowercaseQuery) ||
      (category.description?.toLowerCase().contains(lowercaseQuery) ?? false)
    ).toList();
  }

  // Initialiser les catégories par défaut pour une entité
  Future<void> initializeDefaultCategoriesForEntity(String entityId) async {
    try {
      // Vérifier si les catégories par défaut existent déjà
      final existingCategories = getCategoriesByEntity(entityId);
      if (existingCategories.isNotEmpty) return;

      // Créer les catégories par défaut
      final defaultCategories = TaskCategoryModel.getDefaultCategories(entityId);

      for (final category in defaultCategories) {
        await createCategory(category);
      }

    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de l\'initialisation des catégories: $e');
    }
  }

  // Obtenir les statistiques des catégories
  Map<String, int> getCategoryStatistics() {
    // TODO: Intégrer avec TaskService pour obtenir le nombre de tâches par catégorie
    return {
      for (var category in _categories)
        category.name: 0, // Placeholder
    };
  }

  // Nettoyage
  @override
  void onClose() {
    _categories.close();
    super.onClose();
  }
}