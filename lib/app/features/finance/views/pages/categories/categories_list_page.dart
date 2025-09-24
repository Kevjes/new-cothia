import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/categories_controller.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../models/category_model.dart';
import 'category_create_page.dart';

class CategoriesListPage extends GetView<CategoriesController> {
  const CategoriesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Catégories'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _createCategory(),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'sort':
                  _showSortDialog();
                  break;
                case 'defaults':
                  _addDefaultCategories();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'sort',
                child: Row(
                  children: [
                    Icon(Icons.sort, size: 20),
                    SizedBox(width: 8),
                    Text('Trier'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'defaults',
                child: Row(
                  children: [
                    Icon(Icons.restore, size: 20),
                    SizedBox(width: 8),
                    Text('Catégories par défaut'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterTabs(),
          Expanded(
            child: Obx(() {
              if (controller.hasError) {
                return _buildErrorView();
              }

              if (controller.isLoading && controller.categories.isEmpty) {
                return _buildLoadingView();
              }

              return RefreshIndicator(
                onRefresh: controller.refreshAllData,
                child: controller.categories.isEmpty
                    ? _buildEmptyState()
                    : _buildCategoriesList(),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createCategory(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Catégorie', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Obx(() {
              final selectedType = controller.selectedCategoryType.value;
              return SegmentedButton<CategoryType?>(
                segments: const [
                  ButtonSegment<CategoryType?>(
                    value: null,
                    label: Text('Toutes'),
                    icon: Icon(Icons.category),
                  ),
                  ButtonSegment<CategoryType?>(
                    value: CategoryType.income,
                    label: Text('Revenus'),
                    icon: Icon(Icons.trending_up),
                  ),
                  ButtonSegment<CategoryType?>(
                    value: CategoryType.expense,
                    label: Text('Dépenses'),
                    icon: Icon(Icons.trending_down),
                  ),
                ],
                selected: {selectedType},
                onSelectionChanged: (Set<CategoryType?> selection) {
                  controller.selectedCategoryType.value = selection.first;
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: Get.textTheme.headlineSmall?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage,
              style: Get.textTheme.bodyMedium?.copyWith(
                color: AppColors.hint,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => controller.retryInitialization(),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Chargement des catégories...'),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 80,
              color: AppColors.hint,
            ),
            const SizedBox(height: 24),
            Text(
              'Aucune catégorie',
              style: Get.textTheme.headlineSmall?.copyWith(
                color: AppColors.hint,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Créez des catégories pour organiser vos transactions',
              style: Get.textTheme.bodyMedium?.copyWith(
                color: AppColors.hint,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _addDefaultCategories(),
                  icon: const Icon(Icons.restore),
                  label: const Text('Catégories par défaut'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => _createCategory(),
                  icon: const Icon(Icons.add),
                  label: const Text('Créer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesList() {
    return Obx(() {
      final filteredCategories = _getFilteredCategories();
      final groupedCategories = _groupCategories(filteredCategories);

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: groupedCategories.length,
        itemBuilder: (context, index) {
          final group = groupedCategories[index];
          return _buildCategoryGroup(group);
        },
      );
    });
  }

  List<CategoryModel> _getFilteredCategories() {
    final selectedType = controller.selectedCategoryType.value;
    if (selectedType == null) {
      return controller.categories.where((c) => c.isParentCategory).toList();
    }
    return controller.categories
        .where((c) => c.isParentCategory && (c.type == selectedType || c.type == CategoryType.both))
        .toList();
  }

  List<Map<String, dynamic>> _groupCategories(List<CategoryModel> categories) {
    final sorted = List<CategoryModel>.from(categories)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return sorted.map((parent) {
      final subCategories = controller.categories
          .where((c) => c.parentCategoryId == parent.id)
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      return {
        'parent': parent,
        'children': subCategories,
      };
    }).toList();
  }

  Widget _buildCategoryGroup(Map<String, dynamic> group) {
    final parent = group['parent'] as CategoryModel;
    final children = group['children'] as List<CategoryModel>;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          _buildCategoryTile(parent, isParent: true),
          if (children.isNotEmpty) ...[
            const Divider(height: 1),
            ...children.map((child) => _buildCategoryTile(child, isChild: true)),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryTile(CategoryModel category, {bool isParent = false, bool isChild = false}) {
    return ListTile(
      contentPadding: EdgeInsets.only(
        left: isChild ? 32 : 16,
        right: 16,
        top: 4,
        bottom: 4,
      ),
      leading: CircleAvatar(
        backgroundColor: category.color.withOpacity(0.2),
        child: Icon(
          category.icon,
          color: category.color,
          size: isChild ? 18 : 22,
        ),
      ),
      title: Text(
        category.name,
        style: Get.textTheme.titleMedium?.copyWith(
          fontWeight: isParent ? FontWeight.bold : FontWeight.w500,
          fontSize: isChild ? 14 : null,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getTypeColor(category.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  category.typeDisplayName,
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: _getTypeColor(category.type),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (category.isDefault) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Défaut',
                    style: Get.textTheme.bodySmall?.copyWith(
                      color: AppColors.info,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
              if (!category.isActive) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.hint.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Inactif',
                    style: Get.textTheme.bodySmall?.copyWith(
                      color: AppColors.hint,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (category.description != null && category.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                category.description!,
                style: Get.textTheme.bodySmall?.copyWith(
                  color: AppColors.hint,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) => _handleCategoryAction(value, category),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, size: 18),
                SizedBox(width: 8),
                Text('Modifier'),
              ],
            ),
          ),
          if (isParent)
            const PopupMenuItem(
              value: 'add_sub',
              child: Row(
                children: [
                  Icon(Icons.add_circle_outline, size: 18),
                  SizedBox(width: 8),
                  Text('Ajouter sous-catégorie'),
                ],
              ),
            ),
          PopupMenuItem(
            value: category.isActive ? 'deactivate' : 'activate',
            child: Row(
              children: [
                Icon(
                  category.isActive ? Icons.visibility_off : Icons.visibility,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(category.isActive ? 'Désactiver' : 'Activer'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'duplicate',
            child: Row(
              children: [
                Icon(Icons.copy, size: 18),
                SizedBox(width: 8),
                Text('Dupliquer'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, size: 18, color: Colors.red),
                SizedBox(width: 8),
                Text('Supprimer', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
      onTap: () => _editCategory(category),
    );
  }

  Color _getTypeColor(CategoryType type) {
    switch (type) {
      case CategoryType.income:
        return AppColors.success;
      case CategoryType.expense:
        return AppColors.error;
      case CategoryType.both:
        return AppColors.primary;
    }
  }

  void _createCategory() {
    Get.to(() => const CategoryCreatePage());
  }

  void _editCategory(CategoryModel category) {
    Get.to(() => CategoryCreatePage(category: category));
  }

  void _handleCategoryAction(String action, CategoryModel category) {
    switch (action) {
      case 'edit':
        _editCategory(category);
        break;
      case 'add_sub':
        Get.to(() => CategoryCreatePage(parentCategory: category));
        break;
      case 'activate':
      case 'deactivate':
        _toggleCategoryStatus(category);
        break;
      case 'duplicate':
        _duplicateCategory(category);
        break;
      case 'delete':
        _showDeleteDialog(category);
        break;
    }
  }

  Future<void> _toggleCategoryStatus(CategoryModel category) async {
    try {
      await controller.updateCategory(
        category.copyWith(isActive: !category.isActive, updatedAt: DateTime.now()),
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de modifier le statut: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  void _duplicateCategory(CategoryModel category) {
    Get.to(() => CategoryCreatePage(
      category: category.copyWith(
        id: '',
        name: '${category.name} (Copie)',
        isDefault: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ));
  }

  void _showDeleteDialog(CategoryModel category) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Supprimer la catégorie'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Êtes-vous sûr de vouloir supprimer la catégorie "${category.name}" ?'),
            const SizedBox(height: 12),
            if (category.isParentCategory) ...[
              const Text(
                'Attention: Cette action supprimera également toutes les sous-catégories associées.',
                style: TextStyle(color: Colors.orange),
              ),
              const SizedBox(height: 8),
            ],
            const Text(
              'Cette action est irréversible.',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => _deleteCategory(category),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(CategoryModel category) async {
    Get.back();
    try {
      await controller.deleteCategory(category.id);
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de supprimer la catégorie: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _addDefaultCategories() async {
    try {
      await controller.addDefaultCategories();
      Get.snackbar(
        'Succès',
        'Catégories par défaut ajoutées',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'ajouter les catégories par défaut: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  void _showSortDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Tri des catégories'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Par nom (A-Z)'),
              leading: const Icon(Icons.sort_by_alpha),
              onTap: () {
                Get.back();
                Get.snackbar('Info', 'Tri par nom appliqué');
              },
            ),
            ListTile(
              title: const Text('Par type (Revenus/Dépenses)'),
              leading: const Icon(Icons.category),
              onTap: () {
                Get.back();
                Get.snackbar('Info', 'Tri par type appliqué');
              },
            ),
            ListTile(
              title: const Text('Par utilisation'),
              leading: const Icon(Icons.trending_up),
              onTap: () {
                Get.back();
                Get.snackbar('Info', 'Tri par utilisation appliqué');
              },
            ),
            ListTile(
              title: const Text('Actives seulement'),
              leading: const Icon(Icons.check_circle),
              onTap: () {
                Get.back();
                Get.snackbar('Info', 'Affichage catégories actives');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}