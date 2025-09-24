import 'package:cothia_app/app/core/utils/get_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../controllers/transactions_controller.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../models/transaction_model.dart';
import '../../../models/account_model.dart';

class TransactionCreatePage extends StatefulWidget {
  final TransactionModel? transaction; // Pour l'édition

  const TransactionCreatePage({super.key, this.transaction});

  @override
  State<TransactionCreatePage> createState() => _TransactionCreatePageState();
}

class _TransactionCreatePageState extends State<TransactionCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  TransactionStatus _selectedStatus = TransactionStatus.validated;
  String? _selectedSourceAccountId;
  String? _selectedDestinationAccountId;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadTransactionData();
    }
  }

  void _loadTransactionData() {
    final transaction = widget.transaction!;
    _titleController.text = transaction.title;
    _amountController.text = transaction.amount.toStringAsFixed(0);
    _descriptionController.text = transaction.description ?? '';
    _selectedType = transaction.type;
    _selectedStatus = transaction.status;
    _selectedSourceAccountId = transaction.sourceAccountId;
    _selectedDestinationAccountId = transaction.destinationAccountId;
    _selectedDate = transaction.transactionDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier la Transaction' : 'Nouvelle Transaction'),
        centerTitle: true,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteDialog(),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 24),
              _buildTransactionTypeSection(),
              const SizedBox(height: 24),
              _buildBasicInfoSection(),
              const SizedBox(height: 24),
              _buildAccountsSection(),
              const SizedBox(height: 24),
              _buildDateSection(),
              const SizedBox(height: 24),
              _buildStatusSection(),
              const SizedBox(height: 24),
              _buildAdditionalInfoSection(),
              const SizedBox(height: 32),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: _getTypeColor(_selectedType).withOpacity(0.1),
              child: Icon(
                _getTypeIcon(_selectedType),
                color: _getTypeColor(_selectedType),
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isEditing ? 'Modification de transaction' : 'Nouvelle transaction',
                    style: Get.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _getTypeDescription(_selectedType),
                    style: Get.textTheme.bodyMedium?.copyWith(
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

  Widget _buildTransactionTypeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type de transaction',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: TransactionType.values.map((type) {
                final isSelected = _selectedType == type;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () => setState(() => _selectedType = type),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _getTypeColor(type).withOpacity(0.1)
                              : AppColors.surface,
                          border: Border.all(
                            color: isSelected
                                ? _getTypeColor(type)
                                : AppColors.hint.withOpacity(0.3),
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _getTypeIcon(type),
                              color: isSelected ? _getTypeColor(type) : AppColors.hint,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getTypeDisplayName(type),
                              style: Get.textTheme.bodyMedium?.copyWith(
                                color: isSelected ? _getTypeColor(type) : AppColors.hint,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations de base',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Titre *',
                hintText: 'Ex: Achat supermarché',
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le titre est requis';
                }
                if (value.trim().length < 2) {
                  return 'Le titre doit contenir au moins 2 caractères';
                }
                return null;
              },
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Montant *',
                hintText: '0',
                prefixIcon: const Icon(Icons.money),
                suffixText: 'FCFA',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le montant est requis';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Veuillez saisir un montant valide';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comptes',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedType == TransactionType.transfer) ...[
              // Transfert : Source et Destination
              GetBuilder<TransactionsController>(
                builder: (controller) => DropdownButtonFormField<String>(
                  value: _selectedSourceAccountId,
                  decoration: InputDecoration(
                    labelText: 'Compte source *',
                    prefixIcon: const Icon(Icons.account_balance),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: controller.accounts.map((account) {
                    return DropdownMenuItem(
                      value: account.id,
                      child: Text('${account.name} (${account.currentBalance.toStringAsFixed(0)} FCFA)'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedSourceAccountId = value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Sélectionnez un compte source';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              GetBuilder<TransactionsController>(
                builder: (controller) => DropdownButtonFormField<String>(
                  value: _selectedDestinationAccountId,
                  decoration: InputDecoration(
                    labelText: 'Compte destination *',
                    prefixIcon: const Icon(Icons.account_balance_wallet),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: controller.accounts
                      .where((account) => account.id != _selectedSourceAccountId)
                      .map((account) {
                    return DropdownMenuItem(
                      value: account.id,
                      child: Text('${account.name} (${account.currentBalance.toStringAsFixed(0)} FCFA)'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedDestinationAccountId = value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Sélectionnez un compte destination';
                    }
                    return null;
                  },
                ),
              ),
            ] else if (_selectedType == TransactionType.income) ...[
              // Revenu : Destination seulement
              GetBuilder<TransactionsController>(
                builder: (controller) => DropdownButtonFormField<String>(
                  value: _selectedDestinationAccountId,
                  decoration: InputDecoration(
                    labelText: 'Compte destinataire *',
                    prefixIcon: const Icon(Icons.account_balance_wallet),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: controller.accounts.map((account) {
                    return DropdownMenuItem(
                      value: account.id,
                      child: Text('${account.name} (${account.currentBalance.toStringAsFixed(0)} FCFA)'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedDestinationAccountId = value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Sélectionnez un compte destinataire';
                    }
                    return null;
                  },
                ),
              ),
            ] else ...[
              // Dépense : Source seulement
              GetBuilder<TransactionsController>(
                builder: (controller) => DropdownButtonFormField<String>(
                  value: _selectedSourceAccountId,
                  decoration: InputDecoration(
                    labelText: 'Compte source *',
                    prefixIcon: const Icon(Icons.account_balance),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: controller.accounts.map((account) {
                    return DropdownMenuItem(
                      value: account.id,
                      child: Text('${account.name} (${account.currentBalance.toStringAsFixed(0)} FCFA)'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedSourceAccountId = value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Sélectionnez un compte source';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date de la transaction',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDate(),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.hint.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 12),
                    Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: Get.textTheme.bodyLarge,
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statut',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TransactionStatus.values.map((status) {
                final isSelected = _selectedStatus == status;
                return InkWell(
                  onTap: () => setState(() => _selectedStatus = status),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _getStatusColor(status).withOpacity(0.1)
                          : AppColors.surface,
                      border: Border.all(
                        color: isSelected
                            ? _getStatusColor(status)
                            : AppColors.hint.withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusDisplayName(status),
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: isSelected ? _getStatusColor(status) : AppColors.hint,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations complémentaires',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description (optionnelle)',
                hintText: 'Ajoutez une note ou description...',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
              maxLength: 200,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _saveTransaction,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(_isEditing ? Icons.save : Icons.add),
            label: Text(_isEditing ? 'Enregistrer les modifications' : 'Créer la transaction'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : () => Get.safeBack(),
            icon: const Icon(Icons.cancel),
            label: const Text('Annuler'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.hint,
              side: BorderSide(color: AppColors.hint),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper methods
  Color _getTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return AppColors.success;
      case TransactionType.expense:
        return AppColors.error;
      case TransactionType.transfer:
        return AppColors.primary;
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

  String _getTypeDescription(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return 'Argent entrant dans vos comptes';
      case TransactionType.expense:
        return 'Argent sortant de vos comptes';
      case TransactionType.transfer:
        return 'Transfert entre vos comptes';
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

  String _getStatusDisplayName(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.validated:
        return 'Validée';
      case TransactionStatus.pending:
        return 'En attente';
      case TransactionStatus.planned:
        return 'Prévue';
      case TransactionStatus.cancelled:
        return 'Annulée';
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final controller = Get.find<TransactionsController>();
      final amount = double.parse(_amountController.text);
      bool success = false;

      if (_isEditing) {
        // Mise à jour
        final updatedTransaction = widget.transaction!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          amount: amount,
          type: _selectedType,
          status: _selectedStatus,
          sourceAccountId: _selectedSourceAccountId,
          destinationAccountId: _selectedDestinationAccountId,
          transactionDate: _selectedDate,
          updatedAt: DateTime.now(),
        );

        success = await controller.updateTransaction(widget.transaction!.id, updatedTransaction);
      } else {
        // Création
        final newTransaction = TransactionModel(
          id: '',
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          amount: amount,
          type: _selectedType,
          status: _selectedStatus,
          sourceAccountId: _selectedSourceAccountId,
          destinationAccountId: _selectedDestinationAccountId,
          entityId: '', // Sera défini par le service
          transactionDate: _selectedDate,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        success = await controller.createTransaction(newTransaction);
      }

      if (success) {
        Get.safeBack();
      }

    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur inattendue: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showDeleteDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Supprimer la transaction'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer la transaction "${widget.transaction!.title}" ?\n\nCette action est irréversible.',
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
    setState(() => _isLoading = true);

    try {
      final controller = Get.find<TransactionsController>();
      final success = await controller.deleteTransaction(widget.transaction!.id);

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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}