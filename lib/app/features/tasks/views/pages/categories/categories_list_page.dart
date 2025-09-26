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
    return Center(
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
            'Créez votre première catégorie personnalisée',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: AppColors.hint,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed('/tasks/categories/create'),
            icon: const Icon(Icons.add),
            label: const Text('Créer une catégorie'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(TaskCategoriesController controller) {
    // Séparer les catégories par défaut et personnalisées
    final defaultCategories = controller.categories.where((c) => c.isDefault).toList();
    final customCategories = controller.categories.where((c) => !c.isDefault).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (defaultCategories.isNotEmpty) ...[
          Text(
            'Catégories par défaut',
            style: Get.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ces catégories sont prédéfinies et ne peuvent pas être supprimées',
            style: Get.textTheme.bodySmall?.copyWith(
              color: AppColors.hint,
            ),
          ),
          const SizedBox(height: 16),
          ...defaultCategories.map((category) => _buildCategoryCard(category, controller, isDefault: true)),
          const SizedBox(height: 24),
        ],
        if (customCategories.isNotEmpty) ...[
          Text(
            'Catégories personnalisées',
            style: Get.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 16),
          ...customCategories.map((category) => _buildCategoryCard(category, controller, isDefault: false)),
        ] else if (defaultCategories.isNotEmpty) ...[
          Text(
            'Catégories personnalisées',
            style: Get.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aucune catégorie personnalisée créée',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: AppColors.hint,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              onPressed: () => Get.toNamed('/tasks/categories/create'),
              icon: const Icon(Icons.add),
              label: const Text('Créer une catégorie'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCategoryCard(TaskCategoryModel category, TaskCategoriesController controller, {required bool isDefault}) {
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            category.name,
                            style: Get.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isDefault)
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
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
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
              if (!isDefault)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        Get.toNamed('/tasks/categories/edit', arguments: category);
                        break;
                      case 'delete':
                        _showDeleteConfirmation(category, controller);
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
                )
              else
                Icon(Icons.lock, size: 20, color: AppColors.hint),
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