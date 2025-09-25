import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/finance_controller.dart';
import '../../controllers/automation_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/account_model.dart';
import '../../models/transaction_model.dart';
import 'automation/automation_dashboard_page.dart';

class FinanceOverviewPage extends GetView<FinanceController> {
  const FinanceOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.hasError) {
        return _buildErrorView();
      }

      if (controller.isLoading && controller.accounts.isEmpty) {
        return _buildLoadingView();
      }

      return RefreshIndicator(
        onRefresh: controller.refreshAllData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 24),
              _buildWealthSummary(),
              const SizedBox(height: 24),
              _buildQuickStats(),
              const SizedBox(height: 24),
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildAutomationSection(),
              const SizedBox(height: 24),
              _buildAccountsPreview(),
              const SizedBox(height: 24),
              _buildRecentTransactions(),
            ],
          ),
        ),
      );
    });
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => controller.retryInitialization(),
                  child: const Text('Réessayer'),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Retour'),
                ),
              ],
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
          Text('Chargement des données financières...'),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.secondary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gestion Financière',
                        style: Get.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Suivez vos comptes, transactions et budgets',
                        style: Get.textTheme.bodyMedium?.copyWith(
                          color: AppColors.hint,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Obx(() => Text(
                      'Patrimoine total: ${controller.totalWealth.toStringAsFixed(0)} FCFA',
                      style: Get.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWealthSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Patrimoine Total',
                  style: Get.textTheme.titleMedium?.copyWith(
                    color: AppColors.hint,
                  ),
                ),
                Icon(
                  Icons.trending_up,
                  color: AppColors.success,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Obx(() => Text(
              '${controller.totalWealth.toStringAsFixed(0)} FCFA',
              style: Get.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            )),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMiniStat(
                    'Revenus ce mois',
                    '${controller.monthlyIncome.toStringAsFixed(0)} FCFA',
                    AppColors.success,
                    Icons.arrow_upward,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMiniStat(
                    'Dépenses ce mois',
                    '${controller.monthlyExpense.toStringAsFixed(0)} FCFA',
                    AppColors.error,
                    Icons.arrow_downward,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: Get.textTheme.bodySmall?.copyWith(
                color: AppColors.hint,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Solde Net',
            '${controller.netFlow.toStringAsFixed(0)} FCFA',
            controller.netFlow >= 0 ? AppColors.success : AppColors.error,
            controller.netFlow >= 0 ? Icons.trending_up : Icons.trending_down,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Obx(() => _buildStatCard(
            'Comptes',
            '${controller.accounts.length}',
            AppColors.secondary,
            Icons.account_balance_wallet,
          )),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Obx(() => _buildStatCard(
            'Transactions',
            '${controller.recentTransactions.length}',
            AppColors.primary,
            Icons.receipt_long,
          )),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
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

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions Rapides',
          style: Get.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Ajouter Revenu',
                Icons.add_circle_outline,
                AppColors.success,
                () => _addTransaction(TransactionType.income),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Ajouter Dépense',
                Icons.remove_circle_outline,
                AppColors.error,
                () => _addTransaction(TransactionType.expense),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Transfert',
                Icons.swap_horiz,
                AppColors.primary,
                () => _addTransaction(TransactionType.transfer),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Nouveau Compte',
                Icons.account_balance,
                AppColors.secondary,
                () => _addAccount(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: Get.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAutomationSection() {
    return GetBuilder<AutomationController>(
      init: AutomationController(),
      builder: (automationController) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_fix_high, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Automatisations',
                      style: Get.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Get.to(() => const AutomationDashboardPage()),
                      child: const Text('Voir tout'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (automationController.hasError) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: AppColors.error, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Erreur lors du chargement des automatisations',
                            style: TextStyle(color: AppColors.error, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildAutomationStat(
                          'En attente',
                          automationController.totalPendingAutomations.toString(),
                          Icons.schedule,
                          AppColors.secondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildAutomationStat(
                          'Aujourd\'hui',
                          automationController.automationsToday.toString(),
                          Icons.today,
                          AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildAutomationStat(
                          'Montant total',
                          '${automationController.totalPendingAmount.toStringAsFixed(0)} FCFA',
                          Icons.monetization_on,
                          AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: automationController.isExecuting
                              ? null
                              : () => automationController.executeAllAutomations(showProgress: false),
                          icon: automationController.isExecuting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.play_arrow),
                          label: const Text('Exécuter'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Get.to(() => const AutomationDashboardPage()),
                          icon: const Icon(Icons.settings),
                          label: const Text('Gérer'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAutomationStat(String label, String value, IconData icon, Color color) {
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
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: AppColors.hint,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountsPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mes Comptes',
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => _viewAllAccounts(),
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.accounts.isEmpty) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 48,
                      color: AppColors.hint,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Aucun compte trouvé',
                      style: Get.textTheme.titleMedium?.copyWith(
                        color: AppColors.hint,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Créez votre premier compte pour commencer',
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: AppColors.hint,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: controller.accounts.take(3).map((account) => _buildAccountCard(account)).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildAccountCard(AccountModel account) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.secondary.withOpacity(0.1),
          child: Icon(
            _getAccountIcon(account.type),
            color: AppColors.secondary,
          ),
        ),
        title: Text(
          account.name,
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(account.typeDisplayName),
        trailing: Text(
          '${account.currentBalance.toStringAsFixed(0)} FCFA',
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: account.currentBalance >= 0 ? AppColors.success : AppColors.error,
          ),
        ),
        onTap: () => _viewAccountDetails(account),
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
            Text(
              'Transactions Récentes',
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => _viewAllTransactions(),
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.recentTransactions.isEmpty) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 48,
                      color: AppColors.hint,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Aucune transaction',
                      style: Get.textTheme.titleMedium?.copyWith(
                        color: AppColors.hint,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vos transactions apparaîtront ici',
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: AppColors.hint,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: controller.recentTransactions
                .take(5)
                .map((transaction) => _buildTransactionCard(transaction))
                .toList(),
          );
        }),
      ],
    );
  }

  Widget _buildTransactionCard(TransactionModel transaction) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? AppColors.success : AppColors.error;
    final icon = isIncome ? Icons.arrow_downward : Icons.arrow_upward;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          transaction.title,
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${transaction.statusDisplayName} • ${_formatDate(transaction.transactionDate)}',
        ),
        trailing: Text(
          '${isIncome ? '+' : '-'}${transaction.amount.toStringAsFixed(0)} FCFA',
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        onTap: () => _viewTransactionDetails(transaction),
      ),
    );
  }

  IconData _getAccountIcon(AccountType type) {
    switch (type) {
      case AccountType.checking:
        return Icons.account_balance;
      case AccountType.savings:
        return Icons.savings;
      case AccountType.cash:
        return Icons.money;
      case AccountType.credit:
        return Icons.credit_card;
      case AccountType.virtual:
        return Icons.account_balance_wallet;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Action methods
  void _addTransaction(TransactionType type) {
    Get.toNamed('/finance/transactions/create', arguments: {'type': type});
  }

  void _addAccount() {
    Get.toNamed('/finance/accounts/create');
  }

  void _viewAllAccounts() {
    Get.toNamed('/finance/accounts');
  }

  void _viewAllTransactions() {
    Get.toNamed('/finance/transactions');
  }

  void _viewAccountDetails(AccountModel account) {
    Get.toNamed('/finance/accounts/details', arguments: {'account': account});
  }

  void _viewTransactionDetails(TransactionModel transaction) {
    Get.toNamed('/finance/transactions/details', arguments: {'transaction': transaction});
  }
}