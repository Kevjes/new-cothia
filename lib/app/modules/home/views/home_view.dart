import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../data/services/auth_service.dart';
import '../../../core/widgets/theme_switcher.dart';
import '../../../core/widgets/bottom_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/finance/views/widgets/finance_dashboard.dart';
import '../../../features/finance/views/widgets/finance_drawer.dart';
import '../../../routes/app_pages.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      appBar: AppBar(
        title: Text(controller.currentTabTitle),
        centerTitle: true,
        actions: [
          const ThemeSwitcher(),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => AuthController.to.signOut(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: controller.currentIndex == 1 ? const FinanceDrawer() : null,
      body: _buildCurrentTab(),
      bottomNavigationBar: CustomBottomNavigation(
            currentIndex: controller.currentIndex,
            onTap: controller.changeTabIndex,
          ),
    ));
  }

  Widget _buildCurrentTab() {
    switch (controller.currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return const FinanceDashboard();
      case 2:
        return _buildHabitsTab();
      case 3:
        return _buildTasksTab();
      case 4:
        return _buildProjectsTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(),
          const SizedBox(height: 24),
          _buildQuickActions(),
          const SizedBox(height: 24),
          _buildFinancialOverview(),
          const SizedBox(height: 24),
          _buildRecentActivities(),
        ],
      ),
    );
  }

  Widget _buildHabitsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.track_changes,
            size: 64,
            color: AppColors.grey400,
          ),
          const SizedBox(height: 16),
          Text(
            'Module Habitudes',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Suivez et gérez vos habitudes',
            style: TextStyle(
              color: AppColors.grey500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Get.snackbar('Info', 'Module Habitudes - À implémenter');
            },
            child: const Text('Commencer'),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task,
            size: 64,
            color: AppColors.grey400,
          ),
          const SizedBox(height: 16),
          Text(
            'Module Tâches',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Organisez et suivez vos tâches',
            style: TextStyle(
              color: AppColors.grey500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Get.snackbar('Info', 'Module Tâches - À implémenter');
            },
            child: const Text('Commencer'),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder,
            size: 64,
            color: AppColors.grey400,
          ),
          const SizedBox(height: 16),
          Text(
            'Module Projets',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gérez et suivez vos projets',
            style: TextStyle(
              color: AppColors.grey500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Get.snackbar('Info', 'Module Projets - À implémenter');
            },
            child: const Text('Commencer'),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Obx(() {
      final user = AuthService.to.currentUser;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bonjour ${user?.displayName ?? 'Utilisateur'} !',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Gérez vos finances intelligemment',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions rapides',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Ajouter Transaction',
                Icons.add_circle_outline,
                AppColors.success,
                () => Get.toNamed(AppRoutes.FINANCE_ADD_TRANSACTION),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Transfert',
                Icons.swap_horiz,
                AppColors.primary,
                () => Get.toNamed(AppRoutes.FINANCE_TRANSFERS_CREATE),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Voir Budgets',
                Icons.pie_chart_outline,
                AppColors.warning,
                () => Get.toNamed(AppRoutes.FINANCE_BUDGETS),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Comptes',
                Icons.account_balance,
                AppColors.secondary,
                () => Get.toNamed(AppRoutes.FINANCE_ACCOUNTS),
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
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aperçu financier',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Solde Total',
                '750,000 FCFA',
                Icons.account_balance_wallet,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Ce Mois',
                '+125,000 FCFA',
                Icons.trending_up,
                AppColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).cardColor,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Activités récentes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.FINANCE_TRANSACTIONS),
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildActivityItem(
          'Salaire',
          '+500,000 FCFA',
          'Aujourd\'hui',
          Icons.work,
          AppColors.success,
        ),
        _buildActivityItem(
          'Courses',
          '-25,000 FCFA',
          'Hier',
          Icons.shopping_cart,
          AppColors.error,
        ),
        _buildActivityItem(
          'Transport',
          '-5,000 FCFA',
          'Il y a 2 jours',
          Icons.directions_car,
          AppColors.warning,
        ),
      ],
    );
  }

  Widget _buildActivityItem(String title, String amount, String date, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).cardColor,
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    color: AppColors.grey600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: amount.startsWith('+') ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
