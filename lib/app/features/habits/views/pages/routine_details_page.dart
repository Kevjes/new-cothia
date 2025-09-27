import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/routines_controller.dart';
import '../../controllers/habits_controller.dart';
import '../../models/routine_model.dart';

class RoutineDetailsPage extends StatelessWidget {
  const RoutineDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final routineId = Get.arguments as String;
    final controller = Get.find<RoutinesController>();
    final routine = controller.getRoutineById(routineId);

    if (routine == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Routine introuvable')),
        body: const Center(
          child: Text('Cette routine n\'existe plus.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(routine.name),
        backgroundColor: routine.color,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Get.toNamed('/habits/routines/edit', arguments: routineId),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value, routine),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'start',
                child: Row(
                  children: [
                    Icon(Icons.play_arrow, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Text('Démarrer'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: routine.status == RoutineStatus.active ? 'pause' : 'resume',
                child: Row(
                  children: [
                    Icon(
                      routine.status == RoutineStatus.active ? Icons.pause : Icons.play_arrow,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(routine.status == RoutineStatus.active ? 'Mettre en pause' : 'Reprendre'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'archive',
                child: Row(
                  children: [
                    Icon(Icons.archive, size: 20),
                    SizedBox(width: 8),
                    Text('Archiver'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Supprimer', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Routine Overview
            _buildRoutineOverviewCard(context, routine),
            const SizedBox(height: 16),

            // Today's Status
            _buildTodayStatusCard(context, routine),
            const SizedBox(height: 16),

            // Habits List
            _buildHabitsCard(context, routine),
            const SizedBox(height: 16),

            // Statistics
            _buildStatisticsCard(context, routine),
            const SizedBox(height: 16),

            // Schedule
            _buildScheduleCard(context, routine),
          ],
        ),
      ),
      floatingActionButton: _buildActionButton(context, routine),
    );
  }

  Widget _buildRoutineOverviewCard(BuildContext context, RoutineModel routine) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: routine.color.withOpacity(0.2),
                  radius: 30,
                  child: Icon(
                    routine.icon,
                    color: routine.color,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        routine.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildTypeBadge(routine.type),
                          const SizedBox(width: 8),
                          _buildStatusBadge(routine.status),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (routine.description != null) ...[
              const SizedBox(height: 16),
              Text(
                routine.description!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
            const SizedBox(height: 16),
            _buildRoutineInfo(context, routine),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutineInfo(BuildContext context, RoutineModel routine) {
    return Column(
      children: [
        _buildInfoRow(context, 'Type', routine.type.displayName),
        _buildInfoRow(context, 'Durée estimée', '${routine.estimatedDuration} minutes'),
        _buildInfoRow(context, 'Habitudes', '${routine.habits.length}'),
        if (routine.startTime != null)
          _buildInfoRow(context, 'Heure de début', routine.startTime!.format(context)),
        _buildInfoRow(context, 'Jours actifs', _formatDays(routine.activeDays)),
        _buildInfoRow(context, 'Complétions totales', '${routine.completionCount}'),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayStatusCard(BuildContext context, RoutineModel routine) {
    final controller = Get.find<RoutinesController>();

    return Obx(() {
      final isScheduledToday = routine.isScheduledForToday;
      final isCompletedToday = controller.isCompletedToday(routine.id);

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Statut d\'aujourd\'hui',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (!isScheduledToday) ...[
                Row(
                  children: [
                    Icon(
                      Icons.event_busy,
                      color: Colors.grey,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Non prévue aujourd\'hui',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            'Cette routine n\'est pas programmée pour aujourd\'hui',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ] else if (isCompletedToday) ...[
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Complétée',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            'Félicitations ! Routine terminée aujourd\'hui',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: Colors.orange,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'En attente',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.orange,
                            ),
                          ),
                          Text(
                            'Routine programmée mais pas encore faite',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Get.toNamed('/habits/routines/start', arguments: routine.id),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Démarrer la routine'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildHabitsCard(BuildContext context, RoutineModel routine) {
    final habitsController = Get.find<HabitsController>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Habitudes (${routine.habits.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () => Get.toNamed('/habits/routines/edit', arguments: routine.id),
                  child: const Text('Modifier'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (routine.habits.isEmpty) ...[
              const Center(
                child: Text(
                  'Aucune habitude dans cette routine',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ] else ...[
              Column(
                children: routine.habits.map((habitItem) {
                  final habit = habitsController.getHabitById(habitItem.habitId);
                  if (habit == null) {
                    return const SizedBox.shrink();
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${habitItem.order + 1}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            backgroundColor: habit.color.withOpacity(0.2),
                            radius: 16,
                            child: Icon(habit.icon, color: habit.color, size: 16),
                          ),
                        ],
                      ),
                      title: Text(habit.name),
                      subtitle: habitItem.duration != null
                          ? Text('${habitItem.duration} minutes')
                          : null,
                      trailing: Icon(
                        Icons.chevron_right,
                        color: Colors.grey[400],
                      ),
                      onTap: () => Get.toNamed('/habits/details', arguments: habit.id),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(BuildContext context, RoutineModel routine) {
    final controller = Get.find<RoutinesController>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistiques',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            FutureBuilder<Map<String, dynamic>>(
              future: controller.getRoutineStatistics(routine.id),
              builder: (context, snapshot) {
                final stats = snapshot.data ?? {};

                return Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        context,
                        'Total',
                        '${stats['totalCompletions'] ?? 0}',
                        Icons.done_all,
                        Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        'Cette semaine',
                        '${stats['thisWeek'] ?? 0}',
                        Icons.calendar_view_week,
                        Colors.green,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        'Ce mois',
                        '${stats['thisMonth'] ?? 0}',
                        Icons.calendar_month,
                        Colors.purple,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(BuildContext context, RoutineModel routine) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Planification',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.schedule, color: routine.color),
                const SizedBox(width: 8),
                Text(
                  routine.startTime != null
                      ? 'Heure: ${routine.startTime!.format(context)}'
                      : 'Aucune heure définie',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, color: routine.color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Jours: ${_formatDays(routine.activeDays)}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.timer, color: routine.color),
                const SizedBox(width: 8),
                Text(
                  'Durée estimée: ${routine.estimatedDuration} minutes',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeBadge(RoutineType type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: type.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type.displayName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(RoutineStatus status) {
    Color color;
    String text;

    switch (status) {
      case RoutineStatus.active:
        color = Colors.green;
        text = 'Active';
        break;
      case RoutineStatus.paused:
        color = Colors.orange;
        text = 'En pause';
        break;
      case RoutineStatus.archived:
        color = Colors.grey;
        text = 'Archivée';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget? _buildActionButton(BuildContext context, RoutineModel routine) {
    final controller = Get.find<RoutinesController>();

    return Obx(() {
      final isScheduledToday = routine.isScheduledForToday;
      final isCompletedToday = controller.isCompletedToday(routine.id);

      if (!isScheduledToday || isCompletedToday) {
        return const SizedBox.shrink();
      }

      return FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/habits/routines/start', arguments: routine.id),
        backgroundColor: Colors.green,
        icon: const Icon(Icons.play_arrow, color: Colors.white),
        label: const Text('Démarrer', style: TextStyle(color: Colors.white)),
      );
    });
  }

  String _formatDays(List<int> days) {
    if (days.isEmpty) return 'Aucun jour';
    if (days.length == 7) return 'Tous les jours';

    final dayNames = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    final sortedDays = List<int>.from(days)..sort();
    return sortedDays.map((day) => dayNames[day - 1]).join(', ');
  }

  void _handleMenuAction(String action, RoutineModel routine) {
    final controller = Get.find<RoutinesController>();

    switch (action) {
      case 'start':
        Get.toNamed('/habits/routines/start', arguments: routine.id);
        break;
      case 'pause':
        controller.pauseRoutine(routine.id);
        break;
      case 'resume':
        controller.resumeRoutine(routine.id);
        break;
      case 'archive':
        _confirmArchive(routine);
        break;
      case 'delete':
        _confirmDelete(routine);
        break;
    }
  }

  void _confirmArchive(RoutineModel routine) {
    Get.dialog(
      AlertDialog(
        title: const Text('Archiver la routine'),
        content: Text('Voulez-vous archiver "${routine.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await Get.find<RoutinesController>().archiveRoutine(routine.id);
              if (success) {
                Get.back();
                Get.back();
              }
            },
            child: const Text('Archiver'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(RoutineModel routine) {
    Get.dialog(
      AlertDialog(
        title: const Text('Supprimer la routine'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${routine.name}" ?\n\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await Get.find<RoutinesController>().deleteRoutine(routine.id);
              if (success) {
                Get.back();
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}