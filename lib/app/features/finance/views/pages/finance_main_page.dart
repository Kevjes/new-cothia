import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/finance_controller.dart';
import '../../../../core/constants/app_colors.dart';
import 'finance_overview_page.dart';

class FinanceMainPage extends GetView<FinanceController> {
  const FinanceMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Finance'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshAllData(),
          ),
        ],
      ),
      drawer: _buildFinanceDrawer(),
      body: const FinanceOverviewPage(),
    );
  }

  Widget _buildFinanceDrawer() {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: Column(
        children: [
          _buildDrawerHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerSection(
                  'Vue d\'ensemble',
                  [
                    _buildDrawerItem(
                      'Dashboard',
                      Icons.dashboard,
                      () => _navigateToOverview(),
                      isSelected: true,
                    ),
                    _buildDrawerItem(
                      'Analyses',
                      Icons.analytics,
                      () => _navigateToAnalytics(),
                    ),
                  ],
                ),
                _buildDrawerSection(
                  'Gestion des Comptes',
                  [
                    _buildDrawerItem(
                      'Mes Comptes',
                      Icons.account_balance,
                      () => _navigateToAccounts(),
                    ),
                    _buildDrawerItem(
                      'Créer un Compte',
                      Icons.add_circle,
                      () => _navigateToCreateAccount(),
                    ),
                  ],
                ),
                _buildDrawerSection(
                  'Transactions',
                  [
                    _buildDrawerItem(
                      'Toutes les Transactions',
                      Icons.receipt_long,
                      () => _navigateToTransactions(),
                    ),
                    _buildDrawerItem(
                      'Ajouter Transaction',
                      Icons.add,
                      () => _navigateToAddTransaction(),
                    ),
                    _buildDrawerItem(
                      'Catégories',
                      Icons.category,
                      () => _navigateToCategories(),
                    ),
                  ],
                ),
                _buildDrawerSection(
                  'Budgets & Objectifs',
                  [
                    _buildDrawerItem(
                      'Mes Budgets',
                      Icons.pie_chart,
                      () => _navigateToBudgets(),
                    ),
                    _buildDrawerItem(
                      'Objectifs',
                      Icons.track_changes,
                      () => _navigateToObjectives(),
                    ),
                  ],
                ),
                _buildDrawerSection(
                  'Outils',
                  [
                    _buildDrawerItem(
                      'Paramètres',
                      Icons.settings,
                      () => _navigateToSettings(),
                    ),
                    _buildDrawerItem(
                      'Import/Export',
                      Icons.import_export,
                      () => _navigateToImportExport(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildDrawerFooter(),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return DrawerHeader(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.secondary, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 32,
              ),
              SizedBox(width: 12),
              Text(
                'Finance',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => Text(
            '${controller.accounts.length} compte(s)',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          )),
          Obx(() => Text(
            'Patrimoine: ${controller.totalWealth.toStringAsFixed(2)} €',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildDrawerSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Get.textTheme.titleSmall?.copyWith(
              color: AppColors.hint,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...items,
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildDrawerItem(
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isSelected = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.secondary : AppColors.hint,
      ),
      title: Text(
        title,
        style: Get.textTheme.bodyMedium?.copyWith(
          color: isSelected ? AppColors.secondary : Colors.white,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.secondary.withOpacity(0.1),
      onTap: onTap,
    );
  }

  Widget _buildDrawerFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.hint.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.hint,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Module Finance v1.0',
              style: Get.textTheme.bodySmall?.copyWith(
                color: AppColors.hint,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Navigation methods
  void _navigateToOverview() {
    Get.back(); // Close drawer
    // Already on overview page
  }

  void _navigateToAnalytics() {
    Get.back();
    Get.snackbar('Info', 'Page analyses - À implémenter');
  }

  void _navigateToAccounts() {
    Get.back();
    Get.snackbar('Info', 'Liste des comptes - À implémenter');
  }

  void _navigateToCreateAccount() {
    Get.back();
    Get.snackbar('Info', 'Créer compte - À implémenter');
  }

  void _navigateToTransactions() {
    Get.back();
    Get.snackbar('Info', 'Liste transactions - À implémenter');
  }

  void _navigateToAddTransaction() {
    Get.back();
    Get.snackbar('Info', 'Ajouter transaction - À implémenter');
  }

  void _navigateToCategories() {
    Get.back();
    Get.snackbar('Info', 'Catégories - À implémenter');
  }

  void _navigateToBudgets() {
    Get.back();
    Get.snackbar('Info', 'Budgets - À implémenter');
  }

  void _navigateToObjectives() {
    Get.back();
    Get.snackbar('Info', 'Objectifs - À implémenter');
  }

  void _navigateToSettings() {
    Get.back();
    Get.snackbar('Info', 'Paramètres finance - À implémenter');
  }

  void _navigateToImportExport() {
    Get.back();
    Get.snackbar('Info', 'Import/Export - À implémenter');
  }
}