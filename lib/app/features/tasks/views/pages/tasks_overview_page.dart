import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/tasks_controller.dart';
import '../../controllers/projects_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/task_model.dart';
import '../../models/project_model.dart';

class TasksOverviewPage extends StatelessWidget {
  const TasksOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TasksController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: RefreshIndicator(
            onRefresh: () => controller.refreshTasks(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeHeader(),
                  const SizedBox(height: 24),
                  _buildQuickStats(),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                  const SizedBox(height: 24),
                  _buildTodayTasks(),
                  const SizedBox(height: 24),
                  _buildActiveProjects(),
                  const SizedBox(height: 24),
                  _buildProductivityInsights(),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildWelcomeHeader() {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;

    if (hour < 12) {
      greeting = 'Bonjour';
    } else if (hour < 17) {
      greeting = 'Bonne après-midi';
    } else {
      greeting = 'Bonsoir';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Icon(
                Icons.wb_sunny,
                color: AppColors.primary,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting !',
                    style: Get.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Prêt à accomplir vos objectifs aujourd\'hui ?',
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: AppColors.hint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return GetBuilder<TasksController>(
      builder: (controller) {
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total',
                controller.totalTasks.toString(),
                Icons.assignment,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'En cours',
                controller.inProgressTasks.toString(),
                Icons.play_arrow,
                AppColors.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Terminées',
                controller.completedTasks.toString(),
                Icons.check_circle,
                AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'En retard',
                controller.overdueTasks.toString(),
                Icons.warning,
                AppColors.error,
              ),
            ),
          ],
        );
      }
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions Rapides',
          style: Get.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Nouvelle Tâche',
                Icons.add_task,
                AppColors.primary,
                () => Get.toNamed('/tasks/create'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Nouveau Projet',
                Icons.add_box,
                AppColors.secondary,
                () => Get.toNamed('/tasks/projects/create'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Voir Toutes les Tâches',
                Icons.list,
                AppColors.info,
                () => Get.toNamed('/tasks/list'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Gérer Projets',
                Icons.folder_special,
                AppColors.orange,
                () => Get.toNamed('/tasks/projects'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: Get.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayTasks() {
    return GetBuilder<TasksController>(
      builder: (controller) {
        final todayTasks = controller.todayTasks;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tâches d\'Aujourd\'hui',
                      style: Get.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (todayTasks.isNotEmpty)
                      TextButton(
                        onPressed: () => Get.toNamed('/tasks/list', arguments: {'filter': 'today'}),
                        child: const Text('Voir tout'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (todayTasks.isEmpty)
                  _buildEmptyState(
                    'Aucune tâche pour aujourd\'hui',
                    'Profitez de votre journée libre !',
                    Icons.check_circle_outline,
                    AppColors.success,
                  )
                else
                  Column(
                    children: todayTasks.take(3).map((task) =>
                      _buildTaskTile(task, controller)).toList(),
                  ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildActiveProjects() {
    return GetBuilder<ProjectsController>(
      builder: (controller) {
        final activeProjects = controller.activeProjectsList;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Projets Actifs',
                      style: Get.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (activeProjects.isNotEmpty)
                      TextButton(
                        onPressed: () => Get.toNamed('/tasks/projects'),
                        child: const Text('Voir tout'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (activeProjects.isEmpty)
                  _buildEmptyState(
                    'Aucun projet actif',
                    'Créez un nouveau projet pour commencer',
                    Icons.folder_open,
                    AppColors.secondary,
                  )
                else
                  Column(
                    children: activeProjects.take(3).map((project) =>
                      _buildProjectTile(project)).toList(),
                  ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildProductivityInsights() {
    return GetBuilder<TasksController>(
      builder: (controller) {
        final analysis = controller.getProductivityAnalysis();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aperçu de Productivité',
                  style: Get.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInsightCard(
                        'Taux de Completion',
                        '${controller.completionRate.toStringAsFixed(1)}%',
                        Icons.trending_up,
                        controller.completionRate >= 70 ? AppColors.success :
                        controller.completionRate >= 40 ? Colors.orange : AppColors.error,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInsightCard(
                        'Score de Productivité',
                        '${analysis['productivity'].toStringAsFixed(0)}%',
                        Icons.psychology,
                        analysis['productivity'] >= 70 ? AppColors.success :
                        analysis['productivity'] >= 40 ? Colors.orange : AppColors.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (controller.overdueTasks > 0)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: AppColors.error, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${controller.overdueTasks} tâche(s) en retard nécessitent attention',
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildInsightCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTile(TaskModel task, TasksController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: InkWell(
          onTap: () => controller.completeTask(task.id),
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
              ? Icon(Icons.check, size: 16, color: Colors.white)
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
            if (task.isOverdue) ...[
              const SizedBox(width: 8),
              Icon(Icons.warning, size: 14, color: AppColors.error),
              const SizedBox(width: 4),
              Text(
                'En retard',
                style: Get.textTheme.bodySmall?.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'start':
                controller.startTask(task.id);
                break;
              case 'complete':
                controller.completeTask(task.id);
                break;
              case 'edit':
                Get.toNamed('/tasks/edit', arguments: task);
                break;
            }
          },
          itemBuilder: (context) => [
            if (task.status == TaskStatus.pending)
              const PopupMenuItem(
                value: 'start',
                child: Text('Démarrer'),
              ),
            if (task.status != TaskStatus.completed)
              const PopupMenuItem(
                value: 'complete',
                child: Text('Marquer terminé'),
              ),
            const PopupMenuItem(
              value: 'edit',
              child: Text('Modifier'),
            ),
          ],
        ),
        onTap: () => Get.toNamed('/tasks/details', arguments: task),
      ),
    );
  }

  Widget _buildProjectTile(ProjectModel project) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: project.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: project.color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(project.icon, color: project.color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    project.name,
                    style: Get.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${project.progressPercentage.toStringAsFixed(0)}%',
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: project.color,
                    fontWeight: FontWeight.w600,
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
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(icon, size: 48, color: color),
          const SizedBox(height: 16),
          Text(
            title,
            style: Get.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Get.textTheme.bodySmall?.copyWith(
              color: AppColors.hint,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}