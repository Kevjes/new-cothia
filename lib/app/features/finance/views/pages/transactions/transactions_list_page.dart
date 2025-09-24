import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/transactions_controller.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../models/transaction_model.dart';
import 'transaction_create_page.dart';
import 'transaction_details_page.dart';

class TransactionsListPage extends GetView<TransactionsController> {
  const TransactionsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transactions'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshAllData(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFiltersChips(),
          _buildStatsHeader(),
          Expanded(
            child: Obx(() {
              if (controller.hasError) {
                return _buildErrorView();
              }

              if (controller.isLoading && controller.recentTransactions.isEmpty) {
                return _buildLoadingView();
              }

              return RefreshIndicator(
                onRefresh: controller.refreshAllData,
                child: controller.recentTransactions.isEmpty
                    ? _buildEmptyState()
                    : _buildTransactionsList(),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreateTransaction(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Transaction', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildFiltersChips() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('Toutes', true, () {}),
          const SizedBox(width: 8),
          _buildFilterChip('Revenus', false, () {}),
          const SizedBox(width: 8),
          _buildFilterChip('Dépenses', false, () {}),
          const SizedBox(width: 8),
          _buildFilterChip('Transferts', false, () {}),
          const SizedBox(width: 8),
          _buildFilterChip('En attente', false, () {}),
          const SizedBox(width: 8),
          _buildFilterChip('Ce mois', false, () {}),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.hint,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildStatsHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Ce mois',
              '${controller.monthlyIncome.toStringAsFixed(0)} FCFA',
              AppColors.success,
              Icons.trending_up,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Dépenses',
              '${controller.monthlyExpense.toStringAsFixed(0)} FCFA',
              AppColors.error,
              Icons.trending_down,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Solde',
              '${controller.netFlow.toStringAsFixed(0)} FCFA',
              controller.netFlow >= 0 ? AppColors.success : AppColors.error,
              controller.netFlow >= 0 ? Icons.add_circle : Icons.remove_circle,
            ),
          ),
        ],
      ),
    );
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
              onPressed: () => controller.retryInitialization(),
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
          Text('Chargement des transactions...'),
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
              Icons.receipt_long_outlined,
              size: 80,
              color: AppColors.hint,
            ),
            const SizedBox(height: 24),
            Text(
              'Aucune transaction',
              style: Get.textTheme.headlineSmall?.copyWith(
                color: AppColors.hint,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Commencez à enregistrer vos revenus et dépenses',
              style: Get.textTheme.bodyMedium?.copyWith(
                color: AppColors.hint,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _navigateToCreateTransaction(),
              icon: const Icon(Icons.add),
              label: const Text('Première transaction'),
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

  Widget _buildTransactionsList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: controller.recentTransactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final transaction = controller.recentTransactions[index];
        return _buildTransactionCard(transaction);
      },
    );
  }

  Widget _buildTransactionCard(TransactionModel transaction) {
    final isIncome = transaction.type == TransactionType.income;
    final isTransfer = transaction.type == TransactionType.transfer;

    Color color;
    IconData icon;
    String prefix;

    if (isTransfer) {
      color = AppColors.primary;
      icon = Icons.swap_horiz;
      prefix = '';
    } else if (isIncome) {
      color = AppColors.success;
      icon = Icons.arrow_downward;
      prefix = '+';
    } else {
      color = AppColors.error;
      icon = Icons.arrow_upward;
      prefix = '-';
    }

    return Card(
      child: InkWell(
        onTap: () => _navigateToTransactionDetails(transaction),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: color.withOpacity(0.1),
                    child: Icon(icon, color: color),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.title,
                          style: Get.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (transaction.description != null &&
                            transaction.description!.isNotEmpty)
                          Text(
                            transaction.description!,
                            style: Get.textTheme.bodySmall?.copyWith(
                              color: AppColors.hint,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$prefix${transaction.amount.toStringAsFixed(0)} FCFA',
                        style: Get.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getStatusColor(transaction.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          transaction.statusDisplayName,
                          style: Get.textTheme.bodySmall?.copyWith(
                            color: _getStatusColor(transaction.status),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: AppColors.hint),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(transaction.transactionDate),
                    style: Get.textTheme.bodySmall?.copyWith(
                      color: AppColors.hint,
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (transaction.sourceAccountId != null || transaction.destinationAccountId != null) ...[
                    Icon(Icons.account_balance, size: 16, color: AppColors.hint),
                    const SizedBox(width: 4),
                    Text(
                      _getAccountName(transaction),
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: AppColors.hint,
                      ),
                    ),
                  ],
                ],
              ),
              if (transaction.status == TransactionStatus.pending) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _validateTransaction(transaction),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Valider'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.success,
                          side: BorderSide(color: AppColors.success),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _editTransaction(transaction),
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Modifier'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.validated:
        return AppColors.success;
      case TransactionStatus.pending:
        return AppColors.secondary;
      case TransactionStatus.planned:
        return AppColors.info;
      case TransactionStatus.cancelled:
        return AppColors.error;
    }
  }

  String _getAccountName(TransactionModel transaction) {
    if (transaction.type == TransactionType.transfer) {
      return 'Transfert';
    }

    final accountId = transaction.sourceAccountId ?? transaction.destinationAccountId;
    if (accountId == null) return 'Compte inconnu';

    final account = controller.accounts.where((a) => a.id == accountId).firstOrNull;
    return account?.name ?? 'Compte inconnu';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Aujourd\'hui';
    } else if (difference == 1) {
      return 'Hier';
    } else if (difference < 7) {
      return 'Il y a $difference jours';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showFilterDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.surface,
        child: Container(
          width: Get.width * 0.9,
          height: Get.height * 0.7,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filtres avancés',
                    style: Get.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Type de transaction',
                        style: Get.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          FilterChip(
                            label: const Text('Toutes'),
                            selected: controller.selectedTransactionType.value == null,
                            onSelected: (_) => controller.setTransactionTypeFilter(null),
                          ),
                          ...TransactionType.values.map((type) {
                            return FilterChip(
                              label: Text(type.displayName),
                              selected: controller.selectedTransactionType.value == type,
                              onSelected: (_) => controller.setTransactionTypeFilter(type),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Statut',
                        style: Get.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          FilterChip(
                            label: const Text('Tous'),
                            selected: controller.selectedTransactionStatus.value == null,
                            onSelected: (_) => controller.setTransactionStatusFilter(null),
                          ),
                          ...TransactionStatus.values.map((status) {
                            return FilterChip(
                              label: Text(status.displayName),
                              selected: controller.selectedTransactionStatus.value == status,
                              onSelected: (_) => controller.setTransactionStatusFilter(status),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Période',
                        style: Get.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          'all',
                          'today',
                          'week',
                          'month',
                          'year'
                        ].map((period) {
                          final labels = {
                            'all': 'Toutes',
                            'today': 'Aujourd\'hui',
                            'week': 'Cette semaine',
                            'month': 'Ce mois',
                            'year': 'Cette année',
                          };
                          return FilterChip(
                            label: Text(labels[period]!),
                            selected: controller.selectedPeriod.value == period,
                            onSelected: (_) => controller.setPeriodFilter(period),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      controller.clearAllFilters();
                      Get.back();
                    },
                    child: const Text('Réinitialiser'),
                  ),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Appliquer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToCreateTransaction() {
    Get.to(() => const TransactionCreatePage());
  }

  void _navigateToTransactionDetails(TransactionModel transaction) {
    Get.to(() => TransactionDetailsPage(transaction: transaction));
  }

  void _editTransaction(TransactionModel transaction) {
    Get.to(() => TransactionCreatePage(transaction: transaction));
  }

  Future<void> _validateTransaction(TransactionModel transaction) async {
    try {
      await controller.validateTransaction(transaction.id);
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de valider la transaction: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }
}