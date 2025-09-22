import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/finance_controller.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../models/transaction_model.dart';
import '../../../models/currency.dart';
import '../../../../../routes/app_pages.dart';

class TransactionsList extends GetView<FinanceController> {
  const TransactionsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: _buildTransactionsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.FINANCE_ADD_TRANSACTION),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        border: Border(
          bottom: BorderSide(
            color: AppColors.grey200,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtres',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.grey800,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Tous', true, () {}),
                const SizedBox(width: 8),
                _buildFilterChip('Revenus', false, () {}),
                const SizedBox(width: 8),
                _buildFilterChip('Dépenses', false, () {}),
                const SizedBox(width: 8),
                _buildFilterChip('Transferts', false, () {}),
                const SizedBox(width: 8),
                _buildFilterChip('Ce mois', false, () {}),
                const SizedBox(width: 8),
                _buildFilterChip('Cette semaine', false, () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.grey600,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    return Obx(() {
      final transactions = controller.transactions;

      if (transactions.isEmpty) {
        return _buildEmptyState();
      }

      // Group transactions by date
      final groupedTransactions = _groupTransactionsByDate(transactions);

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: groupedTransactions.length,
        itemBuilder: (context, index) {
          final entry = groupedTransactions.entries.elementAt(index);
          final date = entry.key;
          final dayTransactions = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateHeader(date, dayTransactions),
              const SizedBox(height: 12),
              ...dayTransactions.map((transaction) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildTransactionCard(transaction),
              )),
              const SizedBox(height: 16),
            ],
          );
        },
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 80,
              color: AppColors.grey400,
            ),
            const SizedBox(height: 24),
            Text(
              'Aucune transaction',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.grey700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Commencez à enregistrer vos transactions\npour suivre vos finances',
              style: TextStyle(
                color: AppColors.grey600,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.FINANCE_ADD_TRANSACTION),
              icon: const Icon(Icons.add),
              label: const Text('Ajouter une transaction'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateHeader(DateTime date, List<TransactionModel> transactions) {
    final total = transactions.fold<double>(0.0, (sum, transaction) {
      switch (transaction.type) {
        case TransactionType.income:
          return sum + transaction.amount;
        case TransactionType.expense:
          return sum - transaction.amount;
        case TransactionType.transfer:
          return sum; // Les transferts n'affectent pas le total
        default:
          return sum;
      }
    });

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _formatDateHeader(date),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.grey800,
            ),
          ),
          Text(
            '${total >= 0 ? '+' : ''}${Currency.defaultCurrency.formatAmount(total.abs())}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: total >= 0 ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(TransactionModel transaction) {
    final isIncome = transaction.type == TransactionType.income;
    final isExpense = transaction.type == TransactionType.expense;
    final isTransfer = transaction.type == TransactionType.transfer;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackWithOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getTransactionColor(transaction.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getTransactionIcon(transaction.type),
                  color: _getTransactionColor(transaction.type),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (transaction.description != null && transaction.description!.isNotEmpty)
                      Text(
                        transaction.description!,
                        style: TextStyle(
                          color: AppColors.grey600,
                          fontSize: 14,
                        ),
                      ),
                    Text(
                      _formatTransactionTime(transaction.date),
                      style: TextStyle(
                        color: AppColors.grey500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isIncome ? '+' : isExpense ? '-' : ''}${transaction.currency.formatAmount(transaction.amount)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getTransactionColor(transaction.type),
                    ),
                  ),
                  if (isTransfer && transaction.toAccountId != null)
                    Text(
                      'Transfert',
                      style: TextStyle(
                        color: AppColors.grey600,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ],
          ),
          if (transaction.categoryId != null || transaction.accountId.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  if (transaction.accountId.isNotEmpty) ...[
                    _buildInfoChip(
                      Icons.account_balance_wallet,
                      _getAccountName(transaction.accountId),
                      AppColors.grey600,
                    ),
                    if (transaction.categoryId != null) const SizedBox(width: 8),
                  ],
                  if (transaction.categoryId != null)
                    _buildInfoChip(
                      Icons.category,
                      _getCategoryName(transaction.categoryId!),
                      AppColors.primary,
                    ),
                  if (isTransfer && transaction.toAccountId != null) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 16, color: AppColors.grey500),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      Icons.account_balance_wallet,
                      _getAccountName(transaction.toAccountId!),
                      AppColors.grey600,
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
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

  Map<DateTime, List<TransactionModel>> _groupTransactionsByDate(List<TransactionModel> transactions) {
    final Map<DateTime, List<TransactionModel>> grouped = {};

    for (final transaction in transactions) {
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );

      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(transaction);
    }

    // Sort by date (most recent first)
    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return Map.fromEntries(sortedEntries);
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Aujourd\'hui';
    } else if (dateOnly == yesterday) {
      return 'Hier';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTransactionTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getTransactionColor(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return AppColors.success;
      case TransactionType.expense:
        return AppColors.error;
      case TransactionType.transfer:
        return AppColors.warning;
      default:
        return AppColors.grey600;
    }
  }

  IconData _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return Icons.trending_up;
      case TransactionType.expense:
        return Icons.trending_down;
      case TransactionType.transfer:
        return Icons.swap_horiz;
      default:
        return Icons.receipt;
    }
  }

  String _getAccountName(String accountId) {
    final account = controller.accounts.firstWhereOrNull((acc) => acc.id == accountId);
    return account?.name ?? 'Compte inconnu';
  }

  String _getCategoryName(String categoryId) {
    final category = controller.categories.firstWhereOrNull((cat) => cat.id == categoryId);
    return category?.name ?? 'Non catégorisé';
  }
}