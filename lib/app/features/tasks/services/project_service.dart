import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/project_model.dart';
import '../../entities/controllers/entities_controller.dart';

class ProjectService extends GetxService {
  static ProjectService get to => Get.find();

  // Liste réactive des projets
  final RxList<ProjectModel> _projects = <ProjectModel>[].obs;

  // Getters
  List<ProjectModel> get projects => _projects;

  List<ProjectModel> get activeProjects => _projects.where((project) =>
    project.status == ProjectStatus.active).toList();

  List<ProjectModel> get completedProjects => _projects.where((project) =>
    project.status == ProjectStatus.completed).toList();

  List<ProjectModel> get overdueProjects => _projects.where((project) => project.isOverdue).toList();

  // Statistiques
  int get totalProjects => _projects.length;
  int get activeProjectsCount => activeProjects.length;
  int get completedProjectsCount => completedProjects.length;

  double get overallCompletionRate {
    if (_projects.isEmpty) return 0.0;
    return completedProjectsCount / totalProjects * 100;
  }

  @override
  void onInit() {
    super.onInit();
    loadProjects();
  }

  // Chargement des projets
  Future<void> loadProjects() async {
    try {
      // Ici on chargerait depuis Firebase
      // Pour l'instant, on utilise des données de test
      _projects.assignAll(_getMockProjects());
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors du chargement des projets: $e');
    }
  }

  // Création d'un projet
  Future<bool> createProject(ProjectModel project) async {
    try {
      // Validation
      if (project.name.trim().isEmpty) {
        Get.snackbar('Erreur', 'Le nom du projet est requis');
        return false;
      }

      // Vérifier si un projet avec le même nom existe déjà pour cette entité
      final existingProject = _projects.firstWhereOrNull(
        (p) => p.name.toLowerCase() == project.name.toLowerCase() && p.entityId == project.entityId
      );

      if (existingProject != null) {
        Get.snackbar('Erreur', 'Un projet avec ce nom existe déjà');
        return false;
      }

      // Génération d'un ID unique
      final newProject = project.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Ici on sauvegarderait dans Firebase
      _projects.add(newProject);

      Get.snackbar('Succès', 'Projet créé avec succès');
      return true;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la création: $e');
      return false;
    }
  }

  // Mise à jour d'un projet
  Future<bool> updateProject(ProjectModel updatedProject) async {
    try {
      final index = _projects.indexWhere((p) => p.id == updatedProject.id);
      if (index == -1) {
        Get.snackbar('Erreur', 'Projet non trouvé');
        return false;
      }

      // Vérifier les doublons
      final existingProject = _projects.firstWhereOrNull(
        (p) => p.name.toLowerCase() == updatedProject.name.toLowerCase() &&
               p.entityId == updatedProject.entityId &&
               p.id != updatedProject.id
      );

      if (existingProject != null) {
        Get.snackbar('Erreur', 'Un projet avec ce nom existe déjà');
        return false;
      }

      final projectWithUpdatedTime = updatedProject.copyWith(updatedAt: DateTime.now());

      // Ici on sauvegarderait dans Firebase
      _projects[index] = projectWithUpdatedTime;

      Get.snackbar('Succès', 'Projet mis à jour avec succès');
      return true;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la mise à jour: $e');
      return false;
    }
  }

  // Suppression d'un projet
  Future<bool> deleteProject(String projectId) async {
    try {
      final project = _projects.firstWhereOrNull((p) => p.id == projectId);
      if (project == null) {
        Get.snackbar('Erreur', 'Projet non trouvé');
        return false;
      }

      // TODO: Vérifier si des tâches sont liées à ce projet
      // Si oui, demander confirmation ou proposer de réassigner

      // Ici on supprimerait de Firebase
      _projects.removeWhere((p) => p.id == projectId);

      Get.snackbar('Succès', 'Projet supprimé avec succès');
      return true;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la suppression: $e');
      return false;
    }
  }

  // Changement de statut d'un projet
  Future<bool> changeProjectStatus(String projectId, ProjectStatus newStatus) async {
    try {
      final project = _projects.firstWhereOrNull((p) => p.id == projectId);
      if (project == null) {
        Get.snackbar('Erreur', 'Projet non trouvé');
        return false;
      }

      ProjectModel updatedProject = project.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );

      // Si le projet est marqué comme terminé, on ajoute la date de fin
      if (newStatus == ProjectStatus.completed) {
        updatedProject = updatedProject.copyWith(endDate: DateTime.now());
      }

      return await updateProject(updatedProject);
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors du changement de statut: $e');
      return false;
    }
  }

  // Mise à jour des statistiques du projet (appelée par TaskService)
  Future<void> updateProjectTaskStatistics(String projectId, int totalTasks, int completedTasks) async {
    try {
      final project = _projects.firstWhereOrNull((p) => p.id == projectId);
      if (project == null) return;

      final progressPercentage = totalTasks > 0 ? (completedTasks / totalTasks * 100) : 0.0;

      final updatedProject = project.copyWith(
        totalTasks: totalTasks,
        completedTasks: completedTasks,
        progressPercentage: progressPercentage,
        updatedAt: DateTime.now(),
      );

      await updateProject(updatedProject);
    } catch (e) {
      print('Erreur lors de la mise à jour des statistiques du projet: $e');
    }
  }

  // Obtenir les projets par entité
  List<ProjectModel> getProjectsByEntity(String entityId) {
    return _projects.where((project) => project.entityId == entityId).toList();
  }

  // Obtenir les projets par statut
  List<ProjectModel> getProjectsByStatus(ProjectStatus status) {
    return _projects.where((project) => project.status == status).toList();
  }

  // Obtenir un projet par ID
  ProjectModel? getProjectById(String projectId) {
    return _projects.firstWhereOrNull((p) => p.id == projectId);
  }

  // Recherche de projets
  List<ProjectModel> searchProjects(String query) {
    if (query.trim().isEmpty) return _projects;

    final lowercaseQuery = query.toLowerCase();
    return _projects.where((project) =>
      project.name.toLowerCase().contains(lowercaseQuery) ||
      (project.description?.toLowerCase().contains(lowercaseQuery) ?? false) ||
      project.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery))
    ).toList();
  }

  // Obtenir les statistiques d'une entité
  Map<String, dynamic> getEntityProjectStatistics(String entityId) {
    final entityProjects = getProjectsByEntity(entityId);
    final completed = entityProjects.where((p) => p.status == ProjectStatus.completed).length;
    final active = entityProjects.where((p) => p.status == ProjectStatus.active).length;
    final planning = entityProjects.where((p) => p.status == ProjectStatus.planning).length;
    final onHold = entityProjects.where((p) => p.status == ProjectStatus.onHold).length;
    final overdue = entityProjects.where((p) => p.isOverdue).length;

    return {
      'total': entityProjects.length,
      'completed': completed,
      'active': active,
      'planning': planning,
      'onHold': onHold,
      'overdue': overdue,
      'completionRate': entityProjects.isEmpty ? 0.0 : completed / entityProjects.length * 100,
    };
  }

  // Données de test
  List<ProjectModel> _getMockProjects() {
    final entitiesController = Get.find<EntitiesController>();
    final personalEntityId = entitiesController.personalEntity?.id ?? 'personal';
    final now = DateTime.now();

    return [
      ProjectModel(
        id: '1',
        name: 'Refonte du site web',
        description: 'Modernisation complète du site web de l\'entreprise',
        status: ProjectStatus.active,
        entityId: personalEntityId,
        startDate: now.subtract(const Duration(days: 30)),
        deadline: now.add(const Duration(days: 45)),
        color: Colors.blue,
        icon: Icons.web,
        tags: ['web', 'design', 'développement'],
        progressPercentage: 65.0,
        totalTasks: 20,
        completedTasks: 13,
        estimatedBudget: 5000.0,
        actualBudget: 3200.0,
        createdAt: now.subtract(const Duration(days: 35)),
        updatedAt: now.subtract(const Duration(hours: 4)),
      ),
      ProjectModel(
        id: '2',
        name: 'Organisation déménagement',
        description: 'Préparation et organisation du déménagement',
        status: ProjectStatus.planning,
        entityId: personalEntityId,
        deadline: now.add(const Duration(days: 60)),
        color: Colors.orange,
        icon: Icons.moving,
        tags: ['déménagement', 'personnel'],
        progressPercentage: 25.0,
        totalTasks: 8,
        completedTasks: 2,
        estimatedBudget: 2000.0,
        actualBudget: 150.0,
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      ProjectModel(
        id: '3',
        name: 'Formation Flutter',
        description: 'Apprentissage approfondi du framework Flutter',
        status: ProjectStatus.completed,
        entityId: personalEntityId,
        startDate: now.subtract(const Duration(days: 90)),
        endDate: now.subtract(const Duration(days: 7)),
        color: Colors.green,
        icon: Icons.school,
        tags: ['formation', 'flutter', 'développement'],
        progressPercentage: 100.0,
        totalTasks: 15,
        completedTasks: 15,
        createdAt: now.subtract(const Duration(days: 95)),
        updatedAt: now.subtract(const Duration(days: 7)),
      ),
    ];
  }

  // Nettoyage
  @override
  void onClose() {
    _projects.close();
    super.onClose();
  }
}