import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/finance_controller.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../models/category_model.dart';

class TransactionsCategories extends GetView<FinanceController> {
  const TransactionsCategories({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildCategoriesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateCategoryDialog(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        border: Border(
          bottom: BorderSide(
            color: Get.theme.brightness == Brightness.dark
                ? AppColors.grey700
                : AppColors.grey200,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gestion des Catégories',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Get.theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Organisez vos transactions par catégories',
            style: TextStyle(
              fontSize: 14,
              color: Get.theme.brightness == Brightness.dark
                  ? AppColors.grey400
                  : AppColors.grey600,
            ),
          ),
          const SizedBox(height: 16),
          _buildCategoryTypeTabs(),
        ],
      ),
    );
  }

  Widget _buildCategoryTypeTabs() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Get.theme.brightness == Brightness.dark
            ? AppColors.grey800
            : AppColors.grey100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTypeTab('Revenus', CategoryType.income, true),
          ),
          Expanded(
            child: _buildTypeTab('Dépenses', CategoryType.expense, false),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeTab(String label, CategoryType type, bool isSelected) {
    return GestureDetector(
      onTap: () {
        // TODO: Implement tab switching logic
      },
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : Get.theme.brightness == Brightness.dark
                      ? AppColors.grey300
                      : AppColors.grey600,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesList() {
    return Obx(() {
      final categories = controller.categories;

      if (categories.isEmpty) {
        return _buildEmptyState();
      }

      final incomeCategories = categories.where((cat) => cat.type == CategoryType.income).toList();
      final expenseCategories = categories.where((cat) => cat.type == CategoryType.expense).toList();

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (incomeCategories.isNotEmpty) ...[
              _buildCategorySection('Catégories de Revenus', incomeCategories, CategoryType.income),
              const SizedBox(height: 24),
            ],
            if (expenseCategories.isNotEmpty) ...[
              _buildCategorySection('Catégories de Dépenses', expenseCategories, CategoryType.expense),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildCategorySection(String title, List<CategoryModel> categories, CategoryType type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Get.theme.colorScheme.onSurface,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showCreateCategoryDialog(type: type),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Ajouter'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return _buildCategoryCard(categories[index]);
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard(CategoryModel category) {
    final color = _getCategoryColor(category);
    final icon = _getCategoryIcon(category);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Get.theme.brightness == Brightness.dark
              ? AppColors.grey700
              : AppColors.grey200,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackWithOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Get.theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (category.description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    category.description!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Get.theme.brightness == Brightness.dark
                          ? AppColors.grey400
                          : AppColors.grey600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleCategoryAction(value, category),
            itemBuilder: (context) => [
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
            child: Icon(
              Icons.more_vert,
              color: Get.theme.brightness == Brightness.dark
                  ? AppColors.grey400
                  : AppColors.grey600,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category,
              size: 80,
              color: Get.theme.brightness == Brightness.dark
                  ? AppColors.grey600
                  : AppColors.grey400,
            ),
            const SizedBox(height: 24),
            Text(
              'Aucune catégorie',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Get.theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Créez des catégories pour organiser\nvos transactions',
              style: TextStyle(
                color: Get.theme.brightness == Brightness.dark
                    ? AppColors.grey400
                    : AppColors.grey600,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showCreateCategoryDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Créer une catégorie'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateCategoryDialog({CategoryType? type}) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final selectedType = (type ?? CategoryType.expense).obs;
    final selectedIcon = 'category'.obs;
    final selectedColor = 'primary'.obs;

    Get.dialog(
      AlertDialog(
        backgroundColor: Get.theme.dialogBackgroundColor,
        title: Text(
          'Nouvelle Catégorie',
          style: TextStyle(color: Get.theme.colorScheme.onSurface),
        ),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la catégorie',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optionnel)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Obx(() => DropdownButtonFormField<CategoryType>(
                value: selectedType.value,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: CategoryType.income,
                    child: Text('Revenu'),
                  ),
                  DropdownMenuItem(
                    value: CategoryType.expense,
                    child: Text('Dépense'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) selectedType.value = value;
                },
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => _createCategory(
              nameController.text.trim(),
              descriptionController.text.trim(),
              selectedType.value,
              selectedIcon.value,
              selectedColor.value,
            ),
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  void _createCategory(String name, String description, CategoryType type, String icon, String color) {
    if (name.isEmpty) {
      Get.snackbar('Erreur', 'Le nom de la catégorie est requis');
      return;
    }

    // TODO: Implement category creation via controller
    Get.back();
    Get.snackbar('Succès', 'Catégorie "$name" créée avec succès');
  }

  void _handleCategoryAction(String action, CategoryModel category) {
    switch (action) {
      case 'edit':
        _showEditCategoryDialog(category);
        break;
      case 'delete':
        _showDeleteConfirmation(category);
        break;
    }
  }

  void _showEditCategoryDialog(CategoryModel category) {
    final nameController = TextEditingController(text: category.name);
    final descriptionController = TextEditingController(text: category.description ?? '');

    Get.dialog(
      AlertDialog(
        backgroundColor: Get.theme.dialogBackgroundColor,
        title: Text(
          'Modifier la Catégorie',
          style: TextStyle(color: Get.theme.colorScheme.onSurface),
        ),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la catégorie',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optionnel)',
                  border: OutlineInputBorder(),
                ),
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
            onPressed: () {
              // TODO: Implement category update
              Get.back();
              Get.snackbar('Succès', 'Catégorie modifiée avec succès');
            },
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(CategoryModel category) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Get.theme.dialogBackgroundColor,
        title: Text(
          'Supprimer la Catégorie',
          style: TextStyle(color: Get.theme.colorScheme.onSurface),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer la catégorie "${category.name}" ?\n\nCette action est irréversible.',
          style: TextStyle(color: Get.theme.colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement category deletion
              Get.back();
              Get.snackbar('Succès', 'Catégorie supprimée avec succès');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(CategoryModel category) {
    if (category.color != null) {
      switch (category.color) {
        case 'primary': return AppColors.primary;
        case 'secondary': return AppColors.secondary;
        case 'success': return AppColors.success;
        case 'warning': return AppColors.warning;
        case 'error': return AppColors.error;
        default: return AppColors.primary;
      }
    }
    return category.type == CategoryType.income ? AppColors.success : AppColors.error;
  }

  IconData _getCategoryIcon(CategoryModel category) {
    if (category.icon != null) {
      switch (category.icon) {
        case 'work': return Icons.work;
        case 'home': return Icons.home;
        case 'car': return Icons.directions_car;
        case 'restaurant': return Icons.restaurant;
        case 'shopping': return Icons.shopping_cart;
        case 'health': return Icons.health_and_safety;
        case 'education': return Icons.school;
        case 'entertainment': return Icons.movie;
        case 'travel': return Icons.flight;
        case 'gift': return Icons.card_giftcard;
        default: return Icons.category;
      }
    }
    return Icons.category;
  }
}