import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/habit_model.dart';
import '../models/habit_completion_model.dart';
import '../services/habit_service.dart';
import '../../entities/controllers/entities_controller.dart';

class HabitsController extends GetxController {
  final HabitService _habitService = HabitService();

  // État du contrôleur
  final RxBool isLoading = false.obs;
  final RxString selectedEntityId = ''.obs;
  final RxString selectedFilter = 'all'.obs; // all, good, bad, active, paused
  final RxString searchQuery = ''.obs;

  // Données observables
  final RxList<HabitModel> _habits = <HabitModel>[].obs;
  final RxMap<String, HabitCompletionModel> _todayCompletions = <String, HabitCompletionModel>{}.obs;
  final RxMap<String, List<HabitCompletionModel>> _habitCompletions = <String, List<HabitCompletionModel>>{}.obs;

  // Getters pour les habitudes filtrées
  List<HabitModel> get habits {
    List<HabitModel> filteredHabits = _habits;

    // Filtrer par entité si sélectionnée
    if (selectedEntityId.value.isNotEmpty) {
      filteredHabits = filteredHabits.where((habit) => habit.entityId == selectedEntityId.value).toList();
    }

    // Appliquer les filtres
    switch (selectedFilter.value) {
      case 'good':
        filteredHabits = filteredHabits.where((habit) => habit.type == HabitType.good).toList();
        break;
      case 'bad':
        filteredHabits = filteredHabits.where((habit) => habit.type == HabitType.bad).toList();
        break;
      case 'active':
        filteredHabits = filteredHabits.where((habit) => habit.status == HabitStatus.active).toList();
        break;
      case 'paused':
        filteredHabits = filteredHabits.where((habit) => habit.status == HabitStatus.paused).toList();
        break;
    }

    // Appliquer la recherche
    if (searchQuery.value.isNotEmpty) {
      filteredHabits = filteredHabits.where((habit) =>
        habit.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
        (habit.description?.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false)
      ).toList();
    }

    return filteredHabits;
  }

  // Getters pour les statistiques
  List<HabitModel> get allHabits => _habits;
  RxList<HabitModel> get habitsObservable => _habits;
  List<HabitModel> get activeHabits => _habits.where((h) => h.status == HabitStatus.active).toList();
  List<HabitModel> get goodHabits => _habits.where((h) => h.type == HabitType.good).toList();
  List<HabitModel> get badHabits => _habits.where((h) => h.type == HabitType.bad).toList();
  List<HabitModel> get todayHabits => activeHabits.where((h) => h.isScheduledForToday).toList();

  int get totalHabits => _habits.length;
  int get activeHabitsCount => activeHabits.length;
  int get completedTodayCount => _todayCompletions.values.where((c) => c.isCompleted).length;
  int get todayHabitsCount => todayHabits.length;

  double get todayCompletionRate {
    if (todayHabitsCount == 0) return 0.0;
    return (completedTodayCount / todayHabitsCount) * 100;
  }

  // Getters pour les complétions
  Map<String, HabitCompletionModel> get todayCompletions => _todayCompletions;
  Map<String, List<HabitCompletionModel>> get habitCompletions => _habitCompletions;

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

      // Charger les habitudes si l'entité est trouvée
      if (selectedEntityId.value.isNotEmpty) {
        loadHabits();
      }
    } catch (e) {
      print('EntitiesController not found: $e');
      // Essayer de trouver une entité par défaut ou créer une temporaire
      _setDefaultEntity();
    }
  }

  void _setDefaultEntity() async {
    // En attendant que l'EntitiesController soit disponible
    try {
      await Future.delayed(Duration(seconds: 1));
      final entitiesController = Get.find<EntitiesController>();
      selectedEntityId.value = entitiesController.personalEntity?.id ?? '';

      if (selectedEntityId.value.isNotEmpty) {
        loadHabits();
      } else {
        print('No personal entity found');
      }
    } catch (e) {
      print('Still no EntitiesController available: $e');
    }
  }

  // ================================
  // Chargement des données
  // ================================

  /// Charger toutes les habitudes
  Future<void> loadHabits() async {
    try {
      isLoading.value = true;

      if (selectedEntityId.value.isEmpty) {
        print('Entity ID is empty');
        return;
      }

      final habits = await _habitService.getHabitsByEntity(selectedEntityId.value);
      _habits.assignAll(habits);

      // Charger les complétions d'aujourd'hui
      await _loadTodayCompletions();

      update(); // Notifier GetBuilder
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors du chargement des habitudes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Charger les complétions d'aujourd'hui
  Future<void> _loadTodayCompletions() async {
    try {
      final today = DateTime.now();
      final completions = <String, HabitCompletionModel>{};

      for (final habit in _habits) {
        final completion = await _habitService.getCompletionForDate(habit.id, today);
        if (completion != null) {
          completions[habit.id] = completion;
        }
      }

      _todayCompletions.assignAll(completions);
    } catch (e) {
      print('Erreur lors du chargement des complétions: $e');
    }
  }

  /// Actualiser les données
  Future<void> refreshHabits() async {
    await loadHabits();
  }

  // ================================
  // CRUD Opérations
  // ================================

  /// Créer une nouvelle habitude
  Future<bool> createHabit(HabitModel habit) async {
    try {
      isLoading.value = true;

      print('DEBUG: Creating habit with name: ${habit.name}');
      print('DEBUG: Selected entityId: ${selectedEntityId.value}');

      // S'assurer que l'entité est définie
      if (selectedEntityId.value.isEmpty) {
        Get.snackbar('Erreur', 'Aucune entité sélectionnée. Veuillez recharger l\'application.');
        return false;
      }

      final habitWithEntity = habit.copyWith(
        entityId: habit.entityId.isNotEmpty ? habit.entityId : selectedEntityId.value,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      print('DEBUG: Habit data to save: ${habitWithEntity.toJson()}');

      final success = await _habitService.createHabit(habitWithEntity);

      print('DEBUG: Create habit result: $success');

      if (success) {
        await loadHabits(); // Recharger les données
        Get.snackbar('Succès', 'Habitude créée avec succès');
        print('DEBUG: Habits loaded after creation: ${_habits.length}');
      } else {
        Get.snackbar('Erreur', 'Échec de la création de l\'habitude');
      }

      return success;
    } catch (e) {
      print('DEBUG: Exception during habit creation: $e');
      Get.snackbar('Erreur', 'Erreur lors de la création de l\'habitude: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Mettre à jour une habitude
  Future<bool> updateHabit(HabitModel habit) async {
    try {
      isLoading.value = true;
      final success = await _habitService.updateHabit(habit);

      if (success) {
        await loadHabits(); // Recharger les données
        Get.snackbar('Succès', 'Habitude mise à jour avec succès');
      }

      return success;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la mise à jour de l\'habitude: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Supprimer une habitude
  Future<bool> deleteHabit(String habitId) async {
    try {
      isLoading.value = true;
      final success = await _habitService.deleteHabit(habitId);

      if (success) {
        await loadHabits(); // Recharger les données
        Get.snackbar('Succès', 'Habitude supprimée avec succès');
      }

      return success;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la suppression de l\'habitude: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Obtenir une habitude par ID
  HabitModel? getHabitById(String habitId) {
    try {
      return _habits.firstWhere((habit) => habit.id == habitId);
    } catch (e) {
      return null;
    }
  }

  // ================================
  // Gestion des complétions
  // ================================

  /// Marquer une habitude comme complétée
  Future<bool> completeHabit(String habitId, {
    int? quantityCompleted,
    String? notes,
    int? durationMinutes,
    double? moodRating,
  }) async {
    try {
      final habit = getHabitById(habitId);
      if (habit == null) return false;

      final completion = HabitCompletionModel.create(
        habitId: habitId,
        entityId: habit.entityId,
        status: CompletionStatus.completed,
        quantityCompleted: quantityCompleted,
        targetQuantity: habit.targetQuantity,
        notes: notes,
        durationMinutes: durationMinutes,
        moodRating: moodRating,
      );

      final success = await _habitService.recordCompletion(completion);

      if (success) {
        _todayCompletions[habitId] = completion;
        await loadHabits(); // Recharger pour mettre à jour les stats

        // Calculer l'économie financière pour les mauvaises habitudes
        if (habit.type == HabitType.bad && habit.hasFinancialImpact) {
          final savings = habit.financialImpact!;
          Get.snackbar(
            'Bravo !',
            'Vous avez évité une dépense de ${savings.toStringAsFixed(0)} FCFA',
            backgroundColor: Colors.green.withOpacity(0.8),
            colorText: Colors.white,
          );
        }
      }

      return success;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de l\'enregistrement: $e');
      return false;
    }
  }

  /// Marquer une habitude comme sautée
  Future<bool> skipHabit(String habitId, {String? notes}) async {
    try {
      final habit = getHabitById(habitId);
      if (habit == null) return false;

      final completion = HabitCompletionModel.create(
        habitId: habitId,
        entityId: habit.entityId,
        status: CompletionStatus.skipped,
        notes: notes,
      );

      final success = await _habitService.recordCompletion(completion);

      if (success) {
        _todayCompletions[habitId] = completion;
        update();
      }

      return success;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de l\'enregistrement: $e');
      return false;
    }
  }

  /// Marquer une habitude comme échouée
  Future<bool> failHabit(String habitId, {String? notes}) async {
    try {
      final habit = getHabitById(habitId);
      if (habit == null) return false;

      final completion = HabitCompletionModel.create(
        habitId: habitId,
        entityId: habit.entityId,
        status: CompletionStatus.failed,
        notes: notes,
      );

      final success = await _habitService.recordCompletion(completion);

      if (success) {
        _todayCompletions[habitId] = completion;
        update();
      }

      return success;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de l\'enregistrement: $e');
      return false;
    }
  }

  /// Annuler une complétion
  Future<bool> undoCompletion(String habitId) async {
    try {
      final completion = _todayCompletions[habitId];
      if (completion == null) return false;

      final success = await _habitService.deleteCompletion(completion.id, habitId);

      if (success) {
        _todayCompletions.remove(habitId);
        await loadHabits(); // Recharger pour mettre à jour les stats
      }

      return success;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de l\'annulation: $e');
      return false;
    }
  }

  /// Vérifier si une habitude est complétée aujourd'hui
  bool isCompletedToday(String habitId) {
    final completion = _todayCompletions[habitId];
    return completion != null && completion.isCompleted;
  }

  /// Obtenir la complétion d'aujourd'hui pour une habitude
  HabitCompletionModel? getTodayCompletion(String habitId) {
    return _todayCompletions[habitId];
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
    loadHabits();
  }

  // ================================
  // Statistiques
  // ================================

  /// Obtenir les statistiques d'une habitude
  Future<Map<String, dynamic>> getHabitStatistics(String habitId) async {
    return await _habitService.getHabitStatistics(habitId);
  }

  /// Obtenir les statistiques globales
  Map<String, dynamic> getGlobalStatistics() {
    final now = DateTime.now();
    final thisWeek = _todayCompletions.values.where((c) {
      return c.date.isAfter(now.subtract(const Duration(days: 7))) && c.isCompleted;
    }).length;

    return {
      'totalHabits': totalHabits,
      'activeHabits': activeHabitsCount,
      'todayHabits': todayHabitsCount,
      'completedToday': completedTodayCount,
      'todayCompletionRate': todayCompletionRate,
      'thisWeekCompletions': thisWeek,
    };
  }

  // ================================
  // Gestion du statut des habitudes
  // ================================

  /// Mettre en pause une habitude
  Future<bool> pauseHabit(String habitId) async {
    final habit = getHabitById(habitId);
    if (habit == null) return false;

    return await updateHabit(habit.copyWith(status: HabitStatus.paused));
  }

  /// Reprendre une habitude
  Future<bool> resumeHabit(String habitId) async {
    final habit = getHabitById(habitId);
    if (habit == null) return false;

    return await updateHabit(habit.copyWith(status: HabitStatus.active));
  }

  /// Archiver une habitude
  Future<bool> archiveHabit(String habitId) async {
    final habit = getHabitById(habitId);
    if (habit == null) return false;

    return await updateHabit(habit.copyWith(status: HabitStatus.archived));
  }

  // ================================
  // Intégration avec d'autres modules
  // ================================

  /// Calculer les économies financières des mauvaises habitudes
  Future<double> calculateFinancialSavings({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final end = endDate ?? DateTime.now();

      double totalSavings = 0.0;

      for (final habit in badHabits) {
        if (habit.hasFinancialImpact) {
          final savings = await _habitService.calculateFinancialSavings(habit.id, start, end);
          totalSavings += savings;
        }
      }

      return totalSavings;
    } catch (e) {
      print('Erreur lors du calcul des économies: $e');
      return 0.0;
    }
  }

  // ================================
  // Templates et suggestions
  // ================================

  /// Obtenir des suggestions d'habitudes populaires
  List<Map<String, dynamic>> getHabitSuggestions() {
    return [
      {
        'name': 'Boire 8 verres d\'eau',
        'type': HabitType.good,
        'frequency': HabitFrequency.daily,
        'icon': Icons.local_drink,
        'color': Colors.blue,
        'targetQuantity': 8,
        'unit': 'verres',
      },
      {
        'name': 'Méditation',
        'type': HabitType.good,
        'frequency': HabitFrequency.daily,
        'icon': Icons.self_improvement,
        'color': Colors.purple,
        'targetQuantity': 10,
        'unit': 'minutes',
      },
      {
        'name': 'Lecture',
        'type': HabitType.good,
        'frequency': HabitFrequency.daily,
        'icon': Icons.book,
        'color': Colors.brown,
        'targetQuantity': 10,
        'unit': 'pages',
      },
      {
        'name': 'Exercice physique',
        'type': HabitType.good,
        'frequency': HabitFrequency.daily,
        'icon': Icons.fitness_center,
        'color': Colors.red,
        'targetQuantity': 30,
        'unit': 'minutes',
      },
      {
        'name': 'Éviter les réseaux sociaux',
        'type': HabitType.bad,
        'frequency': HabitFrequency.daily,
        'icon': Icons.phone_android,
        'color': Colors.orange,
        'financialImpact': 0.0, // Pas d'impact financier direct
      },
      {
        'name': 'Arrêter de fumer',
        'type': HabitType.bad,
        'frequency': HabitFrequency.daily,
        'icon': Icons.smoke_free,
        'color': Colors.red,
        'financialImpact': 2000.0, // 2000 FCFA par jour évité
      },
    ];
  }
}