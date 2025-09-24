import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/finance_controller.dart';
import '../../../controllers/transactions_controller.dart';
import '../../../controllers/accounts_controller.dart';
import '../../../controllers/objectives_controller.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/custom_dropdown.dart';

class FinanceAnalyticsPage extends StatefulWidget {
  const FinanceAnalyticsPage({super.key});

  @override
  State<FinanceAnalyticsPage> createState() => _FinanceAnalyticsPageState();
}

class _FinanceAnalyticsPageState extends State<FinanceAnalyticsPage> {
  String _selectedPeriod = 'month';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Analyses Financières'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAnalytics,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildPeriodSelector(),
          const SizedBox(height: 24),
          _buildOverviewCards(),
          const SizedBox(height: 24),
          _buildAccountsAnalytics(),
          const SizedBox(height: 24),
          _buildTransactionsAnalytics(),
          const SizedBox(height: 24),
          _buildObjectivesAnalytics(),
          const SizedBox(height: 24),
          _buildTrendsSection(),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Période d\'analyse',
              style: Get.textTheme.titleMedium?.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            CustomDropdown<String>(
              value: _selectedPeriod,
              items: const [
                DropdownMenuItem(value: 'week', child: Text('Cette semaine')),
                DropdownMenuItem(value: 'month', child: Text('Ce mois')),
                DropdownMenuItem(value: 'quarter', child: Text('Ce trimestre')),
                DropdownMenuItem(value: 'year', child: Text('Cette année')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPeriod = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards() {
    return GetBuilder<FinanceController>(
      builder: (financeController) {
        final totalWealth = financeController.totalWealth;
        final totalIncome = _calculateTotalIncome();
        final totalExpenses = _calculateTotalExpenses();
        final netFlow = totalIncome - totalExpenses;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vue d\'ensemble',
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Patrimoine Total',
                    '${totalWealth.toStringAsFixed(0)} FCFA',
                    Icons.account_balance_wallet,
                    AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    'Flux Net',
                    '${netFlow.toStringAsFixed(0)} FCFA',
                    netFlow >= 0 ? Icons.trending_up : Icons.trending_down,
                    netFlow >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Revenus',
                    '${totalIncome.toStringAsFixed(0)} FCFA',
                    Icons.arrow_downward,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    'Dépenses',
                    '${totalExpenses.toStringAsFixed(0)} FCFA',
                    Icons.arrow_upward,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildAccountsAnalytics() {
    return GetBuilder<AccountsController>(
      builder: (controller) {
        final accounts = controller.accounts;

        return Card(
          color: AppColors.surface,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Répartition des Comptes',
                  style: Get.textTheme.titleMedium?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (accounts.isEmpty)
                  const Center(
                    child: Text('Aucun compte disponible'),
                  )
                else
                  ...accounts.map((account) {
                    final total = accounts.fold(0.0, (sum, acc) => sum + acc.currentBalance);
                    final percentage = total > 0 ? (account.currentBalance / total * 100) : 0.0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                _getAccountIcon(account.type),
                                color: AppColors.secondary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  account.name,
                                  style: Get.textTheme.bodyMedium,
                                ),
                              ),
                              Text(
                                '${percentage.toStringAsFixed(1)}%',
                                style: Get.textTheme.bodySmall?.copyWith(
                                  color: AppColors.hint,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${account.currentBalance.toStringAsFixed(0)} FCFA',
                                style: Get.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: Colors.grey.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionsAnalytics() {
    return GetBuilder<TransactionsController>(
      builder: (controller) {
        final transactions = controller.transactions;
        final categoryStats = _calculateCategoryStats(transactions);

        return Card(
          color: AppColors.surface,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analyse des Transactions',
                  style: Get.textTheme.titleMedium?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTransactionTypeCard(
                        'Revenus',
                        transactions.where((t) => t.type.name == 'income').length,
                        _calculateTotalIncome(),
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTransactionTypeCard(
                        'Dépenses',
                        transactions.where((t) => t.type.name == 'expense').length,
                        _calculateTotalExpenses(),
                        Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (categoryStats.isNotEmpty) ...[
                  Text(
                    'Top Catégories',
                    style: Get.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...categoryStats.take(5).map((stat) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(stat['category'] ?? 'Non catégorisé'),
                          ),
                          Text(
                            '${stat['count']} trans.',
                            style: Get.textTheme.bodySmall?.copyWith(
                              color: AppColors.hint,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(stat['total'] as double).toStringAsFixed(0)} FCFA',
                            style: Get.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildObjectivesAnalytics() {
    return GetBuilder<ObjectivesController>(
      builder: (controller) {
        final stats = controller.objectivesStats;

        return Card(
          color: AppColors.surface,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progression des Objectifs',
                  style: Get.textTheme.titleMedium?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (stats.isEmpty)
                  const Center(child: Text('Aucune donnée d\'objectifs'))
                else ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildObjectiveCard(
                          'Total',
                          stats['totalObjectives']?.toString() ?? '0',
                          Icons.flag,
                          AppColors.secondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildObjectiveCard(
                          'Actifs',
                          stats['activeObjectives']?.toString() ?? '0',
                          Icons.play_arrow,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildObjectiveCard(
                          'Terminés',
                          stats['completedObjectives']?.toString() ?? '0',
                          Icons.check_circle,
                          Colors.green,
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
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progression globale',
                              style: Get.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${(stats['totalProgress'] ?? 0.0).toStringAsFixed(1)}%',
                              style: Get.textTheme.bodyMedium?.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: (stats['totalProgress'] ?? 0.0) / 100,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrendsSection() {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tendances',
              style: Get.textTheme.titleMedium?.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTrendItem('Épargne mensuelle', '+15%', Colors.green, Icons.trending_up),
            _buildTrendItem('Dépenses variables', '-8%', Colors.green, Icons.trending_down),
            _buildTrendItem('Objectifs atteints', '+25%', Colors.green, Icons.trending_up),
            _buildTrendItem('Revenus passifs', '+12%', Colors.green, Icons.trending_up),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.info, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Get.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Get.textTheme.bodySmall?.copyWith(
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTypeCard(String title, int count, double total, Color color) {
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
          Text(
            title,
            style: Get.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$count transactions',
            style: Get.textTheme.bodySmall?.copyWith(
              color: color.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${total.toStringAsFixed(0)} FCFA',
            style: Get.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectiveCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Get.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Get.textTheme.bodySmall?.copyWith(
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendItem(String title, String change, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Get.textTheme.bodyMedium,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              change,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _refreshAnalytics() {
    final financeController = Get.find<FinanceController>();
    final transactionsController = Get.find<TransactionsController>();
    final accountsController = Get.find<AccountsController>();
    final objectivesController = Get.find<ObjectivesController>();

    financeController.refreshAllData();
    transactionsController.loadTransactions();
    accountsController.loadAccounts();
    objectivesController.loadObjectives();
  }

  double _calculateTotalIncome() {
    final controller = Get.find<TransactionsController>();
    return controller.transactions
        .where((t) => t.type.name == 'income' && _isInSelectedPeriod(t.date))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double _calculateTotalExpenses() {
    final controller = Get.find<TransactionsController>();
    return controller.transactions
        .where((t) => t.type.name == 'expense' && _isInSelectedPeriod(t.date))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  List<Map<String, dynamic>> _calculateCategoryStats(List transactions) {
    final categoryMap = <String, Map<String, dynamic>>{};

    for (final transaction in transactions) {
      if (!_isInSelectedPeriod(transaction.date)) continue;

      final category = transaction.categoryId ?? 'Non catégorisé';
      if (!categoryMap.containsKey(category)) {
        categoryMap[category] = {
          'category': category,
          'count': 0,
          'total': 0.0,
        };
      }

      categoryMap[category]!['count']++;
      categoryMap[category]!['total'] += transaction.amount;
    }

    final stats = categoryMap.values.toList();
    stats.sort((a, b) => (b['total'] as double).compareTo(a['total'] as double));
    return stats;
  }

  bool _isInSelectedPeriod(DateTime date) {
    final now = DateTime.now();

    switch (_selectedPeriod) {
      case 'week':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return date.isAfter(weekStart.subtract(const Duration(days: 1)));
      case 'month':
        return date.year == now.year && date.month == now.month;
      case 'quarter':
        final quarter = ((now.month - 1) ~/ 3) + 1;
        final dateQuarter = ((date.month - 1) ~/ 3) + 1;
        return date.year == now.year && dateQuarter == quarter;
      case 'year':
        return date.year == now.year;
      default:
        return true;
    }
  }

  IconData _getAccountIcon(type) {
    return Icons.account_balance; // Simplified for now
  }
}