import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/entity_model.dart';
import '../../../data/services/entity_service.dart';
import '../../auth/controllers/auth_controller.dart';

class EntitiesController extends GetxController {
  final EntityService _entityService = EntityService();

  // Observables
  final _isLoading = false.obs;
  final _entities = <EntityModel>[].obs;
  final _currentEntity = Rxn<EntityModel>();
  final _hasError = false.obs;
  final _errorMessage = ''.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  List<EntityModel> get entities => _entities;
  EntityModel? get currentEntity => _currentEntity.value;
  bool get hasError => _hasError.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    loadEntities();
  }

  Future<void> loadEntities() async {
    try {
      _isLoading.value = true;
      _hasError.value = false;
      _errorMessage.value = '';

      // Get current user ID
      final authController = Get.find<AuthController>();
      final userId = authController.currentUser?.id;

      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      final entitiesList = await _entityService.getUserEntities(userId);
      _entities.value = entitiesList;

      // Set personal entity as current if exists
      final personalEntity = entitiesList.where((e) => e.isPersonal).firstOrNull;
      if (personalEntity != null) {
        _currentEntity.value = personalEntity;
      }
    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = e.toString();
      Get.snackbar(
        'Erreur',
        'Impossible de charger les entités: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> refreshEntities() async {
    await loadEntities();
  }

  Future<void> createEntity({
    required String name,
    required String type,
    String? description,
    String? logoUrl,
  }) async {
    try {
      _isLoading.value = true;

      // Get current user ID
      final authController = Get.find<AuthController>();
      final userId = authController.currentUser?.id;

      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      final createdEntity = await _entityService.createEntity(
        name: name,
        type: type,
        ownerId: userId,
        description: description,
        logoUrl: logoUrl,
      );
      _entities.add(createdEntity);

      Get.snackbar(
        'Succès',
        'Entité créée avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de créer l\'entité: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateEntity(EntityModel entity) async {
    try {
      _isLoading.value = true;

      await _entityService.updateEntity(entity);

      // Update local list
      final index = _entities.indexWhere((e) => e.id == entity.id);
      if (index != -1) {
        _entities[index] = entity;
      }

      // Update current entity if it's the one being updated
      if (_currentEntity.value?.id == entity.id) {
        _currentEntity.value = entity;
      }

      Get.snackbar(
        'Succès',
        'Entité mise à jour avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour l\'entité: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteEntity(String entityId) async {
    try {
      _isLoading.value = true;

      await _entityService.deleteEntity(entityId);

      // Remove from local list
      _entities.removeWhere((e) => e.id == entityId);

      // Clear current entity if it was deleted
      if (_currentEntity.value?.id == entityId) {
        _currentEntity.value = null;
      }

      Get.snackbar(
        'Succès',
        'Entité supprimée avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de supprimer l\'entité: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  void selectEntity(EntityModel entity) {
    _currentEntity.value = entity;
  }

  // Statistics methods
  int get totalEntities => _entities.length;
  int get personalEntitiesCount => _entities.where((e) => e.isPersonal).length;
  int get businessEntitiesCount => _entities.where((e) => !e.isPersonal).length;

  void retryInitialization() {
    loadEntities();
  }
}