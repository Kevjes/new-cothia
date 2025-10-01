import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/automation_controller.dart';
import '../../../../../core/constants/app_colors.dart';
import 'automation_rule_form_page.dart';
import '../../../models/automation_rule_model.dart';

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
            icon: const Icon(Icons.add),
            onPressed: () => Get.to(() => const AutomationRuleFormPage()),
          ),
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

        if (_controller.isLoading && _controller.rules.isEmpty) {
          return const Center(child: CircularProgressIndicator());
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
                _buildRulesList(),
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
            onPressed: () => _controller.retryInitialization(),
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
            title: 'Règles actives',
            value: _controller.activeRulesCount.toString(),
            icon: Icons.check_circle,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Total',
            value: _controller.totalRules.toString(),
            icon: Icons.auto_awesome,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Text(
                  value,
                  style: Get.textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Get.textTheme.bodyMedium?.copyWith(
                color: AppColors.hint,
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
        padding: const EdgeInsets.all(16.0),
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
                  child: _buildActionButton(
                    label: 'Nouvelle Règle',
                    icon: Icons.add,
                    color: AppColors.primary,
                    onTap: () => Get.to(() => const AutomationRuleFormPage()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    label: 'Actualiser',
                    icon: Icons.refresh,
                    color: AppColors.secondary,
                    onTap: () => _controller.refreshData(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
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
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRulesList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Règles d\'automatisation',
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_controller.rules.isNotEmpty)
                  IconButton(
                    onPressed: () => _controller.loadRules(),
                    icon: const Icon(Icons.refresh, size: 20),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_controller.rules.isEmpty)
              _buildEmptyState()
            else
              _buildRulesListView(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              size: 64,
              color: AppColors.hint,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune règle d\'automatisation',
              style: Get.textTheme.titleMedium?.copyWith(
                color: AppColors.hint,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Créez votre première règle pour automatiser vos finances',
              style: Get.textTheme.bodySmall?.copyWith(
                color: AppColors.hint,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Get.to(() => const AutomationRuleFormPage()),
              icon: const Icon(Icons.add),
              label: const Text('Créer une règle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRulesListView() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _controller.rules.length,
      separatorBuilder: (context, index) => const Divider(height: 24),
      itemBuilder: (context, index) {
        final rule = _controller.rules[index];
        return _buildRuleCard(rule);
      },
    );
  }

  Widget _buildRuleCard(AutomationRuleModel rule) {
    // Déterminer l'icône et la couleur selon le type de déclencheur
    IconData triggerIcon;
    Color triggerColor;
    String triggerLabel;

    switch (rule.triggerType) {
      case TriggerType.scheduled:
        triggerIcon = Icons.schedule;
        triggerColor = AppColors.primary;
        triggerLabel = 'Programmé';
        break;
      case TriggerType.eventBased:
        triggerIcon = Icons.event;
        triggerColor = AppColors.secondary;
        triggerLabel = 'Événement';
        break;
      case TriggerType.categoryBased:
        triggerIcon = Icons.category;
        triggerColor = AppColors.success;
        triggerLabel = 'Catégorie';
        break;
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: rule.isActive ? triggerColor.withValues(alpha: 0.3) : AppColors.hint.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(12),
        color: rule.isActive ? triggerColor.withValues(alpha: 0.05) : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: triggerColor.withValues(alpha: 0.1),
          child: Icon(
            triggerIcon,
            color: triggerColor,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                rule.name,
                style: Get.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: rule.isActive ? null : AppColors.hint,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: triggerColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                triggerLabel,
                style: Get.textTheme.labelSmall?.copyWith(
                  color: triggerColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.play_arrow, size: 14, color: AppColors.hint),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    rule.triggerDescription,
                    style: Get.textTheme.bodySmall?.copyWith(
                      color: AppColors.hint,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.bolt, size: 14, color: AppColors.secondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    rule.action.displayDescription,
                    style: Get.textTheme.bodySmall?.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: rule.isActive,
              onChanged: (value) => _controller.toggleRuleStatus(rule.id),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            PopupMenuButton<String>(
              onSelected: (value) => _handleRuleAction(value, rule),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Modifier'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Supprimer', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleRuleAction(String action, AutomationRuleModel rule) {
    switch (action) {
      case 'edit':
        Get.to(() => AutomationRuleFormPage(rule: rule));
        break;
      case 'delete':
        _showDeleteDialog(rule);
        break;
    }
  }

  void _showDeleteDialog(AutomationRuleModel rule) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Supprimer la règle'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer la règle "${rule.name}" ?\n\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _controller.deleteRule(rule.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
