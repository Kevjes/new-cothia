import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/task_categories_controller.dart';
import '../../../models/task_category_model.dart';
import '../../../../entities/controllers/entities_controller.dart';
import '../../../../../core/constants/app_colors.dart';

class TaskCategoryEditPage extends StatefulWidget {
  const TaskCategoryEditPage({super.key});

  @override
  State<TaskCategoryEditPage> createState() => _TaskCategoryEditPageState();
}

class _TaskCategoryEditPageState extends State<TaskCategoryEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedEntityId = '';
  Color _selectedColor = Colors.blue;
  IconData _selectedIcon = Icons.category;

  late TaskCategoryModel _originalCategory;
  final TaskCategoriesController _categoriesController = Get.find<TaskCategoriesController>();
  final EntitiesController _entitiesController = Get.find<EntitiesController>();

  final List<Color> _availableColors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.brown,
    Colors.grey,
    Colors.amber,
    Colors.cyan,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.lightBlue,
    Colors.lightGreen,
  ];

  final List<IconData> _availableIcons = [
    Icons.category,
    Icons.work,
    Icons.home,
    Icons.school,
    Icons.sports,
    Icons.music_note,
    Icons.camera_alt,
    Icons.shopping_cart,
    Icons.restaurant,
    Icons.local_hospital,
    Icons.car_repair,
    Icons.pets,
    Icons.flight,
    Icons.beach_access,
    Icons.fitness_center,
    Icons.palette,
    Icons.book,
    Icons.phone,
    Icons.email,
    Icons.star,
  ];

  @override
  void initState() {
    super.initState();
    _originalCategory = Get.arguments as TaskCategoryModel;
    _initializeForm();
  }

  void _initializeForm() {
    _nameController.text = _originalCategory.name;
    _descriptionController.text = _originalCategory.description ?? '';
    _selectedEntityId = _originalCategory.entityId;
    _selectedColor = _originalCategory.color;
    _selectedIcon = _originalCategory.icon;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Modifier la catégorie'),
        backgroundColor: AppColors.surface,
        actions: [
          TextButton(
            onPressed: _saveCategory,
            child: const Text('Enregistrer'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_originalCategory.isDefault) _buildDefaultCategoryWarning(),
              _buildBasicInfoSection(),
              const SizedBox(height: 24),
              _buildEntitySection(),
              const SizedBox(height: 24),
              _buildCustomizationSection(),
              const SizedBox(height: 24),
              _buildUsageInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultCategoryWarning() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info, color: AppColors.info, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Catégorie par défaut',
                  style: TextStyle(
                    color: AppColors.info,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cette catégorie est prédéfinie. Vous ne pouvez modifier que son apparence.',
                  style: TextStyle(
                    color: AppColors.info,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                hintText: 'ex: Sport, Loisirs, Urgences...',
              ),
              enabled: !_originalCategory.isDefault,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le nom de la catégorie est requis';
                }
                if (value.trim().length < 2) {
                  return 'Le nom doit contenir au moins 2 caractères';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Description de la catégorie (optionnel)',
              ),
              enabled: !_originalCategory.isDefault,
              maxLines: 3,
              validator: (value) {
                if (value != null && value.trim().length > 200) {
                  return 'La description ne doit pas dépasser 200 caractères';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntitySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Entité',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'L\'entité à laquelle cette catégorie appartient',
              style: Get.textTheme.bodySmall?.copyWith(
                color: AppColors.hint,
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              final entities = _entitiesController.entities;
              return IgnorePointer(
                ignoring: _originalCategory.isDefault,
                child: DropdownButtonFormField<String>(
                  value: _selectedEntityId.isNotEmpty ? _selectedEntityId : null,
                  decoration: InputDecoration(
                    labelText: 'Entité *',
                    enabled: !_originalCategory.isDefault,
                  ),
                items: entities.map((entity) {
                  return DropdownMenuItem(
                    value: entity.id,
                    child: Row(
                      children: [
                        Icon(
                          entity.type == 'personal' ? Icons.person : Icons.business,
                          size: 20,
                          color: AppColors.hint,
                        ),
                        const SizedBox(width: 8),
                        Text(entity.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: _originalCategory.isDefault ? null : (value) {
                  if (value != null) {
                    setState(() {
                      _selectedEntityId = value;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner une entité';
                  }
                  return null;
                },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomizationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personnalisation',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Modifiez la couleur et l\'icône pour personnaliser l\'apparence',
              style: Get.textTheme.bodySmall?.copyWith(
                color: AppColors.hint,
              ),
            ),
            const SizedBox(height: 16),

            // Aperçu
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _selectedColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _selectedColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _selectedColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _selectedIcon,
                      color: _selectedColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aperçu',
                        style: Get.textTheme.bodySmall?.copyWith(
                          color: AppColors.hint,
                        ),
                      ),
                      Text(
                        _nameController.text.isNotEmpty ? _nameController.text : 'Nom de la catégorie',
                        style: Get.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Text(
              'Couleur',
              style: Get.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableColors.map((color) {
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedColor == color ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: _selectedColor == color ? [
                        BoxShadow(
                          color: color.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ] : null,
                    ),
                    child: _selectedColor == color
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            Text(
              'Icône',
              style: Get.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableIcons.map((icon) {
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _selectedIcon == icon
                          ? _selectedColor.withOpacity(0.2)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _selectedIcon == icon ? _selectedColor : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: _selectedIcon == icon ? _selectedColor : AppColors.hint,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageInfo() {
    final taskCount = _categoriesController.getTaskCountByCategory(_originalCategory.id);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Utilisation',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.task, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  '$taskCount tâche(s) utilisent cette catégorie',
                  style: Get.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.hint, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Créée le ${_originalCategory.createdAt.day}/${_originalCategory.createdAt.month}/${_originalCategory.createdAt.year}',
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: AppColors.hint,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Vérifier que le nom n'est pas déjà utilisé par une autre catégorie
    if (!_originalCategory.isDefault) {
      final existingCategories = _categoriesController.categories;
      final nameExists = existingCategories.any((cat) =>
          cat.id != _originalCategory.id &&
          cat.name.toLowerCase() == _nameController.text.trim().toLowerCase() &&
          cat.entityId == _selectedEntityId);

      if (nameExists) {
        Get.snackbar(
          'Erreur',
          'Une catégorie avec ce nom existe déjà pour cette entité',
          backgroundColor: AppColors.error.withOpacity(0.1),
          colorText: AppColors.error,
        );
        return;
      }
    }

    final updatedCategory = _originalCategory.copyWith(
      name: !_originalCategory.isDefault ? _nameController.text.trim() : null,
      description: !_originalCategory.isDefault
          ? (_descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null)
          : null,
      entityId: !_originalCategory.isDefault ? _selectedEntityId : null,
      color: _selectedColor,
      icon: _selectedIcon,
      updatedAt: DateTime.now(),
    );

    final success = await _categoriesController.updateCategory(updatedCategory);

    if (success) {
      Get.back();
      Get.snackbar(
        'Succès',
        'Catégorie modifiée avec succès',
        backgroundColor: AppColors.success.withOpacity(0.1),
        colorText: AppColors.success,
      );
    } else {
      Get.snackbar(
        'Erreur',
        'Erreur lors de la modification de la catégorie',
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}