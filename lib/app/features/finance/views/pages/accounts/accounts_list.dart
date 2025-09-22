import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/finance_controller.dart';
import '../../../models/account_model.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/shimmer_widget.dart';
import '../../../../../routes/app_pages.dart';

class AccountsList extends GetView<FinanceController> {
  const AccountsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tous les Comptes'),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.FINANCE_ACCOUNTS_CREATE),
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'sort_name',
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha, size: 16),
                    SizedBox(width: 8),
                    Text('Trier par nom'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'sort_balance',
                child: Row(
                  children: [
                    Icon(Icons.attach_money, size: 16),
                    SizedBox(width: 8),
                    Text('Trier par solde'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'filter_currency',
                child: Row(
                  children: [
                    Icon(Icons.filter_list, size: 16),
                    SizedBox(width: 8),
                    Text('Filtrer par devise'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildStatsHeader(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading) {
                return _buildLoadingState();
              }

              if (controller.accounts.isEmpty) {
                return _buildEmptyState();
              }

              return _buildAccountsList();
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.FINANCE_ACCOUNTS_CREATE),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Rechercher un compte...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Get.theme.cardColor,
        ),
        onChanged: (value) {
          // TODO: Implémenter la recherche
        },
      ),
    );
  }

  Widget _buildStatsHeader() {
    return Obx(() {
      final totalAccounts = controller.accounts.length;
      final totalBalance = controller.accounts.fold<double>(0, (sum, account) => sum + account.balance);
      final selectedAccount = controller.selectedAccount;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Get.theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackWithOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total: $totalAccounts compte(s)',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grey600,
                    ),
                  ),
                  Text(
                    'Solde global: ${totalBalance.toStringAsFixed(2)} FCFA',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: totalBalance >= 0 ? AppColors.success : AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
            if (selectedAccount != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 16, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      selectedAccount.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) => const ShimmerCard(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.adaptiveEmptyStateBackground(Get.context!),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.adaptiveEmptyStateBorder(Get.context!)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_balance_wallet, size: 64, color: AppColors.grey500),
            const SizedBox(height: 16),
            Text(
              'Aucun compte trouvé',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.grey700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Créez votre premier compte pour commencer à gérer vos finances',
              style: TextStyle(
                color: AppColors.grey600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.FINANCE_ACCOUNTS_CREATE),
              icon: const Icon(Icons.add),
              label: const Text('Créer un compte'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.accounts.length,
      itemBuilder: (context, index) {
        final account = controller.accounts[index];
        return _buildAccountItem(account);
      },
    );
  }

  Widget _buildAccountItem(AccountModel account) {
    final isSelected = controller.selectedAccount?.id == account.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.grey200,
          width: isSelected ? 2 : 1,
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
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getAccountColor(account).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getAccountIcon(account),
            color: _getAccountColor(account),
            size: 24,
          ),
        ),
        title: Text(
          account.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.monetization_on, size: 14, color: AppColors.grey600),
                const SizedBox(width: 4),
                Text(
                  account.currency.code,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey600,
                  ),
                ),
                const SizedBox(width: 16),
                if (isSelected) ...[
                  Icon(Icons.check_circle, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Actif',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
            if (account.description.isNotEmpty) ...[
              const SizedBox(height: 4),
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
                fontSize: 16,
                color: account.balance >= 0 ? AppColors.success : AppColors.error,
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) => _handleAccountAction(value, account),
              itemBuilder: (context) => [
                if (!isSelected)
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
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility, size: 16),
                      SizedBox(width: 8),
                      Text('Détails'),
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
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Supprimer', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              child: Icon(
                Icons.more_vert,
                color: AppColors.grey500,
              ),
            ),
          ],
        ),
        onTap: () => Get.toNamed(AppRoutes.FINANCE_ACCOUNTS_DETAILS, arguments: account),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'sort_name':
        // TODO: Implémenter tri par nom
        Get.snackbar('Info', 'Tri par nom - À implémenter');
        break;
      case 'sort_balance':
        // TODO: Implémenter tri par solde
        Get.snackbar('Info', 'Tri par solde - À implémenter');
        break;
      case 'filter_currency':
        // TODO: Implémenter filtre par devise
        Get.snackbar('Info', 'Filtre par devise - À implémenter');
        break;
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
      case 'view':
        Get.toNamed(AppRoutes.FINANCE_ACCOUNTS_DETAILS, arguments: account);
        break;
      case 'edit':
        Get.toNamed(AppRoutes.FINANCE_ACCOUNTS_EDIT, arguments: account);
        break;
      case 'transactions':
        Get.toNamed(AppRoutes.FINANCE_TRANSACTIONS, arguments: {'accountId': account.id});
        break;
      case 'delete':
        _showDeleteConfirmation(account);
        break;
    }
  }

  void _showDeleteConfirmation(AccountModel account) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer le compte "${account.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              // TODO: Implémenter la suppression
              Get.snackbar('Info', 'Suppression - À implémenter');
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Supprimer'),
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