import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/task_model.dart';
import '../../entities/controllers/entities_controller.dart';

class TaskService extends GetxService {
  static TaskService get to => Get.find();

  // Liste réactive des tâches
  final RxList<TaskModel> _tasks = <TaskModel>[].obs;

  // Getters
  List<TaskModel> get tasks => _tasks;

  List<TaskModel> get activeTasks => _tasks.where((task) =>
    task.status != TaskStatus.completed && task.status != TaskStatus.cancelled).toList();

  List<TaskModel> get completedTasks => _tasks.where((task) =>
    task.status == TaskStatus.completed).toList();

  List<TaskModel> get overdueTasks => _tasks.where((task) => task.isOverdue).toList();

  List<TaskModel> get todayTasks => _tasks.where((task) => task.isDueToday).toList();

  List<TaskModel> get tomorrowTasks => _tasks.where((task) => task.isDueTomorrow).toList();

  // Statistiques
  int get totalTasks => _tasks.length;
  int get pendingTasks => _tasks.where((t) => t.status == TaskStatus.pending).length;
  int get inProgressTasks => _tasks.where((t) => t.status == TaskStatus.inProgress).length;
  int get completedTasksCount => _tasks.where((t) => t.status == TaskStatus.completed).length;

  double get completionRate {
    if (_tasks.isEmpty) return 0.0;
    return completedTasksCount / totalTasks * 100;
  }

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  // Chargement des tâches
  Future<void> loadTasks() async {
    try {
      // Ici on chargerait depuis Firebase
      // Pour l'instant, on utilise des données de test
      _tasks.assignAll(_getMockTasks());
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors du chargement des tâches: $e');
    }
  }

  // Création d'une tâche
  Future<bool> createTask(TaskModel task) async {
    try {
      // Validation
      if (task.title.trim().isEmpty) {
        Get.snackbar('Erreur', 'Le titre de la tâche est requis');
        return false;
      }

      // Génération d'un ID unique
      final newTask = task.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Ici on sauvegarderait dans Firebase
      _tasks.add(newTask);

      Get.snackbar('Succès', 'Tâche créée avec succès');
      return true;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la création: $e');
      return false;
    }
  }

  // Mise à jour d'une tâche
  Future<bool> updateTask(TaskModel updatedTask) async {
    try {
      final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
      if (index == -1) {
        Get.snackbar('Erreur', 'Tâche non trouvée');
        return false;
      }

      final taskWithUpdatedTime = updatedTask.copyWith(updatedAt: DateTime.now());

      // Ici on sauvegarderait dans Firebase
      _tasks[index] = taskWithUpdatedTime;

      Get.snackbar('Succès', 'Tâche mise à jour avec succès');
      return true;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la mise à jour: $e');
      return false;
    }
  }

  // Suppression d'une tâche
  Future<bool> deleteTask(String taskId) async {
    try {
      final task = _tasks.firstWhereOrNull((t) => t.id == taskId);
      if (task == null) {
        Get.snackbar('Erreur', 'Tâche non trouvée');
        return false;
      }

      // Ici on supprimerait de Firebase
      _tasks.removeWhere((t) => t.id == taskId);

      Get.snackbar('Succès', 'Tâche supprimée avec succès');
      return true;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la suppression: $e');
      return false;
    }
  }

  // Changement de statut d'une tâche
  Future<bool> changeTaskStatus(String taskId, TaskStatus newStatus) async {
    try {
      final task = _tasks.firstWhereOrNull((t) => t.id == taskId);
      if (task == null) {
        Get.snackbar('Erreur', 'Tâche non trouvée');
        return false;
      }

      TaskModel updatedTask = task.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );

      // Si la tâche est marquée comme terminée, on ajoute la date de complétion
      if (newStatus == TaskStatus.completed) {
        updatedTask = updatedTask.copyWith(completedDate: DateTime.now());
      }

      return await updateTask(updatedTask);
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors du changement de statut: $e');
      return false;
    }
  }

  // Obtenir les tâches par entité
  List<TaskModel> getTasksByEntity(String entityId) {
    return _tasks.where((task) => task.entityId == entityId).toList();
  }

  // Obtenir les tâches par projet
  List<TaskModel> getTasksByProject(String projectId) {
    return _tasks.where((task) => task.projectId == projectId).toList();
  }

  // Obtenir les tâches par catégorie
  List<TaskModel> getTasksByCategory(String categoryId) {
    return _tasks.where((task) => task.categoryId == categoryId).toList();
  }

  // Obtenir les tâches par priorité
  List<TaskModel> getTasksByPriority(TaskPriority priority) {
    return _tasks.where((task) => task.priority == priority).toList();
  }

  // Recherche de tâches
  List<TaskModel> searchTasks(String query) {
    if (query.trim().isEmpty) return _tasks;

    final lowercaseQuery = query.toLowerCase();
    return _tasks.where((task) =>
      task.title.toLowerCase().contains(lowercaseQuery) ||
      (task.description?.toLowerCase().contains(lowercaseQuery) ?? false) ||
      task.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery))
    ).toList();
  }

  // Obtenir les statistiques d'une entité
  Map<String, dynamic> getEntityStatistics(String entityId) {
    final entityTasks = getTasksByEntity(entityId);
    final completed = entityTasks.where((t) => t.status == TaskStatus.completed).length;
    final pending = entityTasks.where((t) => t.status == TaskStatus.pending).length;
    final inProgress = entityTasks.where((t) => t.status == TaskStatus.inProgress).length;
    final overdue = entityTasks.where((t) => t.isOverdue).length;

    return {
      'total': entityTasks.length,
      'completed': completed,
      'pending': pending,
      'inProgress': inProgress,
      'overdue': overdue,
      'completionRate': entityTasks.isEmpty ? 0.0 : completed / entityTasks.length * 100,
    };
  }

  // Données de test
  List<TaskModel> _getMockTasks() {
    final entitiesController = Get.find<EntitiesController>();
    final personalEntityId = entitiesController.personalEntity?.id ?? 'personal';
    final now = DateTime.now();

    return [
      TaskModel(
        id: '1',
        title: 'Finir le rapport mensuel',
        description: 'Compléter le rapport de performance du mois',
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        categoryId: 'work',
        entityId: personalEntityId,
        dueDate: now.add(const Duration(days: 2)),
        estimatedDuration: 4.0,
        actualDuration: 2.5,
        tags: ['rapport', 'urgent'],
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
      TaskModel(
        id: '2',
        title: 'Faire les courses',
        description: 'Acheter les ingrédients pour la semaine',
        status: TaskStatus.pending,
        priority: TaskPriority.medium,
        categoryId: 'personal',
        entityId: personalEntityId,
        dueDate: now.add(const Duration(days: 1)),
        estimatedDuration: 1.5,
        tags: ['courses', 'personnel'],
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      TaskModel(
        id: '3',
        title: 'Rendez-vous médecin',
        description: 'Consultation annuelle',
        status: TaskStatus.completed,
        priority: TaskPriority.high,
        categoryId: 'health',
        entityId: personalEntityId,
        dueDate: now.subtract(const Duration(days: 1)),
        completedDate: now.subtract(const Duration(days: 1)),
        estimatedDuration: 1.0,
        actualDuration: 0.5,
        tags: ['santé', 'médecin'],
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      TaskModel(
        id: '4',
        title: 'Organiser les documents',
        description: 'Classer les factures et documents importants',
        status: TaskStatus.pending,
        priority: TaskPriority.low,
        categoryId: 'household',
        entityId: personalEntityId,
        estimatedDuration: 2.0,
        tags: ['organisation', 'maison'],
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
    ];
  }

  // Nettoyage
  @override
  void onClose() {
    _tasks.close();
    super.onClose();
  }
}