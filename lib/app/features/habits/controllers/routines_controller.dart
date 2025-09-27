import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/routine_model.dart';
import '../services/routine_service.dart';
import '../../entities/controllers/entities_controller.dart';

class RoutinesController extends GetxController {
  final RoutineService _routineService = RoutineService();

  // État du contrôleur
  final RxBool isLoading = false.obs;
  final RxString selectedEntityId = ''.obs;
  final RxString selectedFilter = 'all'.obs; // all, morning, evening, custom, active, paused
  final RxString searchQuery = ''.obs;

  // Données observables
  final RxList<RoutineModel> _routines = <RoutineModel>[].obs;
  final RxMap<String, bool> _todayCompletions = <String, bool>{}.obs;

  // Getters pour les routines filtrées
  List<RoutineModel> get routines {
    List<RoutineModel> filteredRoutines = _routines;

    // Filtrer par entité si sélectionnée
    if (selectedEntityId.value.isNotEmpty) {
      filteredRoutines = filteredRoutines.where((routine) => routine.entityId == selectedEntityId.value).toList();
    }

    // Appliquer les filtres
    switch (selectedFilter.value) {
      case 'morning':
        filteredRoutines = filteredRoutines.where((routine) => routine.type == RoutineType.morning).toList();
        break;
      case 'evening':
        filteredRoutines = filteredRoutines.where((routine) => routine.type == RoutineType.evening).toList();
        break;
      case 'custom':
        filteredRoutines = filteredRoutines.where((routine) => routine.type == RoutineType.custom).toList();
        break;
      case 'active':
        filteredRoutines = filteredRoutines.where((routine) => routine.status == RoutineStatus.active).toList();
        break;
      case 'paused':
        filteredRoutines = filteredRoutines.where((routine) => routine.status == RoutineStatus.paused).toList();
        break;
    }

    // Appliquer la recherche
    if (searchQuery.value.isNotEmpty) {
      filteredRoutines = filteredRoutines.where((routine) =>
        routine.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
        (routine.description?.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false)
      ).toList();
    }

    return filteredRoutines;
  }

  // Getters pour les statistiques
  List<RoutineModel> get allRoutines => _routines;
  List<RoutineModel> get activeRoutines => _routines.where((r) => r.status == RoutineStatus.active).toList();
  List<RoutineModel> get morningRoutines => _routines.where((r) => r.type == RoutineType.morning).toList();
  List<RoutineModel> get eveningRoutines => _routines.where((r) => r.type == RoutineType.evening).toList();
  List<RoutineModel> get todayRoutines => activeRoutines.where((r) => r.isScheduledForToday).toList();

  int get totalRoutines => _routines.length;
  int get activeRoutinesCount => activeRoutines.length;
  int get completedTodayCount => _todayCompletions.values.where((completed) => completed).length;
  int get todayRoutinesCount => todayRoutines.length;

  double get todayCompletionRate {
    if (todayRoutinesCount == 0) return 0.0;
    return (completedTodayCount / todayRoutinesCount) * 100;
  }

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  void _initializeController() {
    // Définir l'entité personnelle par défaut
    try {
      final entitiesController = Get.find<EntitiesController>();
      selectedEntityId.value = entitiesController.personalEntity?.id ?? '';
    } catch (e) {
      print('EntitiesController not found: $e');
    }
  }

  // ================================
  // Chargement des données
  // ================================

  /// Charger toutes les routines
  Future<void> loadRoutines() async {
    try {
      isLoading.value = true;

      if (selectedEntityId.value.isEmpty) {
        print('Entity ID is empty');
        return;
      }

      final routines = await _routineService.getRoutinesByEntity(selectedEntityId.value);
      _routines.assignAll(routines);

      // Charger les complétions d'aujourd'hui
      await _loadTodayCompletions();

      update(); // Notifier GetBuilder
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors du chargement des routines: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Charger les complétions d'aujourd'hui
  Future<void> _loadTodayCompletions() async {
    try {
      final completions = <String, bool>{};

      for (final routine in _routines) {
        final isCompleted = await _routineService.isRoutineCompletedToday(routine.id);
        completions[routine.id] = isCompleted;
      }

      _todayCompletions.assignAll(completions);
    } catch (e) {
      print('Erreur lors du chargement des complétions: $e');
    }
  }

  /// Actualiser les données
  Future<void> refreshRoutines() async {
    await loadRoutines();
  }

  // ================================
  // CRUD Opérations
  // ================================

  /// Créer une nouvelle routine
  Future<bool> createRoutine(RoutineModel routine) async {
    try {
      isLoading.value = true;

      // S'assurer que l'entité est définie
      final routineWithEntity = routine.copyWith(
        entityId: routine.entityId.isNotEmpty ? routine.entityId : selectedEntityId.value,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await _routineService.createRoutine(routineWithEntity);

      if (success) {
        await loadRoutines(); // Recharger les données
        Get.snackbar('Succès', 'Routine créée avec succès');
      }

      return success;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la création de la routine: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Mettre à jour une routine
  Future<bool> updateRoutine(RoutineModel routine) async {
    try {
      isLoading.value = true;
      final success = await _routineService.updateRoutine(routine);

      if (success) {
        await loadRoutines(); // Recharger les données
        Get.snackbar('Succès', 'Routine mise à jour avec succès');
      }

      return success;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la mise à jour de la routine: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Supprimer une routine
  Future<bool> deleteRoutine(String routineId) async {
    try {
      isLoading.value = true;
      final success = await _routineService.deleteRoutine(routineId);

      if (success) {
        await loadRoutines(); // Recharger les données
        Get.snackbar('Succès', 'Routine supprimée avec succès');
      }

      return success;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la suppression de la routine: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Obtenir une routine par ID
  RoutineModel? getRoutineById(String routineId) {
    try {
      return _routines.firstWhere((routine) => routine.id == routineId);
    } catch (e) {
      return null;
    }
  }

  // ================================
  // Gestion des habitudes dans les routines
  // ================================

  /// Ajouter une habitude à une routine
  Future<bool> addHabitToRoutine(String routineId, String habitId, {int? duration}) async {
    try {
      final success = await _routineService.addHabitToRoutine(routineId, habitId, duration: duration);

      if (success) {
        await loadRoutines(); // Recharger les données
        Get.snackbar('Succès', 'Habitude ajoutée à la routine');
      }

      return success;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de l\'ajout de l\'habitude: $e');
      return false;
    }
  }

  /// Retirer une habitude d'une routine
  Future<bool> removeHabitFromRoutine(String routineId, String habitId) async {
    try {
      final success = await _routineService.removeHabitFromRoutine(routineId, habitId);

      if (success) {
        await loadRoutines(); // Recharger les données
        Get.snackbar('Succès', 'Habitude retirée de la routine');
      }

      return success;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la suppression de l\'habitude: $e');
      return false;
    }
  }

  /// Réorganiser les habitudes dans une routine
  Future<bool> reorderHabitsInRoutine(String routineId, List<RoutineHabitItem> orderedHabits) async {
    try {
      final success = await _routineService.reorderHabitsInRoutine(routineId, orderedHabits);

      if (success) {
        await loadRoutines(); // Recharger les données
      }

      return success;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la réorganisation: $e');
      return false;
    }
  }

  // ================================
  // Gestion des complétions
  // ================================

  /// Marquer une routine comme complétée
  Future<bool> completeRoutine(String routineId, {
    List<String>? completedHabits,
    int? durationMinutes,
    double? satisfactionRating,
    String? notes,
  }) async {
    try {
      final routine = getRoutineById(routineId);
      if (routine == null) return false;

      final success = await _routineService.recordRoutineCompletion(
        routineId,
        routine.entityId,
        completedHabits: completedHabits,
        durationMinutes: durationMinutes,
        satisfactionRating: satisfactionRating,
        notes: notes,
      );

      if (success) {
        _todayCompletions[routineId] = true;
        update();
        Get.snackbar('Bravo !', 'Routine complétée avec succès',
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );
      }

      return success;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de l\'enregistrement: $e');
      return false;
    }
  }

  /// Vérifier si une routine est complétée aujourd'hui
  bool isCompletedToday(String routineId) {
    return _todayCompletions[routineId] ?? false;
  }

  // ================================
  // Recherche et filtres
  // ================================

  /// Définir le filtre
  void setFilter(String filter) {
    selectedFilter.value = filter;
    update();
  }

  /// Définir la requête de recherche
  void setSearchQuery(String query) {
    searchQuery.value = query;
    update();
  }

  /// Effacer la recherche
  void clearSearch() {
    searchQuery.value = '';
    update();
  }

  /// Filtrer par entité
  void setEntityFilter(String entityId) {
    selectedEntityId.value = entityId;
    loadRoutines();
  }

  // ================================
  // Statistiques
  // ================================

  /// Obtenir les statistiques d'une routine
  Future<Map<String, dynamic>> getRoutineStatistics(String routineId) async {
    return await _routineService.getRoutineStatistics(routineId);
  }

  /// Obtenir les statistiques globales
  Map<String, dynamic> getGlobalStatistics() {
    return {
      'totalRoutines': totalRoutines,
      'activeRoutines': activeRoutinesCount,
      'todayRoutines': todayRoutinesCount,
      'completedToday': completedTodayCount,
      'todayCompletionRate': todayCompletionRate,
      'morningRoutines': morningRoutines.length,
      'eveningRoutines': eveningRoutines.length,
    };
  }

  // ================================
  // Gestion du statut des routines
  // ================================

  /// Mettre en pause une routine
  Future<bool> pauseRoutine(String routineId) async {
    final routine = getRoutineById(routineId);
    if (routine == null) return false;

    return await updateRoutine(routine.copyWith(status: RoutineStatus.paused));
  }

  /// Reprendre une routine
  Future<bool> resumeRoutine(String routineId) async {
    final routine = getRoutineById(routineId);
    if (routine == null) return false;

    return await updateRoutine(routine.copyWith(status: RoutineStatus.active));
  }

  /// Archiver une routine
  Future<bool> archiveRoutine(String routineId) async {
    final routine = getRoutineById(routineId);
    if (routine == null) return false;

    return await updateRoutine(routine.copyWith(status: RoutineStatus.archived));
  }

  // ================================
  // Templates et suggestions
  // ================================

  /// Créer les routines par défaut
  Future<bool> createDefaultRoutines() async {
    try {
      isLoading.value = true;

      if (selectedEntityId.value.isEmpty) {
        Get.snackbar('Erreur', 'Entité non sélectionnée');
        return false;
      }

      final success = await _routineService.createDefaultRoutines(selectedEntityId.value);

      if (success) {
        await loadRoutines();
        Get.snackbar('Succès', 'Routines par défaut créées avec succès');
      }

      return success;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la création des routines par défaut: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Obtenir des suggestions de routines
  List<Map<String, dynamic>> getRoutineSuggestions() {
    return [
      {
        'name': 'Routine Matinale Énergisante',
        'type': RoutineType.morning,
        'description': 'Commencez la journée avec énergie',
        'estimatedDuration': 45,
        'habits': [
          'Réveil à heure fixe',
          'Étirements',
          'Méditation',
          'Petit-déjeuner sain',
          'Planification de la journée',
        ],
      },
      {
        'name': 'Routine du Soir Relaxante',
        'type': RoutineType.evening,
        'description': 'Terminez la journée en douceur',
        'estimatedDuration': 30,
        'habits': [
          'Rangement',
          'Lecture',
          'Gratitude',
          'Préparation du lendemain',
          'Coucher à heure fixe',
        ],
      },
      {
        'name': 'Routine Pré-Entraînement',
        'type': RoutineType.custom,
        'description': 'Préparation avant l\'exercice',
        'estimatedDuration': 15,
        'habits': [
          'Échauffement',
          'Hydratation',
          'Musique motivante',
        ],
      },
      {
        'name': 'Routine Travail Concentré',
        'type': RoutineType.custom,
        'description': 'Optimisez votre productivité',
        'estimatedDuration': 25,
        'habits': [
          'Éliminer les distractions',
          'Pomodoro',
          'Pause active',
        ],
      },
    ];
  }

  // ================================
  // Utilitaires
  // ================================

  /// Obtenir les routines prévues pour une heure donnée
  List<RoutineModel> getRoutinesForTime(TimeOfDay time) {
    return todayRoutines.where((routine) {
      if (routine.startTime == null) return false;

      // Tolérance de ±30 minutes
      final routineMinutes = routine.startTime!.hour * 60 + routine.startTime!.minute;
      final targetMinutes = time.hour * 60 + time.minute;

      return (routineMinutes - targetMinutes).abs() <= 30;
    }).toList();
  }

  /// Vérifier si l'utilisateur a des routines
  bool get hasRoutines => _routines.isNotEmpty;

  /// Vérifier si l'utilisateur a des routines actives
  bool get hasActiveRoutines => activeRoutines.isNotEmpty;
}