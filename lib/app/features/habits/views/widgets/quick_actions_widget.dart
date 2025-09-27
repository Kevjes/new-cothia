import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/habits_controller.dart';
import '../../controllers/routines_controller.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

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
              'Actions rapides',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Main actions row
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    icon: Icons.add_circle,
                    label: 'Nouvelle habitude',
                    color: Colors.blue,
                    onTap: () => Get.toNamed('/habits/create'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    context,
                    icon: Icons.schedule,
                    label: 'Nouvelle routine',
                    color: Colors.purple,
                    onTap: () => Get.toNamed('/habits/routines/create'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Secondary actions
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    icon: Icons.analytics,
                    label: 'Analyses',
                    color: Colors.teal,
                    onTap: () => Get.toNamed('/habits/analytics'),
                    compact: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    context,
                    icon: Icons.lightbulb,
                    label: 'Suggestions',
                    color: Colors.orange,
                    onTap: () => Get.toNamed('/habits/suggestions'),
                    compact: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() {
                    final morningRoutines = routinesController.morningRoutines
                        .where((r) => r.isScheduledForToday && !routinesController.isCompletedToday(r.id))
                        .toList();

                    return _buildActionButton(
                      context,
                      icon: Icons.wb_sunny,
                      label: morningRoutines.isNotEmpty ? 'Routine matinale' : 'Matin fait',
                      color: morningRoutines.isNotEmpty ? Colors.amber : Colors.grey,
                      onTap: morningRoutines.isNotEmpty
                          ? () => _startMorningRoutine(morningRoutines.first.id)
                          : null,
                      compact: true,
                      badge: morningRoutines.length > 1 ? morningRoutines.length : null,
                    );
                  }),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Quick habits completion
            Obx(() {
              final pendingHabits = habitsController.todayHabits
                  .where((h) => !habitsController.isCompletedToday(h.id))
                  .take(3)
                  .toList();

              if (pendingHabits.isEmpty) {
                return _buildCompletionMessage(context);
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Habitudes en attente',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ...pendingHabits.map((habit) => _buildQuickHabitTile(context, habit)),
                  if (habitsController.todayHabits.length > 3) ...[
                    TextButton(
                      onPressed: () => Get.toNamed('/habits/today'),
                      child: Text('Voir toutes (${habitsController.todayHabits.length})'),
                    ),
                  ],
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
    bool compact = false,
    int? badge,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(compact ? 12 : 16),
          child: Column(
            children: [
              Stack(
                children: [
                  Icon(
                    icon,
                    color: onTap != null ? color : Colors.grey,
                    size: compact ? 24 : 32,
                  ),
                  if (badge != null)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          badge.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: compact ? 4 : 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: onTap != null ? color : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickHabitTile(BuildContext context, habit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        dense: true,
        leading: Icon(
          habit.icon,
          color: habit.color,
          size: 20,
        ),
        title: Text(
          habit.name,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green, size: 20),
              onPressed: () => _quickComplete(habit.id),
              tooltip: 'Marquer comme fait',
            ),
            IconButton(
              icon: const Icon(Icons.skip_next, color: Colors.orange, size: 20),
              onPressed: () => _quickSkip(habit.id),
              tooltip: 'Sauter',
            ),
          ],
        ),
        onTap: () => Get.toNamed('/habits/details', arguments: habit.id),
      ),
    );
  }

  Widget _buildCompletionMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.celebration, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Félicitations !',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Toutes vos habitudes du jour sont terminées',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _quickComplete(String habitId) async {
    final controller = Get.find<HabitsController>();
    await controller.completeHabit(habitId);
  }

  void _quickSkip(String habitId) async {
    final controller = Get.find<HabitsController>();
    await controller.skipHabit(habitId);
  }

  void _startMorningRoutine(String routineId) {
    Get.toNamed('/habits/routines/start', arguments: routineId);
  }
}