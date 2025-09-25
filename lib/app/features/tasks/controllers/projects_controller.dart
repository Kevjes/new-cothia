import 'package:get/get.dart';
import '../models/project_model.dart';
import '../services/project_service.dart';
import '../../entities/controllers/entities_controller.dart';

class ProjectsController extends GetxController {
  final ProjectService _projectService = Get.find<ProjectService>();

  // État du contrôleur
  final RxBool isLoading = false.obs;
  final RxString selectedEntityId = ''.obs;
  final RxString selectedFilter = 'all'.obs; // all, active, completed, overdue
  final RxString searchQuery = ''.obs;

  // Getters pour les projets filtrés
  List<ProjectModel> get projects {
    List<ProjectModel> filteredProjects = _projectService.projects;

    // Filtrer par entité si sélectionnée
    if (selectedEntityId.value.isNotEmpty) {
      filteredProjects = filteredProjects.where((project) => project.entityId == selectedEntityId.value).toList();
    }

    // Appliquer les filtres
    switch (selectedFilter.value) {
      case 'active':
        filteredProjects = filteredProjects.where((project) => project.status == ProjectStatus.active).toList();
        break;
      case 'completed':
        filteredProjects = filteredProjects.where((project) => project.status == ProjectStatus.completed).toList();
        break;
      case 'planning':
        filteredProjects = filteredProjects.where((project) => project.status == ProjectStatus.planning).toList();
        break;
      case 'onHold':
        filteredProjects = filteredProjects.where((project) => project.status == ProjectStatus.onHold).toList();
        break;
      case 'overdue':
        filteredProjects = filteredProjects.where((project) => project.isOverdue).toList();
        break;
    }

    // Appliquer la recherche
    if (searchQuery.value.isNotEmpty) {
      filteredProjects = _projectService.searchProjects(searchQuery.value);
    }

    return filteredProjects;
  }

  // Getters pour les statistiques
  int get totalProjects => _projectService.totalProjects;
  int get activeProjects => _projectService.activeProjectsCount;
  int get completedProjects => _projectService.completedProjectsCount;
  int get overdueProjects => _projectService.overdueProjects.length;
  double get overallCompletionRate => _projectService.overallCompletionRate;

  List<ProjectModel> get activeProjectsList => _projectService.activeProjects;
  List<ProjectModel> get completedProjectsList => _projectService.completedProjects;

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
  Future<void> loadProjects() async {
    try {
      isLoading.value = true;
      await _projectService.loadProjects();
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors du chargement des projets');
    } finally {
      isLoading.value = false;
    }
  }

  // Actualisation
  Future<void> refreshProjects() async {
    await loadProjects();
  }

  // Création d'un projet
  Future<bool> createProject(ProjectModel project) async {
    try {
      isLoading.value = true;

      // S'assurer que l'entité est définie
      final projectWithEntity = project.copyWith(
        entityId: project.entityId.isNotEmpty ? project.entityId : selectedEntityId.value,
      );

      final success = await _projectService.createProject(projectWithEntity);
      return success;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la création du projet');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Mise à jour d'un projet
  Future<bool> updateProject(ProjectModel project) async {
    try {
      isLoading.value = true;
      final success = await _projectService.updateProject(project);
      return success;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la mise à jour du projet');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Suppression d'un projet
  Future<bool> deleteProject(String projectId) async {
    try {
      isLoading.value = true;
      final success = await _projectService.deleteProject(projectId);
      return success;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la suppression du projet');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Changement de statut d'un projet
  Future<bool> changeProjectStatus(String projectId, ProjectStatus newStatus) async {
    try {
      final success = await _projectService.changeProjectStatus(projectId, newStatus);
      return success;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors du changement de statut');
      return false;
    }
  }

  // Actions rapides sur les projets
  Future<bool> startProject(String projectId) async {
    return await changeProjectStatus(projectId, ProjectStatus.active);
  }

  Future<bool> pauseProject(String projectId) async {
    return await changeProjectStatus(projectId, ProjectStatus.onHold);
  }

  Future<bool> completeProject(String projectId) async {
    return await changeProjectStatus(projectId, ProjectStatus.completed);
  }

  Future<bool> cancelProject(String projectId) async {
    return await changeProjectStatus(projectId, ProjectStatus.cancelled);
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

  // Obtenir un projet par ID
  ProjectModel? getProjectById(String projectId) {
    return _projectService.getProjectById(projectId);
  }

  // Obtenir les projets par statut
  List<ProjectModel> getProjectsByStatus(ProjectStatus status) {
    return _projectService.getProjectsByStatus(status);
  }

  // Obtenir les projets par entité
  List<ProjectModel> getProjectsByEntity(String entityId) {
    return _projectService.getProjectsByEntity(entityId);
  }

  // Statistiques par entité
  Map<String, dynamic> getEntityStatistics(String entityId) {
    return _projectService.getEntityProjectStatistics(entityId);
  }

  // Analyse des performances des projets
  Map<String, dynamic> getProjectsAnalysis() {
    final projects = _projectService.projects;

    // Calcul des statistiques globales
    final totalBudget = projects.fold(0.0, (sum, project) => sum + (project.estimatedBudget ?? 0.0));
    final actualBudget = projects.fold(0.0, (sum, project) => sum + (project.actualBudget ?? 0.0));

    final averageProgress = projects.isEmpty ? 0.0 :
      projects.fold(0.0, (sum, project) => sum + project.progressPercentage) / projects.length;

    // Projets en retard
    final overdueProjects = projects.where((project) => project.isOverdue).toList();

    // Projets terminés à temps
    final onTimeProjects = projects.where((project) =>
      project.status == ProjectStatus.completed &&
      project.deadline != null &&
      project.endDate != null &&
      project.endDate!.isBefore(project.deadline!)
    ).length;

    // Distribution par statut
    final statusDistribution = <String, int>{};
    for (final status in ProjectStatus.values) {
      statusDistribution[status.name] = projects.where((p) => p.status == status).length;
    }

    return {
      'totalProjects': projects.length,
      'activeProjects': activeProjects,
      'completedProjects': completedProjects,
      'overdueProjects': overdueProjects.length,
      'onTimeCompletions': onTimeProjects,
      'averageProgress': averageProgress,
      'totalBudget': totalBudget,
      'actualBudget': actualBudget,
      'budgetEfficiency': totalBudget > 0 ? (actualBudget / totalBudget * 100) : 0.0,
      'statusDistribution': statusDistribution,
      'completionRate': overallCompletionRate,
    };
  }

  // Obtenir les projets nécessitant attention
  List<ProjectModel> getProjectsNeedingAttention() {
    final projects = _projectService.projects;

    return projects.where((project) {
      // Projets en retard
      if (project.isOverdue) return true;

      // Projets actifs avec faible progression
      if (project.status == ProjectStatus.active && project.progressPercentage < 25.0) return true;

      // Projets qui approchent de la deadline (moins de 7 jours)
      if (project.deadline != null && project.status == ProjectStatus.active) {
        final daysUntilDeadline = project.deadline!.difference(DateTime.now()).inDays;
        if (daysUntilDeadline <= 7 && daysUntilDeadline > 0) return true;
      }

      // Projets avec dépassement de budget
      if (project.estimatedBudget != null && project.actualBudget != null) {
        if (project.actualBudget! > project.estimatedBudget!) return true;
      }

      return false;
    }).toList();
  }

  // Suggestions d'optimisation
  List<String> getOptimizationSuggestions() {
    final suggestions = <String>[];
    final analysis = getProjectsAnalysis();

    // Suggestions basées sur les métriques
    if (analysis['overdueProjects'] > 0) {
      suggestions.add('${analysis['overdueProjects']} projet(s) en retard nécessitent une attention immédiate');
    }

    if (analysis['averageProgress'] < 50.0 && activeProjects > 0) {
      suggestions.add('La progression moyenne des projets est faible (${analysis['averageProgress'].toStringAsFixed(1)}%)');
    }

    if (analysis['budgetEfficiency'] > 120.0) {
      suggestions.add('Dépassement budgétaire détecté (${analysis['budgetEfficiency'].toStringAsFixed(1)}% du budget)');
    }

    final projectsNeedingAttention = getProjectsNeedingAttention();
    if (projectsNeedingAttention.isNotEmpty) {
      suggestions.add('${projectsNeedingAttention.length} projet(s) nécessitent votre attention');
    }

    return suggestions;
  }

  // Dupliquer un projet
  Future<bool> duplicateProject(String projectId) async {
    try {
      final project = getProjectById(projectId);
      if (project == null) {
        Get.snackbar('Erreur', 'Projet non trouvé');
        return false;
      }

      final duplicatedProject = project.copyWith(
        id: '',
        name: '${project.name} (Copie)',
        status: ProjectStatus.planning,
        startDate: null,
        endDate: null,
        progressPercentage: 0.0,
        totalTasks: 0,
        completedTasks: 0,
        actualBudget: 0.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return await createProject(duplicatedProject);
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la duplication');
      return false;
    }
  }
}