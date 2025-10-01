import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/entities_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/entity_model.dart';

class EntityStatisticsPage extends GetView<EntitiesController> {
  const EntityStatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Statistiques des Entités'),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return _buildLoadingState(context);
        }

        if (controller.hasError) {
          return _buildErrorState(context);
        }

        return RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOverviewCards(),
                const SizedBox(height: 24),
                _buildEntityDistributionChart(context),
                const SizedBox(height: 24),
                _buildDetailedEntityStats(context),
                const SizedBox(height: 24),
                _buildProductivityAnalysis(context),
                const SizedBox(height: 24),
                _buildEngagementInsights(context),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Chargement des statistiques...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          const Text(
            'Erreur lors du chargement',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.errorMessage,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => controller.retryInitialization(),
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Entités',
            controller.totalEntities.toString(),
            Icons.business,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Personnelles',
            controller.personalEntitiesCount.toString(),
            Icons.person,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Organisations',
            controller.businessEntitiesCount.toString(),
            Icons.corporate_fare,
            AppColors.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEntityDistributionChart(BuildContext context) {
    if (controller.entities.isEmpty) {
      return _buildEmptyChart('Aucune entité disponible');
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Répartition des Entités',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: _getPieChartSections(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildChartLegend(),
        ],
      ),
    );
  }

  List<PieChartSectionData> _getPieChartSections() {
    final personal = controller.personalEntitiesCount;
    final business = controller.businessEntitiesCount;
    final total = personal + business;

    if (total == 0) return [];

    return [
      PieChartSectionData(
        color: Colors.green,
        value: personal.toDouble(),
        title: '${((personal / total) * 100).toInt()}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: AppColors.secondary,
        value: business.toDouble(),
        title: '${((business / total) * 100).toInt()}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  Widget _buildChartLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem('Personnelles', Colors.green),
        _buildLegendItem('Organisations', AppColors.secondary),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildDetailedEntityStats(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Détails par Entité',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...controller.entities.map((entity) => _buildEntityDetailCard(entity)),
        ],
      ),
    );
  }

  Widget _buildEntityDetailCard(EntityModel entity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                entity.isPersonal ? Icons.person : Icons.business,
                color: entity.isPersonal ? Colors.green : AppColors.secondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entity.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: entity.isPersonal
                    ? Colors.green.withValues(alpha: 0.1)
                    : AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  entity.typeDisplayName,
                  style: TextStyle(
                    fontSize: 12,
                    color: entity.isPersonal ? Colors.green : AppColors.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (entity.description != null) ...[
            const SizedBox(height: 8),
            Text(
              entity.description!,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 12),
          // Statistiques simulées pour le moment
          Row(
            children: [
              Expanded(child: _buildStatItem('Projets', '3', Icons.work)),
              Expanded(child: _buildStatItem('Tâches', '12', Icons.task)),
              Expanded(child: _buildStatItem('Transactions', '45', Icons.payments)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildProductivityAnalysis(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analyse de Productivité',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildProductivityInsight(
            'Entité la plus active',
            _getMostActiveEntity(),
            Icons.trending_up,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildProductivityInsight(
            'Répartition du temps',
            _getTimeDistribution(),
            Icons.schedule,
            AppColors.primary,
          ),
          const SizedBox(height: 12),
          _buildProductivityInsight(
            'Engagement moyen',
            _getEngagementLevel(),
            Icons.psychology,
            AppColors.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildProductivityInsight(String title, String description, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
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
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEngagementInsights(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aperçu des Engagements',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildEngagementCard(
            'Équilibre Vie Pro/Perso',
            _getWorkLifeBalance(),
            _getWorkLifeBalanceColor(),
          ),
          const SizedBox(height: 12),
          _buildEngagementCard(
            'Diversification des Activités',
            _getActivityDiversification(),
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildEngagementCard(
            'Tendance Récente',
            _getRecentTrend(),
            _getTrendColor(),
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChart(String message) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Méthodes utilitaires pour les calculs
  String _getMostActiveEntity() {
    if (controller.entities.isEmpty) return 'Aucune donnée';
    final personalEntity = controller.personalEntity;
    return personalEntity?.name ?? 'Entité personnelle';
  }

  String _getTimeDistribution() {
    final personal = controller.personalEntitiesCount;
    final business = controller.businessEntitiesCount;

    if (personal == 0 && business == 0) return 'Aucune donnée';
    if (business == 0) return '100% Personnel';
    if (personal == 0) return '100% Professionnel';

    final personalPercent = (personal / (personal + business) * 100).round();
    return '$personalPercent% Personnel / ${100 - personalPercent}% Professionnel';
  }

  String _getEngagementLevel() {
    final totalEntities = controller.totalEntities;
    if (totalEntities <= 1) return 'Faible';
    if (totalEntities <= 3) return 'Modéré';
    return 'Élevé';
  }

  String _getWorkLifeBalance() {
    final personal = controller.personalEntitiesCount;
    final business = controller.businessEntitiesCount;

    if (business == 0) return 'Axé Personnel';
    if (personal == 0) return 'Axé Professionnel';

    final ratio = personal / business;
    if (ratio >= 0.8 && ratio <= 1.2) return 'Équilibré';
    if (ratio > 1.2) return 'Orienté Personnel';
    return 'Orienté Professionnel';
  }

  Color _getWorkLifeBalanceColor() {
    final balance = _getWorkLifeBalance();
    switch (balance) {
      case 'Équilibré':
        return Colors.green;
      case 'Orienté Personnel':
      case 'Orienté Professionnel':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  String _getActivityDiversification() {
    final totalEntities = controller.totalEntities;
    if (totalEntities <= 1) return 'Faible';
    if (totalEntities <= 2) return 'Limitée';
    if (totalEntities <= 4) return 'Bonne';
    return 'Excellente';
  }

  String _getRecentTrend() {
    return 'Stable';
  }

  Color _getTrendColor() {
    final trend = _getRecentTrend();
    switch (trend) {
      case 'Croissance':
        return Colors.green;
      case 'Stable':
        return Colors.blue;
      case 'Déclin':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _refreshData() async {
    await controller.refreshEntities();
  }
}