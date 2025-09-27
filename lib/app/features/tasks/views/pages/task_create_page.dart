import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/tasks_controller.dart';
import '../../controllers/task_categories_controller.dart';
import '../../controllers/projects_controller.dart';
import '../../../entities/controllers/entities_controller.dart';
import '../../models/task_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/loading_button.dart';

class TaskCreatePage extends StatefulWidget {
  const TaskCreatePage({super.key});

  @override
  State<TaskCreatePage> createState() => _TaskCreatePageState();
}

class _TaskCreatePageState extends State<TaskCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final TasksController _tasksController = Get.find<TasksController>();
  final TaskCategoriesController _categoriesController = Get.find<TaskCategoriesController>();
  final ProjectsController _projectsController = Get.find<ProjectsController>();
  final EntitiesController _entitiesController = Get.find<EntitiesController>();

  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final _estimatedDurationController = TextEditingController();

  // Form state
  TaskPriority _selectedPriority = TaskPriority.medium;
  String? _selectedCategoryId;
  String? _selectedProjectId;
  String _selectedEntityId = '';
  DateTime? _selectedDueDate;
  TimeOfDay? _selectedDueTime;
  DateTime? _selectedStartDate;
  bool _isRecurring = false;
  String? _recurringPattern;
  List<String> _tags = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    // Définir l'entité par défaut
    _selectedEntityId = _entitiesController.selectedEntityId.value;
    if (_selectedEntityId.isEmpty && _entitiesController.personalEntity != null) {
      _selectedEntityId = _entitiesController.personalEntity!.id;
    }

    // Charger les catégories si nécessaire
    _categoriesController.loadCategories();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _estimatedDurationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nouvelle Tâche'),
        backgroundColor: AppColors.surface,
        foregroundColor: Colors.white,
        actions: [
          LoadingButton(
            onPressed: _isLoading ? null : _saveTask,
            isLoading: _isLoading,
            child: const Text('Créer'),
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
              _buildCategorizationSection(),
              const SizedBox(height: 24),
              _buildSchedulingSection(),
              const SizedBox(height: 24),
              _buildDetailsSection(),
              const SizedBox(height: 24),
              _buildRecurringSection(),
              const SizedBox(height: 32),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildSection(
      title: 'Informations de base',
      icon: Icons.info_outline,
      children: [
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Titre *',
            hintText: 'Ex: Réviser les comptes mensuels',
            prefixIcon: Icon(Icons.title),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Le titre est obligatoire';
            }
            if (value.trim().length < 3) {
              return 'Le titre doit contenir au moins 3 caractères';
            }
            return null;
          },
          maxLength: 100,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description',
            hintText: 'Décrivez les détails de la tâche...',
            prefixIcon: Icon(Icons.description),
          ),
          maxLines: 3,
          maxLength: 500,
        ),
        const SizedBox(height: 16),
        _buildPrioritySelector(),
      ],
    );
  }

  Widget _buildCategorizationSection() {
    return _buildSection(
      title: 'Catégorisation',
      icon: Icons.category,
      children: [
        _buildEntitySelector(),
        const SizedBox(height: 16),
        _buildCategorySelector(),
        const SizedBox(height: 16),
        _buildProjectSelector(),
        const SizedBox(height: 16),
        _buildTagsInput(),
      ],
    );
  }

  Widget _buildSchedulingSection() {
    return _buildSection(
      title: 'Planification',
      icon: Icons.schedule,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDateSelector(
                'Date de début',
                _selectedStartDate,
                (date) => setState(() => _selectedStartDate = date),
                Icons.play_arrow,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateTimeSelector(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _estimatedDurationController,
          decoration: const InputDecoration(
            labelText: 'Durée estimée (heures)',
            hintText: 'Ex: 2.5',
            prefixIcon: Icon(Icons.timer),
            suffixText: 'h',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final duration = double.tryParse(value);
              if (duration == null || duration <= 0) {
                return 'Durée invalide';
              }
              if (duration > 24) {
                return 'La durée ne peut pas dépasser 24h';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return _buildSection(
      title: 'Détails supplémentaires',
      icon: Icons.notes,
      children: [
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'Notes',
            hintText: 'Informations complémentaires...',
            prefixIcon: Icon(Icons.note),
          ),
          maxLines: 4,
          maxLength: 1000,
        ),
      ],
    );
  }

  Widget _buildRecurringSection() {
    return _buildSection(
      title: 'Récurrence',
      icon: Icons.repeat,
      children: [
        SwitchListTile(
          value: _isRecurring,
          onChanged: (value) {
            setState(() {
              _isRecurring = value;
              if (!value) _recurringPattern = null;
            });
          },
          title: const Text('Tâche récurrente'),
          subtitle: const Text('Répéter cette tâche régulièrement'),
        ),
        if (_isRecurring) ...[
          const SizedBox(height: 16),
          _buildRecurringPatternSelector(),
        ],
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priorité',
          style: Get.textTheme.labelMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: TaskPriority.values.map((priority) {
            final task = TaskModel(
              id: '',
              title: '',
              categoryId: '',
              entityId: '',
              priority: priority,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );

            final isSelected = _selectedPriority == priority;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () => setState(() => _selectedPriority = priority),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                        ? task.priorityColor.withOpacity(0.2)
                        : task.priorityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: task.priorityColor,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          task.priorityIcon,
                          color: task.priorityColor,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          task.priorityDisplayName,
                          style: TextStyle(
                            color: task.priorityColor,
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEntitySelector() {
    return GetBuilder<EntitiesController>(
      builder: (controller) {
        return DropdownButtonFormField<String>(
          value: _selectedEntityId.isNotEmpty ? _selectedEntityId : null,
          decoration: const InputDecoration(
            labelText: 'Entité *',
            prefixIcon: Icon(Icons.business),
          ),
          items: controller.entities.map((entity) {
            return DropdownMenuItem(
              value: entity.id,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    entity.isPersonal ? Icons.person : Icons.business,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      entity.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedEntityId = value ?? '');
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez sélectionner une entité';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildCategorySelector() {
    return GetBuilder<TaskCategoriesController>(
      builder: (controller) {
        if (controller.isLoading.value) {
          return const LinearProgressIndicator();
        }

        // Si aucune catégorie n'existe, proposer de créer les catégories par défaut
        if (controller.hasNoCategories) {
          return _buildNoCategoriesWidget(controller);
        }

        return DropdownButtonFormField<String>(
          value: _selectedCategoryId,
          decoration: const InputDecoration(
            labelText: 'Catégorie *',
            prefixIcon: Icon(Icons.category),
          ),
          items: controller.categories.map((category) {
            return DropdownMenuItem(
              value: category.id,
              child: Row(
                children: [
                  Icon(category.icon, size: 16, color: category.color),
                  const SizedBox(width: 8),
                  Text(category.name),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedCategoryId = value);
          },
          validator: (value) {
            if (value == null) {
              return 'Veuillez sélectionner une catégorie';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildNoCategoriesWidget(TaskCategoriesController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.secondary),
              const SizedBox(width: 8),
              Text(
                'Aucune catégorie trouvée',
                style: Get.textTheme.titleSmall?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Pour créer une tâche, vous devez d\'abord avoir des catégories. Voulez-vous créer les catégories par défaut ?',
            style: Get.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Get.toNamed('/tasks/categories'),
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
    );
  }

  Future<void> _createDefaultCategories(TaskCategoriesController controller) async {
    await controller.createDefaultCategories();
    // Recharger les catégories après création
    await controller.loadCategories();
  }

  Widget _buildProjectSelector() {
    return GetBuilder<ProjectsController>(
      builder: (controller) {
        final entityProjects = controller.getProjectsByEntity(_selectedEntityId);

        return DropdownButtonFormField<String>(
          value: _selectedProjectId,
          decoration: const InputDecoration(
            labelText: 'Projet (optionnel)',
            prefixIcon: Icon(Icons.folder),
          ),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('Aucun projet'),
            ),
            ...entityProjects.map((project) {
              return DropdownMenuItem(
                value: project.id,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(project.icon, size: 16, color: project.color),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        project.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
          onChanged: (value) {
            setState(() => _selectedProjectId = value);
          },
        );
      },
    );
  }

  Widget _buildTagsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Tags',
            hintText: 'Appuyez sur Entrée pour ajouter un tag',
            prefixIcon: Icon(Icons.label),
          ),
          onFieldSubmitted: (value) {
            if (value.trim().isNotEmpty && !_tags.contains(value.trim())) {
              setState(() {
                _tags.add(value.trim());
              });
            }
          },
        ),
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _tags.map((tag) {
              return Chip(
                label: Text(tag),
                onDeleted: () {
                  setState(() => _tags.remove(tag));
                },
                backgroundColor: AppColors.secondary.withOpacity(0.1),
                deleteIconColor: AppColors.secondary,
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildDateSelector(
    String label,
    DateTime? selectedDate,
    Function(DateTime?) onChanged,
    IconData icon,
  ) {
    return InkWell(
      onTap: () => _selectDate(selectedDate, onChanged),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: selectedDate != null
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => onChanged(null),
              )
            : null,
        ),
        child: Text(
          selectedDate != null
            ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
            : 'Sélectionner une date',
          style: TextStyle(
            color: selectedDate != null ? null : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeSelector() {
    return InkWell(
      onTap: () => _selectDateTime(),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date d\'échéance',
          prefixIcon: const Icon(Icons.event),
          suffixIcon: _selectedDueDate != null
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => setState(() {
                  _selectedDueDate = null;
                  _selectedDueTime = null;
                }),
              )
            : null,
        ),
        child: Text(
          _selectedDueDate != null
            ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}' +
              (_selectedDueTime != null ? ' ${_selectedDueTime!.format(context)}' : '')
            : 'Sélectionner une échéance',
          style: TextStyle(
            color: _selectedDueDate != null ? null : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildRecurringPatternSelector() {
    final patterns = [
      {'key': 'daily', 'label': 'Quotidien'},
      {'key': 'weekly', 'label': 'Hebdomadaire'},
      {'key': 'monthly', 'label': 'Mensuel'},
    ];

    return DropdownButtonFormField<String>(
      value: _recurringPattern,
      decoration: const InputDecoration(
        labelText: 'Fréquence',
        prefixIcon: Icon(Icons.repeat),
      ),
      items: patterns.map((pattern) {
        return DropdownMenuItem(
          value: pattern['key'],
          child: Text(pattern['label']!),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _recurringPattern = value);
      },
      validator: _isRecurring ? (value) {
        if (value == null) {
          return 'Veuillez sélectionner une fréquence';
        }
        return null;
      } : null,
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Get.back(),
            child: const Text('Annuler'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: LoadingButton(
            onPressed: _isLoading ? null : _saveTask,
            isLoading: _isLoading,
            backgroundColor: AppColors.primary,
            child: const Text('Créer la tâche'),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(DateTime? currentDate, Function(DateTime?) onChanged) async {
    final date = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (date != null) {
      onChanged(date);
    }
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: _selectedDueTime ?? TimeOfDay.now(),
      );

      setState(() {
        _selectedDueDate = date;
        _selectedDueTime = time;
      });
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final dueDate = _selectedDueDate != null && _selectedDueTime != null
        ? DateTime(
            _selectedDueDate!.year,
            _selectedDueDate!.month,
            _selectedDueDate!.day,
            _selectedDueTime!.hour,
            _selectedDueTime!.minute,
          )
        : _selectedDueDate;

      final task = TaskModel(
        id: '', // Will be generated by the service
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
        priority: _selectedPriority,
        categoryId: _selectedCategoryId!,
        entityId: _selectedEntityId,
        projectId: _selectedProjectId,
        dueDate: dueDate,
        startDate: _selectedStartDate,
        isRecurring: _isRecurring,
        recurringPattern: _recurringPattern,
        tags: _tags,
        estimatedDuration: _estimatedDurationController.text.isNotEmpty
          ? double.tryParse(_estimatedDurationController.text)
          : null,
        notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await _tasksController.createTask(task);

      if (success) {
        Get.back();
        Get.snackbar(
          'Succès',
          'Tâche créée avec succès',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Erreur',
          'Impossible de créer la tâche',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}