import 'package:cothia_app/app/core/utils/get_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../controllers/finance_controller.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../models/account_model.dart';

class AccountCreatePage extends StatefulWidget {
  final AccountModel? account; // Pour l'édition

  const AccountCreatePage({super.key, this.account});

  @override
  State<AccountCreatePage> createState() => _AccountCreatePageState();
}

class _AccountCreatePageState extends State<AccountCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _initialBalanceController = TextEditingController();
  final _descriptionController = TextEditingController();

  AccountType _selectedType = AccountType.checking;
  bool _isLoading = false;
  bool get _isEditing => widget.account != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadAccountData();
    }
  }

  void _loadAccountData() {
    final account = widget.account!;
    _nameController.text = account.name;
    _initialBalanceController.text = account.currentBalance.toStringAsFixed(0);
    _descriptionController.text = account.description ?? '';
    _selectedType = account.type;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _initialBalanceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier le Compte' : 'Créer un Compte'),
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
              _buildBasicInfoSection(),
              const SizedBox(height: 24),
              _buildAccountTypeSection(),
              const SizedBox(height: 24),
              _buildFinancialInfoSection(),
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
              backgroundColor: AppColors.secondary.withOpacity(0.1),
              child: Icon(
                _getAccountIcon(_selectedType),
                color: AppColors.secondary,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isEditing ? 'Modification de compte' : 'Nouveau compte',
                    style: Get.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _isEditing
                        ? 'Modifiez les informations de votre compte'
                        : 'Créez un nouveau compte pour gérer vos finances',
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
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nom du compte *',
                hintText: 'Ex: Compte courant principal',
                prefixIcon: const Icon(Icons.account_balance),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le nom du compte est requis';
                }
                if (value.trim().length < 2) {
                  return 'Le nom doit contenir au moins 2 caractères';
                }
                return null;
              },
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountTypeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type de compte',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: AccountType.values.map((type) {
                final isSelected = _selectedType == type;
                return InkWell(
                  onTap: () => setState(() => _selectedType = type),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.secondary.withOpacity(0.1)
                          : AppColors.surface,
                      border: Border.all(
                        color: isSelected ? AppColors.secondary : AppColors.hint.withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getAccountIcon(type),
                          color: isSelected ? AppColors.secondary : AppColors.hint,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getAccountTypeDisplayName(type),
                          style: Get.textTheme.bodyMedium?.copyWith(
                            color: isSelected ? AppColors.secondary : AppColors.hint,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.info, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getAccountTypeDescription(_selectedType),
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

  Widget _buildFinancialInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations financières',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _initialBalanceController,
              decoration: InputDecoration(
                labelText: _isEditing ? 'Solde actuel *' : 'Solde initial *',
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
                  return 'Le solde est requis';
                }
                final balance = double.tryParse(value);
                if (balance == null) {
                  return 'Veuillez saisir un montant valide';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.hint.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: AppColors.hint, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isEditing
                          ? 'Modifiez le solde actuel si nécessaire'
                          : 'Saisissez le montant actuel sur ce compte',
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: AppColors.hint,
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
                hintText: 'Ajoutez une description pour ce compte...',
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
            onPressed: _isLoading ? null : _saveAccount,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(_isEditing ? Icons.save : Icons.add),
            label: Text(_isEditing ? 'Enregistrer les modifications' : 'Créer le compte'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
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
            onPressed: _isLoading ? null : () => Get.back(),
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

  IconData _getAccountIcon(AccountType type) {
    switch (type) {
      case AccountType.checking:
        return Icons.account_balance;
      case AccountType.savings:
        return Icons.savings;
      case AccountType.cash:
        return Icons.money;
      case AccountType.credit:
        return Icons.credit_card;
      case AccountType.virtual:
        return Icons.account_balance_wallet;
    }
  }

  String _getAccountTypeDisplayName(AccountType type) {
    switch (type) {
      case AccountType.checking:
        return 'Compte courant';
      case AccountType.savings:
        return 'Compte épargne';
      case AccountType.cash:
        return 'Espèces';
      case AccountType.credit:
        return 'Carte de crédit';
      case AccountType.virtual:
        return 'Portefeuille virtuel';
    }
  }

  String _getAccountTypeDescription(AccountType type) {
    switch (type) {
      case AccountType.checking:
        return 'Compte bancaire pour les transactions quotidiennes';
      case AccountType.savings:
        return 'Compte d\'épargne pour économiser de l\'argent';
      case AccountType.cash:
        return 'Argent liquide en main';
      case AccountType.credit:
        return 'Carte de crédit avec limite de crédit';
      case AccountType.virtual:
        return 'Portefeuille numérique (Mobile Money, etc.)';
    }
  }

  Future<void> _saveAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final controller = Get.find<FinanceController>();
      final balance = double.parse(_initialBalanceController.text);
      bool success = false;

      if (_isEditing) {
        // Mise à jour du compte existant
        final updatedAccount = widget.account!.copyWith(
          name: _nameController.text.trim(),
          type: _selectedType,
          currentBalance: balance,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          updatedAt: DateTime.now(),
        );

        success = await controller.updateAccount(updatedAccount);
      } else {
        // Création d'un nouveau compte
        success = await controller.createAccount(
          name: _nameController.text.trim(),
          type: _selectedType,
          initialBalance: balance,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        );
      }

      // Retour automatique à la page précédente si succès
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
        title: const Text('Supprimer le compte'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer le compte "${widget.account!.name}" ?\n\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => _deleteAccount(),
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

  Future<void> _deleteAccount() async {
    Get.back(); // Fermer le dialog
    setState(() => _isLoading = true);

    try {
      final controller = Get.find<FinanceController>();
      final success = await controller.deleteAccount(widget.account!.id);

      // Retour automatique à la page précédente si succès
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