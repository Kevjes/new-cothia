import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/objectives_controller.dart';
import '../../../models/objective_model.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../../../core/widgets/custom_button.dart';
import 'objective_create_page.dart';

class ObjectiveDetailsPage extends StatelessWidget {
  final String objectiveId;

  const ObjectiveDetailsPage({super.key, required this.objectiveId});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ObjectivesController>(
      builder: (controller) {
        // Find objective by ID from the objectives list
        final objective = controller.objectives.where((obj) => obj.id == objectiveId).firstOrNull;

        if (objective == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Objectif')),
            body: const Center(
              child: Text('Objectif non trouvé'),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(objective.name),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editObjective(objective),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(value, objective),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'pause',
                    enabled: objective.isActive,
                    child: Row(
                      children: [
                        Icon(Icons.pause, color: objective.isActive ? null : Colors.grey),
                        const SizedBox(width: 8),
                        Text('Mettre en pause'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'resume',
                    enabled: objective.isPaused,
                    child: Row(
                      children: [
                        Icon(Icons.play_arrow, color: objective.isPaused ? null : Colors.grey),
                        const SizedBox(width: 8),
                        Text('Reprendre'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'complete',
                    enabled: objective.isActive,
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: objective.isActive ? Colors.green : Colors.grey),
                        const SizedBox(width: 8),
                        Text('Marquer comme terminé'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'cancel',
                    enabled: !objective.isCompleted && !objective.isCancelled,
                    child: Row(
                      children: [
                        const Icon(Icons.cancel, color: Colors.red),
                        const SizedBox(width: 8),
                        Text('Annuler'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'duplicate',
                    child: Row(
                      children: [
                        const Icon(Icons.copy),
                        const SizedBox(width: 8),
                        Text('Dupliquer'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete, color: Colors.red),
                        const SizedBox(width: 8),
                        Text('Supprimer'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildProgressSection(objective),
              const SizedBox(height: 24),
              _buildInfoSection(objective),
              const SizedBox(height: 24),
              _buildAmountSection(objective),
              const SizedBox(height: 24),
              _buildConfigurationSection(objective),
              if (objective.tags.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildTagsSection(objective),
              ],
              const SizedBox(height: 32),
              _buildQuickActions(objective),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressSection(ObjectiveModel objective) {
    final progress = objective.progressPercentage;
    final isOverdue = objective.isOverdue;
    final isBehindSchedule = objective.isBehindSchedule;

    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getStatusColor(objective.status),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _getStatusLabel(objective.status),
                  style: Get.textTheme.titleMedium?.copyWith(
                    color: _getStatusColor(objective.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (isOverdue)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'En retard',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  )
                else if (isBehindSchedule)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'En retard sur planning',
                      style: TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  height: 8,
                  width: (Get.width - 72) * (progress / 100),
                  decoration: BoxDecoration(
                    color: _getProgressColor(progress),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${objective.currentAmount.toStringAsFixed(0)} FCFA',
                  style: Get.textTheme.titleLarge?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${progress.toStringAsFixed(1)}%',
                  style: Get.textTheme.titleMedium?.copyWith(
                    color: _getProgressColor(progress),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'sur ${objective.targetAmount.toStringAsFixed(0)} FCFA',
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: AppColors.hint,
                  ),
                ),
                Text(
                  'Restant: ${(objective.targetAmount - objective.currentAmount).toStringAsFixed(0)} FCFA',
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

  Widget _buildInfoSection(ObjectiveModel objective) {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations',
              style: Get.textTheme.titleMedium?.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Nom', objective.name),
            if (objective.description != null && objective.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow('Description', objective.description!),
            ],
            const SizedBox(height: 12),
            _buildInfoRow('Priorité', _getPriorityLabel(objective.priority)),
            const SizedBox(height: 12),
            _buildInfoRow('Créé le', _formatDate(objective.createdAt)),
            const SizedBox(height: 12),
            _buildInfoRow('Dernière mise à jour', _formatDate(objective.updatedAt)),
            if (objective.targetDate != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow('Date limite', _formatDate(objective.targetDate!)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAmountSection(ObjectiveModel objective) {
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
            Row(
              children: [
                Expanded(
                  child: _buildAmountCard(
                    'Montant actuel',
                    objective.currentAmount,
                    Icons.savings,
                    AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAmountCard(
                    'Objectif',
                    objective.targetAmount,
                    Icons.flag,
                    Colors.green,
                  ),
                ),
              ],
            ),
            if (objective.monthlyAllocation != null) ...[
              const SizedBox(height: 16),
              _buildAmountCard(
                'Allocation mensuelle',
                objective.monthlyAllocation!,
                Icons.schedule,
                Colors.orange,
                isFullWidth: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard(
    String label,
    double amount,
    IconData icon,
    Color color, {
    bool isFullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${amount.toStringAsFixed(0)} FCFA',
            style: Get.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigurationSection(ObjectiveModel objective) {
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
            ListTile(
              leading: Icon(
                objective.isAutoAllocated ? Icons.auto_awesome : Icons.person,
                color: objective.isAutoAllocated ? Colors.green : Colors.grey,
              ),
              title: const Text('Allocation automatique'),
              subtitle: Text(
                objective.isAutoAllocated
                    ? 'L\'allocation mensuelle est ajoutée automatiquement'
                    : 'Allocation manuelle uniquement',
              ),
              trailing: Icon(
                objective.isAutoAllocated ? Icons.check_circle : Icons.cancel,
                color: objective.isAutoAllocated ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection(ObjectiveModel objective) {
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
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: objective.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  backgroundColor: AppColors.secondary.withOpacity(0.1),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(ObjectiveModel objective) {
    return Column(
      children: [
        if (objective.isActive) ...[
          CustomButton(
            text: 'Ajouter un montant',
            onPressed: () => _showAddAmountDialog(objective),
            icon: Icons.add_circle,
          ),
          const SizedBox(height: 12),
        ],
        if (objective.currentAmount > 0) ...[
          CustomButton(
            text: 'Retirer un montant',
            onPressed: () => _showSubtractAmountDialog(objective),
            icon: Icons.remove_circle,
            variant: ButtonVariant.outlined,
          ),
          const SizedBox(height: 12),
        ],
        CustomButton(
          text: 'Modifier',
          onPressed: () => _editObjective(objective),
          icon: Icons.edit,
          variant: ButtonVariant.outlined,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: AppColors.hint,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Get.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  void _editObjective(ObjectiveModel objective) {
    Get.to(() => ObjectiveCreatePage(objectiveToEdit: objective));
  }

  void _showAddAmountDialog(ObjectiveModel objective) {
    final controller = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Ajouter un montant'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ajouter un montant à "${objective.name}"'),
            const SizedBox(height: 16),
            CustomTextField(
              controller: controller,
              label: 'Montant (FCFA)',
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => _addAmount(objective, controller.text),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showSubtractAmountDialog(ObjectiveModel objective) {
    final controller = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Retirer un montant'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Retirer un montant de "${objective.name}"'),
            const SizedBox(height: 8),
            Text(
              'Montant actuel: ${objective.currentAmount.toStringAsFixed(0)} FCFA',
              style: Get.textTheme.bodySmall?.copyWith(color: AppColors.hint),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: controller,
              label: 'Montant (FCFA)',
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => _subtractAmount(objective, controller.text),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );
  }

  Future<void> _addAmount(ObjectiveModel objective, String amountStr) async {
    final amount = double.tryParse(amountStr);
    if (amount == null || amount <= 0) {
      Get.snackbar('Erreur', 'Veuillez entrer un montant valide');
      return;
    }

    Get.back(); // Close dialog

    final controller = Get.find<ObjectivesController>();
    await controller.addToObjectiveAmount(objective.id, amount);
  }

  Future<void> _subtractAmount(ObjectiveModel objective, String amountStr) async {
    final amount = double.tryParse(amountStr);
    if (amount == null || amount <= 0) {
      Get.snackbar('Erreur', 'Veuillez entrer un montant valide');
      return;
    }

    if (amount > objective.currentAmount) {
      Get.snackbar('Erreur', 'Le montant ne peut pas être supérieur au montant actuel');
      return;
    }

    Get.back(); // Close dialog

    final controller = Get.find<ObjectivesController>();
    await controller.subtractFromObjectiveAmount(objective.id, amount);
  }

  Future<void> _handleMenuAction(String action, ObjectiveModel objective) async {
    final controller = Get.find<ObjectivesController>();

    switch (action) {
      case 'pause':
        await controller.pauseObjective(objective.id);
        break;
      case 'resume':
        await controller.resumeObjective(objective.id);
        break;
      case 'complete':
        await controller.completeObjective(objective.id);
        break;
      case 'cancel':
        await controller.cancelObjective(objective.id);
        break;
      case 'duplicate':
        _showDuplicateDialog(objective);
        break;
      case 'delete':
        _showDeleteDialog(objective);
        break;
    }
  }

  void _showDuplicateDialog(ObjectiveModel objective) {
    final controller = TextEditingController(text: '${objective.name} (copie)');

    Get.dialog(
      AlertDialog(
        title: const Text('Dupliquer l\'objectif'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Nom du nouvel objectif:'),
            const SizedBox(height: 16),
            CustomTextField(
              controller: controller,
              label: 'Nom',
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => _duplicateObjective(objective, controller.text),
            child: const Text('Dupliquer'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(ObjectiveModel objective) {
    Get.dialog(
      AlertDialog(
        title: const Text('Supprimer l\'objectif'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${objective.name}" ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => _deleteObjective(objective),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _duplicateObjective(ObjectiveModel objective, String newName) async {
    if (newName.trim().isEmpty) {
      Get.snackbar('Erreur', 'Veuillez entrer un nom pour le nouvel objectif');
      return;
    }

    Get.back(); // Close dialog

    final controller = Get.find<ObjectivesController>();
    await controller.duplicateObjective(objective.id, newName.trim());
  }

  Future<void> _deleteObjective(ObjectiveModel objective) async {
    Get.back(); // Close dialog

    final controller = Get.find<ObjectivesController>();
    final success = await controller.deleteObjective(objective.id);

    if (success) {
      Get.back(); // Return to objectives list
    }
  }

  Color _getStatusColor(ObjectiveStatus status) {
    switch (status) {
      case ObjectiveStatus.active:
        return Colors.blue;
      case ObjectiveStatus.completed:
        return Colors.green;
      case ObjectiveStatus.paused:
        return Colors.orange;
      case ObjectiveStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusLabel(ObjectiveStatus status) {
    switch (status) {
      case ObjectiveStatus.active:
        return 'Actif';
      case ObjectiveStatus.completed:
        return 'Terminé';
      case ObjectiveStatus.paused:
        return 'En pause';
      case ObjectiveStatus.cancelled:
        return 'Annulé';
    }
  }

  String _getPriorityLabel(ObjectivePriority priority) {
    switch (priority) {
      case ObjectivePriority.high:
        return 'Haute priorité';
      case ObjectivePriority.medium:
        return 'Priorité moyenne';
      case ObjectivePriority.low:
        return 'Priorité basse';
    }
  }

  Color _getProgressColor(double progress) {
    if (progress >= 80) return Colors.green;
    if (progress >= 50) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}