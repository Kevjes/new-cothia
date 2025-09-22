import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/budgets_controller.dart';
import '../../../controllers/finance_controller.dart';
import '../../../models/budget_model.dart';
import '../../../models/currency.dart';
import '../../../models/account_model.dart';
import '../../../../../core/theme/app_colors.dart';

class BudgetCreate extends GetView<BudgetsController> {
  const BudgetCreate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();

    final selectedType = BudgetType.budget.obs;
    final selectedCurrency = Currency.defaultCurrency.obs;
    final selectedPeriod = BudgetPeriod.monthly.obs;
    final selectedAccount = Rxn<AccountModel>();
    final selectedIcon = 'account_balance_wallet'.obs;
    final selectedColor = 'primary'.obs;
    final isRecurrent = false.obs;
    final isCreating = false.obs;

    final startDate = DateTime.now().obs;
    final endDate = DateTime.now().add(Duration(days: 30)).obs;


    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text('Créer ${selectedType.value.label}')),
        actions: [
          Obx(() => TextButton(
            onPressed: isCreating.value ? null : () async {
              if (formKey.currentState?.validate() ?? false) {
                isCreating.value = true;
                final amount = double.tryParse(amountController.text) ?? 0.0;

                final success = await controller.createBudget(
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim(),
                  type: selectedType.value,
                  amount: amount,
                  currency: selectedCurrency.value,
                  period: selectedPeriod.value,
                  startDate: startDate.value,
                  endDate: endDate.value,
                  categoryIds: [], // TODO: Implémentez la sélection de catégories
                  accountId: selectedAccount.value?.id,
                  isRecurrent: isRecurrent.value,
                  icon: selectedIcon.value,
                  color: selectedColor.value,
                );

                isCreating.value = false;

                if (success) {
                  Get.offAllNamed('/finance/budgets');
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
              _buildTypeSelector(selectedType),
              const SizedBox(height: 24),

              _buildSectionTitle('Informations générales'),
              const SizedBox(height: 16),
              _buildNameField(nameController),
              const SizedBox(height: 16),
              _buildDescriptionField(descriptionController),
              const SizedBox(height: 24),

              _buildSectionTitle('Configuration financière'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildAmountField(amountController)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildCurrencySelector(selectedCurrency)),
                ],
              ),
              const SizedBox(height: 16),
              _buildAccountSelector(selectedAccount),
              const SizedBox(height: 24),

              _buildSectionTitle('Période et récurrence'),
              const SizedBox(height: 16),
              _buildPeriodSelector(selectedPeriod, startDate, endDate),
              const SizedBox(height: 16),
              _buildDateSelectors(startDate, endDate, selectedPeriod),
              const SizedBox(height: 16),
              _buildRecurrenceSelector(isRecurrent),
              const SizedBox(height: 24),

              _buildSectionTitle('Personnalisation'),
              const SizedBox(height: 16),
              _buildIconSelector(selectedIcon, selectedType),
              const SizedBox(height: 16),
              _buildColorSelector(selectedColor),
              const SizedBox(height: 32),

              _buildCreateButton(formKey, nameController, descriptionController,
                               amountController, selectedType, selectedCurrency, selectedPeriod,
                               startDate, endDate, selectedAccount, isRecurrent,
                               selectedIcon, selectedColor, isCreating),
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

  Widget _buildTypeSelector(Rx<BudgetType> selectedType) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Obx(() => Row(
        children: [
          Expanded(
            child: _buildTypeButton(
              'Budget',
              'Gérer vos dépenses',
              BudgetType.budget,
              Icons.account_balance_wallet,
              selectedType.value == BudgetType.budget,
              () => selectedType.value = BudgetType.budget,
            ),
          ),
          Expanded(
            child: _buildTypeButton(
              'Objectif',
              'Atteindre vos rêves',
              BudgetType.objective,
              Icons.flag,
              selectedType.value == BudgetType.objective,
              () => selectedType.value = BudgetType.objective,
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildTypeButton(String title, String subtitle, BudgetType type,
      IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.grey600,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.grey700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: isSelected ? Colors.white.withOpacity(0.8) : AppColors.grey600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Nom *',
        hintText: 'Ex: Alimentation, Maison, Voiture...',
        prefixIcon: const Icon(Icons.label),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Le nom est obligatoire';
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
        hintText: 'Décrivez votre budget ou objectif...',
        prefixIcon: const Icon(Icons.description),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      maxLines: 2,
    );
  }

  Widget _buildAmountField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Montant *',
        hintText: '0',
        prefixIcon: const Icon(Icons.money),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Le montant est obligatoire';
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return 'Veuillez entrer un montant valide';
        }
        return null;
      },
    );
  }

  Widget _buildCurrencySelector(Rx<Currency> selectedCurrency) {
    return Obx(() => DropdownButtonFormField<Currency>(
      value: selectedCurrency.value,
      decoration: InputDecoration(
        labelText: 'Devise',
        prefixIcon: const Icon(Icons.currency_exchange),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: Currency.values.map((currency) {
        return DropdownMenuItem(
          value: currency,
          child: Text('${currency.symbol} ${currency.code}'),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          selectedCurrency.value = value;
        }
      },
    ));
  }

  Widget _buildAccountSelector(Rxn<AccountModel> selectedAccount) {
    final financeController = Get.find<FinanceController>();

    return Obx(() => DropdownButtonFormField<AccountModel>(
      value: selectedAccount.value,
      decoration: InputDecoration(
        labelText: 'Compte (optionnel)',
        hintText: 'Sélectionnez un compte',
        prefixIcon: const Icon(Icons.account_balance),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        helperText: 'Laissez vide pour créer un compte automatiquement',
      ),
      items: [
        const DropdownMenuItem<AccountModel>(
          value: null,
          child: Text('Aucun (créer automatiquement)'),
        ),
        ...financeController.activeAccounts.map((account) {
          return DropdownMenuItem<AccountModel>(
            value: account,
            child: Text(account.name),
          );
        }).toList(),
      ],
      onChanged: (value) {
        selectedAccount.value = value;
      },
    ));
  }

  Widget _buildPeriodSelector(Rx<BudgetPeriod> selectedPeriod, Rx<DateTime> startDate, Rx<DateTime> endDate) {
    return Obx(() => DropdownButtonFormField<BudgetPeriod>(
      value: selectedPeriod.value,
      decoration: InputDecoration(
        labelText: 'Période',
        prefixIcon: const Icon(Icons.schedule),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: BudgetPeriod.values.map((period) {
        return DropdownMenuItem(
          value: period,
          child: Text(period.label),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          selectedPeriod.value = value;
          // Recalculer la date de fin selon la période
          switch (selectedPeriod.value) {
            case BudgetPeriod.weekly:
              endDate.value = startDate.value.add(Duration(days: 7));
              break;
            case BudgetPeriod.monthly:
              endDate.value = DateTime(startDate.value.year, startDate.value.month + 1, startDate.value.day);
              break;
            case BudgetPeriod.quarterly:
              endDate.value = DateTime(startDate.value.year, startDate.value.month + 3, startDate.value.day);
              break;
            case BudgetPeriod.yearly:
              endDate.value = DateTime(startDate.value.year + 1, startDate.value.month, startDate.value.day);
              break;
            case BudgetPeriod.custom:
              // Ne pas changer pour custom
              break;
          }
        }
      },
    ));
  }

  Widget _buildDateSelectors(Rx<DateTime> startDate, Rx<DateTime> endDate, Rx<BudgetPeriod> selectedPeriod) {
    return Row(
      children: [
        Expanded(
          child: Obx(() => TextFormField(
            decoration: InputDecoration(
              labelText: 'Date de début',
              prefixIcon: const Icon(Icons.calendar_today),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            readOnly: true,
            controller: TextEditingController(
              text: '${startDate.value.day}/${startDate.value.month}/${startDate.value.year}',
            ),
            onTap: () async {
              final date = await showDatePicker(
                context: Get.context!,
                initialDate: startDate.value,
                firstDate: DateTime.now().subtract(Duration(days: 365)),
                lastDate: DateTime.now().add(Duration(days: 365 * 5)),
              );
              if (date != null) {
                startDate.value = date;
                // Recalculer la date de fin selon la période
                switch (selectedPeriod.value) {
                  case BudgetPeriod.weekly:
                    endDate.value = startDate.value.add(Duration(days: 7));
                    break;
                  case BudgetPeriod.monthly:
                    endDate.value = DateTime(startDate.value.year, startDate.value.month + 1, startDate.value.day);
                    break;
                  case BudgetPeriod.quarterly:
                    endDate.value = DateTime(startDate.value.year, startDate.value.month + 3, startDate.value.day);
                    break;
                  case BudgetPeriod.yearly:
                    endDate.value = DateTime(startDate.value.year + 1, startDate.value.month, startDate.value.day);
                    break;
                  case BudgetPeriod.custom:
                    // Ne pas changer pour custom
                    break;
                }
              }
            },
          )),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Obx(() => TextFormField(
            decoration: InputDecoration(
              labelText: 'Date de fin',
              prefixIcon: const Icon(Icons.event),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            readOnly: true,
            controller: TextEditingController(
              text: '${endDate.value.day}/${endDate.value.month}/${endDate.value.year}',
            ),
            onTap: () async {
              final date = await showDatePicker(
                context: Get.context!,
                initialDate: endDate.value,
                firstDate: startDate.value,
                lastDate: DateTime.now().add(Duration(days: 365 * 5)),
              );
              if (date != null) {
                endDate.value = date;
              }
            },
          )),
        ),
      ],
    );
  }

  Widget _buildRecurrenceSelector(RxBool isRecurrent) {
    return Obx(() => CheckboxListTile(
      title: const Text('Budget récurrent'),
      subtitle: Text(
        'Le budget se renouvellera automatiquement à la fin de sa période',
        style: TextStyle(color: AppColors.grey600),
      ),
      value: isRecurrent.value,
      onChanged: (value) {
        isRecurrent.value = value ?? false;
      },
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    ));
  }

  Widget _buildIconSelector(RxString selectedIcon, Rx<BudgetType> selectedType) {
    final budgetIcons = {
      'account_balance_wallet': Icons.account_balance_wallet,
      'shopping_cart': Icons.shopping_cart,
      'restaurant': Icons.restaurant,
      'local_gas_station': Icons.local_gas_station,
      'home': Icons.home,
      'health_and_safety': Icons.health_and_safety,
    };

    final objectiveIcons = {
      'flag': Icons.flag,
      'home': Icons.home,
      'directions_car': Icons.directions_car,
      'beach_access': Icons.beach_access,
      'school': Icons.school,
      'savings': Icons.savings,
    };

    return Obx(() {
      final icons = selectedType.value == BudgetType.budget ? budgetIcons : objectiveIcons;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Icône',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
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
          ),
        ],
      );
    });
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
        Text(
          'Couleur',
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
    TextEditingController amountController,
    Rx<BudgetType> selectedType,
    Rx<Currency> selectedCurrency,
    Rx<BudgetPeriod> selectedPeriod,
    Rx<DateTime> startDate,
    Rx<DateTime> endDate,
    Rxn<AccountModel> selectedAccount,
    RxBool isRecurrent,
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
            final amount = double.tryParse(amountController.text) ?? 0.0;

            final success = await controller.createBudget(
              name: nameController.text.trim(),
              description: descriptionController.text.trim(),
              type: selectedType.value,
              amount: amount,
              currency: selectedCurrency.value,
              period: selectedPeriod.value,
              startDate: startDate.value,
              endDate: endDate.value,
              categoryIds: [],
              accountId: selectedAccount.value?.id,
              isRecurrent: isRecurrent.value,
              icon: selectedIcon.value,
              color: selectedColor.value,
            );

            isCreating.value = false;

            if (success) {
              Get.offAllNamed('/finance/budgets');
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
          : Obx(() => Text(
              'Créer ${selectedType.value.label}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            )),
      )),
    );
  }

}