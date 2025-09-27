import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/task_categories_controller.dart';
import '../../../models/task_category_model.dart';
import '../../../../../core/constants/app_colors.dart';

class TaskCategoryDetailsPage extends StatelessWidget {
  const TaskCategoryDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskCategoryModel category = Get.arguments as TaskCategoryModel;
    final controller = Get.find<TaskCategoriesController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(category.name),
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Get.toNamed('/tasks/categories/edit', arguments: category),
            tooltip: 'Modifier la catégorie',
          ),
          if (!category.isDefault)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteConfirmation(category, controller),
              tooltip: 'Supprimer la catégorie',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(category, controller),
            const SizedBox(height: 24),
            _buildInfoCard(category),
            const SizedBox(height: 24),
            _buildTasksList(category, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(TaskCategoryModel category, TaskCategoriesController controller) {
    final taskCount = controller.getTaskCountByCategory(category.id);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                category.icon,
                color: category.color,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          category.name,
                          style: Get.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (category.isDefault)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.info.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Par défaut',
                            style: TextStyle(
                              color: AppColors.info,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.task, size: 16, color: AppColors.hint),
                      const SizedBox(width: 4),
                      Text(
                        '$taskCount tâche(s)',
                        style: Get.textTheme.bodyLarge?.copyWith(
                          color: AppColors.hint,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(TaskCategoryModel category) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations',
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Description', category.description ?? 'Aucune description'),
            const SizedBox(height: 12),
            _buildInfoRow('Type', category.isDefault ? 'Catégorie par défaut' : 'Catégorie personnalisée'),
            const SizedBox(height: 12),
            _buildInfoRow('Créée le', _formatDate(category.createdAt)),
            if (category.updatedAt != category.createdAt) ...[
              const SizedBox(height: 12),
              _buildInfoRow('Modifiée le', _formatDate(category.updatedAt)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Get.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.hint,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Get.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildTasksList(TaskCategoryModel category, TaskCategoriesController controller) {
    // Pour l'instant, on affiche juste le nombre de tâches
    // TODO: Implémenter getTasksByCategory dans TasksController si nécessaire
    final tasks = <dynamic>[];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Tâches associées',
                  style: Get.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${tasks.length} tâche(s)',
                  style: Get.textTheme.bodyMedium?.copyWith(
                    color: AppColors.hint,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (tasks.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.task_outlined,
                      size: 48,
                      color: AppColors.hint,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Aucune tâche dans cette catégorie',
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
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      task.priorityIcon,
                      color: task.priorityColor,
                      size: 20,
                    ),
                    title: Text(
                      task.title,
                      style: Get.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: task.description != null
                        ? Text(
                            task.description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
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
                },
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDeleteConfirmation(TaskCategoryModel category, TaskCategoriesController controller) {
    final taskCount = controller.getTaskCountByCategory(category.id);

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Supprimer la catégorie'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Êtes-vous sûr de vouloir supprimer la catégorie "${category.name}" ?'),
            if (taskCount > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: AppColors.warning, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Attention: $taskCount tâche(s) utilisent cette catégorie. Elles seront transférées vers "Autre".',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteCategory(category.id);
              Get.back(); // Retour à la liste après suppression
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