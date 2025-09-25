import 'package:cothia_app/app/core/utils/get_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/transactions_controller.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../models/transaction_model.dart';
import 'transaction_create_page.dart';

class TransactionDetailsPage extends StatelessWidget {
  final TransactionModel? transaction;

  const TransactionDetailsPage({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    // Vérifier si la transaction est null
    if (transaction == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Erreur'),
          centerTitle: true,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Transaction non trouvée',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('La transaction que vous cherchez n\'existe pas ou n\'a pas pu être chargée.'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Détails Transaction'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editTransaction(),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'validate':
                  _validateTransaction();
                  break;
                case 'duplicate':
                  _duplicateTransaction();
                  break;
                case 'delete':
                  _showDeleteDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              if (transaction!.status == TransactionStatus.pending)
                const PopupMenuItem(
                  value: 'validate',
                  child: Row(
                    children: [
                      Icon(Icons.check, size: 20, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Valider'),
                    ],
                  ),
                ),
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
            _buildTransactionHeader(),
            const SizedBox(height: 24),
            _buildTransactionInfo(),
            const SizedBox(height: 24),
            _buildAccountsInfo(),
            const SizedBox(height: 24),
            _buildStatusInfo(),
            const SizedBox(height: 24),
            _buildQuickActions(),
            if (transaction!.description != null && transaction!.description!.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildDescription(),
            ],
          ],
        ),
      ),
      floatingActionButton: transaction!. status == TransactionStatus.pending
          ? FloatingActionButton.extended(
              onPressed: () => _validateTransaction(),
              backgroundColor: AppColors.success,
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text('Valider', style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }

  Widget _buildTransactionHeader() {
    final isIncome = transaction!.type == TransactionType.income;
    final isTransfer = transaction!.type == TransactionType.transfer;

    Color color;
    IconData icon;
    String prefix;

    if (isTransfer) {
      color = AppColors.primary;
      icon = Icons.swap_horiz;
      prefix = '';
    } else if (isIncome) {
      color = AppColors.success;
      icon = Icons.arrow_downward;
      prefix = '+';
    } else {
      color = AppColors.error;
      icon = Icons.arrow_upward;
      prefix = '-';
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
                  backgroundColor: color.withOpacity(0.1),
                  child: Icon(
                    icon,
                    color: color,
                    size: 35,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction!.title,
                        style: Get.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getTypeDisplayName(transaction!.type),
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
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'Montant',
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: AppColors.hint,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$prefix${transaction!  .amount.toStringAsFixed(0)} FCFA',
                    style: Get.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
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

  Widget _buildTransactionInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations générales',
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Type',
              _getTypeDisplayName(transaction!.type),
              _getTypeIcon(transaction!.type),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Date',
              _formatDate(transaction!.transactionDate),
              Icons.calendar_today,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Créée le',
              _formatDateTime(transaction!.createdAt),
              Icons.access_time,
            ),
            if (transaction!.updatedAt != transaction!.createdAt) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                'Modifiée le',
                _formatDateTime(transaction!.updatedAt),
                Icons.update,
              ),
            ],

            // Liaison avec projet et tâche
            if (transaction!.projectId != null || transaction!.taskId != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Liaisons',
                style: Get.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),

              if (transaction!.projectId != null)
                _buildInfoRow(
                  'Projet lié',
                  transaction!.projectId!, // TODO: Récupérer le nom du projet réel
                  Icons.folder_special,
                ),

              if (transaction!.taskId != null) ...[
                if (transaction!.projectId != null) const SizedBox(height: 12),
                _buildInfoRow(
                  'Tâche liée',
                  transaction!.taskId!, // TODO: Récupérer le nom de la tâche réelle
                  Icons.task_alt,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAccountsInfo() {
    final controller = Get.find<TransactionsController>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comptes concernés',
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (transaction!.sourceAccountId != null) ...[
              _buildAccountRow(
                'Compte source',
                _getAccountName(controller, transaction!.sourceAccountId!),
                Icons.account_balance,
                AppColors.error,
              ),
              if (transaction!.destinationAccountId != null) const SizedBox(height: 12),
            ],
            if (transaction!.destinationAccountId != null) ...[
              _buildAccountRow(
                'Compte destination',
                _getAccountName(controller, transaction!.destinationAccountId!),
                Icons.account_balance_wallet,
                AppColors.success,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusInfo() {
    final statusColor = _getStatusColor(transaction!.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statut et état',
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(transaction!.status),
                    color: statusColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction!.statusDisplayName,
                          style: Get.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                        Text(
                          _getStatusDescription(transaction!.status),
                          style: Get.textTheme.bodySmall?.copyWith(
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
                    'Modifier',
                    Icons.edit,
                    AppColors.primary,
                    () => _editTransaction(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'Dupliquer',
                    Icons.copy,
                    AppColors.secondary,
                    () => _duplicateTransaction(),
                  ),
                ),
              ],
            ),
            if (transaction!.status == TransactionStatus.pending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      'Valider',
                      Icons.check,
                      AppColors.success,
                      () => _validateTransaction(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      'Annuler',
                      Icons.cancel,
                      AppColors.error,
                      () => _cancelTransaction(),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.hint.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                transaction!.description!,
                style: Get.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.hint),
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

  Widget _buildAccountRow(String label, String accountName, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
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
                accountName,
                style: Get.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
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

  // Helper methods
  String _getTypeDisplayName(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return 'Revenu';
      case TransactionType.expense:
        return 'Dépense';
      case TransactionType.transfer:
        return 'Transfert';
    }
  }

  IconData _getTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return Icons.arrow_downward;
      case TransactionType.expense:
        return Icons.arrow_upward;
      case TransactionType.transfer:
        return Icons.swap_horiz;
    }
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.validated:
        return AppColors.success;
      case TransactionStatus.pending:
        return AppColors.secondary;
      case TransactionStatus.planned:
        return AppColors.info;
      case TransactionStatus.cancelled:
        return AppColors.error;
    }
  }

  IconData _getStatusIcon(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.validated:
        return Icons.check_circle;
      case TransactionStatus.pending:
        return Icons.pending;
      case TransactionStatus.planned:
        return Icons.schedule;
      case TransactionStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusDescription(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.validated:
        return 'Transaction confirmée et comptabilisée';
      case TransactionStatus.pending:
        return 'En attente de validation';
      case TransactionStatus.planned:
        return 'Programmée pour plus tard';
      case TransactionStatus.cancelled:
        return 'Transaction annulée';
    }
  }

  String _getAccountName(TransactionsController controller, String accountId) {
    final account = controller.accounts.where((a) => a.id == accountId).firstOrNull;
    return account?.name ?? 'Compte inconnu';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _editTransaction() {
    Get.to(() => TransactionCreatePage(transaction: transaction));
  }

  void _duplicateTransaction() {
    // Créer une copie avec un nouveau titre
    final duplicatedTransaction = transaction!.copyWith(
      id: '',
      title: '${transaction!.title} (copie)',
      status: TransactionStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Get.to(() => TransactionCreatePage(transaction: duplicatedTransaction));
  }

  Future<void> _validateTransaction() async {
    try {
      final controller = Get.find<TransactionsController>();
      await controller.validateTransaction(transaction!.id);

      Get.snackbar(
        'Succès',
        'Transaction validée avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );

      Get.safeBack();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de valider la transaction: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _cancelTransaction() async {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Annuler la transaction'),
        content: const Text('Êtes-vous sûr de vouloir annuler cette transaction ?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              try {
                final controller = Get.find<TransactionsController>();
                final cancelledTransaction = transaction!.copyWith(
                  status: TransactionStatus.cancelled,
                  updatedAt: DateTime.now(),
                );
                await controller.updateTransaction(transaction!.id, cancelledTransaction);
                Get.safeBack();
              } catch (e) {
                Get.snackbar(
                  'Erreur',
                  'Impossible d\'annuler la transaction: $e',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.error,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Supprimer la transaction'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer la transaction "${transaction!.title}" ?\n\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => _deleteTransaction(),
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

  Future<void> _deleteTransaction() async {
    Get.back(); // Fermer le dialog

    try {
      final controller = Get.find<TransactionsController>();
      final success = await controller.deleteTransaction(transaction!.id);

      if (success) {
        Get.safeBack();
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur inattendue lors de la suppression: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }
}