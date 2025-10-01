import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/entities_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/entity_model.dart';
import 'entity_statistics_page.dart';
import 'entities_list_page.dart';
import 'entity_form_page.dart';

class EntitiesOverviewPage extends GetView<EntitiesController> {
  const EntitiesOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.hasError) {
        return _buildErrorView();
      }

      if (controller.isLoading && controller.entities.isEmpty) {
        return _buildLoadingView();
      }

      return RefreshIndicator(
        onRefresh: controller.refreshEntities,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 24),
              _buildQuickStats(),
              const SizedBox(height: 24),
              _buildCurrentEntityCard(),
              const SizedBox(height: 24),
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildRecentEntities(),
            ],
          ),
        ),
      );
    });
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => controller.retryInitialization(),
                  child: const Text('Réessayer'),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Retour'),
                ),
              ],
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
          Text('Chargement des entités...'),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.business_center,
                  color: AppColors.primary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gestion des Entités',
                        style: Get.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Organisez vos activités personnelles et professionnelles',
                        style: Get.textTheme.bodyMedium?.copyWith(
                          color: AppColors.hint,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() => controller.currentEntity != null
                ? Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          controller.currentEntity!.isPersonal
                              ? Icons.person
                              : Icons.business,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Entité active: ${controller.currentEntity!.name}',
                            style: Get.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text('Aucune entité sélectionnée'),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total',
            '${controller.totalEntities}',
            AppColors.primary,
            Icons.business_center,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Personnelles',
            '${controller.personalEntitiesCount}',
            AppColors.success,
            Icons.person,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Professionnelles',
            '${controller.businessEntitiesCount}',
            AppColors.secondary,
            Icons.business,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Organisations',
            '${controller.businessEntitiesCount}',
            AppColors.hint,
            Icons.business,
          ),
        ),
      ],
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
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
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

  Widget _buildCurrentEntityCard() {
    return Obx(() {
      if (controller.currentEntity == null) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Icon(
                  Icons.business_center_outlined,
                  size: 48,
                  color: AppColors.hint,
                ),
                const SizedBox(height: 12),
                Text(
                  'Aucune entité sélectionnée',
                  style: Get.textTheme.titleMedium?.copyWith(
                    color: AppColors.hint,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sélectionnez une entité pour voir ses détails',
                  style: Get.textTheme.bodyMedium?.copyWith(
                    color: AppColors.hint,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      final entity = controller.currentEntity!;
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Icon(
                      entity.isPersonal ? Icons.person : Icons.business,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entity.name,
                          style: Get.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          entity.isPersonal ? 'Entité personnelle' : 'Entité professionnelle',
                          style: Get.textTheme.bodyMedium?.copyWith(
                            color: AppColors.hint,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (entity.description != null && entity.description!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  entity.description!,
                  style: Get.textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _editEntity(entity),
                      icon: const Icon(Icons.edit),
                      label: const Text('Modifier'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _viewEntityDetails(entity),
                      icon: const Icon(Icons.visibility),
                      label: const Text('Détails'),
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

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions Rapides',
          style: Get.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Nouvelle Entité',
                Icons.add_business,
                AppColors.primary,
                () => _createEntity(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Voir Toutes',
                Icons.list,
                AppColors.secondary,
                () => _viewAllEntities(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Statistiques',
                Icons.analytics,
                AppColors.success,
                () => _viewStatistics(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Paramètres',
                Icons.settings,
                AppColors.hint,
                () => _openSettings(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: Get.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentEntities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Entités Récentes',
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => _viewAllEntities(),
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.entities.isEmpty) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.business_center_outlined,
                      size: 48,
                      color: AppColors.hint,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Aucune entité trouvée',
                      style: Get.textTheme.titleMedium?.copyWith(
                        color: AppColors.hint,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Créez votre première entité pour commencer',
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: AppColors.hint,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: controller.entities
                .take(3)
                .map((entity) => _buildEntityCard(entity))
                .toList(),
          );
        }),
      ],
    );
  }

  Widget _buildEntityCard(EntityModel entity) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(
            entity.isPersonal ? Icons.person : Icons.business,
            color: AppColors.primary,
          ),
        ),
        title: Text(
          entity.name,
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          entity.isPersonal ? 'Personnelle' : 'Professionnelle',
        ),
        trailing: Icon(
          entity.isPersonal ? Icons.person : Icons.business,
          color: AppColors.primary,
        ),
        onTap: () => controller.selectEntity(entity),
      ),
    );
  }

  // Action methods
  void _createEntity() {
    Get.to(() => const EntityFormPage());
  }

  void _viewAllEntities() {
    Get.to(() => const EntitiesListPage());
  }

  void _viewStatistics() {
    Get.to(() => const EntityStatisticsPage());
  }

  void _openSettings() {
    Get.snackbar('Info', 'Paramètres - À implémenter');
  }

  void _editEntity(EntityModel entity) {
    Get.snackbar('Info', 'Modifier entité - À implémenter');
  }

  void _viewEntityDetails(EntityModel entity) {
    Get.snackbar('Info', 'Détails entité - À implémenter');
  }
}