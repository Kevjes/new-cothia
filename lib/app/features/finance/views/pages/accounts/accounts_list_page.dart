import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/finance_controller.dart';
import '../../../controllers/automation_controller.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../models/account_model.dart';
import 'account_create_page.dart';
import 'account_details_page.dart';

class AccountsListPage extends GetView<FinanceController> {
  const AccountsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialiser le controller d'automatisation
    final automationController = Get.put(AutomationController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mes Comptes'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.refreshAllData();
              automationController.loadRules();
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.hasError) {
          return _buildErrorView();
        }

        if (controller.isLoading && controller.accounts.isEmpty) {
          return _buildLoadingView();
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.refreshAllData();
            await automationController.loadRules();
          },
          child: Column(
            children: [
              _buildStatsHeader(),
              Expanded(
                child: controller.accounts.isEmpty
                    ? _buildEmptyState()
                    : _buildAccountsGroupedByType(automationController),
              ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreateAccount(),
        backgroundColor: AppColors.secondary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nouveau', style: TextStyle(color: Colors.white)),
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
          Text('Chargement des comptes...'),
        ],
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
              'Total Comptes',
              '${controller.accounts.length}',
              AppColors.secondary,
              Icons.account_balance,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Solde Total',
              '${controller.totalWealth.toStringAsFixed(0)} FCFA',
              controller.totalWealth >= 0 ? AppColors.success : AppColors.error,
              Icons.account_balance_wallet,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 80,
              color: AppColors.hint,
            ),
            const SizedBox(height: 24),
            Text(
              'Aucun compte trouvé',
              style: Get.textTheme.headlineSmall?.copyWith(
                color: AppColors.hint,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Créez votre premier compte pour commencer à gérer vos finances',
              style: Get.textTheme.bodyMedium?.copyWith(
                color: AppColors.hint,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _navigateToCreateAccount(),
              icon: const Icon(Icons.add),
              label: const Text('Créer mon premier compte'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountsGroupedByType(AutomationController automationController) {
    // Séparer les comptes favoris et les autres
    final favoriteAccounts = controller.accounts.where((a) => a.isFavorite).toList();
    final regularAccounts = controller.accounts.where((a) => !a.isFavorite).toList();

    // Grouper les comptes réguliers par type
    final Map<AccountType, List<AccountModel>> accountsByType = {};
    for (final account in regularAccounts) {
      if (!accountsByType.containsKey(account.type)) {
        accountsByType[account.type] = [];
      }
      accountsByType[account.type]!.add(account);
    }

    // Ordre d'affichage des types
    final typeOrder = [
      AccountType.checking,
      AccountType.savings,
      AccountType.cash,
      AccountType.credit,
      AccountType.virtual,
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // Section des favoris
        if (favoriteAccounts.isNotEmpty) ...[
          _buildFavoritesSection(favoriteAccounts, automationController),
          const SizedBox(height: 16),
        ],
        // Sections par type
        ...typeOrder.map((type) {
          final accounts = accountsByType[type];
          if (accounts == null || accounts.isEmpty) {
            return const SizedBox.shrink();
          }
          return _buildAccountTypeSection(type, accounts, automationController);
        }),
      ],
    );
  }

  Widget _buildFavoritesSection(
    List<AccountModel> accounts,
    AutomationController automationController,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            children: [
              Icon(
                Icons.star,
                color: Colors.amber,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Favoris',
                style: Get.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        ...accounts.map((account) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildCompactAccountCard(account, automationController),
            )),
        const Divider(height: 24),
      ],
    );
  }

  Widget _buildAccountTypeSection(
    AccountType type,
    List<AccountModel> accounts,
    AutomationController automationController,
  ) {
    // Calculer le solde total pour ce type
    final totalBalance = accounts.fold<double>(
      0,
      (sum, account) => sum + account.currentBalance,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Row(
            children: [
              Icon(
                _getAccountTypeIcon(type),
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getAccountTypeName(type),
                      style: Get.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${accounts.length} compte${accounts.length > 1 ? 's' : ''} • ${totalBalance.toStringAsFixed(0)} FCFA',
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: AppColors.hint,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ...accounts.map((account) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildCompactAccountCard(account, automationController),
            )),
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildCompactAccountCard(
    AccountModel account,
    AutomationController automationController,
  ) {
    final balanceColor = account.currentBalance >= 0 ? AppColors.success : AppColors.error;

    // Compter les automatisations liées à ce compte
    final relatedRules = automationController.rules.where((rule) {
      return rule.action.sourceAccountId == account.id ||
          rule.action.destinationAccountId == account.id;
    }).toList();

    final hasAutomations = relatedRules.isNotEmpty;
    final activeAutomations = relatedRules.where((r) => r.isActive).length;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToAccountDetails(account),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Icône du compte
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getAccountIcon(account.type),
                  color: AppColors.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // Infos du compte
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (account.isFavorite) ...[
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: Text(
                            account.name,
                            style: Get.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hasAutomations)
                          Icon(
                            Icons.bolt,
                            size: 14,
                            color: AppColors.primary.withValues(alpha: 0.7),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      account.typeDisplayName,
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: AppColors.hint,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // Solde
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${account.currentBalance.toStringAsFixed(0)} FCFA',
                    style: Get.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: balanceColor,
                    ),
                  ),
                  if (hasAutomations) ...[
                    const SizedBox(height: 2),
                    Text(
                      '$activeAutomations règle${activeAutomations > 1 ? 's' : ''}',
                      style: Get.textTheme.labelSmall?.copyWith(
                        color: AppColors.primary.withValues(alpha: 0.7),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.hint,
              ),
            ],
          ),
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
        return Icons.payments;
      case AccountType.credit:
        return Icons.credit_card;
      case AccountType.virtual:
        return Icons.account_balance_wallet;
    }
  }

  IconData _getAccountTypeIcon(AccountType type) {
    return _getAccountIcon(type);
  }

  String _getAccountTypeName(AccountType type) {
    switch (type) {
      case AccountType.checking:
        return 'Comptes Courants';
      case AccountType.savings:
        return 'Comptes Épargne';
      case AccountType.cash:
        return 'Espèces';
      case AccountType.credit:
        return 'Cartes de Crédit';
      case AccountType.virtual:
        return 'Comptes Virtuels';
    }
  }

  void _navigateToCreateAccount() {
    Get.to(() => const AccountCreatePage());
  }

  void _navigateToAccountDetails(AccountModel account) {
    Get.to(() => AccountDetailsPage(account: account));
  }
}
