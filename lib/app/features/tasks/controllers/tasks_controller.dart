import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';
import '../services/task_category_service.dart';
import '../services/project_service.dart';
import '../../entities/controllers/entities_controller.dart';

class TasksController extends GetxController {
  final TaskService _taskService = Get.find<TaskService>();
  final TaskCategoryService _categoryService = Get.find<TaskCategoryService>();
  final ProjectService _projectService = Get.find<ProjectService>();

  // État du contrôleur
  final RxBool isLoading = false.obs;
  final RxString selectedEntityId = ''.obs;
  final RxString selectedFilter = 'all'.obs; // all, today, week, overdue, completed
  final RxString searchQuery = ''.obs;

  // Getters pour les tâches filtrées
  List<TaskModel> get tasks {
    List<TaskModel> filteredTasks = _taskService.tasks;

    // Filtrer par entité si sélectionnée
    if (selectedEntityId.value.isNotEmpty) {
      filteredTasks = filteredTasks.where((task) => task.entityId == selectedEntityId.value).toList();
    }

    // Appliquer les filtres
    switch (selectedFilter.value) {
      case 'today':
        filteredTasks = filteredTasks.where((task) => task.isDueToday).toList();
        break;
      case 'week':
        final weekEnd = DateTime.now().add(const Duration(days: 7));
        filteredTasks = filteredTasks.where((task) =>
          task.dueDate != null && task.dueDate!.isBefore(weekEnd)).toList();
        break;
      case 'overdue':
        filteredTasks = filteredTasks.where((task) => task.isOverdue).toList();
        break;
      case 'completed':
        filteredTasks = filteredTasks.where((task) => task.status == TaskStatus.completed).toList();
        break;
      case 'pending':
        filteredTasks = filteredTasks.where((task) => task.status == TaskStatus.pending).toList();
        break;
      case 'inProgress':
        filteredTasks = filteredTasks.where((task) => task.status == TaskStatus.inProgress).toList();
        break;
    }

    // Appliquer la recherche
    if (searchQuery.value.isNotEmpty) {
      filteredTasks = _taskService.searchTasks(searchQuery.value);
    }

    return filteredTasks;
  }

  // Getters pour les statistiques
  int get totalTasks => _taskService.totalTasks;
  int get pendingTasks => _taskService.pendingTasks;
  int get inProgressTasks => _taskService.inProgressTasks;
  int get completedTasks => _taskService.completedTasksCount;
  int get overdueTasks => _taskService.overdueTasks.length;
  double get completionRate => _taskService.completionRate;

  List<TaskModel> get todayTasks => _taskService.todayTasks;
  List<TaskModel> get tomorrowTasks => _taskService.tomorrowTasks;

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
  Future<void> loadTasks() async {
    try {
      isLoading.value = true;
      await _taskService.loadTasks();
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors du chargement des tâches');
    } finally {
      isLoading.value = false;
    }
  }

  // Actualisation
  Future<void> refreshTasks() async {
    await loadTasks();
  }

  // Création d'une tâche
  Future<bool> createTask(TaskModel task) async {
    try {
      isLoading.value = true;

      // S'assurer que l'entité est définie
      final taskWithEntity = task.copyWith(
        entityId: task.entityId.isNotEmpty ? task.entityId : selectedEntityId.value,
      );

      final success = await _taskService.createTask(taskWithEntity);

      if (success) {
        // Mettre à jour les statistiques du projet si applicable
        if (taskWithEntity.projectId != null) {
          await _updateProjectStatistics(taskWithEntity.projectId!);
        }
      }

      return success;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la création de la tâche');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Mise à jour d'une tâche
  Future<bool> updateTask(TaskModel task) async {
    try {
      isLoading.value = true;
      final success = await _taskService.updateTask(task);

      if (success && task.projectId != null) {
        await _updateProjectStatistics(task.projectId!);
      }

      return success;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la mise à jour de la tâche');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Suppression d'une tâche
  Future<bool> deleteTask(String taskId) async {
    try {
      isLoading.value = true;

      // Récupérer la tâche avant suppression pour mettre à jour les stats du projet
      final task = _taskService.tasks.firstWhereOrNull((t) => t.id == taskId);
      final projectId = task?.projectId;

      final success = await _taskService.deleteTask(taskId);

      if (success && projectId != null) {
        await _updateProjectStatistics(projectId);
      }

      return success;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la suppression de la tâche');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Changement de statut d'une tâche
  Future<bool> changeTaskStatus(String taskId, TaskStatus newStatus) async {
    try {
      final task = _taskService.tasks.firstWhereOrNull((t) => t.id == taskId);
      if (task == null) return false;

      final success = await _taskService.changeTaskStatus(taskId, newStatus);

      if (success && task.projectId != null) {
        await _updateProjectStatistics(task.projectId!);
      }

      return success;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors du changement de statut');
      return false;
    }
  }

  // Marquer une tâche comme terminée
  Future<bool> completeTask(String taskId) async {
    return await changeTaskStatus(taskId, TaskStatus.completed);
  }

  // Démarrer une tâche
  Future<bool> startTask(String taskId) async {
    return await changeTaskStatus(taskId, TaskStatus.inProgress);
  }

  // Reporter une tâche
  Future<bool> rescheduleTask(String taskId, DateTime newDueDate) async {
    try {
      final task = _taskService.tasks.firstWhereOrNull((t) => t.id == taskId);
      if (task == null) return false;

      final updatedTask = task.copyWith(
        dueDate: newDueDate,
        status: TaskStatus.rescheduled,
      );

      return await updateTask(updatedTask);
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors du report de la tâche');
      return false;
    }
  }

  // Filtres et recherche
  void setFilter(String filter) {
    selectedFilter.value = filter;
    update();
  }

  void setEntityFilter(String entityId) {
    selectedEntityId.value = entityId;
    update();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    update();
  }

  void clearFilters() {
    selectedFilter.value = 'all';
    searchQuery.value = '';
    update();
  }

  // Obtenir les tâches par priorité
  List<TaskModel> getTasksByPriority(TaskPriority priority) {
    return _taskService.getTasksByPriority(priority);
  }

  // Obtenir les tâches par catégorie
  List<TaskModel> getTasksByCategory(String categoryId) {
    return _taskService.getTasksByCategory(categoryId);
  }

  // Obtenir les tâches par projet
  List<TaskModel> getTasksByProject(String projectId) {
    return _taskService.getTasksByProject(projectId);
  }

  // Statistiques par entité
  Map<String, dynamic> getEntityStatistics(String entityId) {
    return _taskService.getEntityStatistics(entityId);
  }

  // Mise à jour des statistiques d'un projet
  Future<void> _updateProjectStatistics(String projectId) async {
    try {
      final projectTasks = getTasksByProject(projectId);
      final totalTasks = projectTasks.length;
      final completedTasks = projectTasks.where((t) => t.status == TaskStatus.completed).length;

      await _projectService.updateProjectTaskStatistics(projectId, totalTasks, completedTasks);
    } catch (e) {
      print('Erreur lors de la mise à jour des statistiques du projet: $e');
    }
  }

  // Obtenir les tâches récurrentes à créer
  Future<void> processRecurringTasks() async {
    try {
      final recurringTasks = _taskService.tasks.where((task) => task.isRecurring).toList();

      for (final task in recurringTasks) {
        // Logique pour créer les nouvelles occurrences des tâches récurrentes
        // À implémenter selon les besoins
      }
    } catch (e) {
      print('Erreur lors du traitement des tâches récurrentes: $e');
    }
  }

  // Analyse de productivité
  Map<String, dynamic> getProductivityAnalysis() {
    final last7Days = DateTime.now().subtract(const Duration(days: 7));
    final recentTasks = _taskService.tasks.where((task) =>
      task.createdAt.isAfter(last7Days)).toList();

    final recentCompleted = recentTasks.where((task) =>
      task.status == TaskStatus.completed).length;

    final avgCompletionTime = _calculateAverageCompletionTime();

    return {
      'tasksCreated': recentTasks.length,
      'tasksCompleted': recentCompleted,
      'completionRate': recentTasks.isNotEmpty ? recentCompleted / recentTasks.length * 100 : 0.0,
      'averageCompletionTime': avgCompletionTime,
      'overdueCount': overdueTasks,
      'productivity': _calculateProductivityScore(),
    };
  }

  double _calculateAverageCompletionTime() {
    final completedTasks = _taskService.tasks.where((task) =>
      task.status == TaskStatus.completed &&
      task.estimatedDuration != null &&
      task.actualDuration != null).toList();

    if (completedTasks.isEmpty) return 0.0;

    final totalDifference = completedTasks.fold(0.0, (sum, task) =>
      sum + (task.actualDuration! - task.estimatedDuration!).abs());

    return totalDifference / completedTasks.length;
  }

  double _calculateProductivityScore() {
    // Calcul basé sur le taux de complétion, les tâches en retard, etc.
    final completionRate = this.completionRate;
    final overdueRate = totalTasks > 0 ? (overdueTasks / totalTasks * 100) : 0.0;

    return (completionRate - overdueRate).clamp(0.0, 100.0);
  }
}