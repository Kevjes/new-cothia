import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/objectives_controller.dart';
import '../../../models/objective_model.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../../../core/widgets/custom_dropdown.dart';
import '../../../../../core/widgets/custom_button.dart';

class ObjectiveCreatePage extends StatefulWidget {
  final ObjectiveModel? objectiveToEdit;

  const ObjectiveCreatePage({super.key, this.objectiveToEdit});

  @override
  State<ObjectiveCreatePage> createState() => _ObjectiveCreatePageState();
}

class _ObjectiveCreatePageState extends State<ObjectiveCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _monthlyAllocationController = TextEditingController();

  ObjectivePriority _selectedPriority = ObjectivePriority.medium;
  bool _isAutoAllocated = false;
  DateTime? _targetDate;
  final List<String> _tags = [];
  final _tagController = TextEditingController();

  bool get _isEditing => widget.objectiveToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _initializeForEditing();
    }
  }

  void _initializeForEditing() {
    final objective = widget.objectiveToEdit!;
    _nameController.text = objective.name;
    _descriptionController.text = objective.description ?? '';
    _targetAmountController.text = objective.targetAmount.toString();
    _monthlyAllocationController.text = objective.monthlyAllocation?.toString() ?? '';
    _selectedPriority = objective.priority;
    _isAutoAllocated = objective.isAutoAllocated;
    _targetDate = objective.targetDate;
    _tags.addAll(objective.tags);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    _monthlyAllocationController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier l\'objectif' : 'Nouvel objectif'),
        centerTitle: true,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _showDeleteConfirmation,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildBasicInfoSection(),
            const SizedBox(height: 24),
            _buildAmountSection(),
            const SizedBox(height: 24),
            _buildConfigurationSection(),
            const SizedBox(height: 24),
            _buildDateSection(),
            const SizedBox(height: 24),
            _buildTagsSection(),
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations générales',
              style: Get.textTheme.titleMedium?.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _nameController,
              label: 'Nom de l\'objectif',
              hint: 'Ex: Épargne vacances',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le nom est obligatoire';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _descriptionController,
              label: 'Description (optionnel)',
              hint: 'Décrivez votre objectif',
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            CustomDropdown<ObjectivePriority>(
              label: 'Priorité',
              value: _selectedPriority,
              items: ObjectivePriority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Row(
                    children: [
                      Icon(
                        _getPriorityIcon(priority),
                        color: _getPriorityColor(priority),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(_getPriorityLabel(priority)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPriority = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountSection() {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Montants',
              style: Get.textTheme.titleMedium?.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _targetAmountController,
              label: 'Montant cible (FCFA)',
              hint: '0',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le montant cible est obligatoire';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Veuillez entrer un montant valide';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _monthlyAllocationController,
              label: 'Allocation mensuelle (FCFA)',
              hint: '0 - Optionnel pour l\'auto-allocation',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  final amount = double.tryParse(value);
                  if (amount == null || amount < 0) {
                    return 'Veuillez entrer un montant valide';
                  }
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigurationSection() {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuration',
              style: Get.textTheme.titleMedium?.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Allocation automatique'),
              subtitle: const Text('Ajouter automatiquement l\'allocation mensuelle'),
              value: _isAutoAllocated,
              onChanged: (value) {
                setState(() {
                  _isAutoAllocated = value;
                });
              },
              activeColor: AppColors.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection() {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date limite',
              style: Get.textTheme.titleMedium?.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(_targetDate != null
                  ? 'Date limite: ${_formatDate(_targetDate!)}'
                  : 'Aucune date limite'),
              subtitle: const Text('Optionnel'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_targetDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _targetDate = null;
                        });
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: _selectTargetDate,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tags',
              style: Get.textTheme.titleMedium?.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _tagController,
                    label: 'Ajouter un tag',
                    hint: 'vacation, urgence, etc.',
                    onSubmitted: _addTag,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addTag(_tagController.text),
                ),
              ],
            ),
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => _removeTag(tag),
                    backgroundColor: AppColors.secondary.withOpacity(0.1),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return GetBuilder<ObjectivesController>(
      builder: (controller) {
        return Column(
          children: [
            CustomButton(
              text: _isEditing ? 'Modifier l\'objectif' : 'Créer l\'objectif',
              onPressed: controller.isLoading ? null : _saveObjective,
              isLoading: controller.isLoading,
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Annuler',
              onPressed: () => Get.back(),
              variant: ButtonVariant.outlined,
            ),
          ],
        );
      },
    );
  }

  void _addTag(String tag) {
    final trimmedTag = tag.trim();
    if (trimmedTag.isNotEmpty && !_tags.contains(trimmedTag)) {
      setState(() {
        _tags.add(trimmedTag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _selectTargetDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (date != null) {
      setState(() {
        _targetDate = date;
      });
    }
  }

  Future<void> _saveObjective() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final controller = Get.find<ObjectivesController>();

    final objective = ObjectiveModel(
      id: _isEditing ? widget.objectiveToEdit!.id : '',
      entityId: '', // Will be set by controller
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      targetAmount: double.parse(_targetAmountController.text),
      currentAmount: _isEditing ? widget.objectiveToEdit!.currentAmount : 0.0,
      monthlyAllocation: _monthlyAllocationController.text.trim().isEmpty
          ? null
          : double.parse(_monthlyAllocationController.text),
      priority: _selectedPriority,
      status: _isEditing ? widget.objectiveToEdit!.status : ObjectiveStatus.active,
      isAutoAllocated: _isAutoAllocated,
      targetDate: _targetDate,
      tags: _tags,
      createdAt: _isEditing ? widget.objectiveToEdit!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
    );

    bool success;
    if (_isEditing) {
      success = await controller.updateObjective(objective);
    } else {
      success = await controller.createObjective(objective);
    }

    if (success) {
      Get.back();
    }
  }

  void _showDeleteConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const Text('Supprimer l\'objectif'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cet objectif ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: _deleteObjective,
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteObjective() async {
    Get.back(); // Close dialog

    final controller = Get.find<ObjectivesController>();
    final success = await controller.deleteObjective(widget.objectiveToEdit!.id);

    if (success) {
      Get.back(); // Return to objectives list
    }
  }

  IconData _getPriorityIcon(ObjectivePriority priority) {
    switch (priority) {
      case ObjectivePriority.high:
        return Icons.priority_high;
      case ObjectivePriority.medium:
        return Icons.remove;
      case ObjectivePriority.low:
        return Icons.keyboard_arrow_down;
    }
  }

  Color _getPriorityColor(ObjectivePriority priority) {
    switch (priority) {
      case ObjectivePriority.high:
        return Colors.red;
      case ObjectivePriority.medium:
        return Colors.orange;
      case ObjectivePriority.low:
        return Colors.green;
    }
  }

  String _getPriorityLabel(ObjectivePriority priority) {
    switch (priority) {
      case ObjectivePriority.high:
        return 'Haute';
      case ObjectivePriority.medium:
        return 'Moyenne';
      case ObjectivePriority.low:
        return 'Basse';
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}