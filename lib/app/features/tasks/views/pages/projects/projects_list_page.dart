import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/projects_controller.dart';
import '../../../models/project_model.dart';
import '../../../../../core/constants/app_colors.dart';

class ProjectsListPage extends StatelessWidget {
  const ProjectsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProjectsController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Projets'),
            backgroundColor: AppColors.surface,
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => Get.toNamed('/tasks/projects/create'),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => controller.refreshProjects(),
            child: controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : controller.projects.isEmpty
                    ? _buildEmptyState()
                    : _buildProjectsList(controller),
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: "projects_list_fab",
            onPressed: () => Get.toNamed('/tasks/projects/create'),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: AppColors.hint,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun projet',
            style: Get.textTheme.headlineSmall?.copyWith(
              color: AppColors.hint,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Créez votre premier projet pour commencer',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: AppColors.hint,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed('/tasks/projects/create'),
            icon: const Icon(Icons.add),
            label: const Text('Créer un projet'),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsList(ProjectsController controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.projects.length,
      itemBuilder: (context, index) {
        final project = controller.projects[index];
        return _buildProjectCard(project, controller);
      },
    );
  }

  Widget _buildProjectCard(ProjectModel project, ProjectsController controller) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Get.toNamed('/tasks/projects/details', arguments: project),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: project.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      project.icon,
                      color: project.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: Get.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (project.description != null)
                          Text(
                            project.description!,
                            style: Get.textTheme.bodySmall?.copyWith(
                              color: AppColors.hint,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: project.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      project.statusDisplayName,
                      style: TextStyle(
                        color: project.statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          Get.toNamed('/tasks/projects/edit', arguments: project);
                          break;
                        case 'delete':
                          _showDeleteConfirmation(project, controller);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Modifier'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Supprimer'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.task, size: 16, color: AppColors.hint),
                  const SizedBox(width: 4),
                  Text(
                    '${project.completedTasks}/${project.totalTasks} tâches',
                    style: Get.textTheme.bodySmall?.copyWith(
                      color: AppColors.hint,
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (project.deadline != null) ...[
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: project.isOverdue ? AppColors.error : AppColors.hint,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Échéance: ${project.deadline!.day}/${project.deadline!.month}/${project.deadline!.year}',
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: project.isOverdue ? AppColors.error : AppColors.hint,
                      ),
                    ),
                  ],
                  const Spacer(),
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