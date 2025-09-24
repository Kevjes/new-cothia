import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/objectives_controller.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../models/objective_model.dart';
import 'objective_create_page.dart';
import 'objective_details_page.dart';

class ObjectivesListPage extends GetView<ObjectivesController> {
  const ObjectivesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Objectifs'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () => _showObjectivesAnalytics(),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'auto_allocation':
                  _executeAutoAllocation();
                  break;
                case 'export':
                  controller.exportObjectives();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'auto_allocation',
                child: Row(
                  children: [
                    Icon(Icons.auto_mode, size: 20),
                    SizedBox(width: 8),
                    Text('Allocation automatique'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, size: 20),
                    SizedBox(width: 8),
                    Text('Exporter'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildQuickStats(),
          _buildFilterTabs(),
          Expanded(
            child: Obx(() {
              if (controller.hasError) {
                return _buildErrorView();
              }

              if (controller.isLoading && controller.objectives.isEmpty) {
                return _buildLoadingView();
              }

              return RefreshIndicator(
                onRefresh: controller.refreshData,
                child: controller.objectives.isEmpty
                    ? _buildEmptyState()
                    : _buildObjectivesList(),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createObjective(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Objectif', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Obx(() {
      final activeCount = controller.activeObjectivesCount;
      final completedCount = controller.completedObjectivesCount;
      final behindScheduleCount = controller.behindScheduleCount;
      final totalProgress = controller.totalProgress;

      return Container(
        margin: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Actifs',
                activeCount.toString(),
                AppColors.primary,
                Icons.track_changes,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Terminés',
                completedCount.toString(),
                AppColors.success,
                Icons.check_circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'En retard',
                behindScheduleCount.toString(),
                behindScheduleCount > 0 ? AppColors.error : AppColors.hint,
                Icons.schedule,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Progrès',
                '${totalProgress.toStringAsFixed(0)}%',
                _getProgressColor(totalProgress),
                Icons.trending_up,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: Get.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              label,
              style: Get.textTheme.bodySmall?.copyWith(
                color: AppColors.hint,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  final selectedStatus = controller.selectedStatus.value;
                  return SegmentedButton<ObjectiveStatus?>(
                    segments: const [
                      ButtonSegment<ObjectiveStatus?>(
                        value: null,
                        label: Text('Tous'),
                        icon: Icon(Icons.category),
                      ),
                      ButtonSegment<ObjectiveStatus?>(
                        value: ObjectiveStatus.active,
                        label: Text('Actifs'),
                        icon: Icon(Icons.track_changes),
                      ),
                      ButtonSegment<ObjectiveStatus?>(
                        value: ObjectiveStatus.completed,
                        label: Text('Terminés'),
                        icon: Icon(Icons.check_circle),
                      ),
                    ],
                    selected: {selectedStatus},
                    onSelectionChanged: (Set<ObjectiveStatus?> selection) {
                      controller.setStatusFilter(selection.first);
                    },
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  final selectedPriority = controller.selectedPriority.value;
                  return SegmentedButton<ObjectivePriority?>(
                    segments: const [
                      ButtonSegment<ObjectivePriority?>(
                        value: null,
                        label: Text('Toutes'),
                        icon: Icon(Icons.priority_high),
                      ),
                      ButtonSegment<ObjectivePriority?>(
                        value: ObjectivePriority.high,
                        label: Text('Haute'),
                        icon: Icon(Icons.priority_high),
                      ),
                      ButtonSegment<ObjectivePriority?>(
                        value: ObjectivePriority.medium,
                        label: Text('Moyenne'),
                        icon: Icon(Icons.remove),
                      ),
                      ButtonSegment<ObjectivePriority?>(
                        value: ObjectivePriority.low,
                        label: Text('Basse'),
                        icon: Icon(Icons.low_priority),
                      ),
                    ],
                    selected: {selectedPriority},
                    onSelectionChanged: (Set<ObjectivePriority?> selection) {
                      controller.setPriorityFilter(selection.first);
                    },
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: Get.textTheme.headlineSmall?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage,
              style: Get.textTheme.bodyMedium?.copyWith(
                color: AppColors.hint,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => controller.refreshData(),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Chargement des objectifs...'),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.track_changes_outlined,
              size: 80,
              color: AppColors.hint,
            ),
            const SizedBox(height: 24),
            Text(
              'Aucun objectif',
              style: Get.textTheme.headlineSmall?.copyWith(
                color: AppColors.hint,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Créez des objectifs financiers pour atteindre vos ambitions',
              style: Get.textTheme.bodyMedium?.copyWith(
                color: AppColors.hint,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _createObjective(),
              icon: const Icon(Icons.add),
              label: const Text('Premier objectif'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObjectivesList() {
    return Obx(() {
      final groupedObjectives = controller.groupedObjectives;

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: groupedObjectives.length,
        itemBuilder: (context, index) {
          final status = groupedObjectives.keys.elementAt(index);
          final objectives = groupedObjectives[status]!;
          return _buildObjectiveGroup(status, objectives);
        },
      );
    });
  }

  Widget _buildObjectiveGroup(ObjectiveStatus status, List<ObjectiveModel> objectives) {
    if (objectives.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Icon(
                _getStatusIcon(status),
                color: _getStatusColor(status),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '${_getStatusDisplayName(status)} (${objectives.length})',
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(status),
                ),
              ),
            ],
          ),
        ),
        ...objectives.map((objective) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildObjectiveCard(objective),
        )),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildObjectiveCard(ObjectiveModel objective) {
    final progressPercentage = objective.progressPercentage;
    final progressColor = _getProgressColor(progressPercentage);

    return Card(
      child: InkWell(
        onTap: () => _navigateToObjectiveDetails(objective),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: objective.color.withOpacity(0.2),
                    child: Icon(objective.icon, color: objective.color),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                objective.name,
                                style: Get.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: objective.priorityColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                objective.priorityDisplayName,
                                style: Get.textTheme.bodySmall?.copyWith(
                                  color: objective.priorityColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (objective.description != null && objective.description!.isNotEmpty)
                          Text(
                            objective.description!,
                            style: Get.textTheme.bodySmall?.copyWith(
                              color: AppColors.hint,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleObjectiveAction(value, objective),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Modifier'),
                          ],
                        ),
                      ),
                      if (objective.isActive) ...[
                        const PopupMenuItem(
                          value: 'add_amount',
                          child: Row(
                            children: [
                              Icon(Icons.add_circle, size: 18),
                              SizedBox(width: 8),
                              Text('Ajouter montant'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'complete',
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, size: 18),
                              SizedBox(width: 8),
                              Text('Marquer terminé'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'pause',
                          child: Row(
                            children: [
                              Icon(Icons.pause_circle, size: 18),
                              SizedBox(width: 8),
                              Text('Mettre en pause'),
                            ],
                          ),
                        ),
                      ],
                      if (objective.isPaused)
                        const PopupMenuItem(
                          value: 'resume',
                          child: Row(
                            children: [
                              Icon(Icons.play_circle, size: 18),
                              SizedBox(width: 8),
                              Text('Reprendre'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.copy, size: 18),
                            SizedBox(width: 8),
                            Text('Dupliquer'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Supprimer', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Progress section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${objective.currentAmount.toStringAsFixed(0)} FCFA',
                    style: Get.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: progressColor,
                    ),
                  ),
                  Text(
                    '${objective.targetAmount.toStringAsFixed(0)} FCFA',
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: AppColors.hint,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progressPercentage / 100,
                  backgroundColor: AppColors.hint.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${progressPercentage.toStringAsFixed(1)}%',
                    style: Get.textTheme.bodySmall?.copyWith(
                      color: progressColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (objective.remainingAmount > 0)
                    Text(
                      'Reste: ${objective.remainingAmount.toStringAsFixed(0)} FCFA',
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: AppColors.hint,
                      ),
                    ),
                ],
              ),

              // Additional info
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (objective.targetDate != null)
                    _buildInfoChip(
                      Icons.calendar_today,
                      _formatDate(objective.targetDate!),
                      objective.isBehindSchedule ? AppColors.error : AppColors.info,
                    ),
                  if (objective.isAutoAllocated)
                    _buildInfoChip(
                      Icons.auto_mode,
                      'Auto: ${objective.monthlyAllocation?.toStringAsFixed(0)} FCFA/mois',
                      AppColors.success,
                    ),
                  if (objective.estimatedMonthsToComplete != null)
                    _buildInfoChip(
                      Icons.schedule,
                      '${objective.estimatedMonthsToComplete} mois restants',
                      AppColors.secondary,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: Get.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 100) return AppColors.success;
    if (percentage >= 75) return Colors.orange;
    if (percentage >= 50) return AppColors.secondary;
    return AppColors.error;
  }

  Color _getStatusColor(ObjectiveStatus status) {
    switch (status) {
      case ObjectiveStatus.active:
        return AppColors.primary;
      case ObjectiveStatus.completed:
        return AppColors.success;
      case ObjectiveStatus.paused:
        return Colors.orange;
      case ObjectiveStatus.cancelled:
        return AppColors.error;
    }
  }

  IconData _getStatusIcon(ObjectiveStatus status) {
    switch (status) {
      case ObjectiveStatus.active:
        return Icons.track_changes;
      case ObjectiveStatus.completed:
        return Icons.check_circle;
      case ObjectiveStatus.paused:
        return Icons.pause_circle;
      case ObjectiveStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusDisplayName(ObjectiveStatus status) {
    switch (status) {
      case ObjectiveStatus.active:
        return 'Actifs';
      case ObjectiveStatus.completed:
        return 'Terminés';
      case ObjectiveStatus.paused:
        return 'En pause';
      case ObjectiveStatus.cancelled:
        return 'Annulés';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _createObjective() {
    Get.to(() => const ObjectiveCreatePage());
  }

  void _navigateToObjectiveDetails(ObjectiveModel objective) {
    Get.to(() => ObjectiveDetailsPage(objectiveId: objective.id));
  }

  void _handleObjectiveAction(String action, ObjectiveModel objective) {
    switch (action) {
      case 'edit':
        Get.to(() => ObjectiveCreatePage(objectiveToEdit: objective));
        break;
      case 'add_amount':
        _showAddAmountDialog(objective);
        break;
      case 'complete':
        controller.completeObjective(objective.id);
        break;
      case 'pause':
        controller.pauseObjective(objective.id);
        break;
      case 'resume':
        controller.resumeObjective(objective.id);
        break;
      case 'duplicate':
        controller.duplicateObjectiveFromModel(objective);
        break;
      case 'delete':
        _showDeleteDialog(objective);
        break;
    }
  }

  void _showAddAmountDialog(ObjectiveModel objective) {
    final amountController = TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Ajouter à "${objective.name}"'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Montant actuel: ${objective.currentAmount.toStringAsFixed(0)} FCFA'),
            Text('Objectif: ${objective.targetAmount.toStringAsFixed(0)} FCFA'),
            const SizedBox(height: 16),
            TextFormField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Montant à ajouter',
                suffixText: 'FCFA',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                Get.back();
                controller.addToObjective(objective.id, amount);
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(ObjectiveModel objective) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Supprimer l\'objectif'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer l\'objectif "${objective.name}" ?\n\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteObjective(objective.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showObjectivesAnalytics() {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('Analyses des objectifs'),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Objectifs totaux: ${controller.objectives.length}'),
              const SizedBox(height: 8),
              Text('Objectifs actifs: ${controller.activeObjectivesCount}'),
              const SizedBox(height: 8),
              Text('Objectifs terminés: ${controller.completedObjectivesCount}'),
              const SizedBox(height: 8),
              Text('En retard: ${controller.behindScheduleCount}'),
              const SizedBox(height: 8),
              Text('Montant total cible: ${controller.totalTargetAmount.toStringAsFixed(0)} FCFA'),
              const SizedBox(height: 8),
              Text('Montant total actuel: ${controller.totalCurrentAmount.toStringAsFixed(0)} FCFA'),
              const SizedBox(height: 8),
              Text('Progression globale: ${controller.totalProgress.toStringAsFixed(1)}%'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.exportObjectives();
            },
            child: const Text('Exporter'),
          ),
        ],
      ),
    );
  }

  void _executeAutoAllocation() {
    controller.executeMonthlyAutoAllocation();
  }
}