import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/finance_controller.dart';
import '../../../models/account_model.dart';
import '../../../models/currency.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../routes/app_pages.dart';

class AccountEdit extends GetView<FinanceController> {
  const AccountEdit({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AccountModel account = Get.arguments as AccountModel;
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(text: account.name);
    final descriptionController = TextEditingController(text: account.description);
    final balanceController = TextEditingController(text: account.balance.toString());

    final selectedCurrency = account.currency.obs;
    final selectedIcon = (account.icon ?? 'account_balance_wallet').obs;
    final selectedColor = (account.color ?? 'primary').obs;

    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier ${account.name}'),
        actions: [
          TextButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final success = await controller.updateAccount(
                  accountId: account.id,
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim(),
                  currency: selectedCurrency.value,
                  icon: selectedIcon.value,
                  color: selectedColor.value,
                );

                if (success) {
                  Get.back();
                }
              }
            },
            child: Text(
              'Enregistrer',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAccountPreview(account, nameController, selectedCurrency, selectedIcon, selectedColor),
              const SizedBox(height: 24),

              _buildSectionTitle('Informations générales'),
              const SizedBox(height: 16),
              _buildNameField(nameController),
              const SizedBox(height: 16),
              _buildDescriptionField(descriptionController),
              const SizedBox(height: 24),

              _buildSectionTitle('Configuration financière'),
              const SizedBox(height: 16),
              _buildCurrencySelector(selectedCurrency),
              const SizedBox(height: 16),
              _buildBalanceField(balanceController, account),
              const SizedBox(height: 24),

              _buildSectionTitle('Personnalisation'),
              const SizedBox(height: 16),
              _buildIconSelector(selectedIcon),
              const SizedBox(height: 16),
              _buildColorSelector(selectedColor),
              const SizedBox(height: 32),

              _buildActionButtons(formKey, account, nameController, descriptionController,
                                balanceController, selectedCurrency, selectedIcon, selectedColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountPreview(
    AccountModel account,
    TextEditingController nameController,
    Rx<Currency> selectedCurrency,
    RxString selectedIcon,
    RxString selectedColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.adaptiveEmptyStateBackground(Get.context!),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.adaptiveEmptyStateBorder(Get.context!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.preview, size: 20),
              const SizedBox(width: 8),
              Text(
                'Aperçu',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getColorFromString(selectedColor.value),
                  _getColorFromString(selectedColor.value).withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getIconFromString(selectedIcon.value),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nameController.text.isEmpty ? 'Nom du compte' : nameController.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        selectedCurrency.value.code,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  account.formattedBalance,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildNameField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Nom du compte *',
        hintText: 'Ex: Compte Principal, Épargne...',
        prefixIcon: const Icon(Icons.account_balance),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Le nom du compte est obligatoire';
        }
        if (value.trim().length < 2) {
          return 'Le nom doit contenir au moins 2 caractères';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Description (optionnel)',
        hintText: 'Décrivez l\'usage de ce compte...',
        prefixIcon: const Icon(Icons.description),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      maxLines: 2,
    );
  }

  Widget _buildCurrencySelector(Rx<Currency> selectedCurrency) {
    return Obx(() => DropdownButtonFormField<Currency>(
      value: selectedCurrency.value,
      decoration: InputDecoration(
        labelText: 'Devise *',
        prefixIcon: const Icon(Icons.currency_exchange),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: Currency.values.map((currency) {
        return DropdownMenuItem(
          value: currency,
          child: Row(
            children: [
              Text(
                currency.symbol,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text('${currency.code} - ${currency.name}'),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          selectedCurrency.value = value;
        }
      },
      validator: (value) {
        if (value == null) {
          return 'Veuillez sélectionner une devise';
        }
        return null;
      },
    ));
  }

  Widget _buildBalanceField(TextEditingController controller, AccountModel account) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: AppColors.warning, size: 20),
              const SizedBox(width: 8),
              Text(
                'Solde du compte',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Le solde actuel est de ${account.formattedBalance}. Pour modifier le solde, veuillez ajouter une transaction.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Get.toNamed(AppRoutes.FINANCE_ADD_TRANSACTION, arguments: account),
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter Transaction'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Get.toNamed(AppRoutes.FINANCE_TRANSACTIONS, arguments: {'accountId': account.id}),
                  icon: const Icon(Icons.list),
                  label: const Text('Voir Transactions'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconSelector(RxString selectedIcon) {
    final icons = {
      'account_balance_wallet': Icons.account_balance_wallet,
      'account_balance': Icons.account_balance,
      'savings': Icons.savings,
      'credit_card': Icons.credit_card,
      'payments': Icons.payments,
      'monetization_on': Icons.monetization_on,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Icône du compte',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => Wrap(
          spacing: 12,
          runSpacing: 12,
          children: icons.entries.map((entry) {
            final isSelected = selectedIcon.value == entry.key;
            return GestureDetector(
              onTap: () => selectedIcon.value = entry.key,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Get.theme.cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.grey300,
                  ),
                ),
                child: Icon(
                  entry.value,
                  color: isSelected ? Colors.white : AppColors.grey600,
                  size: 24,
                ),
              ),
            );
          }).toList(),
        )),
      ],
    );
  }

  Widget _buildColorSelector(RxString selectedColor) {
    final colors = {
      'primary': AppColors.primary,
      'secondary': AppColors.secondary,
      'success': AppColors.success,
      'warning': AppColors.warning,
      'error': AppColors.error,
      'purple': Colors.purple,
      'orange': Colors.orange,
      'teal': Colors.teal,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Couleur du compte',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colors.entries.map((entry) {
            final isSelected = selectedColor.value == entry.key;
            return GestureDetector(
              onTap: () => selectedColor.value = entry.key,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: entry.value,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? AppColors.grey800 : AppColors.grey300,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      )
                    : null,
              ),
            );
          }).toList(),
        )),
      ],
    );
  }

  Widget _buildActionButtons(
    GlobalKey<FormState> formKey,
    AccountModel account,
    TextEditingController nameController,
    TextEditingController descriptionController,
    TextEditingController balanceController,
    Rx<Currency> selectedCurrency,
    RxString selectedIcon,
    RxString selectedColor,
  ) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final success = await controller.updateAccount(
                  accountId: account.id,
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim(),
                  currency: selectedCurrency.value,
                  icon: selectedIcon.value,
                  color: selectedColor.value,
                );

                if (success) {
                  Get.back();
                }
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Enregistrer les Modifications',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _showDeleteConfirmation(account),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              side: BorderSide(color: AppColors.error),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Supprimer le Compte',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(AccountModel account) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Êtes-vous sûr de vouloir supprimer le compte "${account.name}" ?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cette action est irréversible et supprimera toutes les transactions associées.',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Get.back(); // Fermer la dialog

              final success = await controller.deleteAccount(account.id);

              if (success) {
                Get.back(); // Fermer la page d'édition
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  Color _getColorFromString(String colorName) {
    switch (colorName) {
      case 'primary': return AppColors.primary;
      case 'secondary': return AppColors.secondary;
      case 'success': return AppColors.success;
      case 'warning': return AppColors.warning;
      case 'error': return AppColors.error;
      case 'purple': return Colors.purple;
      case 'orange': return Colors.orange;
      case 'teal': return Colors.teal;
      default: return AppColors.primary;
    }
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'account_balance': return Icons.account_balance;
      case 'savings': return Icons.savings;
      case 'credit_card': return Icons.credit_card;
      case 'payments': return Icons.payments;
      case 'monetization_on': return Icons.monetization_on;
      default: return Icons.account_balance_wallet;
    }
  }
}