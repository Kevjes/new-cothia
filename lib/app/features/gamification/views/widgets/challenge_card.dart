import 'package:flutter/material.dart';
import '../../../../core/gamification/models/challenge_model.dart';
import '../../../../core/constants/app_colors.dart';

class ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final bool isParticipating;
  final VoidCallback? onTap;
  final VoidCallback? onJoin;

  const ChallengeCard({
    super.key,
    required this.challenge,
    this.isParticipating = false,
    this.onTap,
    this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildTypeIcon(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          challenge.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildInfoItem(
                    Icons.timer,
                    challenge.timeRemainingText,
                    _getTimeColor(),
                  ),
                  const SizedBox(width: 16),
                  _buildInfoItem(
                    Icons.people,
                    '${challenge.participants.length}',
                    Colors.blue,
                  ),
                  const SizedBox(width: 16),
                  _buildInfoItem(
                    Icons.stars,
                    '${challenge.pointsReward}',
                    Colors.amber,
                  ),
                ],
              ),
              if (isParticipating) ...[
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progression',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                        Text(
                          '${challenge.progress}/${challenge.maxProgress}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: challenge.progressPercentage,
                      backgroundColor: Colors.grey[700],
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ],
                ),
              ],
              if (!isParticipating && challenge.isActive) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onJoin,
                    icon: const Icon(Icons.add),
                    label: const Text('Rejoindre le défi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _getTypeColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        _getTypeIconData(),
        color: _getTypeColor(),
        size: 24,
      ),
    );
  }

  Widget _buildStatusChip() {
    Color color;
    String text;

    if (isParticipating) {
      color = Colors.green;
      text = 'Participé';
    } else if (challenge.isExpired) {
      color = Colors.red;
      text = 'Expiré';
    } else if (challenge.isActive) {
      color = Colors.blue;
      text = 'Actif';
    } else {
      color = Colors.grey;
      text = 'Inactif';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  IconData _getTypeIconData() {
    switch (challenge.type) {
      case ChallengeType.daily:
        return Icons.today;
      case ChallengeType.weekly:
        return Icons.calendar_view_week;
      case ChallengeType.monthly:
        return Icons.calendar_view_month;
      case ChallengeType.streak:
        return Icons.local_fire_department;
      case ChallengeType.milestone:
        return Icons.flag;
    }
  }

  Color _getTypeColor() {
    switch (challenge.type) {
      case ChallengeType.daily:
        return Colors.green;
      case ChallengeType.weekly:
        return Colors.blue;
      case ChallengeType.monthly:
        return Colors.purple;
      case ChallengeType.streak:
        return Colors.orange;
      case ChallengeType.milestone:
        return Colors.red;
    }
  }

  Color _getTimeColor() {
    final remaining = challenge.timeRemaining;
    if (remaining.inDays > 7) {
      return Colors.green;
    } else if (remaining.inDays > 1) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}