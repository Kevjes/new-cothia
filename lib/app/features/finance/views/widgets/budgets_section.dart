import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/finance_controller.dart';
import '../../models/budget_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/shimmer_widget.dart';
import '../../../../routes/app_pages.dart';

class BudgetsSection extends GetView<FinanceController> {
  const BudgetsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Budgets actifs',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.FINANCE_BUDGETS),
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isLoading) {
            return _buildLoadingBudgets();
          }

          final activeBudgets = controller.getActiveBudgets();

          if (activeBudgets.isEmpty) {
            return _buildEmptyState();
          }

          return _buildBudgetsList(activeBudgets);
        }),
      ],
    );
  }

  Widget _buildLoadingBudgets() {
    return Column(
      children: List.generate(
        2,
        (index) => const ShimmerCard(height: 100),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.adaptiveEmptyStateBackground(Get.context!),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.adaptiveEmptyStateBorder(Get.context!)),
      ),
      child: Column(
        children: [
          Icon(Icons.pie_chart, size: 48, color: AppColors.grey500),
          const SizedBox(height: 16),
          Text(
            'Aucun budget actif',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.grey700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Créez un budget pour mieux gérer vos dépenses',
            style: TextStyle(
              color: AppColors.grey600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Get.toNamed(AppRoutes.FINANCE_BUDGETS_CREATE),
            child: const Text('Créer un budget'),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetsList(List<BudgetModel> budgets) {
    return Column(
      children: budgets.take(3).map((budget) => _buildBudgetItem(budget)).toList(),
    );
  }

  Widget _buildBudgetItem(BudgetModel budget) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).cardColor,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                budget.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: budget.isOverBudget
                      ? AppColors.error.withOpacity(0.1)
                      : AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${budget.spentPercentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: budget.isOverBudget ? AppColors.error : AppColors.success,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${budget.formattedSpent} / ${budget.formattedAmount}',
                style: TextStyle(
                  color: AppColors.grey600,
                  fontSize: 14,
                ),
              ),
              if (budget.daysRemaining > 0)
                Text(
                  '${budget.daysRemaining} jour(s) restant(s)',
                  style: TextStyle(
                    color: AppColors.grey600,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (budget.spentPercentage / 100).clamp(0.0, 1.0),
            backgroundColor: AppColors.grey200,
            valueColor: AlwaysStoppedAnimation<Color>(
              budget.isOverBudget ? AppColors.error : AppColors.primary,
            ),
          ),
          if (budget.isOverBudget) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.warning,
                  color: AppColors.error,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Budget dépassé',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}