import 'package:cothia_app/app/features/finance/models/account_model.dart';
import 'package:cothia_app/app/features/finance/models/budget_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/finance_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/theme_switcher.dart';
import '../models/transaction_model.dart';

class FinanceView extends GetView<FinanceController> {
  const FinanceView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance'),
        centerTitle: true,
        actions: const [
          ThemeSwitcher(),
          SizedBox(width: 16),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFinancialSummary(),
                const SizedBox(height: 24),
                _buildQuickActions(),
                const SizedBox(height: 24),
                _buildAccountsOverview(),
                const SizedBox(height: 24),
                _buildRecentTransactions(),
                const SizedBox(height: 24),
                _buildBudgetsOverview(),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.goToAddTransaction,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFinancialSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Solde Total',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => Text(
                controller.totalBalanceFormatted,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Revenus',
                  controller.monthlyIncomeFormatted,
                  Icons.trending_up,
                  Colors.white70,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Dépenses',
                  controller.monthlyExpensesFormatted,
                  Icons.trending_down,
                  Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, String amount, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions rapides',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Ajouter Revenu',
                Icons.add_circle_outline,
                AppColors.success,
                controller.goToAddTransaction,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Ajouter Dépense',
                Icons.remove_circle_outline,
                AppColors.error,
                controller.goToAddTransaction,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Transfert',
                Icons.swap_horiz,
                AppColors.primary,
                controller.goToTransfer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Nouveau Compte',
                Icons.account_balance,
                AppColors.secondary,
                controller.goToAddAccount,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
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
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountsOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mes Comptes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: controller.goToAccounts,
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.accounts.isEmpty) {
            return _buildEmptyState(
              'Aucun compte',
              'Créez votre premier compte pour commencer',
              Icons.account_balance_wallet,
              controller.goToAddAccount,
            );
          }

          return SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.accounts.length,
              itemBuilder: (context, index) {
                final account = controller.accounts[index];
                return Container(
                  width: 200,
                  height: 200,
                  margin: EdgeInsets.only(right: index < controller.accounts.length - 1 ? 12 : 0),
                  child: _buildAccountCard(account),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAccountCard(AccountModel account) {
    return Container(
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.more_vert,
                color: AppColors.grey500,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            account.name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            account.formattedBalance,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: account.balance >= 0 ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
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
              onPressed: () => Get.toNamed('/finance/add-transaction'),
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.recentTransactions.isEmpty) {
            return _buildEmptyState(
              'Aucune transaction',
              'Commencez par ajouter une transaction',
              Icons.receipt_long,
              controller.goToAddTransaction,
            );
          }

          return Column(
            children: controller.recentTransactions
                .map((transaction) => _buildTransactionItem(transaction))
                .toList(),
          );
        }),
      ],
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

  Widget _buildBudgetsOverview() {
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
              onPressed: controller.goToBudgets,
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          final activeBudgets = controller.getActiveBudgets();

          if (activeBudgets.isEmpty) {
            return _buildEmptyState(
              'Aucun budget actif',
              'Créez un budget pour mieux gérer vos dépenses',
              Icons.pie_chart,
              controller.goToAddBudget,
            );
          }

          return Column(
            children: activeBudgets.take(3).map((budget) => _buildBudgetItem(budget)).toList(),
          );
        }),
      ],
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
              Text(
                '${budget.spentPercentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: budget.isOverBudget ? AppColors.error : AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${budget.formattedSpent} / ${budget.formattedAmount}',
            style: TextStyle(
              color: AppColors.grey600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: budget.spentPercentage / 100,
            backgroundColor: AppColors.grey200,
            valueColor: AlwaysStoppedAnimation<Color>(
              budget.isOverBudget ? AppColors.error : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: AppColors.grey500),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
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
            child: const Text('Commencer'),
          ),
        ],
      ),
    );
  }
}