import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/constants/app_colors.dart';

class RecurringTasksPage extends StatelessWidget {
  const RecurringTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Tâches récurrentes d'exemple (à remplacer par des données Firebase)
    final List<Map<String, dynamic>> recurringTasks = [
      {
        'id': '1',
        'title': 'Réunion équipe hebdomadaire',
        'pattern': 'weekly',
        'patternDisplay': 'Chaque lundi à 9h00',
        'nextOccurrence': DateTime.now().add(const Duration(days: 1)),
        'isActive': true,
        'category': 'Travail',
        'categoryColor': Colors.blue,
      },
      {
        'id': '2',
        'title': 'Backup des données',
        'pattern': 'daily',
        'patternDisplay': 'Tous les jours à 22h00',
        'nextOccurrence': DateTime.now().add(const Duration(hours: 2)),
        'isActive': true,
        'category': 'Technique',
        'categoryColor': Colors.green,
      },
      {
        'id': '3',
        'title': 'Rapport mensuel',
        'pattern': 'monthly',
        'patternDisplay': 'Le 1er de chaque mois',
        'nextOccurrence': DateTime.now().add(const Duration(days: 15)),
        'isActive': false,
        'category': 'Administration',
        'categoryColor': Colors.orange,
      },
      {
        'id': '4',
        'title': 'Exercice physique',
        'pattern': 'custom',
        'patternDisplay': 'Lun, Mer, Ven à 7h00',
        'nextOccurrence': DateTime.now().add(const Duration(days: 2)),
        'isActive': true,
        'category': 'Santé',
        'categoryColor': Colors.red,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tâches Récurrentes'),
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateRecurringTaskDialog(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh recurring tasks from Firebase
          // TODO: Implémenter le service de tâches récurrentes
          Get.snackbar('Actualisation', 'Tâches récurrentes actualisées');
        },
        child: recurringTasks.isEmpty
            ? _buildEmptyState()
            : _buildRecurringTasksList(recurringTasks),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "recurring_tasks_fab",
        onPressed: () => _showCreateRecurringTaskDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.repeat,
            size: 64,
            color: AppColors.hint,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune tâche récurrente',
            style: Get.textTheme.headlineSmall?.copyWith(
              color: AppColors.hint,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Automatisez vos tâches répétitives',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: AppColors.hint,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateRecurringTaskDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Créer une tâche récurrente'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecurringTasksList(List<Map<String, dynamic>> tasks) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildRecurringTaskCard(task);
      },
    );
  }

  Widget _buildRecurringTaskCard(Map<String, dynamic> task) {
    final nextOccurrence = task['nextOccurrence'] as DateTime;
    final isToday = _isSameDay(nextOccurrence, DateTime.now());
    final isTomorrow = _isSameDay(nextOccurrence, DateTime.now().add(const Duration(days: 1)));

    String nextText = '';
    if (isToday) {
      nextText = 'Aujourd\'hui';
    } else if (isTomorrow) {
      nextText = 'Demain';
    } else {
      nextText = '${nextOccurrence.day}/${nextOccurrence.month}/${nextOccurrence.year}';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: task['categoryColor'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.repeat,
                    color: task['categoryColor'],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task['title'],
                        style: Get.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: task['isActive'] ? null : AppColors.hint,
                        ),
                      ),
                      Text(
                        task['category'],
                        style: Get.textTheme.bodySmall?.copyWith(
                          color: task['categoryColor'],
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: task['isActive'],
                  onChanged: (value) async {
                    // Update recurring task status in Firebase
                    try {
                      task['isActive'] = value;
                      // Here you would typically update in Firebase
                      // TODO: Implémenter la mise à jour des tâches récurrentes

                      Get.snackbar(
                        value ? 'Activé' : 'Désactivé',
                        'Tâche récurrente ${value ? 'activée' : 'désactivée'} avec succès',
                      );
                    } catch (e) {
                      Get.snackbar('Erreur', 'Impossible de modifier le statut');
                    }
                  },
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showEditRecurringTaskDialog(task);
                        break;
                      case 'create_now':
                        _createTaskNow(task);
                        break;
                      case 'delete':
                        _showDeleteConfirmation(task);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Modifier'),
                    ),
                    const PopupMenuItem(
                      value: 'create_now',
                      child: Text('Créer maintenant'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Supprimer'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: AppColors.hint),
                const SizedBox(width: 4),
                Text(
                  task['patternDisplay'],
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: AppColors.hint,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.next_plan, size: 16, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  'Prochaine occurrence: $nextText',
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  void _showCreateRecurringTaskDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Nouvelle Tâche Récurrente'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Titre de la tâche',
                  hintText: 'Ex: Réunion hebdomadaire',
                ),
              ),
              const SizedBox(height: 16),
              const Text('Configuration de récurrence à implémenter'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Save recurring task to Firebase
              try {
                final newRecurringTask = {
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'title': 'Nouvelle tâche récurrente',
                  'pattern': 'weekly',
                  'isActive': true,
                  'createdAt': DateTime.now().toIso8601String(),
                };
                // Here you would typically save to Firebase
                // TODO: Implémenter la création de tâches récurrentes

                Get.back();
                Get.snackbar('Succès', 'Tâche récurrente créée avec succès');
              } catch (e) {
                Get.snackbar('Erreur', 'Impossible de créer la tâche');
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  void _showEditRecurringTaskDialog(Map<String, dynamic> task) {
    Get.dialog(
      AlertDialog(
        title: const Text('Modifier la Tâche Récurrente'),
        content: const SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Titre de la tâche',
                  hintText: 'Modifier le titre...',
                ),
              ),
              SizedBox(height: 16),
              Text('Formulaire de modification à implémenter'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Update recurring task in Firebase
              try {
                // Here you would typically update in Firebase
                // TODO: Implémenter la modification de tâches récurrentes

                Get.back();
                Get.snackbar('Succès', 'Tâche récurrente modifiée avec succès');
              } catch (e) {
                Get.snackbar('Erreur', 'Impossible de modifier la tâche');
              }
            },
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }

  void _createTaskNow(Map<String, dynamic> recurringTask) async {
    // Create a single task instance from the recurring task
    try {
      final newTask = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': recurringTask['title'],
        'description': 'Tâche créée depuis un modèle récurrent',
        'priority': 'medium',
        'status': 'pending',
        'dueDate': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
        'recurringTaskId': recurringTask['id'],
        'createdAt': DateTime.now().toIso8601String(),
      };
      // Here you would typically create the task
      // await taskService.createTask(newTask);

      Get.snackbar(
        'Tâche créée',
        'Une occurrence de "${recurringTask['title']}" a été créée avec succès',
        backgroundColor: AppColors.success.withOpacity(0.1),
        colorText: AppColors.success,
      );
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de créer la tâche');
    }
  }

  void _showDeleteConfirmation(Map<String, dynamic> task) {
    Get.dialog(
      AlertDialog(
        title: const Text('Supprimer la tâche récurrente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Êtes-vous sûr de vouloir supprimer la tâche récurrente "${task['title']}" ?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: AppColors.warning, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Cette action supprimera définitivement la récurrence. Les tâches déjà créées ne seront pas affectées.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Delete recurring task from Firebase
              try {
                // Here you would typically delete from Firebase
                // TODO: Implémenter la suppression de tâches récurrentes

                Get.back();
                Get.snackbar('Succès', 'Tâche récurrente "${task['title']}" supprimée avec succès');
              } catch (e) {
                Get.snackbar('Erreur', 'Impossible de supprimer la tâche');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}