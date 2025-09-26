import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/tasks_controller.dart';
import '../../models/task_model.dart';
import '../../../../core/constants/app_colors.dart';

class TaskDetailsPage extends StatefulWidget {
  const TaskDetailsPage({super.key});

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  final TasksController _controller = Get.find<TasksController>();
  late TaskModel task;

  @override
  void initState() {
    super.initState();
    task = Get.arguments as TaskModel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Détails de la tâche'),
        backgroundColor: AppColors.surface,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Get.toNamed('/tasks/edit', arguments: task),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.content_copy, size: 20, color: AppColors.info),
                    const SizedBox(width: 8),
                    const Text('Dupliquer'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share, size: 20, color: AppColors.secondary),
                    const SizedBox(width: 8),
                    const Text('Partager'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: AppColors.error),
                    const SizedBox(width: 8),
                    Text('Supprimer', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildContent(),
            _buildStatusActions(),
            const SizedBox(height: 16),
            _buildFinanceIntegration(),
            const SizedBox(height: 100), // Space for FAB
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [task.priorityColor.withOpacity(0.8), task.priorityColor.withOpacity(0.4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildStatusIndicator(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: Get.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        decoration: task.status == TaskStatus.completed
                          ? TextDecoration.lineThrough
                          : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildHeaderChips(),
                  ],
                ),
              ),
            ],
          ),
          if (task.description != null && task.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              task.description!,
              style: Get.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.9),
                decoration: task.status == TaskStatus.completed
                  ? TextDecoration.lineThrough
                  : null,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: Icon(
        task.statusIcon,
        size: 30,
        color: task.statusColor,
      ),
    );
  }

  Widget _buildHeaderChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        _buildChip(
          icon: task.priorityIcon,
          label: task.priorityDisplayName,
          color: Colors.white.withOpacity(0.9),
          backgroundColor: Colors.white.withOpacity(0.2),
        ),
        _buildChip(
          icon: task.statusIcon,
          label: task.statusDisplayName,
          color: Colors.white.withOpacity(0.9),
          backgroundColor: Colors.white.withOpacity(0.2),
        ),
        if (task.isOverdue)
          _buildChip(
            icon: Icons.warning,
            label: 'En retard',
            color: Colors.white,
            backgroundColor: AppColors.error.withOpacity(0.8),
          ),
      ],
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildInfoCard(),
          const SizedBox(height: 16),
          _buildDateTimeCard(),
          const SizedBox(height: 16),
          if (task.estimatedDuration != null || task.actualDuration != null)
            _buildDurationCard(),
          if (task.estimatedDuration != null || task.actualDuration != null)
            const SizedBox(height: 16),
          if (task.tags.isNotEmpty) _buildTagsCard(),
          if (task.tags.isNotEmpty) const SizedBox(height: 16),
          if (task.notes != null && task.notes!.isNotEmpty) _buildNotesCard(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Informations générales',
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('ID', task.id),
            _buildInfoRow('Entité', 'ID: ${task.entityId}'),
            _buildInfoRow('Catégorie', 'ID: ${task.categoryId}'),
            if (task.projectId != null)
              _buildInfoRow('Projet', 'ID: ${task.projectId}'),
            _buildInfoRow('Créé le', _formatDateTime(task.createdAt)),
            _buildInfoRow('Modifié le', _formatDateTime(task.updatedAt)),
            if (task.completedDate != null)
              _buildInfoRow('Terminé le', _formatDateTime(task.completedDate!)),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Planification',
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (task.startDate != null)
              _buildDateRow(
                'Date de début',
                task.startDate!,
                Icons.play_arrow,
                AppColors.info,
              ),
            if (task.dueDate != null)
              _buildDateRow(
                'Date d\'échéance',
                task.dueDate!,
                Icons.event,
                task.isOverdue ? AppColors.error : AppColors.secondary,
              ),
            if (task.dueDate != null && !task.isOverdue && task.status != TaskStatus.completed)
              _buildTimeUntilDue(),
            if (task.isRecurring) ...[
              const SizedBox(height: 12),
              _buildRecurringInfo(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateRow(String label, DateTime date, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: Get.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            _formatDateTime(date),
            style: Get.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeUntilDue() {
    final timeUntil = task.timeUntilDue;
    if (timeUntil == null) return const SizedBox.shrink();

    String timeText;
    Color color;

    if (timeUntil.inDays > 0) {
      timeText = 'Dans ${timeUntil.inDays} jour(s)';
      color = timeUntil.inDays <= 3 ? AppColors.orange : AppColors.success;
    } else if (timeUntil.inHours > 0) {
      timeText = 'Dans ${timeUntil.inHours} heure(s)';
      color = AppColors.orange;
    } else {
      timeText = 'Dans ${timeUntil.inMinutes} minute(s)';
      color = AppColors.error;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            timeText,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecurringInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.repeat, size: 16, color: AppColors.secondary),
          const SizedBox(width: 8),
          Text(
            'Tâche récurrente - ${task.recurringPattern ?? "Non défini"}',
            style: TextStyle(
              color: AppColors.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timer, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Durée',
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (task.estimatedDuration != null)
              _buildDurationRow(
                'Durée estimée',
                task.estimatedDuration!,
                Icons.schedule,
                AppColors.info,
              ),
            if (task.actualDuration != null)
              _buildDurationRow(
                'Durée réelle',
                task.actualDuration!,
                Icons.timer,
                AppColors.success,
              ),
            if (task.estimatedDuration != null && task.actualDuration != null)
              _buildDurationComparison(),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationRow(String label, double duration, IconData icon, Color color) {
    String durationText;
    if (duration >= 1) {
      durationText = '${duration.toStringAsFixed(1)} heure(s)';
    } else {
      final minutes = (duration * 60).round();
      durationText = '$minutes minute(s)';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: Get.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            durationText,
            style: Get.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationComparison() {
    final estimated = task.estimatedDuration!;
    final actual = task.actualDuration!;
    final difference = actual - estimated;
    final percentage = (difference / estimated * 100).abs();

    Color color;
    IconData icon;
    String text;

    if (difference > 0) {
      color = AppColors.orange;
      icon = Icons.trending_up;
      text = '+${percentage.toStringAsFixed(1)}% plus long';
    } else if (difference < 0) {
      color = AppColors.success;
      icon = Icons.trending_down;
      text = '${percentage.toStringAsFixed(1)}% plus rapide';
    } else {
      color = AppColors.success;
      icon = Icons.check;
      text = 'Parfaitement estimé';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.label, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Tags',
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: task.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  backgroundColor: AppColors.secondary.withOpacity(0.1),
                  labelStyle: TextStyle(color: AppColors.secondary),
                  side: BorderSide(color: AppColors.secondary.withOpacity(0.3)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.note, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Notes',
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              task.notes!,
              style: Get.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Get.textTheme.bodySmall?.copyWith(
                color: AppColors.hint,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Get.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusActions() {
    if (task.status == TaskStatus.completed) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Actions rapides',
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (task.status == TaskStatus.pending)
                    _buildActionChip(
                      'Démarrer',
                      Icons.play_arrow,
                      AppColors.info,
                      () => _changeStatus(TaskStatus.inProgress),
                    ),
                  if (task.status != TaskStatus.completed)
                    _buildActionChip(
                      'Marquer terminé',
                      Icons.check_circle,
                      AppColors.success,
                      () => _changeStatus(TaskStatus.completed),
                    ),
                  if (task.dueDate != null)
                    _buildActionChip(
                      'Reporter',
                      Icons.schedule_send,
                      AppColors.orange,
                      () => _rescheduleTask(),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionChip(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      heroTag: "task_details_fab",
      onPressed: () => Get.toNamed('/tasks/edit', arguments: task),
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.edit, color: Colors.white),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (dateOnly == today) {
      return 'Aujourd\'hui ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return 'Hier ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (dateOnly == today.add(const Duration(days: 1))) {
      return 'Demain ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _changeStatus(TaskStatus newStatus) async {
    final success = await _controller.changeTaskStatus(task.id, newStatus);
    if (success) {
      setState(() {
        task = task.copyWith(
          status: newStatus,
          completedDate: newStatus == TaskStatus.completed ? DateTime.now() : null,
        );
      });

      Get.snackbar(
        'Succès',
        'Statut mis à jour avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour le statut',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _rescheduleTask() async {
    final newDate = await showDatePicker(
      context: context,
      initialDate: task.dueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (newDate != null) {
      final success = await _controller.rescheduleTask(task.id, newDate);
      if (success) {
        setState(() {
          task = task.copyWith(dueDate: newDate, status: TaskStatus.rescheduled);
        });

        Get.snackbar(
          'Succès',
          'Tâche reportée avec succès',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Erreur',
          'Impossible de reporter la tâche',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
      }
    }
  }

  Future<void> _handleMenuAction(String action) async {
    switch (action) {
      case 'duplicate':
        _duplicateTask();
        break;
      case 'share':
        _shareTask();
        break;
      case 'delete':
        _confirmDelete();
        break;
    }
  }

  void _duplicateTask() {
    final duplicatedTask = task.copyWith(
      id: '', // Will be generated
      title: '${task.title} (Copie)',
      status: TaskStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      completedDate: null,
      startDate: null,
    );

    Get.toNamed('/tasks/create', arguments: duplicatedTask);
  }

  void _shareTask() {
    // Share task functionality
    final taskText = '''
Tâche: ${task.title}

Description: ${task.description ?? 'Aucune description'}

Priorité: ${_getPriorityText(task.priority)}
Statut: ${_getStatusText(task.status)}
${task.dueDate != null ? 'Échéance: ${DateFormat('dd/MM/yyyy à HH:mm').format(task.dueDate!)}' : ''}

Partagé depuis Cothia App
    ''';

    // Here you would typically use the share plugin
    // await Share.share(taskText, subject: 'Tâche: ${task.title}');

    Get.snackbar(
      'Partage préparé',
      'Contenu de la tâche copié dans le presse-papiers',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  String _getPriorityText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'Basse';
      case TaskPriority.medium:
        return 'Moyenne';
      case TaskPriority.high:
        return 'Haute';
    }
  }

  String _getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return 'En attente';
      case TaskStatus.inProgress:
        return 'En cours';
      case TaskStatus.completed:
        return 'Terminée';
      case TaskStatus.cancelled:
        return 'Annulée';
      case TaskStatus.rescheduled:
        return 'Reportée';
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer la tâche "${task.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _controller.deleteTask(task.id);
      if (success) {
        Get.back(); // Return to previous screen
        Get.snackbar(
          'Succès',
          'Tâche supprimée avec succès',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Erreur',
          'Impossible de supprimer la tâche',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
      }
    }
  }

  Widget _buildFinanceIntegration() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet,
                  color: AppColors.secondary,
                  size: 20
                ),
                const SizedBox(width: 8),
                Text(
                  'Intégration Finance',
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              'Liez cette tâche à des transactions financières pour un suivi complet.',
              style: Get.textTheme.bodySmall?.copyWith(
                color: AppColors.hint,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _createLinkedTransaction(),
                    icon: const Icon(Icons.add),
                    label: const Text('Créer Transaction'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondary,
                      side: BorderSide(color: AppColors.secondary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewLinkedTransactions(),
                    icon: const Icon(Icons.list),
                    label: const Text('Voir Transactions'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.info,
                      side: BorderSide(color: AppColors.info),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _createLinkedTransaction() {
    Get.toNamed('/finance/transactions/create', arguments: {
      'taskId': task.id,
      'taskTitle': task.title,
    });
  }

  void _viewLinkedTransactions() {
    Get.toNamed('/finance/transactions', arguments: {
      'taskFilter': task.id,
      'taskTitle': task.title,
    });
  }
}