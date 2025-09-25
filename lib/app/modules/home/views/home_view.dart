import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_pages.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Cothia'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            const SizedBox(height: 40),
            _buildModulesGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final authController = Get.find<AuthController>();

    return Obx(() {
      final user = authController.currentUser;
      final userName = user?.displayName ?? (user?.email != null ? user!.email.split('@').first : 'Utilisateur');

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      userName[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bienvenue, $userName !',
                          style: Get.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Gérez vos finances, tâches et habitudes',
                          style: Get.textTheme.bodyMedium?.copyWith(
                            color: AppColors.hint,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildModulesGrid() {
    return Expanded(
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildModuleCard(
            title: 'Entités',
            subtitle: 'Gérer vos entités',
            icon: Icons.business,
            color: AppColors.primary,
            onTap: () => Get.toNamed(Routes.ENTITIES),
          ),
          _buildModuleCard(
            title: 'Finances',
            subtitle: 'Comptes et budgets',
            icon: Icons.account_balance_wallet,
            color: AppColors.secondary,
            onTap: () => Get.toNamed(Routes.FINANCE),
          ),
          _buildModuleCard(
            title: 'Tâches',
            subtitle: 'Gérer vos tâches',
            icon: Icons.task_alt,
            color: AppColors.success,
            onTap: () => Get.toNamed(Routes.TASKS),
          ),
          _buildModuleCard(
            title: 'Habitudes',
            subtitle: 'Suivi des habitudes',
            icon: Icons.trending_up,
            color: AppColors.info,
            onTap: () => Get.snackbar('Info', 'Module Habitudes - En développement'),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Get.textTheme.bodySmall?.copyWith(
                  color: AppColors.hint,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.find<AuthController>().signOut();
            },
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }
}
