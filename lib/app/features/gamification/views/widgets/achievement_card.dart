import 'package:flutter/material.dart';
import '../../../../core/gamification/models/achievement_model.dart';
import '../../../../core/constants/app_colors.dart';

class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback? onTap;

  const AchievementCard({
    super.key,
    required this.achievement,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: achievement.isUnlocked ? Colors.white : Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: achievement.isUnlocked ? Colors.grey[300] : Colors.grey[500],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildDifficultyChip(),
                        const SizedBox(width: 8),
                        _buildPointsChip(),
                      ],
                    ),
                  ],
                ),
              ),
              if (achievement.isUnlocked)
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 20,
                )
              else
                Icon(
                  Icons.lock,
                  color: Colors.grey[600],
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _getDifficultyColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        _getTypeIcon(),
        color: achievement.isUnlocked ? _getDifficultyColor() : Colors.grey[600],
        size: 24,
      ),
    );
  }

  Widget _buildDifficultyChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getDifficultyColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _getDifficultyDisplayName(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: _getDifficultyColor(),
        ),
      ),
    );
  }

  Widget _buildPointsChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.stars,
            size: 10,
            color: Colors.amber,
          ),
          const SizedBox(width: 2),
          Text(
            '${achievement.pointsReward}',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.amber,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon() {
    switch (achievement.type) {
      case AchievementType.badge:
        return Icons.military_tech;
      case AchievementType.milestone:
        return Icons.flag;
      case AchievementType.streak:
        return Icons.local_fire_department;
      case AchievementType.challenge:
        return Icons.emoji_events;
      case AchievementType.level:
        return Icons.trending_up;
    }
  }

  Color _getDifficultyColor() {
    switch (achievement.difficulty) {
      case AchievementDifficulty.bronze:
        return const Color(0xFFCD7F32);
      case AchievementDifficulty.silver:
        return const Color(0xFFC0C0C0);
      case AchievementDifficulty.gold:
        return const Color(0xFFFFD700);
      case AchievementDifficulty.platinum:
        return const Color(0xFFE5E4E2);
      case AchievementDifficulty.diamond:
        return const Color(0xFFB9F2FF);
    }
  }

  String _getDifficultyDisplayName() {
    switch (achievement.difficulty) {
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
}