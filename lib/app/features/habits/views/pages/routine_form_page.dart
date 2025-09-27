import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/routines_controller.dart';
import '../../controllers/habits_controller.dart';
import '../../models/routine_model.dart';
import '../../models/habit_model.dart';

class RoutineFormPage extends StatefulWidget {
  const RoutineFormPage({super.key});

  @override
  State<RoutineFormPage> createState() => _RoutineFormPageState();
}

class _RoutineFormPageState extends State<RoutineFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isEditing = false;
  String? _editingRoutineId;
  RoutineModel? _originalRoutine;

  RoutineType _selectedType = RoutineType.morning;
  Color _selectedColor = Colors.blue;
  IconData _selectedIcon = Icons.schedule;
  List<int> _selectedDays = [1, 2, 3, 4, 5]; // Lun-Ven par défaut
  TimeOfDay? _startTime;
  List<RoutineHabitItem> _selectedHabits = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    final arguments = Get.arguments;
    if (arguments is String) {
      _isEditing = true;
      _editingRoutineId = arguments;
      _loadRoutineData();
    } else {
      // Set default values based on type
      _selectedColor = _selectedType.color;
      _selectedIcon = _selectedType.icon;
      _startTime = _selectedType == RoutineType.morning
          ? const TimeOfDay(hour: 7, minute: 0)
          : const TimeOfDay(hour: 21, minute: 0);
    }
  }

  void _loadRoutineData() {
    final controller = Get.find<RoutinesController>();
    final routine = controller.getRoutineById(_editingRoutineId!);

    if (routine != null) {
      _originalRoutine = routine;
      _nameController.text = routine.name;
      _descriptionController.text = routine.description ?? '';

      _selectedType = routine.type;
      _selectedColor = routine.color;
      _selectedIcon = routine.icon;
      _selectedDays = routine.activeDays;
      _startTime = routine.startTime;
      _selectedHabits = List.from(routine.habits);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier la routine' : 'Nouvelle routine'),
        backgroundColor: _selectedColor,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information
              _buildSectionCard(
                title: 'Informations de base',
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom de la routine *',
                      hintText: 'Ex: Routine matinale',
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Le nom est obligatoire';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (optionnel)',
                      hintText: 'Décrivez votre routine...',
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Type and Timing
              _buildSectionCard(
                title: 'Type et planification',
                children: [
                  Text(
                    'Type de routine',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTypeChip(
                          'Matinale',
                          RoutineType.morning,
                          Icons.wb_sunny,
                          Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildTypeChip(
                          'Du soir',
                          RoutineType.evening,
                          Icons.nightlight_round,
                          Colors.indigo,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildTypeChip(
                          'Personnalisée',
                          RoutineType.custom,
                          Icons.settings,
                          Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Start time
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text(_startTime != null
                        ? 'Heure de début: ${_startTime!.format(context)}'
                        : 'Choisir l\'heure de début'),
                    subtitle: const Text('Optionnel'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _selectStartTime(),
                  ),

                  const SizedBox(height: 16),

                  // Active days
                  Text(
                    'Jours actifs',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _buildDaysSelector(),
                ],
              ),

              const SizedBox(height: 16),

              // Habits Selection
              _buildSectionCard(
                title: 'Habitudes dans la routine',
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_selectedHabits.length} habitude(s) sélectionnée(s)',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showHabitsSelector(),
                        icon: const Icon(Icons.add),
                        label: const Text('Ajouter'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_selectedHabits.isEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: const Center(
                        child: Text(
                          'Aucune habitude sélectionnée\nTouchez "Ajouter" pour choisir des habitudes',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ] else ...[
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _selectedHabits.length,
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) newIndex--;
                          final item = _selectedHabits.removeAt(oldIndex);
                          _selectedHabits.insert(newIndex, item);

                          // Update orders
                          for (int i = 0; i < _selectedHabits.length; i++) {
                            _selectedHabits[i] = _selectedHabits[i].copyWith(order: i);
                          }
                        });
                      },
                      itemBuilder: (context, index) {
                        final habitItem = _selectedHabits[index];
                        return _buildHabitItem(habitItem, index);
                      },
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Get.back(),
                child: const Text('Annuler'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveRoutine,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditing ? 'Modifier' : 'Créer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(String label, RoutineType type, IconData icon, Color color) {
    final isSelected = _selectedType == type;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = type;
          _selectedColor = color;
          _selectedIcon = icon;

          // Set default start time
          if (type == RoutineType.morning) {
            _startTime = const TimeOfDay(hour: 7, minute: 0);
          } else if (type == RoutineType.evening) {
            _startTime = const TimeOfDay(hour: 21, minute: 0);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaysSelector() {
    final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

    return Wrap(
      spacing: 8,
      children: List.generate(7, (index) {
        final dayIndex = index + 1;
        final isSelected = _selectedDays.contains(dayIndex);

        return FilterChip(
          label: Text(days[index]),
          selected: isSelected,
          selectedColor: _selectedColor.withOpacity(0.2),
          checkmarkColor: _selectedColor,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedDays.add(dayIndex);
              } else {
                _selectedDays.remove(dayIndex);
              }
            });
          },
        );
      }),
    );
  }

  Widget _buildHabitItem(RoutineHabitItem habitItem, int index) {
    final habitsController = Get.find<HabitsController>();
    final habit = habitsController.getHabitById(habitItem.habitId);

    if (habit == null) {
      return Container(key: ValueKey(habitItem.habitId));
    }

    return Card(
      key: ValueKey(habitItem.habitId),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.drag_handle, color: Colors.grey),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: habit.color.withOpacity(0.2),
              radius: 16,
              child: Icon(habit.icon, color: habit.color, size: 16),
            ),
          ],
        ),
        title: Text(habit.name),
        subtitle: habitItem.duration != null
            ? Text('${habitItem.duration} minutes')
            : null,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'duration') {
              _editHabitDuration(habitItem);
            } else if (value == 'remove') {
              setState(() {
                _selectedHabits.removeAt(index);
                // Update orders
                for (int i = 0; i < _selectedHabits.length; i++) {
                  _selectedHabits[i] = _selectedHabits[i].copyWith(order: i);
                }
              });
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'duration',
              child: Row(
                children: [
                  Icon(Icons.timer, size: 20),
                  SizedBox(width: 8),
                  Text('Modifier durée'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  Icon(Icons.remove, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text('Retirer', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        _startTime = time;
      });
    }
  }

  void _showHabitsSelector() {
    final habitsController = Get.find<HabitsController>();
    final availableHabits = habitsController.activeHabits
        .where((habit) => !_selectedHabits.any((item) => item.habitId == habit.id))
        .toList();

    Get.dialog(
      AlertDialog(
        title: const Text('Sélectionner des habitudes'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: availableHabits.isEmpty
              ? const Center(
                  child: Text('Aucune habitude disponible'),
                )
              : ListView.builder(
                  itemCount: availableHabits.length,
                  itemBuilder: (context, index) {
                    final habit = availableHabits[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: habit.color.withOpacity(0.2),
                        child: Icon(habit.icon, color: habit.color),
                      ),
                      title: Text(habit.name),
                      subtitle: Text(habit.type.displayName),
                      onTap: () {
                        setState(() {
                          _selectedHabits.add(RoutineHabitItem(
                            habitId: habit.id,
                            order: _selectedHabits.length,
                            duration: 5, // Default duration
                          ));
                        });
                        Get.back();
                      },
                    );
                  },
                ),
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

  void _editHabitDuration(RoutineHabitItem habitItem) {
    final durationController = TextEditingController(
      text: habitItem.duration?.toString() ?? '5',
    );

    Get.dialog(
      AlertDialog(
        title: const Text('Durée estimée'),
        content: TextField(
          controller: durationController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Minutes',
            suffixText: 'min',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final duration = int.tryParse(durationController.text);
              if (duration != null && duration > 0) {
                setState(() {
                  final index = _selectedHabits.indexWhere((item) => item.habitId == habitItem.habitId);
                  if (index != -1) {
                    _selectedHabits[index] = _selectedHabits[index].copyWith(duration: duration);
                  }
                });
              }
              Get.back();
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveRoutine() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDays.isEmpty) {
      Get.snackbar(
        'Erreur',
        'Veuillez sélectionner au moins un jour',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final controller = Get.find<RoutinesController>();

      final estimatedDuration = _selectedHabits.fold(
        0,
        (total, item) => total + (item.duration ?? 5),
      );

      final routine = RoutineModel(
        id: _isEditing ? _editingRoutineId! : '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        type: _selectedType,
        habits: _selectedHabits,
        color: _selectedColor,
        icon: _selectedIcon,
        activeDays: _selectedDays,
        startTime: _startTime,
        estimatedDuration: estimatedDuration,
        entityId: '', // Will be set by controller
        status: _originalRoutine?.status ?? RoutineStatus.active,
        completionCount: _originalRoutine?.completionCount ?? 0,
        lastCompletedAt: _originalRoutine?.lastCompletedAt,
        createdAt: _originalRoutine?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      bool success;
      if (_isEditing) {
        success = await controller.updateRoutine(routine);
      } else {
        success = await controller.createRoutine(routine);
      }

      if (success) {
        Get.back();
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue: $e',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}