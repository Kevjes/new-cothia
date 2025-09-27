import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../controllers/tasks_controller.dart';

class TasksAnalyticsPage extends StatelessWidget {
  const TasksAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Analyses des Tâches'),
        backgroundColor: AppColors.surface,
      ),
      body: GetBuilder<TasksController>(
        builder: (controller) {
          return RefreshIndicator(
            onRefresh: () async {
              // Refresh analytics data from Firebase
              await controller.loadTasks();
              Get.snackbar('Actualisation', 'Données analytiques actualisées');
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsOverview(controller),
                  const SizedBox(height: 24),
                  _buildCompletionChart(controller),
                  const SizedBox(height: 24),
                  _buildPriorityDistribution(controller),
                  const SizedBox(height: 24),
                  _buildProductivityInsights(controller),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsOverview(TasksController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vue d\'ensemble',
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total',
                  controller.totalTasks.toString(),
                  Icons.assignment,
                  AppColors.primary,
                ),
                _buildStatItem(
                  'En cours',
                  controller.inProgressTasks.toString(),
                  Icons.play_circle,
                  AppColors.warning,
                ),
                _buildStatItem(
                  'Terminées',
                  controller.completedTasks.toString(),
                  Icons.check_circle,
                  AppColors.success,
                ),
                _buildStatItem(
                  'En retard',
                  controller.overdueTasks.toString(),
                  Icons.warning,
                  AppColors.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Get.textTheme.bodySmall?.copyWith(
            color: AppColors.hint,
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionChart(TasksController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progression sur 7 jours',
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 3),
                        const FlSpot(1, 5),
                        const FlSpot(2, 2),
                        const FlSpot(3, 7),
                        const FlSpot(4, 4),
                        const FlSpot(5, 6),
                        const FlSpot(6, 8),
                      ],
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityDistribution(TasksController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Répartition par priorité',
              style: Get.textTheme.titleLarge?.copyWith(
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
                  sections: [
                    PieChartSectionData(
                      color: AppColors.error,
                      value: 25,
                      title: 'Haute',
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: AppColors.warning,
                      value: 35,
                      title: 'Moyenne',
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: AppColors.success,
                      value: 40,
                      title: 'Basse',
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductivityInsights(TasksController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Insights Productivité',
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInsightItem(
              Icons.trending_up,
              'Productivité en hausse',
              '+15% cette semaine',
              AppColors.success,
            ),
            const SizedBox(height: 12),
            _buildInsightItem(
              Icons.access_time,
              'Temps moyen par tâche',
              '2h 30min',
              AppColors.primary,
            ),
            const SizedBox(height: 12),
            _buildInsightItem(
              Icons.calendar_today,
              'Meilleur jour',
              'Mardi (8 tâches terminées)',
              AppColors.secondary,
            ),
            const SizedBox(height: 12),
            _buildInsightItem(
              Icons.warning,
              'Tâches en retard',
              '3 tâches nécessitent attention',
              AppColors.error,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(IconData icon, String title, String subtitle, Color color) {
    return Row(
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
                style: Get.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: Get.textTheme.bodySmall?.copyWith(
                  color: AppColors.hint,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}