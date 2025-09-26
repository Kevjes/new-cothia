import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/projects_controller.dart';
import '../../../controllers/tasks_controller.dart';
import '../../../models/project_model.dart';
import '../../../models/task_model.dart';
import '../../../../../core/constants/app_colors.dart';

class ProjectDetailsPage extends StatelessWidget {
  const ProjectDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProjectModel project = Get.arguments as ProjectModel;

    return GetBuilder<ProjectsController>(
      builder: (projectsController) {
        return GetBuilder<TasksController>(
          builder: (tasksController) {
            final projectTasks = tasksController.getTasksByProject(project.id);

            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                title: Text(project.name),
                backgroundColor: AppColors.surface,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => Get.toNamed('/tasks/projects/edit', arguments: project),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'delete':
                          _showDeleteConfirmation(project, projectsController);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Supprimer le projet'),
                      ),
                    ],
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProjectHeader(project),
                    const SizedBox(height: 24),
                    _buildProjectStats(project, projectTasks),
                    const SizedBox(height: 24),
                    _buildProjectInfo(project),
                    const SizedBox(height: 24),
                    _buildTasksSection(projectTasks, tasksController, project),
                    if (project.estimatedBudget != null) ...[
                      const SizedBox(height: 24),
                      _buildBudgetSection(project),
                    ],
                  ],
                ),
              ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () => Get.toNamed('/tasks/create', arguments: {'projectId': project.id}),
                icon: const Icon(Icons.add_task),
                label: const Text('Nouvelle tâche'),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProjectHeader(ProjectModel project) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: project.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    project.icon,
                    color: project.color,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: Get.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (project.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          project.description!,
                          style: Get.textTheme.bodyMedium?.copyWith(
                            color: AppColors.hint,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: project.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        project.statusIcon,
                        color: project.statusColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        project.statusDisplayName,
                        style: TextStyle(
                          color: project.statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progression',
                      style: Get.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${project.progressPercentage.toStringAsFixed(0)}%',
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: project.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: project.progressPercentage / 100,
                  backgroundColor: AppColors.surface,
                  valueColor: AlwaysStoppedAnimation<Color>(project.color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectStats(ProjectModel project, List<TaskModel> tasks) {
    final completedTasks = tasks.where((t) => t.status == TaskStatus.completed).length;
    final inProgressTasks = tasks.where((t) => t.status == TaskStatus.inProgress).length;
    final overdueTasks = tasks.where((t) => t.isOverdue).length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total',
            tasks.length.toString(),
            Icons.assignment,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Terminées',
            completedTasks.toString(),
            Icons.check_circle,
            AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'En cours',
            inProgressTasks.toString(),
            Icons.play_arrow,
            AppColors.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'En retard',
            overdueTasks.toString(),
            Icons.warning,
            AppColors.error,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: Get.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: Get.textTheme.bodySmall?.copyWith(
                color: AppColors.hint,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectInfo(ProjectModel project) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (project.startDate != null)
              _buildInfoRow(
                'Date de début',
                '${project.startDate!.day}/${project.startDate!.month}/${project.startDate!.year}',
                Icons.calendar_today,
              ),
            if (project.endDate != null)
              _buildInfoRow(
                'Date de fin',
                '${project.endDate!.day}/${project.endDate!.month}/${project.endDate!.year}',
                Icons.event,
              ),
            if (project.deadline != null)
              _buildInfoRow(
                'Échéance',
                '${project.deadline!.day}/${project.deadline!.month}/${project.deadline!.year}',
                Icons.schedule,
                color: project.isOverdue ? AppColors.error : null,
              ),
            _buildInfoRow(
              'Créé le',
              '${project.createdAt.day}/${project.createdAt.month}/${project.createdAt.year}',
              Icons.add_circle_outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? AppColors.hint),
          const SizedBox(width: 12),
          Text(
            label,
            style: Get.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: Get.textTheme.bodyMedium?.copyWith(
                color: color ?? AppColors.hint,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksSection(List<TaskModel> tasks, TasksController tasksController, ProjectModel project) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tâches du projet',
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => Get.toNamed('/tasks/create', arguments: {'projectId': project.id}),
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (tasks.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.task_alt,
                      size: 48,
                      color: AppColors.hint,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Aucune tâche',
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: AppColors.hint,
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tasks.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return _buildTaskTile(task, tasksController);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskTile(TaskModel task, TasksController tasksController) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: InkWell(
        onTap: () => tasksController.completeTask(task.id),
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: task.priorityColor, width: 2),
            color: task.status == TaskStatus.completed
                ? task.priorityColor
                : Colors.transparent,
          ),
          child: task.status == TaskStatus.completed
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : null,
        ),
      ),
      title: Text(
        task.title,
        style: Get.textTheme.bodyMedium?.copyWith(
          decoration: task.status == TaskStatus.completed
              ? TextDecoration.lineThrough
              : null,
        ),
      ),
      subtitle: Row(
        children: [
          Icon(task.priorityIcon, size: 14, color: task.priorityColor),
          const SizedBox(width: 4),
          Text(
            task.priorityDisplayName,
            style: Get.textTheme.bodySmall?.copyWith(
              color: task.priorityColor,
            ),
          ),
          if (task.dueDate != null) ...[
            const SizedBox(width: 12),
            Icon(Icons.schedule, size: 14, color: AppColors.hint),
            const SizedBox(width: 4),
            Text(
              '${task.dueDate!.day}/${task.dueDate!.month}',
              style: Get.textTheme.bodySmall?.copyWith(
                color: AppColors.hint,
              ),
            ),
          ],
        ],
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: task.statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          task.statusDisplayName,
          style: TextStyle(
            color: task.statusColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      onTap: () => Get.toNamed('/tasks/details', arguments: task),
    );
  }

  Widget _buildBudgetSection(ProjectModel project) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Budget',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Budget estimé',
                        style: Get.textTheme.bodySmall?.copyWith(
                          color: AppColors.hint,
                        ),
                      ),
                      Text(
                        '${project.estimatedBudget!.toStringAsFixed(0)} XOF',
                        style: Get.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Budget utilisé',
                        style: Get.textTheme.bodySmall?.copyWith(
                          color: AppColors.hint,
                        ),
                      ),
                      Text(
                        '${(project.actualBudget ?? 0).toStringAsFixed(0)} XOF',
                        style: Get.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: (project.actualBudget ?? 0) > project.estimatedBudget!
                              ? AppColors.error
                              : AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: project.budgetUsageRate.clamp(0.0, 1.0),
              backgroundColor: AppColors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(
                project.budgetUsageRate > 1.0 ? AppColors.error : AppColors.success,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Taux d\'utilisation: ${(project.budgetUsageRate * 100).toStringAsFixed(1)}%',
              style: Get.textTheme.bodySmall?.copyWith(
                color: project.budgetUsageRate > 1.0 ? AppColors.error : AppColors.hint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(ProjectModel project, ProjectsController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Supprimer le projet'),
        content: Text('Êtes-vous sûr de vouloir supprimer le projet "${project.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteProject(project.id);
              Get.back(); // Retour à la liste des projets
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}