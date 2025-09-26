import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/task_categories_controller.dart';
import '../../../models/task_category_model.dart';
import '../../../../entities/controllers/entities_controller.dart';
import '../../../../../core/constants/app_colors.dart';

class TaskCategoryCreatePage extends StatefulWidget {
  const TaskCategoryCreatePage({super.key});

  @override
  State<TaskCategoryCreatePage> createState() => _TaskCategoryCreatePageState();
}

class _TaskCategoryCreatePageState extends State<TaskCategoryCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedEntityId = '';
  Color _selectedColor = Colors.blue;
  IconData _selectedIcon = Icons.category;

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
    _selectedEntityId = _entitiesController.personalEntity?.id ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nouvelle Catégorie'),
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
              _buildBasicInfoSection(),
              const SizedBox(height: 24),
              _buildEntitySection(),
              const SizedBox(height: 24),
              _buildCustomizationSection(),
            ],
          ),
        ),
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
              'Choisissez l\'entité à laquelle cette catégorie appartient',
              style: Get.textTheme.bodySmall?.copyWith(
                color: AppColors.hint,
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              final entities = _entitiesController.entities;
              return DropdownButtonFormField<String>(
                value: _selectedEntityId.isNotEmpty ? _selectedEntityId : null,
                decoration: const InputDecoration(
                  labelText: 'Entité *',
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
                onChanged: (value) {
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
              'Choisissez une couleur et une icône pour identifier facilement cette catégorie',
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

  void _saveCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Vérifier que le nom n'est pas déjà utilisé
    final existingCategories = _categoriesController.categories;
    final nameExists = existingCategories.any((cat) =>
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

    final category = TaskCategoryModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      icon: _selectedIcon,
      color: _selectedColor,
      isDefault: false,
      entityId: _selectedEntityId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await _categoriesController.createCategory(category);

    if (success) {
      Get.back();
      Get.snackbar(
        'Succès',
        'Catégorie créée avec succès',
        backgroundColor: AppColors.success.withOpacity(0.1),
        colorText: AppColors.success,
      );
    } else {
      Get.snackbar(
        'Erreur',
        'Erreur lors de la création de la catégorie',
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