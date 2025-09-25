import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/task_model.dart';
import '../../../../core/constants/app_colors.dart';

class TaskCardWidget extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final Function(TaskStatus) onStatusChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCardWidget({
    super.key,
    required this.task,
    required this.onTap,
    required this.onStatusChanged,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getBorderColor().withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildTitle(),
            if (task.description != null && task.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildDescription(),
            ],
            const SizedBox(height: 12),
            _buildMetadata(),
            const SizedBox(height: 12),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _buildStatusIndicator(),
        const SizedBox(width: 12),
        _buildPriorityChip(),
        const Spacer(),
        _buildActionsMenu(),
      ],
    );
  }

  Widget _buildStatusIndicator() {
    return InkWell(
      onTap: () => _showStatusChangeDialog(),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: task.status == TaskStatus.completed
            ? task.statusColor
            : task.statusColor.withOpacity(0.1),
          border: Border.all(
            color: task.statusColor,
            width: 2,
          ),
        ),
        child: task.status == TaskStatus.completed
          ? const Icon(Icons.check, size: 16, color: Colors.white)
          : Icon(task.statusIcon, size: 14, color: task.statusColor),
      ),
    );
  }

  Widget _buildPriorityChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: task.priorityColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: task.priorityColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(task.priorityIcon, size: 12, color: task.priorityColor),
          const SizedBox(width: 4),
          Text(
            task.priorityDisplayName,
            style: TextStyle(
              color: task.priorityColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsMenu() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: AppColors.hint, size: 20),
      color: AppColors.surface,
      onSelected: (value) {
        switch (value) {
          case 'start':
            onStatusChanged(TaskStatus.inProgress);
            break;
          case 'complete':
            onStatusChanged(TaskStatus.completed);
            break;
          case 'edit':
            onEdit();
            break;
          case 'delete':
            onDelete();
            break;
        }
      },
      itemBuilder: (context) => [
        if (task.status == TaskStatus.pending)
          const PopupMenuItem(
            value: 'start',
            child: Row(
              children: [
                Icon(Icons.play_arrow, size: 16),
                SizedBox(width: 8),
                Text('Démarrer'),
              ],
            ),
          ),
        if (task.status != TaskStatus.completed)
          const PopupMenuItem(
            value: 'complete',
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 16),
                SizedBox(width: 8),
                Text('Marquer terminé'),
              ],
            ),
          ),
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 16),
              SizedBox(width: 8),
              Text('Modifier'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 16, color: Colors.red),
              SizedBox(width: 8),
              Text('Supprimer', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      task.title,
      style: Get.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        decoration: task.status == TaskStatus.completed
          ? TextDecoration.lineThrough
          : null,
        color: task.status == TaskStatus.completed
          ? AppColors.hint
          : Colors.white,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDescription() {
    return Text(
      task.description!,
      style: Get.textTheme.bodySmall?.copyWith(
        color: AppColors.hint,
        decoration: task.status == TaskStatus.completed
          ? TextDecoration.lineThrough
          : null,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildMetadata() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        if (task.dueDate != null) _buildDateInfo(),
        if (task.estimatedDuration != null) _buildDurationInfo(),
        if (task.tags.isNotEmpty) _buildTagsInfo(),
      ],
    );
  }

  Widget _buildDateInfo() {
    final now = DateTime.now();
    final dueDate = task.dueDate!;
    final isOverdue = task.isOverdue;
    final isDueToday = task.isDueToday;
    final isDueTomorrow = task.isDueTomorrow;

    Color dateColor;
    IconData dateIcon;
    String dateText;

    if (isOverdue) {
      dateColor = AppColors.error;
      dateIcon = Icons.warning;
      final overdueDays = now.difference(dueDate).inDays;
      dateText = 'En retard de $overdueDays jour(s)';
    } else if (isDueToday) {
      dateColor = AppColors.orange;
      dateIcon = Icons.today;
      dateText = 'Aujourd\'hui';
    } else if (isDueTomorrow) {
      dateColor = AppColors.info;
      dateIcon = Icons.wb_sunny;
      dateText = 'Demain';
    } else {
      dateColor = AppColors.hint;
      dateIcon = Icons.event;
      final remainingDays = dueDate.difference(now).inDays;
      if (remainingDays <= 7) {
        dateText = 'Dans $remainingDays jour(s)';
      } else {
        dateText = '${dueDate.day}/${dueDate.month}/${dueDate.year}';
      }
    }

    return _buildMetadataChip(
      icon: dateIcon,
      label: dateText,
      color: dateColor,
    );
  }

  Widget _buildDurationInfo() {
    final duration = task.estimatedDuration!;
    String durationText;

    if (duration >= 1) {
      durationText = '${duration.toStringAsFixed(1)}h';
    } else {
      final minutes = (duration * 60).round();
      durationText = '${minutes}min';
    }

    return _buildMetadataChip(
      icon: Icons.schedule,
      label: durationText,
      color: AppColors.info,
    );
  }

  Widget _buildTagsInfo() {
    final tagCount = task.tags.length;
    return _buildMetadataChip(
      icon: Icons.label,
      label: '$tagCount tag(s)',
      color: AppColors.secondary,
    );
  }

  Widget _buildMetadataChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        _buildStatusBadge(),
        if (task.projectId != null) ...[
          const SizedBox(width: 8),
          _buildProjectInfo(),
        ],
        const Spacer(),
        if (task.completionRate > 0 && task.status != TaskStatus.completed)
          _buildProgressIndicator(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: task.statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: task.statusColor.withOpacity(0.3)),
      ),
      child: Text(
        task.statusDisplayName,
        style: TextStyle(
          color: task.statusColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildProjectInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder, size: 12, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            'Projet',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final progress = task.completionRate;

    return Container(
      width: 60,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${(progress * 100).round()}%',
            style: TextStyle(
              color: AppColors.info,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.background,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.info),
            minHeight: 2,
          ),
        ],
      ),
    );
  }

  Color _getBorderColor() {
    if (task.isOverdue) return AppColors.error;
    if (task.isDueToday) return AppColors.orange;
    if (task.status == TaskStatus.completed) return AppColors.success;
    return task.priorityColor;
  }

  void _showStatusChangeDialog() {
    final currentStatus = task.status;
    final availableStatuses = TaskStatus.values.where((status) => status != currentStatus).toList();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Changer le statut',
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ...availableStatuses.map((status) {
              final statusTask = task.copyWith(status: status);
              return ListTile(
                leading: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: status == TaskStatus.completed
                      ? statusTask.statusColor
                      : statusTask.statusColor.withOpacity(0.1),
                    border: Border.all(
                      color: statusTask.statusColor,
                      width: 2,
                    ),
                  ),
                  child: status == TaskStatus.completed
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : Icon(statusTask.statusIcon, size: 12, color: statusTask.statusColor),
                ),
                title: Text(statusTask.statusDisplayName),
                onTap: () {
                  Get.back();
                  onStatusChanged(status);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}