import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/finance_controller.dart';
import '../../models/account_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/shimmer_widget.dart';
import '../../../../routes/app_pages.dart';

class AccountsSection extends GetView<FinanceController> {
  const AccountsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            Row(
              children: [
                IconButton(
                  onPressed: () => Get.toNamed(AppRoutes.FINANCE_ACCOUNTS),
                  icon: Icon(
                    Icons.dashboard,
                    color: AppColors.primary,
                  ),
                ),
                TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.FINANCE_ACCOUNTS_LIST),
                  child: const Text('Voir tout'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isLoading) {
            return _buildLoadingAccounts();
          }

          if (controller.accounts.isEmpty) {
            return _buildEmptyState();
          }

          return _buildAccountsList();
        }),
      ],
    );
  }

  Widget _buildLoadingAccounts() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) => const ShimmerAccountCard(),
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
        border: Border.all(
          color: AppColors.adaptiveEmptyStateBorder(Get.context!),
        ),
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

  Widget _buildAccountsList() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.accounts.length,
        itemBuilder: (context, index) {
          final account = controller.accounts[index];
          return Container(
            width: 200,
            margin: EdgeInsets.only(
              right: index < controller.accounts.length - 1 ? 12 : 0,
            ),
            child: _buildAccountCard(account),
          );
        },
      ),
    );
  }

  Widget _buildAccountCard(AccountModel account) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.FINANCE_ACCOUNTS_DETAILS, arguments: account),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: controller.selectedAccount?.id == account.id
                ? AppColors.primary
                : Colors.transparent,
            width: 2,
          ),
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
                    color: _getAccountColor(account).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getAccountIcon(account),
                    color: _getAccountColor(account),
                    size: 20,
                  ),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleAccountAction(value, account),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'select',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, size: 16),
                          SizedBox(width: 8),
                          Text('Sélectionner'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('Modifier'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'transactions',
                      child: Row(
                        children: [
                          Icon(Icons.list, size: 16),
                          SizedBox(width: 8),
                          Text('Transactions'),
                        ],
                      ),
                    ),
                  ],
                  child: Icon(
                    Icons.more_vert,
                    color: AppColors.grey500,
                    size: 20,
                  ),
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
            if (account.description.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                account.description,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.grey600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
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

  void _handleAccountAction(String action, AccountModel account) {
    switch (action) {
      case 'select':
        controller.selectAccount(account);
        Get.snackbar(
          'Compte sélectionné',
          '${account.name} est maintenant le compte actif',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
      case 'edit':
        Get.toNamed(AppRoutes.FINANCE_ACCOUNTS_EDIT, arguments: account);
        break;
      case 'transactions':
        Get.toNamed(AppRoutes.FINANCE_TRANSACTIONS, arguments: {'accountId': account.id});
        break;
    }
  }

}