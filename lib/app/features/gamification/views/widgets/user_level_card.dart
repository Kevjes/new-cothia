import 'package:flutter/material.dart';
import '../../../../core/gamification/models/user_profile_model.dart';
import '../../../../core/constants/app_colors.dart';

class UserLevelCard extends StatelessWidget {
  final UserProfile userProfile;
  final VoidCallback? onTap;

  const UserLevelCard({
    super.key,
    required this.userProfile,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                _getLevelColor().withOpacity(0.3),
                _getLevelColor().withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _buildLevelIcon(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getLevelDisplayName(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${userProfile.totalPoints} points',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[300],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getLevelColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Niveau ${_getLevelNumber()}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getLevelColor(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progression vers ${_getNextLevelName()}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                      Text(
                        '${userProfile.currentLevelPoints}/${userProfile.nextLevelPoints}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: userProfile.levelProgress,
                    backgroundColor: Colors.grey[700],
                    valueColor: AlwaysStoppedAnimation<Color>(_getLevelColor()),
                    minHeight: 6,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    Icons.emoji_events,
                    '${userProfile.totalAchievements}',
                    'Achievements',
                    Colors.amber,
                  ),
                  _buildStatItem(
                    Icons.local_fire_department,
                    '${userProfile.streakDays}',
                    'Streak',
                    Colors.orange,
                  ),
                  _buildStatItem(
                    Icons.flag,
                    '${userProfile.activeChallengesCount}',
                    'Défis actifs',
                    Colors.blue,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelIcon() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: _getLevelColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: _getLevelColor(),
          width: 2,
        ),
      ),
      child: Icon(
        _getLevelIcon(),
        color: _getLevelColor(),
        size: 30,
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }

  Color _getLevelColor() {
    switch (userProfile.level) {
      case UserLevel.novice:
        return const Color(0xFFCD7F32); // Bronze
      case UserLevel.apprentice:
        return const Color(0xFFC0C0C0); // Silver
      case UserLevel.expert:
        return const Color(0xFFFFD700); // Gold
      case UserLevel.master:
        return const Color(0xFFE5E4E2); // Platinum
      case UserLevel.legend:
        return const Color(0xFFB9F2FF); // Diamond
    }
  }

  IconData _getLevelIcon() {
    switch (userProfile.level) {
      case UserLevel.novice:
        return Icons.school;
      case UserLevel.apprentice:
        return Icons.build;
      case UserLevel.expert:
        return Icons.star;
      case UserLevel.master:
        return Icons.emoji_events;
      case UserLevel.legend:
        return Icons.military_tech;
    }
  }

  String _getLevelDisplayName() {
    switch (userProfile.level) {
      case UserLevel.novice:
        return 'Novice';
      case UserLevel.apprentice:
        return 'Apprenti';
      case UserLevel.expert:
        return 'Expert';
      case UserLevel.master:
        return 'Maître';
      case UserLevel.legend:
        return 'Légende';
    }
  }

  int _getLevelNumber() {
    switch (userProfile.level) {
      case UserLevel.novice:
        return 1;
      case UserLevel.apprentice:
        return 2;
      case UserLevel.expert:
        return 3;
      case UserLevel.master:
        return 4;
      case UserLevel.legend:
        return 5;
    }
  }

  String _getNextLevelName() {
    switch (userProfile.level) {
      case UserLevel.novice:
        return 'Apprenti';
      case UserLevel.apprentice:
        return 'Expert';
      case UserLevel.expert:
        return 'Maître';
      case UserLevel.master:
        return 'Légende';
      case UserLevel.legend:
        return 'Légende Max';
    }
  }
}