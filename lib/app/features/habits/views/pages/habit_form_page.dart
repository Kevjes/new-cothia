import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/habits_controller.dart';
import '../../models/habit_model.dart';

class HabitFormPage extends StatefulWidget {
  const HabitFormPage({super.key});

  @override
  State<HabitFormPage> createState() => _HabitFormPageState();
}

class _HabitFormPageState extends State<HabitFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetQuantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _financialImpactController = TextEditingController();

  bool _isEditing = false;
  String? _editingHabitId;
  HabitModel? _originalHabit;

  HabitType _selectedType = HabitType.good;
  HabitFrequency _selectedFrequency = HabitFrequency.daily;
  IconData _selectedIcon = Icons.emoji_events;
  Color _selectedColor = Colors.blue;
  List<int> _selectedDays = [];
  bool _hasReminder = false;
  TimeOfDay? _reminderTime;
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
      _editingHabitId = arguments;
      _loadHabitData();
    }
  }

  void _loadHabitData() {
    final controller = Get.find<HabitsController>();
    final habit = controller.getHabitById(_editingHabitId!);

    if (habit != null) {
      _originalHabit = habit;
      _nameController.text = habit.name;
      _descriptionController.text = habit.description ?? '';
      _targetQuantityController.text = habit.targetQuantity?.toString() ?? '';
      _unitController.text = habit.unit ?? '';
      _financialImpactController.text = habit.financialImpact?.toString() ?? '';

      _selectedType = habit.type;
      _selectedFrequency = habit.frequency;
      _selectedIcon = habit.icon;
      _selectedColor = habit.color;
      _selectedDays = habit.specificDays;
      _hasReminder = habit.reminderTime != null;
      _reminderTime = habit.reminderTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier l\'habitude' : 'Nouvelle habitude'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.analytics),
              onPressed: () => Get.toNamed('/habits/details', arguments: _editingHabitId),
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
              // Basic Information Section
              _buildSectionCard(
                title: 'Informations de base',
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom de l\'habitude *',
                      hintText: 'Ex: Boire 8 verres d\'eau',
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
                      hintText: 'Décrivez votre habitude...',
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Type and Frequency Section
              _buildSectionCard(
                title: 'Type et fréquence',
                children: [
                  // Habit Type
                  Text(
                    'Type d\'habitude',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTypeChip(
                          'Bonne habitude',
                          HabitType.good,
                          Icons.trending_up,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTypeChip(
                          'Mauvaise habitude',
                          HabitType.bad,
                          Icons.trending_down,
                          Colors.red,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Frequency
                  Text(
                    'Fréquence',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<HabitFrequency>(
                    value: _selectedFrequency,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.schedule),
                    ),
                    items: HabitFrequency.values.map((frequency) {
                      return DropdownMenuItem(
                        value: frequency,
                        child: Text(frequency.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedFrequency = value!;
                        if (value != HabitFrequency.specificDays) {
                          _selectedDays.clear();
                        }
                      });
                    },
                  ),

                  // Specific days selection
                  if (_selectedFrequency == HabitFrequency.specificDays) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Jours spécifiques',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _buildDaysSelector(),
                  ],
                ],
              ),

              const SizedBox(height: 16),

              // Appearance Section
              _buildSectionCard(
                title: 'Apparence',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Icône',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            _buildIconSelector(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Couleur',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            _buildColorSelector(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Quantity and Unit Section
              _buildSectionCard(
                title: 'Objectif quantifiable (optionnel)',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _targetQuantityController,
                          decoration: const InputDecoration(
                            labelText: 'Quantité cible',
                            hintText: 'Ex: 8',
                            prefixIcon: Icon(Icons.numbers),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final quantity = int.tryParse(value);
                              if (quantity == null || quantity <= 0) {
                                return 'Quantité invalide';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _unitController,
                          decoration: const InputDecoration(
                            labelText: 'Unité',
                            hintText: 'Ex: verres',
                            prefixIcon: Icon(Icons.label),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Financial Impact Section (for bad habits)
              if (_selectedType == HabitType.bad) ...[
                const SizedBox(height: 16),
                _buildSectionCard(
                  title: 'Impact financier (optionnel)',
                  children: [
                    TextFormField(
                      controller: _financialImpactController,
                      decoration: const InputDecoration(
                        labelText: 'Coût évité par jour (FCFA)',
                        hintText: 'Ex: 2000',
                        prefixIcon: Icon(Icons.savings),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final amount = double.tryParse(value);
                          if (amount == null || amount < 0) {
                            return 'Montant invalide';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Montant économisé chaque jour où vous évitez cette habitude',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 16),

              // Reminder Section
              _buildSectionCard(
                title: 'Rappel',
                children: [
                  SwitchListTile(
                    title: const Text('Activer les rappels'),
                    subtitle: _hasReminder && _reminderTime != null
                        ? Text('${_reminderTime!.format(context)}')
                        : const Text('Aucun rappel configuré'),
                    value: _hasReminder,
                    onChanged: (value) {
                      setState(() {
                        _hasReminder = value;
                        if (!value) {
                          _reminderTime = null;
                        }
                      });
                    },
                  ),
                  if (_hasReminder) ...[
                    const SizedBox(height: 8),
                    ListTile(
                      leading: const Icon(Icons.access_time),
                      title: Text(_reminderTime != null
                          ? 'Heure: ${_reminderTime!.format(context)}'
                          : 'Choisir l\'heure'),
                      onTap: () => _selectReminderTime(),
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
                onPressed: _isLoading ? null : _saveHabit,
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

  Widget _buildTypeChip(String label, HabitType type, IconData icon, Color color) {
    final isSelected = _selectedType == type;

    return InkWell(
      onTap: () => setState(() => _selectedType = type),
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

  Widget _buildIconSelector() {
    final icons = [
      Icons.emoji_events, Icons.local_drink, Icons.book, Icons.fitness_center,
      Icons.self_improvement, Icons.restaurant, Icons.bedtime, Icons.work,
      Icons.school, Icons.sports_esports, Icons.music_note, Icons.phone_android,
      Icons.smoking_rooms, Icons.local_bar, Icons.fastfood, Icons.tv,
    ];

    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: icons.length,
        itemBuilder: (context, index) {
          final icon = icons[index];
          final isSelected = _selectedIcon == icon;

          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => setState(() => _selectedIcon = icon),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected ? _selectedColor.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected ? _selectedColor : Colors.grey.withOpacity(0.3),
                  ),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? _selectedColor : Colors.grey,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildColorSelector() {
    final colors = [
      Colors.blue, Colors.green, Colors.red, Colors.orange, Colors.purple,
      Colors.teal, Colors.amber, Colors.pink, Colors.indigo, Colors.cyan,
    ];

    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: colors.length,
        itemBuilder: (context, index) {
          final color = colors[index];
          final isSelected = _selectedColor == color;

          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => setState(() => _selectedColor = color),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white)
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectReminderTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        _reminderTime = time;
      });
    }
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedFrequency == HabitFrequency.specificDays && _selectedDays.isEmpty) {
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
      final controller = Get.find<HabitsController>();

      int? targetQuantity;
      if (_targetQuantityController.text.isNotEmpty) {
        targetQuantity = int.parse(_targetQuantityController.text);
      }

      double? financialImpact;
      if (_financialImpactController.text.isNotEmpty) {
        financialImpact = double.parse(_financialImpactController.text);
      }

      final habit = HabitModel(
        id: _isEditing ? _editingHabitId! : '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        type: _selectedType,
        frequency: _selectedFrequency,
        specificDays: _selectedDays,
        targetQuantity: targetQuantity??0,
        unit: _unitController.text.trim().isEmpty
            ? null
            : _unitController.text.trim(),
        icon: _selectedIcon,
        color: _selectedColor,
        reminderTime: _hasReminder ? _reminderTime : null,
        financialImpact: financialImpact,
        entityId: '', // Will be set by controller
        status: _originalHabit?.status ?? HabitStatus.active,
        currentStreak: _originalHabit?.currentStreak ?? 0,
        bestStreak: _originalHabit?.bestStreak ?? 0,
        totalCompletions: _originalHabit?.totalCompletions ?? 0,
        createdAt: _originalHabit?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(), startDate: _originalHabit?.startDate ?? DateTime.now(),
      );

      bool success;
      if (_isEditing) {
        success = await controller.updateHabit(habit);
      } else {
        success = await controller.createHabit(habit);
      }

      if (success) {
        Get.back(); // Close form page and return to previous page
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
    _targetQuantityController.dispose();
    _unitController.dispose();
    _financialImpactController.dispose();
    super.dispose();
  }
}