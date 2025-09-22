import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/finance_controller.dart';
import '../../../models/account_model.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../routes/app_pages.dart';

class AccountDetails extends GetView<FinanceController> {
  const AccountDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AccountModel account = Get.arguments as AccountModel;

    return Scaffold(
      appBar: AppBar(
        title: Text(account.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleAction(value, account),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 8),
                    Text('Modifier'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'select',
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 20),
                    SizedBox(width: 8),
                    Text('Sélectionner'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'transactions',
                child: Row(
                  children: [
                    Icon(Icons.list, size: 20),
                    SizedBox(width: 8),
                    Text('Transactions'),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAccountCard(account),
            const SizedBox(height: 24),
            _buildQuickActions(account),
            const SizedBox(height: 24),
            _buildAccountInfo(account),
            const SizedBox(height: 24),
            _buildRecentTransactions(account),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCard(AccountModel account) {
    final isSelected = controller.selectedAccount?.id == account.id;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getAccountColor(account),
            _getAccountColor(account).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getAccountColor(account).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getAccountIcon(account),
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const Spacer(),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Compte Actif',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            account.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            account.currency.code,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Solde actuel',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            account.formattedBalance,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(AccountModel account) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions Rapides',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Nouvelle Transaction',
                Icons.add,
                AppColors.primary,
                () => Get.toNamed(AppRoutes.FINANCE_ADD_TRANSACTION, arguments: account),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Voir Transactions',
                Icons.list,
                AppColors.secondary,
                () => Get.toNamed(AppRoutes.FINANCE_TRANSACTIONS, arguments: {'accountId': account.id}),
              ),
            ),
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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountInfo(AccountModel account) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informations du Compte',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
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
          child: Column(
            children: [
              _buildInfoRow('Nom', account.name),
              if (account.description.isNotEmpty) ...[
                const Divider(),
                _buildInfoRow('Description', account.description),
              ],
              const Divider(),
              _buildInfoRow('Devise', '${account.currency.name} (${account.currency.code})'),
              const Divider(),
              _buildInfoRow('Solde', account.formattedBalance),
              const Divider(),
              _buildInfoRow('Créé le', 'Date de création - À implémenter'),
              const Divider(),
              _buildInfoRow('Dernière activité', 'Dernière transaction - À implémenter'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.grey600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(AccountModel account) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Transactions Récentes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.FINANCE_TRANSACTIONS, arguments: {'accountId': account.id}),
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.adaptiveEmptyStateBackground(Get.context!),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.adaptiveEmptyStateBorder(Get.context!)),
          ),
          child: Column(
            children: [
              Icon(Icons.receipt_long, size: 48, color: AppColors.grey500),
              const SizedBox(height: 16),
              Text(
                'Aucune transaction',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Les transactions de ce compte apparaîtront ici',
                style: TextStyle(
                  color: AppColors.grey600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Get.toNamed(AppRoutes.FINANCE_ADD_TRANSACTION, arguments: account),
                child: const Text('Ajouter une transaction'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleAction(String action, AccountModel account) {
    switch (action) {
      case 'edit':
        Get.toNamed(AppRoutes.FINANCE_ACCOUNTS_EDIT, arguments: account);
        break;
      case 'select':
        controller.selectAccount(account);
        Get.snackbar(
          'Compte sélectionné',
          '${account.name} est maintenant le compte actif',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
        );
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Êtes-vous sûr de vouloir supprimer le compte "${account.name}" ?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cette action est irréversible et supprimera toutes les transactions associées.',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Get.back(); // Fermer la dialog

              final success = await controller.deleteAccount(account.id);

              if (success) {
                Get.back(); // Fermer la page des détails
              }
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
      switch (account.color) {
        case 'primary': return AppColors.primary;
        case 'secondary': return AppColors.secondary;
        case 'success': return AppColors.success;
        case 'warning': return AppColors.warning;
        case 'error': return AppColors.error;
        case 'purple': return Colors.purple;
        case 'orange': return Colors.orange;
        case 'teal': return Colors.teal;
        default: return AppColors.primary;
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
      case 'monetization_on':
        return Icons.monetization_on;
      default:
        return Icons.account_balance_wallet;
    }
  }
}