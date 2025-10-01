import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/gamification/models/achievement_model.dart';
import '../../../core/gamification/models/user_profile_model.dart';
import '../../../core/gamification/models/challenge_model.dart';
import '../../../core/gamification/services/gamification_service.dart';

class GamificationController extends GetxController {
  final GamificationService _gamificationService = Get.find<GamificationService>();

  // Observables
  final _userProfile = Rxn<UserProfile>();
  final _achievements = <Achievement>[].obs;
  final _activeChallenges = <Challenge>[].obs;
  final _userAchievements = <Achievement>[].obs;
  final _isLoading = false.obs;
  final _hasError = false.obs;
  final _errorMessage = ''.obs;

  // Getters
  UserProfile? get userProfile => _userProfile.value;
  List<Achievement> get achievements => _achievements;
  List<Challenge> get activeChallenges => _activeChallenges;
  List<Achievement> get userAchievements => _userAchievements;
  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;
  String get errorMessage => _errorMessage.value;

  // Stats calculées
  int get totalPoints => userProfile?.totalPoints ?? 0;
  UserLevel get currentLevel => userProfile?.level ?? UserLevel.novice;
  double get levelProgress => userProfile?.levelProgress ?? 0.0;
  int get streakDays => userProfile?.streakDays ?? 0;
  int get unlockedAchievementsCount => userProfile?.totalAchievements ?? 0;
  int get activeChallengesCount => userProfile?.activeChallengesCount ?? 0;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  /// Charge toutes les données utilisateur
  Future<void> loadUserData() async {
    try {
      _isLoading.value = true;
      _hasError.value = false;

      await Future.wait([
        _loadUserProfile(),
        _loadAchievements(),
        _loadActiveChallenges(),
      ]);

    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = 'Erreur lors du chargement: $e';
      print('Erreur loadUserData: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Charge le profil utilisateur
  Future<void> _loadUserProfile() async {
    final profile = await _gamificationService.getUserProfile();
    _userProfile.value = profile;
  }

  /// Charge tous les achievements
  Future<void> _loadAchievements() async {
    final achievements = await _gamificationService.getAvailableAchievements();
    _achievements.assignAll(achievements);

    // Filtrer les achievements de l'utilisateur
    if (userProfile != null) {
      final unlockedIds = userProfile!.unlockedAchievements;
      _userAchievements.assignAll(
        achievements.where((a) => unlockedIds.contains(a.id)).toList()
      );
    }
  }

  /// Charge les challenges actifs
  Future<void> _loadActiveChallenges() async {
    final challenges = await _gamificationService.getActiveChallenges();
    _activeChallenges.assignAll(challenges);
  }

  /// Ajoute des points manuellement
  Future<void> addPoints(int points, String reason) async {
    try {
      await _gamificationService.addPoints(points, reason);
      await _loadUserProfile(); // Recharger le profil
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'ajouter les points: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Rejoint un challenge
  Future<void> joinChallenge(String challengeId) async {
    try {
      await _gamificationService.joinChallenge(challengeId);
      await loadUserData(); // Recharger les données
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de rejoindre le challenge: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Met à jour le streak quotidien
  Future<void> updateDailyStreak() async {
    try {
      await _gamificationService.updateStreak();
      await _loadUserProfile();
    } catch (e) {
      print('Erreur updateDailyStreak: $e');
    }
  }

  /// Vérifie si une fonctionnalité est débloquée
  Future<bool> isFeatureUnlocked(String featureId) async {
    return await _gamificationService.isFeatureUnlocked(featureId);
  }

  /// Débloque une fonctionnalité
  Future<void> unlockFeature(String featureId) async {
    try {
      await _gamificationService.unlockFeature(featureId);
      await _loadUserProfile();

      Get.snackbar(
        '🔓 Fonctionnalité débloquée!',
        'Nouvelle fonctionnalité disponible',
        backgroundColor: Get.theme.colorScheme.secondary,
        colorText: Get.theme.colorScheme.onSecondary,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de débloquer la fonctionnalité: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Filtre les achievements par catégorie
  List<Achievement> getAchievementsByCategory(AchievementCategory category) {
    return _achievements.where((a) => a.category == category).toList();
  }

  /// Filtre les achievements par difficulté
  List<Achievement> getAchievementsByDifficulty(AchievementDifficulty difficulty) {
    return _achievements.where((a) => a.difficulty == difficulty).toList();
  }

  /// Récupère les achievements non débloqués
  List<Achievement> get lockedAchievements {
    if (userProfile == null) return _achievements;

    final unlockedIds = userProfile!.unlockedAchievements;
    return _achievements.where((a) => !unlockedIds.contains(a.id)).toList();
  }

  /// Récupère les achievements récemment débloqués (7 derniers jours)
  List<Achievement> get recentAchievements {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _userAchievements.where((a) {
      return a.unlockedAt != null && a.unlockedAt!.isAfter(weekAgo);
    }).toList();
  }

  /// Calcule le pourcentage de completion global
  double get globalCompletionPercentage {
    if (_achievements.isEmpty) return 0.0;
    return _userAchievements.length / _achievements.length;
  }

  /// Récupère les challenges auxquels l'utilisateur participe
  List<Challenge> get userActiveChallenges {
    if (userProfile == null) return [];

    final userChallengeIds = userProfile!.activeChallenge;
    return _activeChallenges.where((c) => userChallengeIds.contains(c.id)).toList();
  }

  /// Récupère les challenges disponibles (non rejoints)
  List<Challenge> get availableChallenges {
    if (userProfile == null) return _activeChallenges;

    final userChallengeIds = userProfile!.activeChallenge;
    return _activeChallenges.where((c) => !userChallengeIds.contains(c.id)).toList();
  }

  /// Rafraîchit toutes les données
  Future<void> refresh() async {
    await loadUserData();
  }

  /// Affiche les détails d'un achievement
  void showAchievementDetails(Achievement achievement) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(
              achievement.isUnlocked ? Icons.emoji_events : Icons.lock,
              color: achievement.isUnlocked ? Colors.orange : Colors.grey,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(achievement.name)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(achievement.description),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.stars, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text('${achievement.pointsReward} points'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.category, size: 16),
                const SizedBox(width: 4),
                Text(_getCategoryDisplayName(achievement.category)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.military_tech, size: 16),
                const SizedBox(width: 4),
                Text(_getDifficultyDisplayName(achievement.difficulty)),
              ],
            ),
            if (achievement.isUnlocked && achievement.unlockedAt != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 4),
                  Text('Débloqué le ${_formatDate(achievement.unlockedAt!)}'),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  /// Affiche les détails d'un challenge
  void showChallengeDetails(Challenge challenge) {
    final isParticipating = userProfile?.activeChallenge.contains(challenge.id) ?? false;

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(child: Text(challenge.name)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(challenge.description),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.stars, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text('${challenge.pointsReward} points'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.timer, size: 16),
                const SizedBox(width: 4),
                Text(challenge.timeRemainingText),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.people, size: 16),
                const SizedBox(width: 4),
                Text('${challenge.participants.length} participants'),
              ],
            ),
            if (isParticipating) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: challenge.progressPercentage,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Get.theme.colorScheme.primary),
              ),
              const SizedBox(height: 4),
              Text('Progression: ${challenge.progress}/${challenge.maxProgress}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Fermer'),
          ),
          if (!isParticipating && challenge.isActive)
            ElevatedButton(
              onPressed: () {
                Get.back();
                joinChallenge(challenge.id);
              },
              child: const Text('Rejoindre'),
            ),
        ],
      ),
    );
  }

  String _getCategoryDisplayName(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.finance:
        return 'Finance';
      case AchievementCategory.tasks:
        return 'Tâches';
      case AchievementCategory.habits:
        return 'Habitudes';
      case AchievementCategory.general:
        return 'Général';
      case AchievementCategory.social:
        return 'Social';
    }
  }

  String _getDifficultyDisplayName(AchievementDifficulty difficulty) {
    switch (difficulty) {
      case AchievementDifficulty.bronze:
        return 'Bronze';
      case AchievementDifficulty.silver:
        return 'Argent';
      case AchievementDifficulty.gold:
        return 'Or';
      case AchievementDifficulty.platinum:
        return 'Platine';
      case AchievementDifficulty.diamond:
        return 'Diamant';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}