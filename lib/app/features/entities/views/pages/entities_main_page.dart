import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/entities_controller.dart';
import '../../../../core/constants/app_colors.dart';
import 'entities_overview_page.dart';

class EntitiesMainPage extends GetView<EntitiesController> {
  const EntitiesMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Entités'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshEntities(),
          ),
        ],
      ),
      drawer: _buildEntitiesDrawer(),
      body: const EntitiesOverviewPage(),
    );
  }

  Widget _buildEntitiesDrawer() {
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
                      'Statistiques',
                      Icons.analytics,
                      () => _navigateToStats(),
                    ),
                  ],
                ),
                _buildDrawerSection(
                  'Gestion',
                  [
                    _buildDrawerItem(
                      'Liste des entités',
                      Icons.list,
                      () => _navigateToList(),
                    ),
                    _buildDrawerItem(
                      'Créer une entité',
                      Icons.add_business,
                      () => _navigateToCreate(),
                    ),
                  ],
                ),
                _buildDrawerSection(
                  'Configuration',
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
          colors: [AppColors.primary, AppColors.secondary],
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
                Icons.business_center,
                color: Colors.white,
                size: 32,
              ),
              SizedBox(width: 12),
              Text(
                'Entités',
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
            '${controller.totalEntities} entité(s)',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          )),
          Obx(() => controller.currentEntity != null
              ? Text(
                  'Actuelle: ${controller.currentEntity!.name}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : const SizedBox.shrink()),
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
        color: isSelected ? AppColors.primary : AppColors.hint,
      ),
      title: Text(
        title,
        style: Get.textTheme.bodyMedium?.copyWith(
          color: isSelected ? AppColors.primary : Colors.white,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.primary.withOpacity(0.1),
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
              'Module Entités v1.0',
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

  void _navigateToStats() {
    Get.back();
    Get.snackbar('Info', 'Page statistiques - À implémenter');
  }

  void _navigateToList() {
    Get.back();
    Get.snackbar('Info', 'Liste des entités - À implémenter');
  }

  void _navigateToCreate() {
    Get.back();
    Get.snackbar('Info', 'Créer entité - À implémenter');
  }

  void _navigateToSettings() {
    Get.back();
    Get.snackbar('Info', 'Paramètres entités - À implémenter');
  }

  void _navigateToImportExport() {
    Get.back();
    Get.snackbar('Info', 'Import/Export - À implémenter');
  }
}