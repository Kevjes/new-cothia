import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/finance_controller.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../models/account_model.dart';
import 'account_create_page.dart';
import 'account_details_page.dart';

class AccountsListPage extends GetView<FinanceController> {
  const AccountsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mes Comptes'),
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
          return _buildErrorView();
        }

        if (controller.isLoading && controller.accounts.isEmpty) {
          return _buildLoadingView();
        }

        return RefreshIndicator(
          onRefresh: controller.refreshAllData,
          child: Column(
            children: [
              _buildStatsHeader(),
              Expanded(
                child: controller.accounts.isEmpty
                    ? _buildEmptyState()
                    : _buildAccountsList(),
              ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateAccount(),
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add, color: Colors.white),
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: Get.textTheme.titleMedium?.copyWith(
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

  Widget _buildAccountsList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: controller.accounts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final account = controller.accounts[index];
        return _buildAccountCard(account);
      },
    );
  }

  Widget _buildAccountCard(AccountModel account) {
    final balanceColor = account.currentBalance >= 0 ? AppColors.success : AppColors.error;

    return Card(
      child: InkWell(
        onTap: () => _navigateToAccountDetails(account),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.secondary.withOpacity(0.1),
                    child: Icon(
                      _getAccountIcon(account.type),
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.name,
                          style: Get.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          account.typeDisplayName,
                          style: Get.textTheme.bodySmall?.copyWith(
                            color: AppColors.hint,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${account.currentBalance.toStringAsFixed(0)} FCFA',
                        style: Get.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: balanceColor,
                        ),
                      ),
                      Text(
                        'Solde actuel',
                        style: Get.textTheme.bodySmall?.copyWith(
                          color: AppColors.hint,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (account.description != null && account.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  account.description!,
                  style: Get.textTheme.bodyMedium?.copyWith(
                    color: AppColors.hint,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _editAccount(account),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Modifier'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.secondary,
                        side: BorderSide(color: AppColors.secondary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _navigateToAccountDetails(account),
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text('Détails'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
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
        return Icons.money;
      case AccountType.credit:
        return Icons.credit_card;
      case AccountType.virtual:
        return Icons.account_balance_wallet;
    }
  }

  void _navigateToCreateAccount() {
    Get.to(() => const AccountCreatePage());
  }

  void _navigateToAccountDetails(AccountModel account) {
    Get.to(() => AccountDetailsPage(account: account));
  }

  void _editAccount(AccountModel account) {
    Get.to(() => AccountCreatePage(account: account));
  }
}