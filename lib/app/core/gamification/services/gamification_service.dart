import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/achievement_model.dart';
import '../models/user_profile_model.dart';
import '../models/challenge_model.dart';
import '../../services/storage_service.dart';

class GamificationService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storageService = Get.find<StorageService>();

  String? get currentUserId => _storageService.getUserId();

  // Collections references
  CollectionReference get _userProfilesCollection => _firestore.collection('user_profiles');
  CollectionReference get _achievementsCollection => _firestore.collection('achievements');
  CollectionReference get _challengesCollection => _firestore.collection('challenges');
  CollectionReference get _userAchievementsCollection => _firestore.collection('user_achievements');
  CollectionReference get _userChallengesCollection => _firestore.collection('user_challenges');

  /// Initialise ou récupère le profil utilisateur
  Future<UserProfile?> getUserProfile() async {
    if (currentUserId == null) return null;

    try {
      final doc = await _userProfilesCollection.doc(currentUserId).get();

      if (doc.exists) {
        return UserProfile.fromMap({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>
        });
      } else {
        // Créer un nouveau profil
        final newProfile = UserProfile.createDefault(currentUserId!);
        await _createUserProfile(newProfile);
        return newProfile;
      }
    } catch (e) {
      print('Erreur getUserProfile: $e');
      return null;
    }
  }

  /// Crée un nouveau profil utilisateur
  Future<void> _createUserProfile(UserProfile profile) async {
    try {
      await _userProfilesCollection.doc(currentUserId).set(profile.toMap());

      // Initialiser quelques achievements de base
      await _initializeDefaultAchievements();
    } catch (e) {
      print('Erreur _createUserProfile: $e');
      rethrow;
    }
  }

  /// Ajoute des points à l'utilisateur
  Future<void> addPoints(int points, String reason) async {
    if (currentUserId == null) return;

    try {
      final profile = await getUserProfile();
      if (profile == null) return;

      final newTotalPoints = profile.totalPoints + points;
      final updatedProfile = await _calculateLevelProgress(profile, newTotalPoints);

      await _userProfilesCollection.doc(currentUserId).update({
        'totalPoints': newTotalPoints,
        'level': updatedProfile.level.toString().split('.').last,
        'currentLevelPoints': updatedProfile.currentLevelPoints,
        'nextLevelPoints': updatedProfile.nextLevelPoints,
        'lastActivityDate': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Vérifier si de nouveaux achievements sont débloqués
      await _checkAchievements(updatedProfile);

      // Notification de gain de points
      Get.snackbar(
        '🎉 Points gagnés!',
        '+$points points pour: $reason',
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
        duration: const Duration(seconds: 2),
      );

    } catch (e) {
      print('Erreur addPoints: $e');
    }
  }

  /// Calcule la progression de niveau
  Future<UserProfile> _calculateLevelProgress(UserProfile profile, int newTotalPoints) async {
    UserLevel newLevel = profile.level;
    int currentLevelPoints = profile.currentLevelPoints;
    int nextLevelPoints = profile.nextLevelPoints;

    // Définir les seuils de niveau
    final levelThresholds = {
      UserLevel.novice: 0,
      UserLevel.apprentice: 500,
      UserLevel.expert: 1500,
      UserLevel.master: 5000,
      UserLevel.legend: 15000,
    };

    // Déterminer le nouveau niveau
    for (final entry in levelThresholds.entries.toList().reversed) {
      if (newTotalPoints >= entry.value) {
        newLevel = entry.key;
        break;
      }
    }

    // Calculer les points pour le niveau actuel
    final currentThreshold = levelThresholds[newLevel] ?? 0;
    final nextLevel = _getNextLevel(newLevel);
    final nextThreshold = levelThresholds[nextLevel] ?? currentThreshold;

    currentLevelPoints = newTotalPoints - currentThreshold;
    nextLevelPoints = nextThreshold - currentThreshold;

    return profile.copyWith(
      totalPoints: newTotalPoints,
      level: newLevel,
      currentLevelPoints: currentLevelPoints,
      nextLevelPoints: nextLevelPoints,
    );
  }

  UserLevel _getNextLevel(UserLevel currentLevel) {
    switch (currentLevel) {
      case UserLevel.novice:
        return UserLevel.apprentice;
      case UserLevel.apprentice:
        return UserLevel.expert;
      case UserLevel.expert:
        return UserLevel.master;
      case UserLevel.master:
        return UserLevel.legend;
      case UserLevel.legend:
        return UserLevel.legend;
    }
  }

  /// Vérifie et débloque les achievements
  Future<void> _checkAchievements(UserProfile profile) async {
    try {
      final achievements = await getAvailableAchievements();

      for (final achievement in achievements) {
        if (!profile.unlockedAchievements.contains(achievement.id)) {
          final shouldUnlock = await _evaluateAchievementCriteria(achievement, profile);

          if (shouldUnlock) {
            await _unlockAchievement(achievement);
          }
        }
      }
    } catch (e) {
      print('Erreur _checkAchievements: $e');
    }
  }

  /// Évalue si un achievement doit être débloqué
  Future<bool> _evaluateAchievementCriteria(Achievement achievement, UserProfile profile) async {
    try {
      final criteria = achievement.criteria;

      switch (achievement.type) {
        case AchievementType.milestone:
          final requiredPoints = criteria['points'] as int? ?? 0;
          return profile.totalPoints >= requiredPoints;

        case AchievementType.streak:
          final requiredStreak = criteria['streak'] as int? ?? 0;
          return profile.streakDays >= requiredStreak;

        case AchievementType.badge:
          // Logique spécifique aux badges
          return await _evaluateBadgeCriteria(criteria, profile);

        default:
          return false;
      }
    } catch (e) {
      print('Erreur _evaluateAchievementCriteria: $e');
      return false;
    }
  }

  /// Évalue les critères spécifiques aux badges
  Future<bool> _evaluateBadgeCriteria(Map<String, dynamic> criteria, UserProfile profile) async {
    // À implémenter selon les critères spécifiques
    return false;
  }

  /// Débloque un achievement
  Future<void> _unlockAchievement(Achievement achievement) async {
    if (currentUserId == null) return;

    try {
      // Ajouter à la liste des achievements débloqués
      await _userProfilesCollection.doc(currentUserId).update({
        'unlockedAchievements': FieldValue.arrayUnion([achievement.id]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Ajouter les points de récompense
      await addPoints(achievement.pointsReward, 'Achievement: ${achievement.name}');

      // Notification d'achievement débloqué
      Get.snackbar(
        '🏆 Achievement débloqué!',
        achievement.name,
        backgroundColor: Get.theme.colorScheme.secondary,
        colorText: Get.theme.colorScheme.onSecondary,
        duration: const Duration(seconds: 3),
      );

    } catch (e) {
      print('Erreur _unlockAchievement: $e');
    }
  }

  /// Récupère tous les achievements disponibles
  Future<List<Achievement>> getAvailableAchievements() async {
    try {
      final snapshot = await _achievementsCollection.get();
      return snapshot.docs
          .map((doc) => Achievement.fromMap({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>
              }))
          .toList();
    } catch (e) {
      print('Erreur getAvailableAchievements: $e');
      return [];
    }
  }

  /// Récupère les challenges actifs
  Future<List<Challenge>> getActiveChallenges() async {
    try {
      final snapshot = await _challengesCollection
          .where('status', isEqualTo: 'active')
          .where('endDate', isGreaterThan: Timestamp.now())
          .get();

      return snapshot.docs
          .map((doc) => Challenge.fromMap({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>
              }))
          .toList();
    } catch (e) {
      print('Erreur getActiveChallenges: $e');
      return [];
    }
  }

  /// Participe à un challenge
  Future<void> joinChallenge(String challengeId) async {
    if (currentUserId == null) return;

    try {
      // Ajouter l'utilisateur aux participants du challenge
      await _challengesCollection.doc(challengeId).update({
        'participants': FieldValue.arrayUnion([currentUserId]),
      });

      // Ajouter le challenge aux challenges actifs de l'utilisateur
      await _userProfilesCollection.doc(currentUserId).update({
        'activeChallenge': FieldValue.arrayUnion([challengeId]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      Get.snackbar(
        '✅ Challenge rejoint!',
        'Bonne chance!',
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );

    } catch (e) {
      print('Erreur joinChallenge: $e');
    }
  }

  /// Met à jour le streak de l'utilisateur
  Future<void> updateStreak() async {
    if (currentUserId == null) return;

    try {
      final profile = await getUserProfile();
      if (profile == null) return;

      final now = DateTime.now();
      final lastActivity = profile.lastActivityDate;

      int newStreak = profile.streakDays;

      if (lastActivity != null) {
        final daysDifference = now.difference(lastActivity).inDays;

        if (daysDifference == 1) {
          // Continuité du streak
          newStreak += 1;
        } else if (daysDifference > 1) {
          // Streak cassé
          newStreak = 1;
        }
        // Si daysDifference == 0, on garde le même streak
      } else {
        newStreak = 1;
      }

      await _userProfilesCollection.doc(currentUserId).update({
        'streakDays': newStreak,
        'lastActivityDate': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      });

    } catch (e) {
      print('Erreur updateStreak: $e');
    }
  }

  /// Initialise les achievements par défaut
  Future<void> _initializeDefaultAchievements() async {
    final defaultAchievements = [
      {
        'id': 'first_steps',
        'name': 'Premiers pas',
        'description': 'Bienvenue dans Cothia!',
        'iconPath': 'assets/icons/trophy.png',
        'type': 'milestone',
        'category': 'general',
        'difficulty': 'bronze',
        'pointsReward': 50,
        'criteria': {'points': 0},
        'maxProgress': 1,
      },
      {
        'id': 'point_collector',
        'name': 'Collecteur de points',
        'description': 'Gagnez 500 points',
        'iconPath': 'assets/icons/star.png',
        'type': 'milestone',
        'category': 'general',
        'difficulty': 'silver',
        'pointsReward': 100,
        'criteria': {'points': 500},
        'maxProgress': 1,
      },
      {
        'id': 'streak_master',
        'name': 'Maître du streak',
        'description': 'Maintenez un streak de 7 jours',
        'iconPath': 'assets/icons/fire.png',
        'type': 'streak',
        'category': 'general',
        'difficulty': 'gold',
        'pointsReward': 200,
        'criteria': {'streak': 7},
        'maxProgress': 1,
      },
    ];

    for (final achievement in defaultAchievements) {
      try {
        await _achievementsCollection.doc(achievement['id'] as String).set(achievement);
      } catch (e) {
        print('Erreur initialisation achievement ${achievement['id']}: $e');
      }
    }
  }

  /// Débloque une fonctionnalité premium
  Future<void> unlockFeature(String featureId) async {
    if (currentUserId == null) return;

    try {
      await _userProfilesCollection.doc(currentUserId).update({
        'unlockedFeatures.$featureId': true,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      print('Erreur unlockFeature: $e');
    }
  }

  /// Vérifie si une fonctionnalité est débloquée
  Future<bool> isFeatureUnlocked(String featureId) async {
    final profile = await getUserProfile();
    return profile?.hasUnlockedFeature(featureId) ?? false;
  }
}