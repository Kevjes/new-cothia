import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/projects_controller.dart';
import '../../../models/project_model.dart';
import '../../../../entities/controllers/entities_controller.dart';
import '../../../../../core/constants/app_colors.dart';

class ProjectEditPage extends StatefulWidget {
  const ProjectEditPage({super.key});

  @override
  State<ProjectEditPage> createState() => _ProjectEditPageState();
}

class _ProjectEditPageState extends State<ProjectEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _estimatedBudgetController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _deadline;
  ProjectStatus _selectedStatus = ProjectStatus.planning;
  String _selectedEntityId = '';
  Color _selectedColor = Colors.blue;
  IconData _selectedIcon = Icons.work;

  late ProjectModel _originalProject;
  final ProjectsController _projectsController = Get.find<ProjectsController>();
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
  ];

  final List<IconData> _availableIcons = [
    Icons.work,
    Icons.business,
    Icons.home,
    Icons.school,
    Icons.fitness_center,
    Icons.music_note,
    Icons.camera_alt,
    Icons.code,
    Icons.palette,
    Icons.rocket_launch,
  ];

  @override
  void initState() {
    super.initState();
    _originalProject = Get.arguments as ProjectModel;
    _initializeForm();
  }

  void _initializeForm() {
    _nameController.text = _originalProject.name;
    _descriptionController.text = _originalProject.description ?? '';
    _estimatedBudgetController.text = _originalProject.estimatedBudget?.toString() ?? '';

    _startDate = _originalProject.startDate;
    _endDate = _originalProject.endDate;
    _deadline = _originalProject.deadline;
    _selectedStatus = _originalProject.status;
    _selectedEntityId = _originalProject.entityId;
    _selectedColor = _originalProject.color;
    _selectedIcon = _originalProject.icon;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Modifier le projet'),
        backgroundColor: AppColors.surface,
        actions: [
          TextButton(
            onPressed: _saveProject,
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
              _buildDatesSection(),
              const SizedBox(height: 24),
              _buildCustomizationSection(),
              const SizedBox(height: 24),
              _buildBudgetSection(),
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
                labelText: 'Nom du projet *',
                hintText: 'Entrez le nom du projet',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le nom du projet est requis';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Description du projet (optionnel)',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ProjectStatus>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Statut',
              ),
              items: ProjectStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(_getStatusDisplayName(status)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedStatus = value;
                  });
                }
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
                    child: Text(entity.name),
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

  Widget _buildDatesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dates',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate('start'),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date de début',
                      ),
                      child: Text(
                        _startDate != null
                            ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                            : 'Sélectionner',
                        style: TextStyle(
                          color: _startDate != null ? null : AppColors.hint,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate('end'),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date de fin',
                      ),
                      child: Text(
                        _endDate != null
                            ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                            : 'Sélectionner',
                        style: TextStyle(
                          color: _endDate != null ? null : AppColors.hint,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDate('deadline'),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Échéance',
                ),
                child: Text(
                  _deadline != null
                      ? '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}'
                      : 'Sélectionner une échéance',
                  style: TextStyle(
                    color: _deadline != null ? null : AppColors.hint,
                  ),
                ),
              ),
            ),
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
            const SizedBox(height: 16),
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
                    ),
                    child: _selectedColor == color
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
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

  Widget _buildBudgetSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Budget',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _estimatedBudgetController,
              decoration: const InputDecoration(
                labelText: 'Budget estimé',
                hintText: '0.00',
                prefixText: 'XOF ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final budget = double.tryParse(value);
                  if (budget == null || budget < 0) {
                    return 'Budget invalide';
                  }
                }
                return null;
              },
            ),
            if (_originalProject.actualBudget != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: AppColors.info, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Budget actuel utilisé: ${_originalProject.actualBudget!.toStringAsFixed(0)} XOF',
                        style: TextStyle(
                          color: AppColors.info,
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
      ),
    );
  }

  Future<void> _selectDate(String type) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _getInitialDate(type),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      setState(() {
        switch (type) {
          case 'start':
            _startDate = picked;
            break;
          case 'end':
            _endDate = picked;
            break;
          case 'deadline':
            _deadline = picked;
            break;
        }
      });
    }
  }

  DateTime _getInitialDate(String type) {
    switch (type) {
      case 'start':
        return _startDate ?? DateTime.now();
      case 'end':
        return _endDate ?? DateTime.now();
      case 'deadline':
        return _deadline ?? DateTime.now();
      default:
        return DateTime.now();
    }
  }

  String _getStatusDisplayName(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning:
        return 'Planification';
      case ProjectStatus.active:
        return 'Actif';
      case ProjectStatus.onHold:
        return 'En pause';
      case ProjectStatus.completed:
        return 'Terminé';
      case ProjectStatus.cancelled:
        return 'Annulé';
    }
  }

  void _saveProject() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final updatedProject = _originalProject.copyWith(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      status: _selectedStatus,
      entityId: _selectedEntityId,
      startDate: _startDate,
      endDate: _endDate,
      deadline: _deadline,
      color: _selectedColor,
      icon: _selectedIcon,
      estimatedBudget: _estimatedBudgetController.text.isNotEmpty
          ? double.tryParse(_estimatedBudgetController.text)
          : null,
      updatedAt: DateTime.now(),
    );

    final success = await _projectsController.updateProject(updatedProject);

    if (success) {
      Get.back();
      Get.snackbar('Succès', 'Projet modifié avec succès');
    } else {
      Get.snackbar('Erreur', 'Erreur lors de la modification du projet');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _estimatedBudgetController.dispose();
    super.dispose();
  }
}