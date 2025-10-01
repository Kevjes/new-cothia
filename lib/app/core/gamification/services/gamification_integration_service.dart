import 'package:get/get.dart';
import 'gamification_service.dart';

class GamificationIntegrationService extends GetxService {
  final GamificationService _gamificationService = Get.find<GamificationService>();

  /// Points attribués pour différentes actions
  static const Map<String, int> actionPoints = {
    // Actions Finance
    'transaction_created': 10,
    'account_created': 25,
    'budget_created': 30,
    'objective_created': 40,
    'automation_created': 50,

    // Actions Tâches
    'task_created': 15,
    'task_completed': 20,
    'project_created': 35,
    'task_category_created': 20,

    // Actions Habitudes
    'habit_created': 25,
    'habit_completed': 15,
    'routine_created': 40,
    'routine_completed': 30,
    'streak_milestone': 50,

    // Actions Entités
    'entity_created': 30,

    // Actions générales
    'first_login_today': 5,
    'profile_updated': 10,
    'settings_configured': 15,
  };

  /// Ajoute des points pour une action spécifique
  Future<void> addPointsForAction(String action, {String? customReason}) async {
    try {
      final points = actionPoints[action];
      if (points != null) {
        final reason = customReason ?? _getActionDisplayName(action);
        await _gamificationService.addPoints(points, reason);

        // Mettre à jour le streak quotidien
        await _gamificationService.updateStreak();
      }
    } catch (e) {
      print('Erreur addPointsForAction: $e');
    }
  }

  /// Ajoute des points personnalisés
  Future<void> addCustomPoints(int points, String reason) async {
    try {
      await _gamificationService.addPoints(points, reason);
    } catch (e) {
      print('Erreur addCustomPoints: $e');
    }
  }

  /// Actions Finance
  Future<void> onTransactionCreated() async {
    await addPointsForAction('transaction_created');
  }

  Future<void> onAccountCreated() async {
    await addPointsForAction('account_created');
  }

  Future<void> onBudgetCreated() async {
    await addPointsForAction('budget_created');
  }

  Future<void> onObjectiveCreated() async {
    await addPointsForAction('objective_created');
  }

  Future<void> onAutomationCreated() async {
    await addPointsForAction('automation_created');
  }

  /// Actions Tâches
  Future<void> onTaskCreated() async {
    await addPointsForAction('task_created');
  }

  Future<void> onTaskCompleted() async {
    await addPointsForAction('task_completed');
  }

  Future<void> onProjectCreated() async {
    await addPointsForAction('project_created');
  }

  Future<void> onTaskCategoryCreated() async {
    await addPointsForAction('task_category_created');
  }

  /// Actions Habitudes
  Future<void> onHabitCreated() async {
    await addPointsForAction('habit_created');
  }

  Future<void> onHabitCompleted() async {
    await addPointsForAction('habit_completed');
  }

  Future<void> onRoutineCreated() async {
    await addPointsForAction('routine_created');
  }

  Future<void> onRoutineCompleted() async {
    await addPointsForAction('routine_completed');
  }

  Future<void> onStreakMilestone(int streakDays) async {
    await addPointsForAction('streak_milestone',
        customReason: 'Streak de $streakDays jours atteint!');
  }

  /// Actions Entités
  Future<void> onEntityCreated() async {
    await addPointsForAction('entity_created');
  }

  /// Actions générales
  Future<void> onFirstLoginToday() async {
    await addPointsForAction('first_login_today');
  }

  Future<void> onProfileUpdated() async {
    await addPointsForAction('profile_updated');
  }

  Future<void> onSettingsConfigured() async {
    await addPointsForAction('settings_configured');
  }

  /// Bonus pour objectifs atteints
  Future<void> onObjectiveReached(String objectiveName, double amount) async {
    final bonusPoints = (amount / 1000).round().clamp(50, 500); // 1 point par 1000 FCFA, max 500
    await addCustomPoints(bonusPoints, 'Objectif atteint: $objectiveName');
  }

  /// Bonus pour completion de projet
  Future<void> onProjectCompleted(String projectName) async {
    await addCustomPoints(100, 'Projet terminé: $projectName');
  }

  /// Bonus pour série d'habitudes
  Future<void> onHabitSeriesCompleted(int habitsCount) async {
    final bonusPoints = habitsCount * 5;
    await addCustomPoints(bonusPoints, '$habitsCount habitudes complétées aujourd\'hui');
  }

  /// Vérifie et applique les bonus de streak
  Future<void> checkStreakBonuses(int currentStreak) async {
    // Bonus pour milestones de streak
    final milestones = [7, 14, 30, 60, 100, 365];

    for (final milestone in milestones) {
      if (currentStreak == milestone) {
        final bonusPoints = milestone * 2;
        await addCustomPoints(bonusPoints, 'Milestone de streak: $milestone jours!');
        break;
      }
    }
  }

  /// Bonus pour utilisation complète de l'app (tous les modules)
  Future<void> onFullAppUsage() async {
    await addCustomPoints(75, 'Utilisation complète de l\'application');
  }

  /// Convertit le nom d'action en libellé d'affichage
  String _getActionDisplayName(String action) {
    switch (action) {
      case 'transaction_created':
        return 'Création de transaction';
      case 'account_created':
        return 'Création de compte';
      case 'budget_created':
        return 'Création de budget';
      case 'objective_created':
        return 'Création d\'objectif';
      case 'automation_created':
        return 'Création d\'automatisation';
      case 'task_created':
        return 'Création de tâche';
      case 'task_completed':
        return 'Tâche terminée';
      case 'project_created':
        return 'Création de projet';
      case 'task_category_created':
        return 'Création de catégorie';
      case 'habit_created':
        return 'Création d\'habitude';
      case 'habit_completed':
        return 'Habitude effectuée';
      case 'routine_created':
        return 'Création de routine';
      case 'routine_completed':
        return 'Routine terminée';
      case 'streak_milestone':
        return 'Milestone de streak';
      case 'entity_created':
        return 'Création d\'entité';
      case 'first_login_today':
        return 'Première connexion du jour';
      case 'profile_updated':
        return 'Profil mis à jour';
      case 'settings_configured':
        return 'Paramètres configurés';
      default:
        return 'Action effectuée';
    }
  }
}