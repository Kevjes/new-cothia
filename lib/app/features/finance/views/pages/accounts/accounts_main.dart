import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/finance_controller.dart';
import '../../../models/account_model.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/shimmer_widget.dart';
import '../../../../../routes/app_pages.dart';

class AccountsMain extends GetView<FinanceController> {
  const AccountsMain({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Comptes'),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.FINANCE_CURRENCIES),
            icon: const Icon(Icons.currency_exchange),
            tooltip: 'Devises',
          ),
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.FINANCE_ACCOUNTS_CREATE),
            icon: const Icon(Icons.add),
            tooltip: 'Créer un compte',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuickActions(),
            const SizedBox(height: 24),
            _buildAccountsList(),
          ],
        ),
      ),
    );
  }


  Widget _buildQuickActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Nouveau Compte',
                Icons.add_circle_outline,
                AppColors.primary,
                () => Get.toNamed(AppRoutes.FINANCE_ACCOUNTS_CREATE),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Liste Complète',
                Icons.list,
                AppColors.secondary,
                () => Get.toNamed(AppRoutes.FINANCE_ACCOUNTS_LIST),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Devises',
                Icons.currency_exchange,
                AppColors.warning,
                () => Get.toNamed(AppRoutes.FINANCE_CURRENCIES),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(child: SizedBox()), // Empty space
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
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Comptes Récents',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.FINANCE_ACCOUNTS_LIST),
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isLoading) {
            return Column(
              children: List.generate(3, (index) => const ShimmerCard()),
            );
          }

          if (controller.accounts.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: controller.accounts
                .take(5)
                .map((account) => _buildAccountItem(account))
                .toList(),
          );
        }),
      ],
    );
  }

  Widget _buildAccountItem(AccountModel account) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: controller.selectedAccount?.id == account.id
              ? AppColors.primary
              : AppColors.grey200,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackWithOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getAccountColor(account).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getAccountIcon(account),
            color: _getAccountColor(account),
            size: 20,
          ),
        ),
        title: Text(
          account.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(account.currency.code),
            if (account.description.isNotEmpty)
              Text(
                account.description,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.grey600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              account.formattedBalance,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: account.balance >= 0 ? AppColors.success : AppColors.error,
              ),
            ),
            if (controller.selectedAccount?.id == account.id)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Actif',
                  style: TextStyle(
                    color: Get.theme.cardColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        onTap: () => Get.toNamed(AppRoutes.FINANCE_ACCOUNTS_DETAILS, arguments: account),
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
          Icon(Icons.account_balance_wallet, size: 48, color: AppColors.grey500),
          const SizedBox(height: 16),
          Text(
            'Aucun compte',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.grey700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Créez votre premier compte pour commencer',
            style: TextStyle(
              color: AppColors.grey600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Get.toNamed(AppRoutes.FINANCE_ACCOUNTS_CREATE),
            child: const Text('Créer un compte'),
          ),
        ],
      ),
    );
  }

  Color _getAccountColor(AccountModel account) {
    if (account.color != null) {
      try {
        return Color(int.parse('FF${account.color}', radix: 16));
      } catch (e) {
        return AppColors.primary;
      }
    }
    return AppColors.primary;
  }

  IconData _getAccountIcon(AccountModel account) {
    switch (account.icon) {
      case 'account_balance':
        return Icons.account_balance;
      case 'savings':
        return Icons.savings;
      case 'credit_card':
        return Icons.credit_card;
      case 'payments':
        return Icons.payments;
      default:
        return Icons.account_balance_wallet;
    }
  }
}