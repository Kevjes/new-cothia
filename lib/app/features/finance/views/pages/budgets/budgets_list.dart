import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../routes/app_pages.dart';
import '../../../controllers/budgets_controller.dart';
import '../../../models/budget_model.dart';
import '../../../../../core/theme/app_colors.dart';

class BudgetsList extends GetView<BudgetsController> {
  const BudgetsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets & Objectifs'),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.FINANCE_BUDGETS_CREATE),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTypeSelector(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final items = controller.selectedType == BudgetType.budget
                  ? controller.budgets
                  : controller.objectives;

              if (items.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: controller.refreshData,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildBudgetCard(item);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.FINANCE_BUDGETS_CREATE),
        icon: const Icon(Icons.add),
        label: Obx(() => Text(
          'Créer ${controller.selectedType == BudgetType.budget ? 'Budget' : 'Objectif'}',
        )),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Obx(() => Row(
        children: [
          Expanded(
            child: _buildTypeButton(
              'Budgets',
              BudgetType.budget,
              Icons.account_balance_wallet,
              controller.selectedType == BudgetType.budget,
            ),
          ),
          Expanded(
            child: _buildTypeButton(
              'Objectifs',
              BudgetType.objective,
              Icons.flag,
              controller.selectedType == BudgetType.objective,
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildTypeButton(String title, BudgetType type, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () => controller.changeSelectedType(type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.grey600,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.grey600,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetCard(BudgetModel budget) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackWithOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getBudgetColor(budget).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getBudgetIcon(budget),
                  color: _getBudgetColor(budget),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      budget.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (budget.description?.isNotEmpty ?? false)
                      Text(
                        budget.description!,
                        style: TextStyle(
                          color: AppColors.grey600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleAction(value, budget),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'details',
                    child: Row(
                      children: [
                        Icon(Icons.info, size: 20),
                        SizedBox(width: 8),
                        Text('Détails'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Modifier'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
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

          // Barre de progression
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    budget.progressText,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grey700,
                    ),
                  ),
                  Text(
                    '${budget.spentPercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: budget.isOverBudget ? AppColors.error : AppColors.grey700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: budget.spentPercentage / 100,
                backgroundColor: AppColors.grey200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  budget.isOverBudget ? AppColors.error : _getBudgetColor(budget),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Informations supplémentaires
          Row(
            children: [
              _buildInfoChip(
                budget.period.label,
                Icons.schedule,
                AppColors.primary,
              ),
              const SizedBox(width: 8),
              if (budget.isRecurrent)
                _buildInfoChip(
                  'Récurrent',
                  Icons.repeat,
                  AppColors.success,
                ),
              const Spacer(),
              if (budget.daysRemaining > 0)
                Text(
                  '${budget.daysRemaining} jour${budget.daysRemaining > 1 ? 's' : ''} restant${budget.daysRemaining > 1 ? 's' : ''}',
                  style: TextStyle(
                    color: AppColors.grey600,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                controller.selectedType == BudgetType.budget
                    ? Icons.account_balance_wallet
                    : Icons.flag,
                size: 48,
                color: AppColors.grey500,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              controller.selectedType == BudgetType.budget
                  ? 'Aucun budget'
                  : 'Aucun objectif',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.grey700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.selectedType == BudgetType.budget
                  ? 'Créez votre premier budget pour mieux gérer vos dépenses'
                  : 'Créez votre premier objectif pour atteindre vos rêves',
              style: TextStyle(
                color: AppColors.grey600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.FINANCE_BUDGETS_CREATE),
              icon: const Icon(Icons.add),
              label: Text(
                'Créer ${controller.selectedType == BudgetType.budget ? 'Budget' : 'Objectif'}',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAction(String action, BudgetModel budget) {
    switch (action) {
      case 'details':
        Get.toNamed(AppRoutes.FINANCE_BUDGETS_DETAILS, arguments: budget);
        break;
      case 'edit':
        Get.toNamed(AppRoutes.FINANCE_BUDGETS_EDIT, arguments: budget);
        break;
      case 'delete':
        _showDeleteConfirmation(budget);
        break;
    }
  }

  void _showDeleteConfirmation(BudgetModel budget) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Êtes-vous sûr de vouloir supprimer ${budget.typeLabel.toLowerCase()} "${budget.name}" ?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cette action est irréversible.',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                      ),
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
          TextButton(
            onPressed: () async {
              Get.back();
              final success = await controller.deleteBudget(budget.id, budget.type);
              // Pas besoin de Get.back() car on reste sur la liste
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  Color _getBudgetColor(BudgetModel budget) {
    if (budget.color != null) {
      switch (budget.color) {
        case 'primary': return AppColors.primary;
        case 'secondary': return AppColors.secondary;
        case 'success': return AppColors.success;
        case 'warning': return AppColors.warning;
        case 'error': return AppColors.error;
        case 'purple': return Colors.purple;
        case 'orange': return Colors.orange;
        case 'teal': return Colors.teal;
        default: return AppColors.primary;
      }
    }
    return budget.isObjective ? AppColors.success : AppColors.primary;
  }

  IconData _getBudgetIcon(BudgetModel budget) {
    if (budget.icon != null) {
      switch (budget.icon) {
        case 'savings': return Icons.savings;
        case 'home': return Icons.home;
        case 'car': return Icons.directions_car;
        case 'vacation': return Icons.beach_access;
        case 'shopping': return Icons.shopping_cart;
        case 'food': return Icons.restaurant;
        case 'health': return Icons.local_hospital;
        case 'education': return Icons.school;
        default: return Icons.account_balance_wallet;
      }
    }
    return budget.isObjective ? Icons.flag : Icons.account_balance_wallet;
  }
}