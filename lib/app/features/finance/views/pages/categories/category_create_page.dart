import 'package:cothia_app/app/features/finance/controllers/categories_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/finance_controller.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../models/category_model.dart';
import '../../../../../core/utils/get_extensions.dart';

class CategoryCreatePage extends StatefulWidget {
  final CategoryModel? category;
  final CategoryModel? parentCategory;

  const CategoryCreatePage({super.key, this.category, this.parentCategory});

  @override
  State<CategoryCreatePage> createState() => _CategoryCreatePageState();
}

class _CategoryCreatePageState extends State<CategoryCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  late CategoryType _selectedType;
  late IconData _selectedIcon;
  late Color _selectedColor;
  late bool _isActive;
  late int _sortOrder;
  CategoryModel? _selectedParentCategory;

  final List<IconData> _availableIcons = [
    Icons.category,
    Icons.restaurant,
    Icons.home,
    Icons.directions_car,
    Icons.local_hospital,
    Icons.sports_esports,
    Icons.shopping_bag,
    Icons.work,
    Icons.laptop,
    Icons.trending_up,
    Icons.account_balance_wallet,
    Icons.school,
    Icons.fitness_center,
    Icons.local_gas_station,
    Icons.phone,
    Icons.electric_bolt,
    Icons.local_grocery_store,
    Icons.movie,
    Icons.music_note,
    Icons.pets,
    Icons.child_care,
    Icons.elderly,
    Icons.medical_services,
    Icons.savings,
    Icons.credit_card,
    Icons.money,
    Icons.business,
    Icons.flight,
    Icons.hotel,
    Icons.beach_access,
  ];

  final List<Color> _availableColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.indigo,
    Colors.amber,
    Colors.deepOrange,
    Colors.cyan,
    Colors.lime,
    Colors.brown,
    Colors.blueGrey,
  ];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.category != null) {
      final category = widget.category!;
      _nameController.text = category.name;
      _descriptionController.text = category.description ?? '';
      _selectedType = category.type;
      _selectedIcon = category.icon;
      _selectedColor = category.color;
      _isActive = category.isActive;
      _sortOrder = category.sortOrder;

      if (category.parentCategoryId != null) {
        final controller = Get.find<CategoriesController>();
        _selectedParentCategory = controller.categories
            .where((c) => c.id == category.parentCategoryId)
            .firstOrNull;
      }
    } else {
      _selectedType = widget.parentCategory != null
          ? widget.parentCategory!.type
          : CategoryType.expense;
      _selectedIcon = Icons.category;
      _selectedColor = Colors.blue;
      _isActive = true;
      _sortOrder = 0;
      _selectedParentCategory = widget.parentCategory;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;
    final isSubCategory = widget.parentCategory != null || _selectedParentCategory != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier catégorie' : 'Nouvelle catégorie'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveCategory,
            child: Text(
              isEditing ? 'Modifier' : 'Créer',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPreviewCard(),
              const SizedBox(height: 24),
              _buildBasicInfoSection(),
              const SizedBox(height: 24),
              if (!isSubCategory) _buildTypeSection(),
              if (!isSubCategory) const SizedBox(height: 24),
              _buildParentCategorySection(),
              const SizedBox(height: 24),
              _buildAppearanceSection(),
              const SizedBox(height: 24),
              _buildSettingsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aperçu',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: _selectedColor.withOpacity(0.2),
                child: Icon(_selectedIcon, color: _selectedColor),
              ),
              title: Text(
                _nameController.text.isEmpty ? 'Nom de la catégorie' : _nameController.text,
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
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
                          color: _getTypeColor(_selectedType).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getTypeDisplayName(_selectedType),
                          style: Get.textTheme.bodySmall?.copyWith(
                            color: _getTypeColor(_selectedType),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (!_isActive) ...[
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
                  if (_descriptionController.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _descriptionController.text,
                        style: Get.textTheme.bodySmall?.copyWith(
                          color: AppColors.hint,
                        ),
                      ),
                    ),
                  if (_selectedParentCategory != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Sous-catégorie de: ${_selectedParentCategory!.name}',
                        style: Get.textTheme.bodySmall?.copyWith(
                          color: AppColors.info,
                          fontStyle: FontStyle.italic,
                        ),
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

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations de base',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom de la catégorie *',
                hintText: 'Ex: Alimentation, Transport...',
                prefixIcon: Icon(Icons.edit),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le nom est requis';
                }
                if (value.trim().length < 2) {
                  return 'Le nom doit contenir au moins 2 caractères';
                }
                return null;
              },
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optionnelle)',
                hintText: 'Décrivez l\'usage de cette catégorie...',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              onChanged: (value) => setState(() {}),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type de catégorie',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SegmentedButton<CategoryType>(
              segments: const [
                ButtonSegment<CategoryType>(
                  value: CategoryType.income,
                  label: Text('Revenus'),
                  icon: Icon(Icons.trending_up),
                ),
                ButtonSegment<CategoryType>(
                  value: CategoryType.expense,
                  label: Text('Dépenses'),
                  icon: Icon(Icons.trending_down),
                ),
                ButtonSegment<CategoryType>(
                  value: CategoryType.both,
                  label: Text('Les deux'),
                  icon: Icon(Icons.swap_vert),
                ),
              ],
              selected: {_selectedType},
              onSelectionChanged: (Set<CategoryType> selection) {
                setState(() {
                  _selectedType = selection.first;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParentCategorySection() {
    final controller = Get.find<CategoriesController>();
    final parentCategories = controller.categories
        .where((c) => c.isParentCategory && c.id != widget.category?.id)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Catégorie parente',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Laissez vide pour une catégorie principale',
              style: Get.textTheme.bodySmall?.copyWith(
                color: AppColors.hint,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<CategoryModel?>(
              value: _selectedParentCategory,
              decoration: const InputDecoration(
                labelText: 'Catégorie parente (optionnelle)',
                prefixIcon: Icon(Icons.account_tree),
              ),
              items: [
                const DropdownMenuItem<CategoryModel?>(
                  value: null,
                  child: Text('Aucune (catégorie principale)'),
                ),
                ...parentCategories.map((category) {
                  return DropdownMenuItem<CategoryModel?>(
                    value: category,
                    child: Row(
                      children: [
                        Icon(category.icon, color: category.color, size: 20),
                        const SizedBox(width: 8),
                        Text(category.name),
                      ],
                    ),
                  );
                }),
              ],
              onChanged: widget.parentCategory != null
                  ? null
                  : (CategoryModel? value) {
                      setState(() {
                        _selectedParentCategory = value;
                        if (value != null) {
                          _selectedType = value.type;
                        }
                      });
                    },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apparence',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Icône',
              style: Get.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 120,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  childAspectRatio: 1,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _availableIcons.length,
                itemBuilder: (context, index) {
                  final icon = _availableIcons[index];
                  final isSelected = icon == _selectedIcon;
                  return InkWell(
                    onTap: () => setState(() => _selectedIcon = icon),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? _selectedColor : AppColors.hint.withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                        color: isSelected ? _selectedColor.withOpacity(0.1) : null,
                      ),
                      child: Icon(
                        icon,
                        color: isSelected ? _selectedColor : AppColors.hint,
                        size: 20,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Couleur',
              style: Get.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableColors.map((color) {
                final isSelected = color == _selectedColor;
                return InkWell(
                  onTap: () => setState(() => _selectedColor = color),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paramètres',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Catégorie active'),
              subtitle: Text(
                _isActive
                    ? 'Disponible pour les nouvelles transactions'
                    : 'Masquée lors de la création de transactions',
                style: Get.textTheme.bodySmall?.copyWith(
                  color: AppColors.hint,
                ),
              ),
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _sortOrder.toString(),
              decoration: const InputDecoration(
                labelText: 'Ordre de tri',
                hintText: '0',
                prefixIcon: Icon(Icons.sort),
                helperText: 'Plus le nombre est petit, plus la catégorie apparaît en premier',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _sortOrder = int.tryParse(value) ?? 0;
              },
            ),
          ],
        ),
      ),
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

  String _getTypeDisplayName(CategoryType type) {
    switch (type) {
      case CategoryType.income:
        return 'Revenus';
      case CategoryType.expense:
        return 'Dépenses';
      case CategoryType.both:
        return 'Revenus & Dépenses';
    }
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final controller = Get.find<CategoriesController>();
    final isEditing = widget.category != null;

    try {
      final categoryData = CategoryModel(
        id: isEditing ? widget.category!.id : '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        type: _selectedType,
        entityId: controller.currentEntityId ?? '',
        parentCategoryId: _selectedParentCategory?.id,
        icon: _selectedIcon,
        color: _selectedColor,
        isActive: _isActive,
        isDefault: isEditing ? widget.category!.isDefault : false,
        sortOrder: _sortOrder,
        createdAt: isEditing ? widget.category!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      bool success;
      if (isEditing) {
        success = await controller.updateCategory(categoryData);
      } else {
        success = await controller.createCategory(categoryData);
      }

      if (success) {
        Get.safeBack();
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de la sauvegarde: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }
}