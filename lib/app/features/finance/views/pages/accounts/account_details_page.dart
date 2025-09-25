import 'package:cothia_app/app/core/utils/get_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/accounts_controller.dart';
import '../../../controllers/transactions_controller.dart';
import '../../../controllers/finance_controller.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../models/account_model.dart';
import '../../../models/transaction_model.dart';
import 'account_create_page.dart';
import '../transactions/transaction_create_page.dart';
import '../transactions/transactions_list_page.dart';

class AccountDetailsPage extends StatelessWidget {
  final AccountModel? account;

  const AccountDetailsPage({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    // Vérifier si le compte est null
    if (account == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Erreur'),
          centerTitle: true,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Compte non trouvé',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Le compte que vous cherchez n\'existe pas ou n\'a pas pu être chargé.'),
            ],
          ),
        ),
      );
    }

    final currentAccount = account!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(account!.name),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editAccount(),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  _showDeleteDialog();
                  break;
                case 'duplicate':
                  _duplicateAccount();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.copy, size: 20),
                    SizedBox(width: 8),
                    Text('Dupliquer'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAccountHeader(),
            const SizedBox(height: 24),
            _buildAccountInfo(),
            const SizedBox(height: 24),
            _buildBalanceHistory(),
            const SizedBox(height: 24),
            _buildQuickActions(),
            const SizedBox(height: 24),
            _buildRecentTransactions(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addTransaction(),
        backgroundColor: AppColors.secondary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Transaction', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildAccountHeader() {
    final balanceColor = account!.currentBalance >= 0 ? AppColors.success : AppColors.error;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: AppColors.secondary.withOpacity(0.1),
                  child: Icon(
                    _getAccountIcon(account!.type),
                    color: AppColors.secondary,
                    size: 35,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account!.name,
                        style: Get.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        account!.typeDisplayName,
                        style: Get.textTheme.bodyLarge?.copyWith(
                          color: AppColors.hint,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: balanceColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: balanceColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'Solde actuel',
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: AppColors.hint,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${account!.currentBalance.toStringAsFixed(0)} FCFA',
                    style: Get.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: balanceColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations du compte',
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Type de compte',
              account!.typeDisplayName,
              _getAccountIcon(account!.type),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Date de création',
              _formatDate(account!.createdAt),
              Icons.calendar_today,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Dernière modification',
              _formatDate(account!.updatedAt),
              Icons.update,
            ),
            if (account!.description != null && account!.description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Description',
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                account!.description!,
                style: Get.textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.hint),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Get.textTheme.bodySmall?.copyWith(
                  color: AppColors.hint,
                ),
              ),
              Text(
                value,
                style: Get.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceHistory() {
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
                  'Évolution du solde',
                  style: Get.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => _viewFullHistory(),
                  child: const Text('Voir tout'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.hint.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 48,
                      color: AppColors.hint,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Graphique d\'évolution',
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: AppColors.hint,
                      ),
                    ),
                    Text(
                      'Évolution du solde au fil du temps',
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: AppColors.hint,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions rapides',
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Ajouter Revenu',
                    Icons.add_circle_outline,
                    AppColors.success,
                    () => _addTransaction(isIncome: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'Ajouter Dépense',
                    Icons.remove_circle_outline,
                    AppColors.error,
                    () => _addTransaction(isIncome: false),
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
                    () => _transferMoney(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'Ajuster Solde',
                    Icons.tune,
                    AppColors.secondary,
                    () => _adjustBalance(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: Get.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    final controller = Get.find<FinanceController>();

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
                  'Transactions récentes',
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
            const SizedBox(height: 16),
            Obx(() {
              // Filtrer les transactions pour ce compte
              final accountTransactions = controller.recentTransactions
                  .where((t) => t.sourceAccountId == account!.id || t.destinationAccountId == account!.id)
                  .take(5)
                  .toList();

              if (accountTransactions.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(24),
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
                        style: Get.textTheme.bodyMedium?.copyWith(
                          color: AppColors.hint,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: accountTransactions.map((transaction) {
                  final isIncome = transaction.type.name == 'income';
                  final color = isIncome ? AppColors.success : AppColors.error;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: color.withOpacity(0.1),
                        child: Icon(
                          isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                          color: color,
                        ),
                      ),
                      title: Text(
                        transaction.title,
                        style: Get.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(_formatDate(transaction.transactionDate)),
                      trailing: Text(
                        '${isIncome ? '+' : '-'}${transaction.amount.toStringAsFixed(0)} FCFA',
                        style: Get.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            }),
          ],
        ),
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

  void _editAccount() {
    Get.to(() => AccountCreatePage(account: account));
  }

  void _addTransaction({bool? isIncome}) {
    Get.to(() => const TransactionCreatePage());
  }

  void _transferMoney() {
    _showTransferDialog();
  }

  void _adjustBalance() {
    _showAdjustBalanceDialog();
  }

  void _viewFullHistory() {
    _showAccountHistory();
  }

  void _viewAllTransactions() {
    final transactionsController = Get.put(TransactionsController());
    transactionsController.setAccountFilter(account);
    Get.to(() => const TransactionsListPage());
  }

  void _duplicateAccount() {
    final accountsController = Get.find<AccountsController>();
    accountsController.duplicateAccount(account!);
  }

  void _showDeleteDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Supprimer le compte'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer le compte "${account!.name}" ?\n\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => _deleteAccount(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    Get.back(); // Fermer le dialog
    final accountsController = Get.find<AccountsController>();
    final success = await accountsController.deleteAccount(account!.id);
    if (success) {
      Get.safeBack();
    }
  }

  void _showTransferDialog() {
    final accountsController = Get.find<AccountsController>();
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    AccountModel? selectedDestination;

    final availableAccounts = accountsController.accounts
        .where((a) => a.id != account!.id && a.isActive)
        .toList();

    if (availableAccounts.isEmpty) {
      Get.snackbar(
        'Info',
        'Aucun autre compte disponible pour le transfert',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Transfert d\'argent'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Depuis: ${account!.name}'),
              Text('Solde: ${account!.currentBalance.toStringAsFixed(0)} FCFA'),
              const SizedBox(height: 16),
              DropdownButtonFormField<AccountModel>(
                decoration: const InputDecoration(
                  labelText: 'Vers le compte',
                ),
                items: availableAccounts.map((acc) {
                  return DropdownMenuItem<AccountModel>(
                    value: acc,
                    child: Text(acc.name),
                  );
                }).toList(),
                onChanged: (value) => selectedDestination = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Montant',
                  suffixText: 'FCFA',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optionnelle)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedDestination != null && amountController.text.isNotEmpty) {
                final amount = double.tryParse(amountController.text);
                if (amount != null && amount > 0) {
                  Get.back();
                  accountsController.transferMoney(
                    account!.id,
                    selectedDestination!.id,
                    amount,
                    descriptionController.text,
                  );
                }
              }
            },
            child: const Text('Transférer'),
          ),
        ],
      ),
    );
  }

  void _showAdjustBalanceDialog() {
    final accountsController = Get.find<AccountsController>();
    final balanceController = TextEditingController(
      text: account!.currentBalance.toStringAsFixed(0),
    );
    final reasonController = TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Ajuster le solde'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Solde actuel: ${account!.currentBalance.toStringAsFixed(0)} FCFA'),
            const SizedBox(height: 16),
            TextFormField(
              controller: balanceController,
              decoration: const InputDecoration(
                labelText: 'Nouveau solde',
                suffixText: 'FCFA',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Raison de l\'ajustement',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final newBalance = double.tryParse(balanceController.text);
              if (newBalance != null && reasonController.text.isNotEmpty) {
                Get.back();
                accountsController.adjustBalance(
                  account!.id,
                  newBalance,
                  reasonController.text,
                );
              }
            },
            child: const Text('Ajuster'),
          ),
        ],
      ),
    );
  }

  void _showAccountHistory() {
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.surface,
        child: Container(
          width: Get.width * 0.9,
          height: Get.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Historique - ${account!.name}',
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
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: Get.find<AccountsController>().getAccountHistory(account!.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Erreur: ${snapshot.error}'),
                      );
                    }

                    final history = snapshot.data ?? [];

                    if (history.isEmpty) {
                      return const Center(
                        child: Text('Aucun historique disponible'),
                      );
                    }

                    return ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final item = history[index];
                        final transaction = item['transaction'] as TransactionModel;
                        final balanceAfter = item['balanceAfter'] as double;
                        final amount = item['amount'] as double;

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: amount >= 0
                                ? AppColors.success.withOpacity(0.1)
                                : AppColors.error.withOpacity(0.1),
                            child: Icon(
                              amount >= 0 ? Icons.add : Icons.remove,
                              color: amount >= 0 ? AppColors.success : AppColors.error,
                            ),
                          ),
                          title: Text(transaction.title),
                          subtitle: Text(
                            '${transaction.transactionDate.day}/${transaction.transactionDate.month}/${transaction.transactionDate.year}',
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${amount >= 0 ? '+' : ''}${amount.toStringAsFixed(0)} FCFA',
                                style: TextStyle(
                                  color: amount >= 0 ? AppColors.success : AppColors.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Solde: ${balanceAfter.toStringAsFixed(0)} FCFA',
                                style: Get.textTheme.bodySmall?.copyWith(
                                  color: AppColors.hint,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}