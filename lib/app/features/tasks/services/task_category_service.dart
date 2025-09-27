import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/task_category_model.dart';
import '../../entities/controllers/entities_controller.dart';

class TaskCategoryService extends GetxService {
  static TaskCategoryService get to => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
      final user = _auth.currentUser;
      if (user == null) return;

      final QuerySnapshot snapshot = await _firestore
          .collection('task_categories')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: false)
          .get();

      final List<TaskCategoryModel> loadedCategories = snapshot.docs
          .map((doc) => TaskCategoryModel.fromFirestore(doc))
          .toList();

      _categories.assignAll(loadedCategories);

      // Ne plus créer automatiquement les catégories par défaut
      // L'utilisateur doit explicitement choisir de les créer
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors du chargement des catégories: $e');
    }
  }

  // Créer les catégories par défaut (maintenant accessible publiquement)
  Future<void> createDefaultCategories() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final entitiesController = Get.find<EntitiesController>();
      final personalEntityId = entitiesController.personalEntity?.id ?? 'personal';

      final defaultCategories = TaskCategoryModel.getDefaultCategories(personalEntityId, userId: user.uid);

      for (final category in defaultCategories) {
        await createCategory(category);
      }
    } catch (e) {
      print('Erreur lors de la création des catégories par défaut: $e');
    }
  }

  // Vérifier si l'utilisateur n'a aucune catégorie
  bool get hasNoCategories => _categories.isEmpty;

  // Création d'une catégorie
  Future<bool> createCategory(TaskCategoryModel category) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar('Erreur', 'Utilisateur non connecté');
        return false;
      }

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

      // Génération d'un ID unique et ajout des données utilisateur
      final newCategory = category.copyWith(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Sauvegarder dans Firebase
      final docRef = await _firestore.collection('task_categories').add(newCategory.toFirestore());
      final categoryWithId = newCategory.copyWith(id: docRef.id);

      // Mettre à jour avec l'ID généré par Firebase
      await docRef.update({'id': docRef.id});

      _categories.add(categoryWithId);

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
      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar('Erreur', 'Utilisateur non connecté');
        return false;
      }

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

      // Sauvegarder dans Firebase
      await _firestore
          .collection('task_categories')
          .doc(updatedCategory.id)
          .update(categoryWithUpdatedTime.toFirestore());

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

      // Vérifier si des tâches utilisent cette catégorie
      final tasksWithCategory = await _checkTasksUsingCategory(categoryId);
      if (tasksWithCategory > 0) {
        final confirmed = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Catégorie utilisée'),
            content: Text('Cette catégorie est utilisée par $tasksWithCategory tâche(s). Voulez-vous vraiment la supprimer ?'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Supprimer'),
              ),
            ],
          ),
        );

        if (confirmed != true) return false;
      }

      // Supprimer de Firebase
      await _firestore.collection('task_categories').doc(categoryId).delete();
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

  // Vérifier combien de tâches utilisent une catégorie
  Future<int> _checkTasksUsingCategory(String categoryId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      final QuerySnapshot snapshot = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: user.uid)
          .where('categoryId', isEqualTo: categoryId)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('Erreur lors de la vérification des tâches utilisant la catégorie: $e');
      return 0;
    }
  }

  // Obtenir les statistiques d'usage des catégories
  Future<Map<String, int>> getCategoryUsageStats() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return {};

      final stats = <String, int>{};

      for (final category in _categories) {
        final QuerySnapshot snapshot = await _firestore
            .collection('tasks')
            .where('userId', isEqualTo: user.uid)
            .where('categoryId', isEqualTo: category.id)
            .get();

        stats[category.id] = snapshot.docs.length;
      }

      return stats;
    } catch (e) {
      print('Erreur lors de la récupération des statistiques: $e');
      return {};
    }
  }

  // Initialiser les catégories par défaut pour une entité
  Future<void> initializeDefaultCategoriesForEntity(String entityId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Vérifier si les catégories par défaut existent déjà
      final existingCategories = getCategoriesByEntity(entityId);
      if (existingCategories.isNotEmpty) return;

      // Créer les catégories par défaut
      final defaultCategories = TaskCategoryModel.getDefaultCategories(entityId, userId: user.uid);

      for (final category in defaultCategories) {
        await createCategory(category);
      }

    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de l\'initialisation des catégories: $e');
    }
  }

  // Obtenir les statistiques des catégories
  Future<Map<String, int>> getCategoryStatistics() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return {};

      final stats = <String, int>{};

      for (var category in _categories) {
        final QuerySnapshot snapshot = await _firestore
            .collection('tasks')
            .where('userId', isEqualTo: user.uid)
            .where('categoryId', isEqualTo: category.id)
            .get();

        stats[category.name] = snapshot.docs.length;
      }

      return stats;
    } catch (e) {
      print('Erreur lors de la récupération des statistiques: $e');
      return {};
    }
  }

  // Nettoyage
  @override
  void onClose() {
    _categories.close();
    super.onClose();
  }
}