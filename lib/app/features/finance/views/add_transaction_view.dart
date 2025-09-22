import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/add_transaction_controller.dart';
import '../models/transaction_model.dart';
import '../models/currency.dart';
import '../../../core/theme/app_colors.dart';

class AddTransactionView extends GetView<AddTransactionController> {
  const AddTransactionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle Transaction'),
        actions: [
          TextButton(
            onPressed: controller.clearForm,
            child: const Text('Effacer'),
          ),
        ],
      ),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTransactionTypeSelector(),
              const SizedBox(height: 24),
              _buildTitleField(),
              const SizedBox(height: 16),
              _buildAmountField(),
              const SizedBox(height: 16),
              _buildAccountSelector(),
              const SizedBox(height: 16),
              Obx(() {
                if (controller.transactionType == TransactionType.transfer) {
                  return Column(
                    children: [
                      _buildToAccountSelector(),
                      const SizedBox(height: 16),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildCategorySelector(),
                      const SizedBox(height: 16),
                    ],
                  );
                }
              }),
              _buildDateSelector(),
              const SizedBox(height: 16),
              _buildDescriptionField(),
              const SizedBox(height: 32),
              _buildSaveButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type de transaction',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Obx(() => Row(
              children: [
                Expanded(
                  child: _buildTypeButton(
                    'Revenu',
                    Icons.trending_up,
                    AppColors.success,
                    TransactionType.income,
                    controller.transactionType == TransactionType.income,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTypeButton(
                    'Dépense',
                    Icons.trending_down,
                    AppColors.error,
                    TransactionType.expense,
                    controller.transactionType == TransactionType.expense,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTypeButton(
                    'Transfert',
                    Icons.swap_horiz,
                    AppColors.primary,
                    TransactionType.transfer,
                    controller.transactionType == TransactionType.transfer,
                  ),
                ),
              ],
            )),
      ],
    );
  }

  Widget _buildTypeButton(
    String label,
    IconData icon,
    Color color,
    TransactionType type,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => controller.setTransactionType(type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : AppColors.grey300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppColors.grey600,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : AppColors.grey600,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: controller.titleController,
      validator: controller.validateTitle,
      decoration: const InputDecoration(
        labelText: 'Titre *',
        hintText: 'Ex: Courses, Salaire, etc.',
        prefixIcon: Icon(Icons.title),
      ),
      textCapitalization: TextCapitalization.sentences,
    );
  }

  Widget _buildAmountField() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextFormField(
            controller: controller.amountController,
            validator: controller.validateAmount,
            decoration: const InputDecoration(
              labelText: 'Montant *',
              hintText: '0',
              prefixIcon: Icon(Icons.attach_money),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Obx(() => DropdownButtonFormField<Currency>(
                value: controller.selectedCurrency,
                onChanged: (currency) {
                  if (currency != null) {
                    controller.setSelectedCurrency(currency);
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Devise',
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
                items: Currency.values.map((currency) {
                  return DropdownMenuItem(
                    value: currency,
                    child: Text(currency.code),
                  );
                }).toList(),
              )),
        ),
      ],
    );
  }

  Widget _buildAccountSelector() {
    return Obx(() => DropdownButtonFormField<String>(
          value: controller.selectedAccount?.id,
          onChanged: (accountId) {
            if (accountId != null) {
              final account = controller.accounts.firstWhere((a) => a.id == accountId);
              controller.setSelectedAccount(account);
            }
          },
          decoration: const InputDecoration(
            labelText: 'Compte *',
            prefixIcon: Icon(Icons.account_balance_wallet),
          ),
          items: controller.accounts.map((account) {
            return DropdownMenuItem(
              value: account.id,
              child: Row(
                children: [
                  Expanded(
                    child: Text(account.name),
                  ),
                  Text(
                    account.formattedBalance,
                    style: TextStyle(
                      color: AppColors.grey600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez sélectionner un compte';
            }
            return null;
          },
        ));
  }

  Widget _buildToAccountSelector() {
    return Obx(() => DropdownButtonFormField<String>(
          value: controller.selectedToAccount?.id,
          onChanged: (accountId) {
            if (accountId != null) {
              final account = controller.availableToAccounts.firstWhere((a) => a.id == accountId);
              controller.setSelectedToAccount(account);
            }
          },
          decoration: const InputDecoration(
            labelText: 'Vers le compte *',
            prefixIcon: Icon(Icons.arrow_forward),
          ),
          items: controller.availableToAccounts.map((account) {
            return DropdownMenuItem(
              value: account.id,
              child: Row(
                children: [
                  Expanded(
                    child: Text(account.name),
                  ),
                  Text(
                    account.formattedBalance,
                    style: TextStyle(
                      color: AppColors.grey600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          validator: (value) {
            if (controller.transactionType == TransactionType.transfer &&
                (value == null || value.isEmpty)) {
              return 'Veuillez sélectionner un compte de destination';
            }
            return null;
          },
        ));
  }

  Widget _buildCategorySelector() {
    return Obx(() => DropdownButtonFormField<String>(
          value: controller.selectedCategory?.id,
          onChanged: (categoryId) {
            if (categoryId != null) {
              final category = controller.categories.firstWhere((c) => c.id == categoryId);
              controller.setSelectedCategory(category);
            }
          },
          decoration: const InputDecoration(
            labelText: 'Catégorie *',
            prefixIcon: Icon(Icons.category),
          ),
          items: controller.categories.map((category) {
            return DropdownMenuItem(
              value: category.id,
              child: Text(category.name),
            );
          }).toList(),
          validator: (value) {
            if (controller.transactionType != TransactionType.transfer &&
                (value == null || value.isEmpty)) {
              return 'Veuillez sélectionner une catégorie';
            }
            return null;
          },
        ));
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: controller.selectDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppColors.grey600),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date',
                  style: TextStyle(
                    color: AppColors.grey600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Obx(() => Text(
                      DateFormat('dd MMMM yyyy').format(controller.selectedDate),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    )),
              ],
            ),
            const Spacer(),
            Icon(Icons.arrow_drop_down, color: AppColors.grey600),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: controller.descriptionController,
      validator: controller.validateDescription,
      decoration: const InputDecoration(
        labelText: 'Description (optionnel)',
        hintText: 'Ajouter une note...',
        prefixIcon: Icon(Icons.note),
      ),
      maxLines: 3,
      textCapitalization: TextCapitalization.sentences,
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: Obx(() => ElevatedButton(
            onPressed: controller.isLoading ? null : controller.saveTransaction,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: controller.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Enregistrer',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          )),
    );
  }
}