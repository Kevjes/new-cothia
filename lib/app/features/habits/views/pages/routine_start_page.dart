import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/routines_controller.dart';
import '../../controllers/habits_controller.dart';
import '../../models/habit_model.dart';
import '../../models/routine_model.dart';

class RoutineStartPage extends StatefulWidget {
  const RoutineStartPage({super.key});

  @override
  State<RoutineStartPage> createState() => _RoutineStartPageState();
}

class _RoutineStartPageState extends State<RoutineStartPage> {
  final PageController _pageController = PageController();
  final RxInt currentStep = 0.obs;
  final RxList<String> completedHabits = <String>[].obs;
  final RxInt totalDuration = 0.obs;
  final RxDouble satisfactionRating = 5.0.obs;
  final TextEditingController notesController = TextEditingController();

  RoutineModel? routine;
  DateTime? startTime;
  bool isCompleting = false;

  @override
  void initState() {
    super.initState();
    _initializeRoutine();
  }

  void _initializeRoutine() {
    final routineId = Get.arguments as String;
    final controller = Get.find<RoutinesController>();
    routine = controller.getRoutineById(routineId);

    if (routine == null) {
      Get.back();
      return;
    }

    startTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    if (routine == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(routine!.name),
        backgroundColor: routine!.color,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _showExitDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16.0),
            color: routine!.color.withOpacity(0.1),
            child: Column(
              children: [
                Obx(() => LinearProgressIndicator(
                  value: routine!.habits.isEmpty ? 1.0 : (currentStep.value + 1) / (routine!.habits.length + 1),
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(routine!.color),
                )),
                const SizedBox(height: 8),
                Obx(() => Text(
                  'Étape ${currentStep.value + 1} sur ${routine!.habits.length + 1}',
                  style: Theme.of(context).textTheme.bodyMedium,
                )),
              ],
            ),
          ),

          // Page view with steps
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Habit steps
                ...routine!.habits.map((habitItem) => _buildHabitStep(habitItem)),
                // Completion step
                _buildCompletionStep(),
              ],
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Obx(() => Row(
              children: [
                if (currentStep.value > 0) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      child: const Text('Précédent'),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: isCompleting ? null : _nextStep,
                    child: isCompleting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(currentStep.value == routine!.habits.length ? 'Terminer' : 'Suivant'),
                  ),
                ),
              ],
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitStep(RoutineHabitItem habitItem) {
    final habitsController = Get.find<HabitsController>();
    final habit = habitsController.getHabitById(habitItem.habitId);

    if (habit == null) {
      return const Center(child: Text('Habitude introuvable'));
    }

    final isCompleted = completedHabits.contains(habit.id);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Habit info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: habit.color.withOpacity(0.2),
                    radius: 40,
                    child: Icon(
                      habit.icon,
                      color: habit.color,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    habit.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (habit.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      habit.description!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (habitItem.duration != null)
                        _buildInfoChip(
                          icon: Icons.timer,
                          label: '${habitItem.duration} min',
                          color: habit.color,
                        ),
                      _buildInfoChip(
                        icon: habit.type == HabitType.good ? Icons.trending_up : Icons.trending_down,
                        label: habit.type.displayName,
                        color: habit.type.color,
                      ),
                      if (habit.targetQuantity != null)
                        _buildInfoChip(
                          icon: Icons.track_changes,
                          label: '${habit.targetQuantity} ${habit.unit ?? ''}',
                          color: habit.color,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Completion status
          Card(
            color: isCompleted ? Colors.green.withOpacity(0.1) : null,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (isCompleted) ...[
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Habitude complétée !',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Vous pouvez passer à l\'étape suivante',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          completedHabits.remove(habit.id);
                        });
                      },
                      icon: const Icon(Icons.undo),
                      label: const Text('Annuler'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                      ),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Icon(Icons.radio_button_unchecked, color: Colors.grey, size: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Effectuez cette habitude',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                'Marquez comme fait une fois terminé',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _completeHabit(habit.id),
                            icon: const Icon(Icons.check),
                            label: const Text('Fait'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () => _skipHabit(habit.id),
                          child: const Text('Passer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          const Spacer(),

          // Timer display if duration is specified
          if (habitItem.duration != null && !isCompleted) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: habit.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: habit.color.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timer, color: habit.color),
                  const SizedBox(width: 8),
                  Text(
                    'Durée suggérée: ${habitItem.duration} minutes',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: habit.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompletionStep() {
    final duration = startTime != null
        ? DateTime.now().difference(startTime!).inMinutes
        : routine!.estimatedDuration;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    Icons.celebration,
                    color: Colors.green,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Routine terminée !',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Félicitations pour avoir terminé votre routine "${routine!.name}"',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSummaryItem(
                        icon: Icons.check_circle,
                        label: 'Habitudes',
                        value: '${completedHabits.length}/${routine!.habits.length}',
                        color: Colors.green,
                      ),
                      _buildSummaryItem(
                        icon: Icons.timer,
                        label: 'Durée',
                        value: '${duration} min',
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Satisfaction rating
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Évaluation de satisfaction',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Comment vous sentez-vous après cette routine ?',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(() => Slider(
                    value: satisfactionRating.value,
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: _getSatisfactionLabel(satisfactionRating.value),
                    onChanged: (value) => satisfactionRating.value = value,
                  )),
                  Obx(() => Center(
                    child: Text(
                      _getSatisfactionLabel(satisfactionRating.value),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _getSatisfactionColor(satisfactionRating.value),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Notes
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notes (optionnel)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      hintText: 'Comment s\'est passée cette routine ?',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _completeHabit(String habitId) {
    if (!completedHabits.contains(habitId)) {
      completedHabits.add(habitId);
    }
  }

  void _skipHabit(String habitId) {
    // For routines, we still count skipped habits as "done" for progression
    if (!completedHabits.contains(habitId)) {
      completedHabits.add(habitId);
    }
  }

  void _nextStep() {
    if (currentStep.value < routine!.habits.length) {
      currentStep.value++;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeRoutine();
    }
  }

  void _previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeRoutine() async {
    setState(() {
      isCompleting = true;
    });

    try {
      final controller = Get.find<RoutinesController>();
      final duration = startTime != null
          ? DateTime.now().difference(startTime!).inMinutes
          : routine!.estimatedDuration;

      final success = await controller.completeRoutine(
        routine!.id,
        completedHabits: completedHabits.toList(),
        durationMinutes: duration,
        satisfactionRating: satisfactionRating.value,
        notes: notesController.text.isEmpty ? null : notesController.text,
      );

      if (success) {
        Get.back(); // Return to previous page
        Get.snackbar(
          'Félicitations !',
          'Routine "${routine!.name}" terminée avec succès',
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de la sauvegarde: $e',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        isCompleting = false;
      });
    }
  }

  void _showExitDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Abandonner la routine'),
        content: const Text(
          'Êtes-vous sûr de vouloir quitter ? Votre progression sera perdue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Continuer'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(); // Close routine page
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Abandonner'),
          ),
        ],
      ),
    );
  }

  String _getSatisfactionLabel(double rating) {
    if (rating <= 1.5) return 'Très insatisfait';
    if (rating <= 2.5) return 'Insatisfait';
    if (rating <= 3.5) return 'Neutre';
    if (rating <= 4.5) return 'Satisfait';
    return 'Très satisfait';
  }

  Color _getSatisfactionColor(double rating) {
    if (rating <= 2) return Colors.red;
    if (rating <= 3) return Colors.orange;
    if (rating <= 4) return Colors.blue;
    return Colors.green;
  }

  @override
  void dispose() {
    _pageController.dispose();
    notesController.dispose();
    super.dispose();
  }
}