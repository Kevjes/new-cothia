import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/task_model.dart';
import '../models/project_model.dart';
import '../services/task_service.dart';
import '../services/task_category_service.dart';
import '../services/project_service.dart';
import '../controllers/projects_controller.dart';
import '../../entities/controllers/entities_controller.dart';
import '../../finance/controllers/transactions_controller.dart';

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

  // Getter pour les projets (utilise ProjectsController)
  List<ProjectModel> get projects {
    try {
      final projectsController = Get.find<ProjectsController>();
      return projectsController.projects;
    } catch (e) {
      return [];
    }
  }

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
    final task = _taskService.tasks.firstWhereOrNull((t) => t.id == taskId);
    if (task == null) return false;

    final success = await changeTaskStatus(taskId, TaskStatus.completed);

    // Vérifier la synchronisation financière si la tâche est liée à une transaction
    if (success && task.linkedTransactionId != null) {
      await _handleLinkedTransactionCompletion(task);
    }

    return success;
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

  // Nouvelles méthodes de tri et filtrage
  void sortTasks(String sortBy) {
    List<TaskModel> sortedTasks = List.from(_taskService.tasks);

    switch (sortBy) {
      case 'createdAt':
        sortedTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'dueDate':
        sortedTasks.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
      case 'priority':
        sortedTasks.sort((a, b) => b.priority.index.compareTo(a.priority.index));
        break;
      case 'title':
        sortedTasks.sort((a, b) => a.title.compareTo(b.title));
        break;
    }

    _taskService.tasks = sortedTasks;
    update();
    Get.snackbar('Tri appliqué', 'Tâches triées par $sortBy');
  }

  void filterByPriority(TaskPriority? priority) {
    if (priority == null) {
      selectedFilter.value = 'all';
    } else {
      selectedFilter.value = 'priority_${priority.name}';
    }
    update();
    Get.snackbar('Filtre appliqué', priority == null ? 'Toutes les priorités' : 'Priorité ${priority.name}');
  }

  void filterByStatus(TaskStatus? status) {
    if (status == null) {
      selectedFilter.value = 'all';
    } else {
      selectedFilter.value = 'status_${status.name}';
    }
    update();
    Get.snackbar('Filtre appliqué', status == null ? 'Tous les statuts' : 'Statut ${status.name}');
  }

  void filterByDate(String? dateFilter) {
    if (dateFilter == null) {
      selectedFilter.value = 'all';
    } else {
      selectedFilter.value = 'date_$dateFilter';
    }
    update();
    String message = switch (dateFilter) {
      'today' => 'Tâches d\'aujourd\'hui',
      'week' => 'Tâches de cette semaine',
      'overdue' => 'Tâches en retard',
      _ => 'Toutes les dates'
    };
    Get.snackbar('Filtre appliqué', message);
  }

  void filterByProject(String? projectId) {
    if (projectId == null) {
      selectedFilter.value = 'all';
    } else if (projectId == 'none') {
      selectedFilter.value = 'project_none';
    } else {
      selectedFilter.value = 'project_$projectId';
    }
    update();
    String message = switch (projectId) {
      null => 'Tous les projets',
      'none' => 'Tâches sans projet',
      _ => 'Projet sélectionné'
    };
    Get.snackbar('Filtre appliqué', message);
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
      // Log error silently
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
      // Log error silently
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

  // Gestion de la synchronisation financière
  Future<void> _handleLinkedTransactionCompletion(TaskModel task) async {
    try {
      // Afficher une boîte de dialogue pour demander confirmation de validation de la transaction
      final shouldConfirmTransaction = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Tâche terminée'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('La tâche "${task.title}" est terminée.'),
              const SizedBox(height: 12),
              Text(
                'Cette tâche est liée à une transaction financière. Voulez-vous confirmer et valider la transaction associée ?',
                style: Get.textTheme.bodyMedium,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Plus tard'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Confirmer la transaction'),
            ),
          ],
        ),
      );

      if (shouldConfirmTransaction == true) {
        // Récupérer le contrôleur des transactions
        final transactionsController = Get.find<TransactionsController>();

        // Confirmer la transaction liée
        final success = await transactionsController.confirmTransaction(task.linkedTransactionId!);

        if (success) {
          Get.snackbar(
            'Synchronisation réussie',
            'La transaction financière a été confirmée automatiquement.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green,
            duration: const Duration(seconds: 3),
          );
        } else {
          Get.snackbar(
            'Erreur de synchronisation',
            'Impossible de confirmer automatiquement la transaction. Veuillez la confirmer manuellement.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange.withOpacity(0.1),
            colorText: Colors.orange,
            duration: const Duration(seconds: 4),
          );
        }
      }
    } catch (e) {
      // Log error silently
      Get.snackbar(
        'Erreur',
        'Erreur lors de la synchronisation avec les transactions financières.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  // Détection des tâches reportées et suggestions de productivité
  List<String> getProductivitySuggestions() {
    final suggestions = <String>[];

    // Analyser les tâches reportées
    final rescheduledTasks = _taskService.tasks.where((task) =>
      task.status == TaskStatus.rescheduled).toList();

    if (rescheduledTasks.length > 5) {
      suggestions.add('Vous avez ${rescheduledTasks.length} tâches reportées. Considérez décomposer les tâches complexes en sous-tâches plus petites.');
    }

    // Analyser les tâches en retard
    final overdueTasks = _taskService.overdueTasks;
    if (overdueTasks.length > 3) {
      suggestions.add('${overdueTasks.length} tâches sont en retard. Réorganisez vos priorités et planifiez mieux vos échéances.');
    }

    // Analyser les estimations vs réalité
    final tasksWithDuration = _taskService.tasks.where((task) =>
      task.estimatedDuration != null && task.actualDuration != null).toList();

    if (tasksWithDuration.length > 10) {
      final avgOverestimation = tasksWithDuration.fold(0.0, (sum, task) =>
        sum + (task.actualDuration! - task.estimatedDuration!)) / tasksWithDuration.length;

      if (avgOverestimation > 1.0) {
        suggestions.add('Vos tâches prennent en moyenne ${avgOverestimation.toStringAsFixed(1)}h de plus que prévu. Revoyez vos estimations à la hausse.');
      } else if (avgOverestimation < -0.5) {
        suggestions.add('Vos estimations sont souvent trop pessimistes. Vous pourriez planifier plus de tâches.');
      }
    }

    // Analyser la charge de travail
    final today = DateTime.now();
    final todayTasks = _taskService.tasks.where((task) =>
      task.isDueToday && task.status != TaskStatus.completed).toList();

    if (todayTasks.length > 8) {
      suggestions.add('Vous avez ${todayTasks.length} tâches prévues aujourd\'hui. Considérez en reporter certaines pour éviter la surcharge.');
    }

    // Suggestions basées sur les catégories
    final workTasks = _taskService.getTasksByCategory('work');
    final personalTasks = _taskService.getTasksByCategory('personal');

    if (workTasks.length > personalTasks.length * 3) {
      suggestions.add('Votre charge de travail professionnelle semble élevée. N\'oubliez pas d\'équilibrer avec des activités personnelles.');
    }

    return suggestions;
  }

  // Analyse des modèles de procrastination
  Map<String, dynamic> getProcrastinationAnalysis() {
    final now = DateTime.now();
    final lastWeek = now.subtract(const Duration(days: 7));

    final recentTasks = _taskService.tasks.where((task) =>
      task.createdAt.isAfter(lastWeek)).toList();

    final completedOnTime = recentTasks.where((task) =>
      task.status == TaskStatus.completed &&
      task.completedDate != null &&
      task.dueDate != null &&
      task.completedDate!.isBefore(task.dueDate!)).length;

    final completedLate = recentTasks.where((task) =>
      task.status == TaskStatus.completed &&
      task.completedDate != null &&
      task.dueDate != null &&
      task.completedDate!.isAfter(task.dueDate!)).length;

    final postponed = recentTasks.where((task) =>
      task.status == TaskStatus.rescheduled).length;

    return {
      'totalTasks': recentTasks.length,
      'completedOnTime': completedOnTime,
      'completedLate': completedLate,
      'postponed': postponed,
      'procrastinationRate': recentTasks.isNotEmpty
          ? (completedLate + postponed) / recentTasks.length * 100
          : 0.0,
      'suggestions': getProductivitySuggestions(),
    };
  }
}