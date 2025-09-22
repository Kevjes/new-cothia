import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/finance_controller.dart';
import '../../models/transaction_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/shimmer_widget.dart';
import '../../../../routes/app_pages.dart';

class TransactionsSection extends GetView<FinanceController> {
  const TransactionsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Transactions récentes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.FINANCE_TRANSACTIONS),
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isLoading) {
            return _buildLoadingTransactions();
          }

          if (controller.recentTransactions.isEmpty) {
            return _buildEmptyState();
          }

          return _buildTransactionsList();
        }),
      ],
    );
  }

  Widget _buildLoadingTransactions() {
    return Column(
      children: List.generate(
        3,
        (index) => const ShimmerCard(),
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
          Icon(Icons.receipt_long, size: 48, color: AppColors.grey500),
          const SizedBox(height: 16),
          Text(
            'Aucune transaction',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.grey700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Commencez par ajouter une transaction',
            style: TextStyle(
              color: AppColors.grey600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Get.toNamed(AppRoutes.FINANCE_ADD_TRANSACTION),
            child: const Text('Ajouter une transaction'),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    return Column(
      children: controller.recentTransactions
          .map((transaction) => _buildTransactionItem(transaction))
          .toList(),
    );
  }

  Widget _buildTransactionItem(TransactionModel transaction) {
    final category = controller.categories.firstWhereOrNull((c) => c.id == transaction.categoryId);
    late IconData icon;
    late Color color;

    switch (transaction.type) {
      case TransactionType.income:
        icon = Icons.trending_up;
        color = AppColors.success;
        break;
      case TransactionType.expense:
        icon = Icons.trending_down;
        color = AppColors.error;
        break;
      case TransactionType.transfer:
        icon = Icons.swap_horiz;
        color = AppColors.primary;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (category != null)
                  Text(
                    category.name,
                    style: TextStyle(
                      color: AppColors.grey600,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            transaction.displayAmount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}