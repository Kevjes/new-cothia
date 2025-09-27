import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/task_categories_controller.dart';
import '../../../models/task_category_model.dart';
import '../../../../../core/constants/app_colors.dart';

class TaskCategoriesListPage extends StatelessWidget {
  const TaskCategoriesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaskCategoriesController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Catégories de Tâches'),
            backgroundColor: AppColors.surface,
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => Get.toNamed('/tasks/categories/create'),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => controller.refreshCategories(),
            child: controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : controller.categories.isEmpty
                    ? _buildEmptyState()
                    : _buildCategoriesList(controller),
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: "categories_list_fab",
            onPressed: () => Get.toNamed('/tasks/categories/create'),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return GetBuilder<TaskCategoriesController>(
      builder: (controller) {
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.category_outlined,
                  size: 64,
                  color: AppColors.hint,
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucune catégorie',
                  style: Get.textTheme.headlineSmall?.copyWith(
                    color: AppColors.hint,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pour organiser vos tâches, vous devez d\'abord créer des catégories.',
                  style: Get.textTheme.bodyMedium?.copyWith(
                    color: AppColors.hint,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Proposition de catégories par défaut
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome, color: AppColors.secondary),
                          const SizedBox(width: 8),
                          Text(
                            'Suggestion',
                            style: Get.textTheme.titleMedium?.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Nous pouvons créer des catégories par défaut pour vous aider à démarrer rapidement.',
                        style: Get.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Get.toNamed('/tasks/categories/create'),
                              icon: const Icon(Icons.add),
                              label: const Text('Créer manuellement'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.secondary,
                                side: BorderSide(color: AppColors.secondary),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _createDefaultCategories(controller),
                              icon: const Icon(Icons.auto_awesome),
                              label: const Text('Catégories par défaut'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                foregroundColor: Colors.white,
                              ),
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
      },
    );
  }

  Future<void> _createDefaultCategories(TaskCategoriesController controller) async {
    await controller.createDefaultCategories();
    // Recharger les catégories après création
    await controller.loadCategories();
  }

  Widget _buildCategoriesList(TaskCategoriesController controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.categories.length,
      itemBuilder: (context, index) {
        final category = controller.categories[index];
        return _buildCategoryCard(category, controller);
      },
    );
  }

  Widget _buildCategoryCard(TaskCategoryModel category, TaskCategoriesController controller) {
    final taskCount = controller.getTaskCountByCategory(category.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Get.toNamed('/tasks/categories/details', arguments: category),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  category.icon,
                  color: category.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: Get.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (category.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        category.description!,
                        style: Get.textTheme.bodySmall?.copyWith(
                          color: AppColors.hint,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.task, size: 16, color: AppColors.hint),
                        const SizedBox(width: 4),
                        Text(
                          '$taskCount tâche(s)',
                          style: Get.textTheme.bodySmall?.copyWith(
                            color: AppColors.hint,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Get.toNamed('/tasks/categories/edit', arguments: category),
                icon: Icon(
                  Icons.edit,
                  color: AppColors.primary,
                  size: 20,
                ),
                tooltip: 'Modifier la catégorie',
              ),
              if (!category.isDefault)
                IconButton(
                  onPressed: () => _showDeleteConfirmation(category, controller),
                  icon: Icon(
                    Icons.delete,
                    color: AppColors.error,
                    size: 20,
                  ),
                  tooltip: 'Supprimer la catégorie',
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(TaskCategoryModel category, TaskCategoriesController controller) {
    final taskCount = controller.getTaskCountByCategory(category.id);

    Get.dialog(
      AlertDialog(
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