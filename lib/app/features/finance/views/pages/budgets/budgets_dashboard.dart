import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../routes/app_pages.dart';
import '../../../controllers/budgets_controller.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../models/budget_model.dart';

class BudgetsDashboard extends GetView<BudgetsController> {
  const BudgetsDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsSection(),
            const SizedBox(height: 24),
            _buildQuickActions(),
            const SizedBox(height: 24),
            _buildActiveBudgets(),
            const SizedBox(height: 24),
            _buildActiveObjectives(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.dashboard,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vue d\'ensemble',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Budgets & Objectifs',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Obx(() => Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Budgets',
                  '${controller.budgets.length}',
                  '${controller.activeBudgets.length} actifs',
                  Icons.account_balance_wallet,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Objectifs',
                  '${controller.objectives.length}',
                  '${controller.activeObjectives.length} actifs',
                  Icons.flag,
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions Rapides',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.grey800,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Nouveau Budget',
                'Gérer vos dépenses',
                Icons.account_balance_wallet,
                AppColors.primary,
                () => Get.toNamed('/finance/budgets/create'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                'Nouvel Objectif',
                'Atteindre vos rêves',
                Icons.flag,
                AppColors.success,
                () => Get.toNamed('/finance/budgets/create'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Voir Tous les Budgets',
                'Gérer vos budgets',
                Icons.list,
                AppColors.secondary,
                () => Get.toNamed(AppRoutes.FINANCE_BUDGETS_LIST),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                'Statistiques',
                'Analyser vos données',
                Icons.analytics,
                AppColors.warning,
                () => Get.toNamed(AppRoutes.FINANCE_BUDGETS_STATS),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: AppColors.grey600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveBudgets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Budgets Actifs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.grey800,
              ),
            ),
            TextButton(
              onPressed: () => Get.toNamed('/finance/budgets/list'),
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          final activeBudgets = controller.activeBudgets.take(3).toList();

          if (activeBudgets.isEmpty) {
            return _buildEmptySection(
              'Aucun budget actif',
              'Créez votre premier budget pour mieux gérer vos dépenses',
              Icons.account_balance_wallet,
              () => Get.toNamed('/finance/budgets/create'),
            );
          }

          return Column(
            children: activeBudgets.map((budget) =>
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildBudgetPreview(budget),
              )
            ).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildActiveObjectives() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Objectifs Actifs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.grey800,
              ),
            ),
            TextButton(
              onPressed: () => Get.toNamed('/finance/budgets/list'),
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          final activeObjectives = controller.activeObjectives.take(3).toList();

          if (activeObjectives.isEmpty) {
            return _buildEmptySection(
              'Aucun objectif actif',
              'Créez votre premier objectif pour atteindre vos rêves',
              Icons.flag,
              () => Get.toNamed('/finance/budgets/create'),
            );
          }

          return Column(
            children: activeObjectives.map((objective) =>
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildBudgetPreview(objective),
              )
            ).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildEmptySection(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.adaptiveEmptyStateBackground(Get.context!),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.adaptiveEmptyStateBorder(Get.context!)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: AppColors.grey500),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.grey700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: AppColors.grey600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onTap,
            child: const Text('Créer maintenant'),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetPreview(BudgetModel budget) {
    return Container(
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
                    Text(
                      budget.progressText,
                      style: TextStyle(
                        color: AppColors.grey600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${budget.spentPercentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: budget.isOverBudget ? AppColors.error : _getBudgetColor(budget),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: budget.spentPercentage / 100,
            backgroundColor: AppColors.grey200,
            valueColor: AlwaysStoppedAnimation<Color>(
              budget.isOverBudget ? AppColors.error : _getBudgetColor(budget),
            ),
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
        case 'directions_car': return Icons.directions_car;
        case 'beach_access': return Icons.beach_access;
        case 'shopping_cart': return Icons.shopping_cart;
        case 'restaurant': return Icons.restaurant;
        case 'local_gas_station': return Icons.local_gas_station;
        case 'health_and_safety': return Icons.health_and_safety;
        case 'school': return Icons.school;
        case 'flag': return Icons.flag;
        default: return Icons.account_balance_wallet;
      }
    }
    return budget.isObjective ? Icons.flag : Icons.account_balance_wallet;
  }
}