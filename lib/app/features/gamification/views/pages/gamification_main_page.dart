import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/gamification_controller.dart';
import '../widgets/user_level_card.dart';
import '../widgets/achievement_card.dart';
import '../widgets/challenge_card.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/gamification/models/achievement_model.dart';

class GamificationMainPage extends GetView<GamificationController> {
  const GamificationMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gamification'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refresh(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.hasError) {
          return _buildErrorView();
        }

        if (controller.userProfile == null) {
          return _buildNoDataView();
        }

        return RefreshIndicator(
          onRefresh: () => controller.refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Carte de niveau utilisateur
                UserLevelCard(
                  userProfile: controller.userProfile!,
                  onTap: () => _showLevelDetails(),
                ),

                // Statistiques rapides
                _buildQuickStats(),

                // Achievements récents
                _buildRecentAchievements(),

                // Challenges actifs
                _buildActiveChallenges(),

                // Achievements par catégorie
                _buildAchievementsByCategory(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Erreur de chargement',
            style: Get.textTheme.titleLarge?.copyWith(color: Colors.red),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              controller.errorMessage,
              style: Get.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => controller.refresh(),
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Gamification non disponible',
            style: Get.textTheme.titleLarge?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Connectez-vous pour accéder à vos achievements et défis',
            style: Get.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistiques rapides',
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Points',
                  '${controller.totalPoints}',
                  Icons.stars,
                  Colors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Achievements',
                  '${controller.unlockedAchievementsCount}/${controller.achievements.length}',
                  Icons.emoji_events,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Streak',
                  '${controller.streakDays} jours',
                  Icons.local_fire_department,
                  Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Completion',
                  '${(controller.globalCompletionPercentage * 100).toInt()}%',
                  Icons.pie_chart,
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[400],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAchievements() {
    final recentAchievements = controller.recentAchievements;

    if (recentAchievements.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'Achievements récents',
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _showAllAchievements(),
                child: const Text('Voir tout'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: recentAchievements.length,
            itemBuilder: (context, index) {
              final achievement = recentAchievements[index];
              return SizedBox(
                width: 280,
                child: AchievementCard(
                  achievement: achievement,
                  onTap: () => controller.showAchievementDetails(achievement),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActiveChallenges() {
    final userChallenges = controller.userActiveChallenges;
    final availableChallenges = controller.availableChallenges.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'Défis',
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _showAllChallenges(),
                child: const Text('Voir tout'),
              ),
            ],
          ),
        ),

        // Défis participés
        if (userChallenges.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Mes défis actifs',
              style: Get.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[400],
              ),
            ),
          ),
          ...userChallenges.map((challenge) => ChallengeCard(
                challenge: challenge,
                isParticipating: true,
                onTap: () => controller.showChallengeDetails(challenge),
              )),
        ],

        // Défis disponibles
        if (availableChallenges.isNotEmpty) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Défis disponibles',
              style: Get.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[400],
              ),
            ),
          ),
          ...availableChallenges.map((challenge) => ChallengeCard(
                challenge: challenge,
                isParticipating: false,
                onTap: () => controller.showChallengeDetails(challenge),
                onJoin: () => controller.joinChallenge(challenge.id),
              )),
        ],

        // Message si aucun défi
        if (userChallenges.isEmpty && availableChallenges.isEmpty)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.emoji_events,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aucun défi disponible',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAchievementsByCategory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Tous les achievements',
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        DefaultTabController(
          length: 5,
          child: Column(
            children: [
              TabBar(
                isScrollable: true,
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey[400],
                indicatorColor: AppColors.primary,
                tabs: const [
                  Tab(text: 'Général'),
                  Tab(text: 'Finance'),
                  Tab(text: 'Tâches'),
                  Tab(text: 'Habitudes'),
                  Tab(text: 'Social'),
                ],
              ),
              SizedBox(
                height: 400,
                child: TabBarView(
                  children: [
                    _buildAchievementsTab(controller.getAchievementsByCategory(AchievementCategory.general)),
                    _buildAchievementsTab(controller.getAchievementsByCategory(AchievementCategory.finance)),
                    _buildAchievementsTab(controller.getAchievementsByCategory(AchievementCategory.tasks)),
                    _buildAchievementsTab(controller.getAchievementsByCategory(AchievementCategory.habits)),
                    _buildAchievementsTab(controller.getAchievementsByCategory(AchievementCategory.social)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsTab(List achievements) {
    if (achievements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'Aucun achievement dans cette catégorie',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return AchievementCard(
          achievement: achievement,
          onTap: () => controller.showAchievementDetails(achievement),
        );
      },
    );
  }

  void _showLevelDetails() {
    // TODO: Implémenter page détails niveau
  }

  void _showAllAchievements() {
    // TODO: Implémenter page tous les achievements
  }

  void _showAllChallenges() {
    // TODO: Implémenter page tous les challenges
  }
}