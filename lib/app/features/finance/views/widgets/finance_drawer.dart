import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routes/app_pages.dart';

class FinanceDrawer extends StatelessWidget {
  const FinanceDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: Icon(Icons.account_balance, color: AppColors.primary),
                  title: const Text('Comptes'),
                  onTap: () => Get.toNamed(AppRoutes.FINANCE_ACCOUNTS),
                ),
                ListTile(
                  leading: Icon(Icons.receipt_long, color: AppColors.primary),
                  title: const Text('Transactions'),
                  onTap: () => Get.toNamed(AppRoutes.FINANCE_TRANSACTIONS),
                ),
                ListTile(
                  leading: Icon(Icons.pie_chart, color: AppColors.primary),
                  title: const Text('Budgets'),
                  onTap: () => Get.toNamed(AppRoutes.FINANCE_BUDGETS),
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.analytics, color: AppColors.primary),
                  title: const Text('Statistiques'),
                  onTap: () => Get.toNamed(AppRoutes.FINANCE_STATS),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        border: Border(
          bottom: BorderSide(
            color: AppColors.grey200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.account_balance_wallet,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Finance',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Get.theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Gérez vos finances',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}