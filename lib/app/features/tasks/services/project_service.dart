import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/project_model.dart';
import '../../entities/controllers/entities_controller.dart';

class ProjectService extends GetxService {
  static ProjectService get to => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
      final user = _auth.currentUser;
      if (user == null) return;

      final QuerySnapshot snapshot = await _firestore
          .collection('projects')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      final List<ProjectModel> loadedProjects = snapshot.docs
          .map((doc) => ProjectModel.fromFirestore(doc))
          .toList();

      _projects.assignAll(loadedProjects);
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors du chargement des projets: $e');
    }
  }

  // Création d'un projet
  Future<bool> createProject(ProjectModel project) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar('Erreur', 'Utilisateur non connecté');
        return false;
      }

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

      // Génération d'un ID unique et ajout des données utilisateur
      final newProject = project.copyWith(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Sauvegarder dans Firebase
      final docRef = await _firestore.collection('projects').add(newProject.toFirestore());
      final projectWithId = newProject.copyWith(id: docRef.id);

      // Mettre à jour avec l'ID généré par Firebase
      await docRef.update({'id': docRef.id});

      _projects.add(projectWithId);

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
      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar('Erreur', 'Utilisateur non connecté');
        return false;
      }

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

      // Sauvegarder dans Firebase
      await _firestore
          .collection('projects')
          .doc(updatedProject.id)
          .update(projectWithUpdatedTime.toFirestore());

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
      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar('Erreur', 'Utilisateur non connecté');
        return false;
      }

      final project = _projects.firstWhereOrNull((p) => p.id == projectId);
      if (project == null) {
        Get.snackbar('Erreur', 'Projet non trouvé');
        return false;
      }

      // Vérifier si des tâches sont liées à ce projet
      final tasksCount = await _checkTasksLinkedToProject(projectId);
      if (tasksCount > 0) {
        final confirmed = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Projet utilisé'),
            content: Text('Ce projet contient $tasksCount tâche(s). Voulez-vous vraiment le supprimer ?'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Supprimer'),
              ),
            ],
          ),
        );

        if (confirmed != true) return false;
      }

      // Supprimer de Firebase
      await _firestore.collection('projects').doc(projectId).delete();
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

  // Vérifier combien de tâches sont liées à un projet
  Future<int> _checkTasksLinkedToProject(String projectId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      final QuerySnapshot snapshot = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: user.uid)
          .where('projectId', isEqualTo: projectId)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('Erreur lors de la vérification des tâches liées: $e');
      return 0;
    }
  }

  // Obtenir les statistiques des projets
  Map<String, dynamic> getProjectsStatistics() {
    return {
      'totalProjects': _projects.length,
      'activeProjects': _projects.where((p) => p.status == ProjectStatus.active).length,
      'completedProjects': _projects.where((p) => p.status == ProjectStatus.completed).length,
      'totalTasks': _projects.fold<int>(0, (sum, project) => sum + project.totalTasks),
    };
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


  // Nettoyage
  @override
  void onClose() {
    _projects.close();
    super.onClose();
  }
}