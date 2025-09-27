import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/habits_controller.dart';
import '../../models/habit_model.dart';
import '../../models/habit_completion_model.dart';

class HabitDetailsPage extends StatelessWidget {
  const HabitDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final habitId = Get.arguments as String;
    final controller = Get.find<HabitsController>();
    final habit = controller.getHabitById(habitId);

    if (habit == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Habitude introuvable')),
        body: const Center(
          child: Text('Cette habitude n\'existe plus.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(habit.name),
        backgroundColor: habit.color,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Get.toNamed('/habits/edit', arguments: habitId),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value, habit),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: habit.status == HabitStatus.active ? 'pause' : 'resume',
                child: Row(
                  children: [
                    Icon(
                      habit.status == HabitStatus.active ? Icons.pause : Icons.play_arrow,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(habit.status == HabitStatus.active ? 'Mettre en pause' : 'Reprendre'),
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
            // Habit Overview Card
            _buildHabitOverviewCard(context, habit),
            const SizedBox(height: 16),

            // Today's Status Card
            _buildTodayStatusCard(context, habit),
            const SizedBox(height: 16),

            // Statistics Card
            _buildStatisticsCard(context, habit),
            const SizedBox(height: 16),

            // Streak Information
            if (habit.currentStreak > 0 || habit.bestStreak > 0)
              _buildStreakCard(context, habit),
            const SizedBox(height: 16),

            // Financial Impact (for bad habits)
            if (habit.type == HabitType.bad && habit.hasFinancialImpact)
              _buildFinancialImpactCard(context, habit),
            const SizedBox(height: 16),

            // Recent Completions
            _buildRecentCompletionsCard(context, habitId),
          ],
        ),
      ),
      floatingActionButton: _buildActionButton(context, habit),
    );
  }

  Widget _buildHabitOverviewCard(BuildContext context, HabitModel habit) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: habit.color.withOpacity(0.2),
                  radius: 30,
                  child: Icon(
                    habit.icon,
                    color: habit.color,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildTypeBadge(habit.type),
                          const SizedBox(width: 8),
                          _buildStatusBadge(habit.status),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (habit.description != null) ...[
              const SizedBox(height: 16),
              Text(
                habit.description!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
            const SizedBox(height: 16),
            _buildHabitInfo(context, habit),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitInfo(BuildContext context, HabitModel habit) {
    return Column(
      children: [
        _buildInfoRow(context, 'Fréquence', habit.frequency.displayName),
        if (habit.targetQuantity != null)
          _buildInfoRow(context, 'Objectif', '${habit.targetQuantity} ${habit.unit ?? ''}'),
        if (habit.reminderTime != null)
          _buildInfoRow(context, 'Rappel', habit.reminderTime!.format(context)),
        if (habit.frequency == HabitFrequency.specificDays && habit.specificDays.isNotEmpty)
          _buildInfoRow(context, 'Jours', _formatDays(habit.specificDays)),
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

  Widget _buildTodayStatusCard(BuildContext context, HabitModel habit) {
    final controller = Get.find<HabitsController>();

    return Obx(() {
      final completion = controller.getTodayCompletion(habit.id);

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
              if (completion == null) ...[
                // Not completed
                Row(
                  children: [
                    Icon(
                      Icons.circle_outlined,
                      color: Colors.grey,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Non fait',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            'Cette habitude n\'a pas encore été faite aujourd\'hui',
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
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showCompleteDialog(context, habit),
                        icon: const Icon(Icons.check),
                        label: const Text('Marquer comme fait'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => controller.skipHabit(habit.id),
                      child: const Text('Sauter'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Completed
                Row(
                  children: [
                    Icon(
                      _getCompletionIcon(completion.status),
                      color: _getCompletionColor(completion.status),
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            completion.status.displayName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: _getCompletionColor(completion.status),
                            ),
                          ),
                          Text(
                            'À ${completion.completedAt.hour.toString().padLeft(2, '0')}:${completion.completedAt.minute.toString().padLeft(2, '0')}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          if (completion.quantityCompleted != null)
                            Text(
                              'Quantité: ${completion.displayQuantity}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (completion.notes != null && completion.notes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    width: double.infinity,
                    child: Text(
                      completion.notes!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => controller.undoCompletion(habit.id),
                  icon: const Icon(Icons.undo),
                  label: const Text('Annuler'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildStatisticsCard(BuildContext context, HabitModel habit) {
    final controller = Get.find<HabitsController>();

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
              future: controller.getHabitStatistics(habit.id),
              builder: (context, snapshot) {
                final stats = snapshot.data ?? {};

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            context,
                            'Total',
                            habit.totalCompletions.toString(),
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
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            context,
                            'Ce mois',
                            '${stats['thisMonth'] ?? 0}',
                            Icons.calendar_month,
                            Colors.purple,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            context,
                            'Taux de réussite',
                            '${(stats['completionRate'] ?? 0.0).toStringAsFixed(0)}%',
                            Icons.percent,
                            Colors.orange,
                          ),
                        ),
                      ],
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

  Widget _buildStreakCard(BuildContext context, HabitModel habit) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Séries',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${habit.currentStreak}',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Série actuelle',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 50,
                  width: 1,
                  color: Colors.grey[300],
                ),
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        Icons.emoji_events,
                        color: Colors.amber,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${habit.bestStreak}',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Meilleure série',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialImpactCard(BuildContext context, HabitModel habit) {
    final controller = Get.find<HabitsController>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.savings, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Impact financier',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Économie par jour évité',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            Text(
              '${habit.financialImpact!.toStringAsFixed(0)} FCFA',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<double>(
              future: controller.calculateFinancialSavings(
                startDate: DateTime.now().subtract(const Duration(days: 30)),
                endDate: DateTime.now(),
              ),
              builder: (context, snapshot) {
                final totalSavings = snapshot.data ?? 0.0;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Économies des 30 derniers jours',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${totalSavings.toStringAsFixed(0)} FCFA',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
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

  Widget _buildRecentCompletionsCard(BuildContext context, String habitId) {
    final controller = Get.find<HabitsController>();

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
                  'Activité récente',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () => _showCompletionHistory(context, habitId),
                  child: const Text('Voir tout'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FutureBuilder(
              future: _getRecentCompletions(habitId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final completions = snapshot.data as List? ?? [];

                if (completions.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aucune activité récente',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return Column(
                  children: completions.take(5).map<Widget>((completion) {
                    final date = completion['date'] as DateTime;
                    final status = completion['status'] as String;

                    return ListTile(
                      dense: true,
                      leading: Icon(
                        _getStatusIcon(status),
                        color: _getStatusColor(status),
                        size: 20,
                      ),
                      title: Text(_getStatusDisplayName(status)),
                      subtitle: Text(_formatDate(date)),
                      trailing: completion['notes'] != null && completion['notes'].toString().isNotEmpty
                          ? const Icon(Icons.note, size: 16, color: Colors.grey)
                          : null,
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getRecentCompletions(String habitId) async {
    // Simulate loading recent completions from service
    // In a real app, this would call the habit service
    try {
      final controller = Get.find<HabitsController>();
      final completions = controller.habitCompletions[habitId] ?? [];

      return completions.map((completion) => {
        'date': completion.date,
        'status': completion.status.name,
        'notes': completion.notes,
        'quantityCompleted': completion.quantityCompleted,
      }).toList();
    } catch (e) {
      return [];
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'skipped':
        return Icons.skip_next;
      case 'failed':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'skipped':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'completed':
        return 'Complétée';
      case 'skipped':
        return 'Sautée';
      case 'failed':
        return 'Échouée';
      default:
        return 'Inconnu';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return 'Aujourd\'hui';
    if (difference == 1) return 'Hier';
    if (difference < 7) return 'Il y a $difference jours';

    return '${date.day}/${date.month}/${date.year}';
  }

  void _showCompletionHistory(BuildContext context, String habitId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Historique des complétions'),
        content: const Text('Affichage complet de l\'historique à venir'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(HabitType type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: type == HabitType.good ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type == HabitType.good ? 'Bonne' : 'Mauvaise',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(HabitStatus status) {
    Color color;
    String text;

    switch (status) {
      case HabitStatus.active:
        color = Colors.green;
        text = 'Active';
        break;
      case HabitStatus.paused:
        color = Colors.orange;
        text = 'En pause';
        break;
      case HabitStatus.archived:
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

  Widget? _buildActionButton(BuildContext context, HabitModel habit) {
    final controller = Get.find<HabitsController>();

    return Obx(() {
      final completion = controller.getTodayCompletion(habit.id);

      if (completion != null) {
        // Already completed - no action button
        return const SizedBox.shrink();
      }

      // Not completed - show complete button
      return FloatingActionButton.extended(
        onPressed: () => _showCompleteDialog(context, habit),
        backgroundColor: Colors.green,
        icon: const Icon(Icons.check, color: Colors.white),
        label: const Text('Marquer fait', style: TextStyle(color: Colors.white)),
      );
    });
  }

  IconData _getCompletionIcon(CompletionStatus status) {
    switch (status) {
      case CompletionStatus.completed:
        return Icons.check_circle;
      case CompletionStatus.skipped:
        return Icons.skip_next;
      case CompletionStatus.failed:
        return Icons.cancel;
    }
  }

  Color _getCompletionColor(CompletionStatus status) {
    switch (status) {
      case CompletionStatus.completed:
        return Colors.green;
      case CompletionStatus.skipped:
        return Colors.orange;
      case CompletionStatus.failed:
        return Colors.red;
    }
  }

  String _formatDays(List<int> days) {
    final dayNames = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return days.map((day) => dayNames[day - 1]).join(', ');
  }

  void _showCompleteDialog(BuildContext context, HabitModel habit) {
    final quantityController = TextEditingController();
    final notesController = TextEditingController();
    final moodRating = RxDouble(5.0);

    Get.dialog(
      AlertDialog(
        title: Text('Compléter: ${habit.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (habit.targetQuantity != null) ...[
                Text('Quantité accomplie:'),
                const SizedBox(height: 8),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Ex: ${habit.targetQuantity}',
                    suffixText: habit.unit,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              const Text('Satisfaction (1-5):'),
              const SizedBox(height: 8),
              Obx(() => Slider(
                value: moodRating.value,
                min: 1,
                max: 5,
                divisions: 4,
                label: moodRating.value.toStringAsFixed(0),
                onChanged: (value) => moodRating.value = value,
              )),

              const SizedBox(height: 16),
              const Text('Notes (optionnel):'),
              const SizedBox(height: 8),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  hintText: 'Commentaires sur cette session...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final controller = Get.find<HabitsController>();

              int? quantity;
              if (habit.targetQuantity != null && quantityController.text.isNotEmpty) {
                quantity = int.tryParse(quantityController.text);
              }

              final success = await controller.completeHabit(
                habit.id,
                quantityCompleted: quantity,
                notes: notesController.text.isEmpty ? null : notesController.text,
                moodRating: moodRating.value,
              );

              if (success) {
                Get.back();
              }
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, HabitModel habit) {
    final controller = Get.find<HabitsController>();

    switch (action) {
      case 'pause':
        controller.pauseHabit(habit.id);
        break;
      case 'resume':
        controller.resumeHabit(habit.id);
        break;
      case 'archive':
        _confirmArchive(habit);
        break;
      case 'delete':
        _confirmDelete(habit);
        break;
    }
  }

  void _confirmArchive(HabitModel habit) {
    Get.dialog(
      AlertDialog(
        title: const Text('Archiver l\'habitude'),
        content: Text('Voulez-vous archiver "${habit.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await Get.find<HabitsController>().archiveHabit(habit.id);
              if (success) {
                Get.back();
                Get.back(); // Return to previous page
              }
            },
            child: const Text('Archiver'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(HabitModel habit) {
    Get.dialog(
      AlertDialog(
        title: const Text('Supprimer l\'habitude'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${habit.name}" ?\n\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await Get.find<HabitsController>().deleteHabit(habit.id);
              if (success) {
                Get.back();
                Get.back(); // Return to previous page
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