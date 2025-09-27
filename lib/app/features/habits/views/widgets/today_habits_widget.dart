import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/habits_controller.dart';
import '../../models/habit_model.dart';
import '../../models/habit_completion_model.dart';

class TodayHabitsWidget extends StatelessWidget {
  const TodayHabitsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HabitsController>();

    return Obx(() {
      final todayHabits = controller.todayHabits;

      if (controller.isLoading.value) {
        return _buildShimmerList();
      }

      if (todayHabits.isEmpty) {
        return _buildEmptyState(context);
      }

      return Column(
        children: todayHabits.map((habit) => _buildHabitTile(context, habit)).toList(),
      );
    });
  }

  Widget _buildHabitTile(BuildContext context, HabitModel habit) {
    final controller = Get.find<HabitsController>();

    return Obx(() {
      final completion = controller.getTodayCompletion(habit.id);
      final isCompleted = completion?.isCompleted ?? false;
      final isSkipped = completion?.isSkipped ?? false;
      final isFailed = completion?.isFailed ?? false;

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getStatusColor(completion).withOpacity(0.3),
          ),
          color: _getStatusColor(completion).withOpacity(0.05),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: habit.color.withOpacity(0.2),
            child: Icon(
              habit.icon,
              color: habit.color,
              size: 20,
            ),
          ),
          title: Text(
            habit.name,
            style: TextStyle(
              decoration: isCompleted ? TextDecoration.lineThrough : null,
              color: isCompleted ? Colors.grey : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (habit.targetQuantity != null) ...[
                Text('Objectif: ${habit.targetQuantity} ${habit.unit ?? ''}'),
              ],
              if (completion != null) ...[
                const SizedBox(height: 4),
                _buildCompletionInfo(completion),
              ],
              if (habit.currentStreak > 0) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      '${habit.currentStreak} jours',
                      style: const TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ],
          ),
          trailing: _buildActionButtons(context, habit, completion),
          onTap: () => Get.toNamed('/habits/details', arguments: habit.id),
        ),
      );
    });
  }

  Widget _buildCompletionInfo(HabitCompletionModel completion) {
    IconData icon;
    Color color;
    String text;

    switch (completion.status) {
      case CompletionStatus.completed:
        icon = Icons.check_circle;
        color = Colors.green;
        text = 'Complétée';
        if (completion.quantityCompleted != null) {
          text += ' (${completion.displayQuantity})';
        }
        break;
      case CompletionStatus.skipped:
        icon = Icons.skip_next;
        color = Colors.orange;
        text = 'Sautée';
        break;
      case CompletionStatus.failed:
        icon = Icons.cancel;
        color = Colors.red;
        text = 'Échouée';
        break;
    }

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(color: color, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, HabitModel habit, HabitCompletionModel? completion) {
    final controller = Get.find<HabitsController>();

    if (completion != null) {
      // Already completed - show undo option
      return IconButton(
        icon: const Icon(Icons.undo, color: Colors.grey),
        onPressed: () => _showUndoDialog(context, habit),
      );
    }

    // Not completed - show action options
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: habit.color,
      ),
      onSelected: (value) {
        switch (value) {
          case 'complete':
            _showCompleteDialog(context, habit);
            break;
          case 'skip':
            controller.skipHabit(habit.id);
            break;
          case 'fail':
            controller.failHabit(habit.id);
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'complete',
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              const Text('Marquer comme fait'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'skip',
          child: Row(
            children: [
              Icon(Icons.skip_next, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              const Text('Sauter'),
            ],
          ),
        ),
        if (habit.type == HabitType.good)
          PopupMenuItem(
            value: 'fail',
            child: Row(
              children: [
                Icon(Icons.cancel, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                const Text('Marquer comme échoué'),
              ],
            ),
          ),
      ],
    );
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

  void _showUndoDialog(BuildContext context, HabitModel habit) {
    Get.dialog(
      AlertDialog(
        title: const Text('Annuler la complétion'),
        content: Text('Voulez-vous annuler la complétion de "${habit.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await Get.find<HabitsController>().undoCompletion(habit.id);
              if (success) {
                Get.back();
              }
            },
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(HabitCompletionModel? completion) {
    if (completion == null) return Colors.grey;

    switch (completion.status) {
      case CompletionStatus.completed:
        return Colors.green;
      case CompletionStatus.skipped:
        return Colors.orange;
      case CompletionStatus.failed:
        return Colors.red;
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.emoji_events,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune habitude pour aujourd\'hui',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Créez de nouvelles habitudes pour commencer',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed('/habits/create'),
            icon: const Icon(Icons.add),
            label: const Text('Créer une habitude'),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    return Column(
      children: List.generate(3, (index) => _buildShimmerItem()),
    );
  }

  Widget _buildShimmerItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            shape: BoxShape.circle,
          ),
        ),
        title: Container(
          height: 16,
          color: Colors.grey[300],
        ),
        subtitle: Container(
          height: 12,
          width: 100,
          color: Colors.grey[300],
          margin: const EdgeInsets.only(top: 4),
        ),
        trailing: Container(
          width: 24,
          height: 24,
          color: Colors.grey[300],
        ),
      ),
    );
  }
}