import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/budgets_controller.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../models/budget_model.dart';
import 'budget_create_page.dart';
import 'budget_details_page.dart';

class BudgetsListPage extends GetView<BudgetsController> {
  const BudgetsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Budgets'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () => _showBudgetsAnalytics(),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'templates':
                  _showBudgetTemplates();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'templates',
                child: Row(
                  children: [
                    Icon(Icons.list_alt_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('Modèles'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildQuickStats(),
          _buildFilterTabs(),
          Expanded(
            child: Obx(() {
              if (controller.hasError) {
                return _buildErrorView();
              }

              if (controller.isLoading && controller.budgets.isEmpty) {
                return _buildLoadingView();
              }

              return RefreshIndicator(
                onRefresh: controller.refreshAllData,
                child: controller.budgets.isEmpty
                    ? _buildEmptyState()
                    : _buildBudgetsList(),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createBudget(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Budget', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Obx(() {
      final activeBudgets = controller.budgets.where((b) => b.isActive).toList();
      final expenseBudgets = activeBudgets.where((b) => b.isExpenseBudget).toList();
      final savingBudgets = activeBudgets.where((b) => b.isSavingBudget).toList();
      final overBudget = expenseBudgets.where((b) => b.isOverBudget).length;

      return Container(
        margin: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total',
                activeBudgets.length.toString(),
                AppColors.primary,
                Icons.account_balance_wallet,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Dépenses',
                expenseBudgets.length.toString(),
                AppColors.error,
                Icons.trending_down,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Épargne',
                savingBudgets.length.toString(),
                AppColors.success,
                Icons.savings,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Dépassés',
                overBudget.toString(),
                overBudget > 0 ? AppColors.error : AppColors.hint,
                Icons.warning,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: Get.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
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

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Obx(() {
              final selectedType = controller.selectedBudgetType.value;
              return SegmentedButton<BudgetType?>(
                segments: const [
                  ButtonSegment<BudgetType?>(
                    value: null,
                    label: Text('Tous'),
                    icon: Icon(Icons.category),
                  ),
                  ButtonSegment<BudgetType?>(
                    value: BudgetType.expense,
                    label: Text('Dépenses'),
                    icon: Icon(Icons.trending_down),
                  ),
                  ButtonSegment<BudgetType?>(
                    value: BudgetType.saving,
                    label: Text('Épargne'),
                    icon: Icon(Icons.savings),
                  ),
                ],
                selected: {selectedType},
                onSelectionChanged: (Set<BudgetType?> selection) {
                  controller.selectedBudgetType.value = selection.first;
                },
              );
            }),
          ),
        ],
      ),
    );
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
            ElevatedButton(
              onPressed: () => controller.retryInitialization(),
              child: const Text('Réessayer'),
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
          Text('Chargement des budgets...'),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 80,
              color: AppColors.hint,
            ),
            const SizedBox(height: 24),
            Text(
              'Aucun budget',
              style: Get.textTheme.headlineSmall?.copyWith(
                color: AppColors.hint,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Créez des budgets pour mieux contrôler vos finances',
              style: Get.textTheme.bodyMedium?.copyWith(
                color: AppColors.hint,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _createExpenseBudget(),
                  icon: const Icon(Icons.trending_down),
                  label: const Text('Budget dépense'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => _createSavingBudget(),
                  icon: const Icon(Icons.savings),
                  label: const Text('Budget épargne'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetsList() {
    return Obx(() {
      final filteredBudgets = _getFilteredBudgets();

      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: filteredBudgets.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final budget = filteredBudgets[index];
          return _buildBudgetCard(budget);
        },
      );
    });
  }

  List<BudgetModel> _getFilteredBudgets() {
    final selectedType = controller.selectedBudgetType.value;
    final budgets = controller.budgets.where((b) => b.isActive).toList();

    if (selectedType == null) {
      return budgets;
    }

    return budgets.where((b) => b.type == selectedType).toList();
  }

  Widget _buildBudgetCard(BudgetModel budget) {
    final progressPercentage = budget.progressPercentage;
    final isOverBudget = budget.isOverBudget;
    final isUnderTarget = budget.isUnderTarget;

    Color progressColor;
    if (budget.isExpenseBudget) {
      if (progressPercentage >= 100) {
        progressColor = AppColors.error;
      } else if (progressPercentage >= 80) {
        progressColor = Colors.orange;
      } else {
        progressColor = AppColors.success;
      }
    } else {
      if (progressPercentage >= 100) {
        progressColor = AppColors.success;
      } else if (progressPercentage >= 50) {
        progressColor = Colors.orange;
      } else {
        progressColor = AppColors.error;
      }
    }

    return Card(
      child: InkWell(
        onTap: () => _navigateToBudgetDetails(budget),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: budget.isExpenseBudget
                        ? AppColors.error.withOpacity(0.1)
                        : AppColors.success.withOpacity(0.1),
                    child: Icon(
                      budget.isExpenseBudget ? Icons.trending_down : Icons.savings,
                      color: budget.isExpenseBudget ? AppColors.error : AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          budget.name,
                          style: Get.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          budget.periodDisplayName,
                          style: Get.textTheme.bodySmall?.copyWith(
                            color: AppColors.hint,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleBudgetAction(value, budget),
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
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.copy, size: 18),
                            SizedBox(width: 8),
                            Text('Dupliquer'),
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
              const SizedBox(height: 16),

              // Barre de progression
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${budget.currentAmount.toStringAsFixed(0)} FCFA',
                        style: Get.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: progressColor,
                        ),
                      ),
                      Text(
                        '${budget.targetAmount.toStringAsFixed(0)} FCFA',
                        style: Get.textTheme.bodyMedium?.copyWith(
                          color: AppColors.hint,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressPercentage / 100,
                      backgroundColor: AppColors.hint.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${progressPercentage.toStringAsFixed(1)}%',
                        style: Get.textTheme.bodySmall?.copyWith(
                          color: progressColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (budget.remainingAmount != 0)
                        Text(
                          budget.isExpenseBudget
                              ? 'Reste: ${budget.remainingAmount.toStringAsFixed(0)} FCFA'
                              : 'Manque: ${budget.remainingAmount.abs().toStringAsFixed(0)} FCFA',
                          style: Get.textTheme.bodySmall?.copyWith(
                            color: AppColors.hint,
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              if (isOverBudget || isUnderTarget) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: AppColors.error, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isOverBudget
                              ? 'Budget dépassé de ${(budget.currentAmount - budget.targetAmount).toStringAsFixed(0)} FCFA'
                              : 'Objectif d\'épargne non atteint',
                          style: Get.textTheme.bodySmall?.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

            ],
          ),
        ),
      ),
    );
  }

  void _createBudget() {
    Get.to(() => const BudgetCreatePage());
  }

  void _createExpenseBudget() {
    Get.to(() => const BudgetCreatePage(initialType: BudgetType.expense));
  }

  void _createSavingBudget() {
    Get.to(() => const BudgetCreatePage(initialType: BudgetType.saving));
  }

  void _navigateToBudgetDetails(BudgetModel budget) {
    Get.to(() => BudgetDetailsPage(budget: budget));
  }

  void _handleBudgetAction(String action, BudgetModel budget) {
    switch (action) {
      case 'edit':
        Get.to(() => BudgetCreatePage(budget: budget));
        break;
      case 'duplicate':
        _duplicateBudget(budget);
        break;
      case 'delete':
        _showDeleteDialog(budget);
        break;
    }
  }

  void _duplicateBudget(BudgetModel budget) {
    Get.to(() => BudgetCreatePage(
      budget: budget.copyWith(
        id: '',
        name: '${budget.name} (Copie)',
        currentAmount: 0.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ));
  }

  void _showDeleteDialog(BudgetModel budget) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Supprimer le budget'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer le budget "${budget.name}" ?\n\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => _deleteBudget(budget),
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

  Future<void> _deleteBudget(BudgetModel budget) async {
    Get.back();
    try {
      await controller.deleteBudget(budget.id);
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de supprimer le budget: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  void _showBudgetsAnalytics() {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('Analyses des budgets'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Budgets totaux: ${controller.budgets.length}'),
            const SizedBox(height: 8),
            Text('Budgets actifs: ${controller.activeBudgets.length}'),
            const SizedBox(height: 8),
            Text('Budgets dépassés: ${controller.exceededBudgets.length}'),
            const SizedBox(height: 8),
            Text('Budgets proches limite: ${controller.budgetsCloseToLimit.length}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showBudgetTemplates() {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('Modèles de budgets'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.restaurant),
              title: const Text('Budget Alimentaire'),
              subtitle: const Text('500 000 FCFA/mois'),
              onTap: () {
                Navigator.of(context).pop();
                Get.snackbar('Info', 'Modèle alimentaire appliqué');
              },
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Budget Logement'),
              subtitle: const Text('1 000 000 FCFA/mois'),
              onTap: () {
                Navigator.of(context).pop();
                Get.snackbar('Info', 'Modèle logement appliqué');
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions_car),
              title: const Text('Budget Transport'),
              subtitle: const Text('200 000 FCFA/mois'),
              onTap: () {
                Navigator.of(context).pop();
                Get.snackbar('Info', 'Modèle transport appliqué');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

}