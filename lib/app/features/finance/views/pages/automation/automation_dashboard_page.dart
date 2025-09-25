import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/automation_controller.dart';
import '../../../../../core/constants/app_colors.dart';

class AutomationDashboardPage extends StatefulWidget {
  const AutomationDashboardPage({super.key});

  @override
  State<AutomationDashboardPage> createState() => _AutomationDashboardPageState();
}

class _AutomationDashboardPageState extends State<AutomationDashboardPage> {
  late AutomationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(AutomationController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Automatisations'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.refreshData(),
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.hasError) {
          return _buildErrorView();
        }

        return RefreshIndicator(
          onRefresh: () => _controller.refreshData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsCards(),
                const SizedBox(height: 24),
                _buildQuickActions(),
                const SizedBox(height: 24),
                _buildNextExecutions(),
                const SizedBox(height: 24),
                _buildLastResults(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'Erreur de chargement',
            style: Get.textTheme.titleLarge?.copyWith(
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _controller.errorMessage,
              style: Get.textTheme.bodyMedium?.copyWith(
                color: AppColors.hint,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _controller.refreshData(),
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Automatisations en attente',
            _controller.totalPendingAutomations.toString(),
            Icons.schedule,
            AppColors.secondary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Aujourd\'hui',
            _controller.automationsToday.toString(),
            Icons.today,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Montant total',
            '${_controller.totalPendingAmount.toStringAsFixed(0)} FCFA',
            Icons.monetization_on,
            AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Get.textTheme.bodySmall?.copyWith(
                      color: AppColors.hint,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions rapides',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _controller.isExecuting
                        ? null
                        : () => _controller.executeAllAutomations(),
                    icon: _controller.isExecuting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.play_arrow),
                    label: const Text('Exécuter maintenant'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _controller.showExecutionResults(),
                    icon: const Icon(Icons.history),
                    label: const Text('Historique'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _controller.scheduleAutomaticExecution(),
                icon: const Icon(Icons.schedule),
                label: const Text('Programmer l\'exécution'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextExecutions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Prochaines exécutions',
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _controller.loadNextExecutions(),
                  icon: const Icon(Icons.refresh, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_controller.nextExecutions.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.schedule_outlined,
                      size: 48,
                      color: AppColors.hint,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Aucune automatisation programmée',
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: AppColors.hint,
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _controller.nextExecutions.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final execution = _controller.nextExecutions[index];
                  final nextExecution = execution['nextExecution'] as DateTime?;
                  final budgetName = execution['budgetName'] as String? ?? 'Budget inconnu';
                  final amount = (execution['amount'] as num?)?.toDouble() ?? 0.0;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.secondary.withOpacity(0.1),
                      child: Icon(
                        Icons.schedule,
                        color: AppColors.secondary,
                        size: 20,
                      ),
                    ),
                    title: Text(budgetName),
                    subtitle: Text(
                      nextExecution != null
                          ? 'Prochaine exécution: ${nextExecution.day}/${nextExecution.month}/${nextExecution.year}'
                          : 'Date non définie',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${amount.toStringAsFixed(0)} FCFA',
                          style: Get.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton(
                          onPressed: () => _controller.previewAutomation(
                            execution['budgetId'] as String? ?? '',
                            budgetName,
                          ),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Aperçu'),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastResults() {
    if (_controller.lastExecutionResults.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Dernières exécutions',
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _controller.clearExecutionResults(),
                  child: const Text('Effacer'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _controller.lastExecutionResults.length.clamp(0, 5),
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final result = _controller.lastExecutionResults[index];
                final isSuccess = result['success'] == true;
                final budgetName = result['budgetName'] as String? ?? 'Budget inconnu';
                final message = result['message'] as String? ?? 'Aucun message';

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: (isSuccess ? AppColors.success : AppColors.error).withOpacity(0.1),
                    child: Icon(
                      isSuccess ? Icons.check : Icons.error,
                      color: isSuccess ? AppColors.success : AppColors.error,
                      size: 20,
                    ),
                  ),
                  title: Text(budgetName),
                  subtitle: Text(message),
                  trailing: isSuccess
                      ? Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.hint)
                      : null,
                );
              },
            ),
            if (_controller.lastExecutionResults.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Center(
                  child: TextButton(
                    onPressed: () => _controller.showExecutionResults(),
                    child: Text('Voir tous les résultats (${_controller.lastExecutionResults.length})'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}