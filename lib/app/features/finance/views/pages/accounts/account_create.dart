import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/finance_controller.dart';
import '../../../models/currency.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../routes/app_pages.dart';

class AccountCreate extends GetView<FinanceController> {
  const AccountCreate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final balanceController = TextEditingController(text: '0');

    final selectedCurrency = Currency.fcfa.obs;
    final selectedIcon = 'account_balance_wallet'.obs;
    final selectedColor = 'primary'.obs;
    final isCreating = false.obs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un Compte'),
        actions: [
          Obx(() => TextButton(
            onPressed: isCreating.value ? null : () async {
              if (formKey.currentState?.validate() ?? false) {
                isCreating.value = true;
                final balance = double.tryParse(balanceController.text) ?? 0.0;

                final success = await controller.createAccount(
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim(),
                  currency: selectedCurrency.value,
                  balance: balance,
                  icon: selectedIcon.value,
                  color: selectedColor.value,
                );

                isCreating.value = false;

                if (success) {
                  Get.back();
                }
              }
            },
            child: isCreating.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  'Créer',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
          )),
        ],
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              _buildBalanceField(balanceController),
              const SizedBox(height: 24),

              _buildSectionTitle('Personnalisation'),
              const SizedBox(height: 16),
              _buildIconSelector(selectedIcon),
              const SizedBox(height: 16),
              _buildColorSelector(selectedColor),
              const SizedBox(height: 32),

              _buildCreateButton(formKey, nameController, descriptionController,
                               balanceController, selectedCurrency, selectedIcon, selectedColor, isCreating),
            ],
          ),
        ),
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

  Widget _buildBalanceField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Solde initial',
        hintText: '0',
        prefixIcon: const Icon(Icons.money),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        helperText: 'Laissez à 0 si vous ne voulez pas définir de solde initial',
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final balance = double.tryParse(value);
          if (balance == null) {
            return 'Veuillez entrer un montant valide';
          }
        }
        return null;
      },
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

  Widget _buildCreateButton(
    GlobalKey<FormState> formKey,
    TextEditingController nameController,
    TextEditingController descriptionController,
    TextEditingController balanceController,
    Rx<Currency> selectedCurrency,
    RxString selectedIcon,
    RxString selectedColor,
    RxBool isCreating,
  ) {
    return SizedBox(
      width: double.infinity,
      child: Obx(() => ElevatedButton(
        onPressed: isCreating.value ? null : () async {
          if (formKey.currentState?.validate() ?? false) {
            isCreating.value = true;
            final balance = double.tryParse(balanceController.text) ?? 0.0;

            final success = await controller.createAccount(
              name: nameController.text.trim(),
              description: descriptionController.text.trim(),
              currency: selectedCurrency.value,
              balance: balance,
              icon: selectedIcon.value,
              color: selectedColor.value,
            );

            isCreating.value = false;

            if (success) {
              // Rediriger vers la liste des comptes
              Get.offAllNamed(AppRoutes.FINANCE_ACCOUNTS);
            }
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isCreating.value
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Création en cours...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          : const Text(
              'Créer le Compte',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
      )),
    );
  }
}