import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/finance_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/account_model.dart';
import '../../models/transaction_model.dart';
import 'accounts/accounts_list_page.dart';
import 'accounts/account_create_page.dart';
import 'accounts/account_details_page.dart';
import 'transactions/transactions_list_page.dart';
import 'transactions/transaction_create_page.dart';
import 'transactions/transaction_details_page.dart';

class FinanceDashboardPage extends GetView<FinanceController> {
  const FinanceDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Finance'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshAllData(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.hasError) {
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

        if (controller.isLoading && controller.accounts.isEmpty) {
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

        return RefreshIndicator(
          onRefresh: controller.refreshAllData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWealthSummary(),
                const SizedBox(height: 24),
                _buildQuickStats(),
                const SizedBox(height: 24),
                _buildQuickActions(),
                const SizedBox(height: 24),
                _buildAccountsPreview(),
                const SizedBox(height: 24),
                _buildRecentTransactions(),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuickAddMenu(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
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
              '${controller.totalWealth.toStringAsFixed(2)} €',
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
                    '${controller.monthlyIncome.toStringAsFixed(0)} €',
                    AppColors.success,
                    Icons.arrow_upward,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMiniStat(
                    'Dépenses ce mois',
                    '${controller.monthlyExpense.toStringAsFixed(0)} €',
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
            '${controller.netFlow.toStringAsFixed(0)} €',
            controller.netFlow >= 0 ? AppColors.success : AppColors.error,
            controller.netFlow >= 0 ? Icons.trending_up : Icons.trending_down,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Obx(() => _buildStatCard(
            'Comptes',
            '${controller.accounts.length}',
            AppColors.primary,
            Icons.account_balance_wallet,
          )),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Obx(() => _buildStatCard(
            'Transactions',
            '${controller.recentTransactions.length}',
            AppColors.secondary,
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
              onPressed: () => Get.to(() => const AccountsListPage()),
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
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(
            _getAccountIcon(account.type),
            color: AppColors.primary,
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
          '${account.currentBalance.toStringAsFixed(2)} €',
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: account.currentBalance >= 0 ? AppColors.success : AppColors.error,
          ),
        ),
        onTap: () => Get.to(() => AccountDetailsPage(account: account)),
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
              onPressed: () => Get.to(() => const TransactionsListPage()),
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
          '${isIncome ? '+' : '-'}${transaction.amount.toStringAsFixed(2)} €',
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        onTap: () => Get.to(() => TransactionDetailsPage(transaction: transaction)),
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

  void _showQuickAddMenu() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.hint,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Ajouter',
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.add_circle, color: AppColors.success),
              title: const Text('Ajouter un revenu'),
              onTap: () {
                Get.back();
                _addTransaction(TransactionType.income);
              },
            ),
            ListTile(
              leading: Icon(Icons.remove_circle, color: AppColors.error),
              title: const Text('Ajouter une dépense'),
              onTap: () {
                Get.back();
                _addTransaction(TransactionType.expense);
              },
            ),
            ListTile(
              leading: Icon(Icons.swap_horiz, color: AppColors.primary),
              title: const Text('Faire un transfert'),
              onTap: () {
                Get.back();
                _addTransaction(TransactionType.transfer);
              },
            ),
            ListTile(
              leading: Icon(Icons.account_balance, color: AppColors.secondary),
              title: const Text('Créer un compte'),
              onTap: () {
                Get.back();
                _addAccount();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _addTransaction(TransactionType type) {
    Get.to(() => const TransactionCreatePage());
  }

  void _addAccount() {
    Get.to(() => const AccountCreatePage());
  }
}