import 'package:cothia_app/app/features/finance/controllers/categories_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/budgets_controller.dart';
import '../../../controllers/finance_controller.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../models/budget_model.dart';
import 'budget_create_page.dart';
import '../../../../../core/utils/get_extensions.dart';

class BudgetDetailsPage extends StatelessWidget {
  final BudgetModel budget;

  const BudgetDetailsPage({super.key, required this.budget});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(budget.name),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editBudget(),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'duplicate':
                  _duplicateBudget();
                  break;
                case 'reset':
                  _showResetDialog();
                  break;
                case 'delete':
                  _showDeleteDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.copy, size: 20),
                    SizedBox(width: 8),
                    Text('Dupliquer'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 20),
                    SizedBox(width: 8),
                    Text('Remettre à zéro'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Supprimer', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBudgetHeader(),
            const SizedBox(height: 24),
            _buildProgressCard(),
            const SizedBox(height: 24),
            _buildBudgetInfo(),
            const SizedBox(height: 24),
            _buildPeriodInfo(),
            const SizedBox(height: 24),
            if (budget.hasAutomation) _buildAutomationInfo(),
            if (budget.hasAutomation) const SizedBox(height: 24),
            _buildQuickActions(),
            const SizedBox(height: 24),
            _buildTransactionHistory(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _adjustBudgetAmount(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.tune, color: Colors.white),
        label: const Text('Ajuster', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildBudgetHeader() {
    final progressPercentage = budget.progressPercentage;
    final isOverBudget = budget.isOverBudget;
    final isUnderTarget = budget.isUnderTarget;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (budget.isExpenseBudget) {
      if (isOverBudget) {
        statusColor = AppColors.error;
        statusText = 'Budget dépassé';
        statusIcon = Icons.warning;
      } else if (progressPercentage >= 80) {
        statusColor = Colors.orange;
        statusText = 'Attention au budget';
        statusIcon = Icons.info;
      } else {
        statusColor = AppColors.success;
        statusText = 'Dans le budget';
        statusIcon = Icons.check_circle;
      }
    } else {
      if (progressPercentage >= 100) {
        statusColor = AppColors.success;
        statusText = 'Objectif atteint';
        statusIcon = Icons.check_circle;
      } else if (progressPercentage >= 50) {
        statusColor = Colors.orange;
        statusText = 'En progression';
        statusIcon = Icons.trending_up;
      } else {
        statusColor = AppColors.error;
        statusText = 'Objectif non atteint';
        statusIcon = Icons.trending_down;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: budget.isExpenseBudget
                      ? AppColors.error.withOpacity(0.1)
                      : AppColors.success.withOpacity(0.1),
                  child: Icon(
                    budget.isExpenseBudget ? Icons.trending_down : Icons.savings,
                    color: budget.isExpenseBudget ? AppColors.error : AppColors.success,
                    size: 35,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        budget.name,
                        style: Get.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        budget.typeDisplayName,
                        style: Get.textTheme.bodyLarge?.copyWith(
                          color: AppColors.hint,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statusText,
                          style: Get.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                        Text(
                          '${progressPercentage.toStringAsFixed(1)}% ${budget.isExpenseBudget ? 'utilisé' : 'atteint'}',
                          style: Get.textTheme.bodyMedium?.copyWith(
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    final progressPercentage = budget.progressPercentage;
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
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progression',
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Actuel',
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: AppColors.hint,
                      ),
                    ),
                    Text(
                      '${budget.currentAmount.toStringAsFixed(0)} FCFA',
                      style: Get.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: progressColor,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Objectif',
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: AppColors.hint,
                      ),
                    ),
                    Text(
                      '${budget.targetAmount.toStringAsFixed(0)} FCFA',
                      style: Get.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.hint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progressPercentage / 100,
                backgroundColor: AppColors.hint.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${progressPercentage.toStringAsFixed(1)}%',
                  style: Get.textTheme.bodyMedium?.copyWith(
                    color: progressColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (budget.remainingAmount != 0)
                  Text(
                    budget.isExpenseBudget
                        ? 'Reste: ${budget.remainingAmount.toStringAsFixed(0)} FCFA'
                        : 'Manque: ${budget.remainingAmount.abs().toStringAsFixed(0)} FCFA',
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: AppColors.hint,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetInfo() {
    final controller = Get.find<CategoriesController>();
    final category = budget.categoryId != null
        ? controller.categories.where((c) => c.id == budget.categoryId).firstOrNull
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations du budget',
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Type',
              budget.typeDisplayName,
              budget.isExpenseBudget ? Icons.trending_down : Icons.savings,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Période',
              budget.periodDisplayName,
              Icons.schedule,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Devise',
              budget.currency,
              Icons.currency_exchange,
            ),
            if (category != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                'Catégorie',
                category.name,
                category.icon,
                iconColor: category.color,
              ),
            ],
            if (budget.description != null && budget.description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Description',
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                budget.description!,
                style: Get.textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {Color? iconColor}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor ?? AppColors.hint),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Get.textTheme.bodySmall?.copyWith(
                  color: AppColors.hint,
                ),
              ),
              Text(
                value,
                style: Get.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Période actuelle',
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Début',
                        style: Get.textTheme.bodySmall?.copyWith(
                          color: AppColors.hint,
                        ),
                      ),
                      Text(
                        _formatDate(budget.currentPeriodStart),
                        style: Get.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Fin',
                        style: Get.textTheme.bodySmall?.copyWith(
                          color: AppColors.hint,
                        ),
                      ),
                      Text(
                        _formatDate(budget.currentPeriodEnd),
                        style: Get.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.info.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: AppColors.info, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Les montants sont calculés pour cette période',
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutomationInfo() {
    final automation = budget.automationRule!;
    final controller = Get.find<FinanceController>();

    final sourceAccount = automation.sourceAccountId != null
        ? controller.accounts.where((a) => a.id == automation.sourceAccountId).firstOrNull
        : null;
    final destinationAccount = automation.destinationAccountId != null
        ? controller.accounts.where((a) => a.id == automation.destinationAccountId).firstOrNull
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_mode, color: AppColors.info),
                const SizedBox(width: 8),
                Text(
                  'Automatisation active',
                  style: Get.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (sourceAccount != null)
              _buildInfoRow(
                'Compte source',
                sourceAccount.name,
                Icons.account_balance,
              ),
            if (destinationAccount != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                'Compte destination',
                destinationAccount.name,
                Icons.savings,
              ),
            ],
            const SizedBox(height: 12),
            _buildInfoRow(
              'Montant automatique',
              '${automation.amount.toStringAsFixed(0)} FCFA',
              Icons.attach_money,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Jour d\'exécution',
              '${automation.dayOfMonth} de chaque mois',
              Icons.today,
            ),
            if (automation.description != null && automation.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                'Description',
                automation.description!,
                Icons.description,
              ),
            ],
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
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Ajuster montant',
                    Icons.tune,
                    AppColors.primary,
                    () => _adjustBudgetAmount(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'Dupliquer',
                    Icons.copy,
                    AppColors.secondary,
                    () => _duplicateBudget(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Remettre à zéro',
                    Icons.refresh,
                    Colors.orange,
                    () => _showResetDialog(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'Historique',
                    Icons.history,
                    AppColors.info,
                    () => _viewHistory(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: Get.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHistory() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transactions liées',
                  style: Get.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => _viewHistory(),
                  child: const Text('Voir tout'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 48,
                    color: AppColors.hint,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Historique des transactions',
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: AppColors.hint,
                    ),
                  ),
                  Text(
                    'Transactions liées au budget',
                    style: Get.textTheme.bodySmall?.copyWith(
                      color: AppColors.hint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _editBudget() {
    Get.to(() => BudgetCreatePage(budget: budget));
  }

  void _duplicateBudget() {
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

  void _adjustBudgetAmount() {
    final controller = TextEditingController(
      text: budget.currentAmount.toStringAsFixed(0),
    );

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Ajuster le montant'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Montant actuel: ${budget.currentAmount.toStringAsFixed(0)} FCFA'),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Nouveau montant',
                suffixText: 'FCFA',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => _updateBudgetAmount(controller.text),
            child: const Text('Mettre à jour'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateBudgetAmount(String amountText) async {
    Get.back();
    final amount = double.tryParse(amountText);
    if (amount == null) {
      Get.snackbar('Erreur', 'Montant invalide');
      return;
    }

    final controller = Get.find<BudgetsController>();
    await controller.updateBudget(budget.copyWith(currentAmount: amount));
  }

  void _showResetDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Remettre à zéro'),
        content: Text(
          'Êtes-vous sûr de vouloir remettre le montant actuel de ce budget à zéro ?\n\nCette action ne peut pas être annulée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => _resetBudget(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remettre à zéro'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetBudget() async {
    Get.back();
    final controller = Get.find<BudgetsController>();
    await controller.updateBudget(budget.copyWith(currentAmount: 0.0));
  }

  void _showDeleteDialog() {
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
            onPressed: () => _deleteBudget(),
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

  Future<void> _deleteBudget() async {
    Get.back();
    final controller = Get.find<BudgetsController>();
    final success = await controller.deleteBudget(budget.id);
    if (success) {
      Get.safeBack();
    }
  }

  void _viewHistory() {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('Historique des transactions'),
        content: Container(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              Text('Budget: ${budget.name}'),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: 5, // Exemple
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.2),
                        child: Icon(
                          Icons.shopping_cart,
                          color: AppColors.primary,
                        ),
                      ),
                      title: Text('Transaction ${index + 1}'),
                      subtitle: Text('Catégorie associée'),
                      trailing: Text(
                        '${(index + 1) * 25000} FCFA',
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Get.toNamed('/finance/transactions');
            },
            child: const Text('Voir toutes'),
          ),
        ],
      ),
    );
  }
}