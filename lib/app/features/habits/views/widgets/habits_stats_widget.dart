import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/habits_controller.dart';
import '../../controllers/routines_controller.dart';

class HabitsStatsWidget extends StatelessWidget {
  const HabitsStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final habitsController = Get.find<HabitsController>();
    final routinesController = Get.find<RoutinesController>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aperçu statistique',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Progress indicator
            Obx(() {
              final completionRate = habitsController.todayCompletionRate;
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progression du jour',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${completionRate.toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: _getCompletionColor(completionRate),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: completionRate / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getCompletionColor(completionRate),
                    ),
                  ),
                ],
              );
            }),

            const SizedBox(height: 16),

            // Stats grid
            Obx(() => GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2,
              children: [
                _buildStatCard(
                  context,
                  icon: Icons.emoji_events,
                  title: 'Habitudes',
                  value: habitsController.totalHabits.toString(),
                  subtitle: '${habitsController.activeHabitsCount} actives',
                  color: Colors.blue,
                ),
                _buildStatCard(
                  context,
                  icon: Icons.schedule,
                  title: 'Routines',
                  value: routinesController.totalRoutines.toString(),
                  subtitle: '${routinesController.activeRoutinesCount} actives',
                  color: Colors.purple,
                ),
                _buildStatCard(
                  context,
                  icon: Icons.check_circle,
                  title: 'Aujourd\'hui',
                  value: '${habitsController.completedTodayCount}/${habitsController.todayHabitsCount}',
                  subtitle: 'Complétées',
                  color: Colors.green,
                ),
                _buildStatCard(
                  context,
                  icon: Icons.trending_up,
                  title: 'Bonnes',
                  value: habitsController.goodHabits.length.toString(),
                  subtitle: 'habitudes',
                  color: Colors.teal,
                ),
              ],
            )),

            const SizedBox(height: 16),

            // Quick insights
            Obx(() {
              final insights = _generateInsights(habitsController, routinesController);
              if (insights.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aperçus rapides',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ...insights.map((insight) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(insight['icon'], size: 16, color: insight['color']),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            insight['text'],
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getCompletionColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    if (percentage >= 40) return Colors.amber;
    return Colors.red;
  }

  List<Map<String, dynamic>> _generateInsights(
    HabitsController habitsController,
    RoutinesController routinesController,
  ) {
    final insights = <Map<String, dynamic>>[];

    // Streak insights
    final habitsWithStreaks = habitsController.activeHabits
        .where((h) => h.currentStreak > 0)
        .toList();

    if (habitsWithStreaks.isNotEmpty) {
      final bestStreak = habitsWithStreaks
          .map((h) => h.currentStreak)
          .reduce((a, b) => a > b ? a : b);

      insights.add({
        'icon': Icons.local_fire_department,
        'color': Colors.orange,
        'text': 'Votre meilleure série actuelle est de $bestStreak jours',
      });
    }

    // Completion rate insight
    final completionRate = habitsController.todayCompletionRate;
    if (completionRate == 100) {
      insights.add({
        'icon': Icons.celebration,
        'color': Colors.green,
        'text': 'Parfait ! Toutes vos habitudes sont complétées aujourd\'hui',
      });
    } else if (completionRate >= 80) {
      insights.add({
        'icon': Icons.thumb_up,
        'color': Colors.blue,
        'text': 'Excellent travail ! Vous avez presque tout terminé',
      });
    }

    // Morning routine insight
    final morningRoutines = routinesController.morningRoutines;
    if (morningRoutines.isNotEmpty && morningRoutines.any((r) => r.isScheduledForToday)) {
      final completed = morningRoutines
          .where((r) => routinesController.isCompletedToday(r.id))
          .length;

      if (completed > 0) {
        insights.add({
          'icon': Icons.wb_sunny,
          'color': Colors.amber,
          'text': 'Vous avez terminé $completed routine(s) matinale(s)',
        });
      }
    }

    // Financial savings insight for bad habits
    final badHabitsWithImpact = habitsController.badHabits
        .where((h) => h.hasFinancialImpact)
        .toList();

    if (badHabitsWithImpact.isNotEmpty) {
      final todayCompletions = badHabitsWithImpact
          .where((h) => habitsController.isCompletedToday(h.id))
          .length;

      if (todayCompletions > 0) {
        insights.add({
          'icon': Icons.savings,
          'color': Colors.green,
          'text': 'Vous avez évité $todayCompletions mauvaise(s) habitude(s) aujourd\'hui',
        });
      }
    }

    return insights.take(3).toList(); // Limit to 3 insights
  }
}