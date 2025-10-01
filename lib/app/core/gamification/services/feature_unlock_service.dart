import 'package:get/get.dart';
import 'gamification_service.dart';
import '../models/user_profile_model.dart';

class FeatureUnlockService extends GetxService {
  final GamificationService _gamificationService = Get.find<GamificationService>();

  /// Configuration des fonctionnalités débloquables
  static const Map<String, Map<String, dynamic>> featureConfig = {
    // Fonctionnalités de base (toujours débloquées)
    'basic_dashboard': {
      'name': 'Dashboard de base',
      'description': 'Accès au dashboard principal',
      'requiredPoints': 0,
      'requiredLevel': UserLevel.novice,
      'category': 'core',
    },
    'basic_tracking': {
      'name': 'Suivi de base',
      'description': 'Fonctionnalités de suivi essentielles',
      'requiredPoints': 0,
      'requiredLevel': UserLevel.novice,
      'category': 'core',
    },

    // Fonctionnalités Finance
    'advanced_budgets': {
      'name': 'Budgets avancés',
      'description': 'Budgets avec catégories multiples et prévisions',
      'requiredPoints': 250,
      'requiredLevel': UserLevel.apprentice,
      'category': 'finance',
    },
    'investment_tracking': {
      'name': 'Suivi d\'investissements',
      'description': 'Suivi des portefeuilles et investissements',
      'requiredPoints': 500,
      'requiredLevel': UserLevel.expert,
      'category': 'finance',
    },
    'automated_transfers': {
      'name': 'Transferts automatisés',
      'description': 'Automatisation des transferts et épargne',
      'requiredPoints': 750,
      'requiredLevel': UserLevel.expert,
      'category': 'finance',
    },
    'financial_analytics': {
      'name': 'Analytics financières avancées',
      'description': 'Rapports détaillés et prédictions',
      'requiredPoints': 1000,
      'requiredLevel': UserLevel.master,
      'category': 'finance',
    },

    // Fonctionnalités Tâches
    'advanced_projects': {
      'name': 'Gestion de projets avancée',
      'description': 'Projets avec sous-tâches et dépendances',
      'requiredPoints': 300,
      'requiredLevel': UserLevel.apprentice,
      'category': 'tasks',
    },
    'time_tracking': {
      'name': 'Suivi du temps',
      'description': 'Chronométrage des tâches et rapports de temps',
      'requiredPoints': 600,
      'requiredLevel': UserLevel.expert,
      'category': 'tasks',
    },
    'team_collaboration': {
      'name': 'Collaboration d\'équipe',
      'description': 'Partage de projets et assignation de tâches',
      'requiredPoints': 1200,
      'requiredLevel': UserLevel.master,
      'category': 'tasks',
    },

    // Fonctionnalités Habitudes
    'habit_analytics': {
      'name': 'Analytics d\'habitudes',
      'description': 'Analyses approfondies des patterns d\'habitudes',
      'requiredPoints': 400,
      'requiredLevel': UserLevel.apprentice,
      'category': 'habits',
    },
    'advanced_routines': {
      'name': 'Routines avancées',
      'description': 'Routines complexes avec conditions et déclencheurs',
      'requiredPoints': 700,
      'requiredLevel': UserLevel.expert,
      'category': 'habits',
    },
    'habit_coaching': {
      'name': 'Coaching d\'habitudes IA',
      'description': 'Suggestions personnalisées basées sur l\'IA',
      'requiredPoints': 1500,
      'requiredLevel': UserLevel.master,
      'category': 'habits',
    },

    // Fonctionnalités Premium
    'unlimited_entities': {
      'name': 'Entités illimitées',
      'description': 'Créez autant d\'entités que vous voulez',
      'requiredPoints': 800,
      'requiredLevel': UserLevel.expert,
      'category': 'premium',
    },
    'data_export': {
      'name': 'Export de données',
      'description': 'Exportez vos données dans différents formats',
      'requiredPoints': 1000,
      'requiredLevel': UserLevel.master,
      'category': 'premium',
    },
    'backup_sync': {
      'name': 'Sauvegarde cloud',
      'description': 'Synchronisation automatique dans le cloud',
      'requiredPoints': 1200,
      'requiredLevel': UserLevel.master,
      'category': 'premium',
    },
    'premium_themes': {
      'name': 'Thèmes premium',
      'description': 'Accès à des thèmes exclusifs',
      'requiredPoints': 500,
      'requiredLevel': UserLevel.expert,
      'category': 'premium',
    },
    'advanced_ai': {
      'name': 'IA avancée',
      'description': 'Suggestions IA personnalisées et prédictions',
      'requiredPoints': 2000,
      'requiredLevel': UserLevel.legend,
      'category': 'premium',
    },

    // Fonctionnalités sociales
    'achievements_sharing': {
      'name': 'Partage d\'achievements',
      'description': 'Partagez vos succès avec d\'autres utilisateurs',
      'requiredPoints': 350,
      'requiredLevel': UserLevel.apprentice,
      'category': 'social',
    },
    'leaderboards': {
      'name': 'Classements',
      'description': 'Participez aux classements communautaires',
      'requiredPoints': 600,
      'requiredLevel': UserLevel.expert,
      'category': 'social',
    },
    'group_challenges': {
      'name': 'Défis de groupe',
      'description': 'Participez à des défis avec d\'autres utilisateurs',
      'requiredPoints': 900,
      'requiredLevel': UserLevel.expert,
      'category': 'social',
    },
  };

  /// Vérifie si une fonctionnalité est débloquée pour l'utilisateur
  Future<bool> isFeatureUnlocked(String featureId) async {
    final profile = await _gamificationService.getUserProfile();
    if (profile == null) return false;

    // Vérifier d'abord si c'est déjà débloqué manuellement
    if (profile.hasUnlockedFeature(featureId)) return true;

    // Vérifier les critères automatiques
    return _checkAutomaticUnlock(featureId, profile);
  }

  /// Vérifie les critères de déblocage automatique
  bool _checkAutomaticUnlock(String featureId, UserProfile profile) {
    final config = featureConfig[featureId];
    if (config == null) return false;

    final requiredPoints = config['requiredPoints'] as int;
    final requiredLevel = config['requiredLevel'] as UserLevel;

    // Vérifier les points et le niveau
    final hasEnoughPoints = profile.totalPoints >= requiredPoints;
    final hasRequiredLevel = _isLevelHigherOrEqual(profile.level, requiredLevel);

    return hasEnoughPoints && hasRequiredLevel;
  }

  /// Compare les niveaux utilisateur
  bool _isLevelHigherOrEqual(UserLevel userLevel, UserLevel requiredLevel) {
    const levelOrder = [
      UserLevel.novice,
      UserLevel.apprentice,
      UserLevel.expert,
      UserLevel.master,
      UserLevel.legend,
    ];

    final userIndex = levelOrder.indexOf(userLevel);
    final requiredIndex = levelOrder.indexOf(requiredLevel);

    return userIndex >= requiredIndex;
  }

  /// Vérifie et débloque automatiquement les fonctionnalités
  Future<List<String>> checkAndUnlockFeatures() async {
    final profile = await _gamificationService.getUserProfile();
    if (profile == null) return [];

    final newlyUnlocked = <String>[];

    for (final featureId in featureConfig.keys) {
      // Skip si déjà débloqué
      if (profile.hasUnlockedFeature(featureId)) continue;

      // Vérifier les critères
      if (_checkAutomaticUnlock(featureId, profile)) {
        await _gamificationService.unlockFeature(featureId);
        newlyUnlocked.add(featureId);

        // Notification de déblocage
        final config = featureConfig[featureId]!;
        Get.snackbar(
          '🔓 Nouvelle fonctionnalité!',
          config['name'] as String,
          backgroundColor: Get.theme.colorScheme.secondary,
          colorText: Get.theme.colorScheme.onSecondary,
          duration: const Duration(seconds: 4),
        );
      }
    }

    return newlyUnlocked;
  }

  /// Récupère toutes les fonctionnalités avec leur statut
  Future<Map<String, Map<String, dynamic>>> getAllFeaturesWithStatus() async {
    final profile = await _gamificationService.getUserProfile();
    final featuresWithStatus = <String, Map<String, dynamic>>{};

    for (final entry in featureConfig.entries) {
      final featureId = entry.key;
      final config = Map<String, dynamic>.from(entry.value);

      // Ajouter le statut de déblocage
      config['isUnlocked'] = profile != null &&
          (profile.hasUnlockedFeature(featureId) || _checkAutomaticUnlock(featureId, profile));

      // Ajouter les informations de progression
      if (profile != null && !config['isUnlocked']) {
        final requiredPoints = config['requiredPoints'] as int;
        final requiredLevel = config['requiredLevel'] as UserLevel;

        config['pointsProgress'] = profile.totalPoints;
        config['pointsNeeded'] = requiredPoints - profile.totalPoints;
        config['levelProgress'] = profile.level;
        config['levelNeeded'] = requiredLevel;
        config['canUnlock'] = _checkAutomaticUnlock(featureId, profile);
      }

      featuresWithStatus[featureId] = config;
    }

    return featuresWithStatus;
  }

  /// Récupère les fonctionnalités par catégorie
  Future<Map<String, List<Map<String, dynamic>>>> getFeaturesByCategory() async {
    final allFeatures = await getAllFeaturesWithStatus();
    final categories = <String, List<Map<String, dynamic>>>{};

    for (final entry in allFeatures.entries) {
      final featureId = entry.key;
      final config = entry.value;
      final category = config['category'] as String;

      categories.putIfAbsent(category, () => []);
      categories[category]!.add({
        'id': featureId,
        ...config,
      });
    }

    return categories;
  }

  /// Récupère les fonctionnalités récemment débloquées
  Future<List<String>> getRecentlyUnlockedFeatures() async {
    final profile = await _gamificationService.getUserProfile();
    if (profile == null) return [];

    // Pour l'instant, on retourne toutes les fonctionnalités débloquées
    // Dans une version future, on pourrait stocker la date de déblocage
    return profile.unlockedFeatures.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();
  }

  /// Débloque manuellement une fonctionnalité (pour les admins/tests)
  Future<void> manuallyUnlockFeature(String featureId) async {
    await _gamificationService.unlockFeature(featureId);
  }

  /// Affiche les détails d'une fonctionnalité
  Map<String, dynamic>? getFeatureDetails(String featureId) {
    return featureConfig[featureId];
  }

  /// Récupère le nom d'affichage d'une catégorie
  String getCategoryDisplayName(String category) {
    switch (category) {
      case 'core':
        return 'Fonctionnalités de base';
      case 'finance':
        return 'Finance avancée';
      case 'tasks':
        return 'Gestion de tâches';
      case 'habits':
        return 'Habitudes avancées';
      case 'premium':
        return 'Fonctionnalités premium';
      case 'social':
        return 'Fonctionnalités sociales';
      default:
        return 'Autres';
    }
  }
}