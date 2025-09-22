import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/finance_service.dart';
import '../../../data/services/transactions_service.dart';
import '../../../data/services/budgets_service.dart';
import '../models/account_model.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/budget_model.dart';
import '../models/currency.dart';
import 'package:intl/intl.dart';

class AddTransactionController extends GetxController {
  static AddTransactionController get to => Get.find<AddTransactionController>();

  final FinanceService _financeService = FinanceService.to;
  final TransactionsService _transactionsService = TransactionsService.to;
  final BudgetsService _budgetsService = BudgetsService.to;

  // Form controllers
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();

  // Observable variables
  final _transactionType = TransactionType.expense.obs;
  final _transactionStatus = TransactionStatus.completed.obs;
  final _selectedAccount = Rxn<AccountModel>();
  final _selectedToAccount = Rxn<AccountModel>(); // Pour les transferts
  final _selectedCategory = Rxn<CategoryModel>();
  final _selectedBudget = Rxn<BudgetModel>();
  final _selectedCurrency = Currency.defaultCurrency.obs;
  final _selectedDate = DateTime.now().obs;
  final _selectedTime = TimeOfDay.now().obs;
  final _recurrence = TransactionRecurrence.none.obs;
  final _isLoading = false.obs;
  final _tags = <String>[].obs;
  final _saveAsPending = false.obs;
  final _includeTime = true.obs;

  // Getters
  TransactionType get transactionType => _transactionType.value;
  TransactionStatus get transactionStatus => _transactionStatus.value;
  AccountModel? get selectedAccount => _selectedAccount.value;
  AccountModel? get selectedToAccount => _selectedToAccount.value;
  CategoryModel? get selectedCategory => _selectedCategory.value;
  BudgetModel? get selectedBudget => _selectedBudget.value;
  Currency get selectedCurrency => _selectedCurrency.value;
  DateTime get selectedDate => _selectedDate.value;
  TimeOfDay get selectedTime => _selectedTime.value;
  TransactionRecurrence get recurrence => _recurrence.value;
  bool get isLoading => _isLoading.value;
  List<String> get tags => _tags;
  bool get saveAsPending => _saveAsPending.value;
  bool get includeTime => _includeTime.value;

  List<AccountModel> get accounts => _financeService.accounts.where((a) => a.isActive).toList();
  List<AccountModel> get availableToAccounts => accounts.where((a) => a.id != selectedAccount?.id).toList();
  List<BudgetModel> get budgets => _budgetsService.budgets.where((b) => b.isActive && !b.isObjective).toList();

  List<CategoryModel> get categories {
    switch (transactionType) {
      case TransactionType.income:
        return _financeService.categories.where((c) => c.type == CategoryType.income).toList();
      case TransactionType.expense:
        return _financeService.categories.where((c) => c.type == CategoryType.expense).toList();
      case TransactionType.transfer:
        return [];
    }
  }

  @override
  void onInit() {
    super.onInit();
    _initializeDefaults();
  }

  @override
  void onClose() {
    titleController.dispose();
    amountController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    super.onClose();
  }

  void _initializeDefaults() {
    if (accounts.isNotEmpty) {
      _selectedAccount.value = accounts.first;
    }
  }

  void setTransactionType(TransactionType type) {
    _transactionType.value = type;
    _selectedCategory.value = null; // Reset category when type changes

    // Set default title based on type
    switch (type) {
      case TransactionType.income:
        if (titleController.text.isEmpty) titleController.text = 'Nouveau revenu';
        break;
      case TransactionType.expense:
        if (titleController.text.isEmpty) titleController.text = 'Nouvelle dépense';
        break;
      case TransactionType.transfer:
        if (titleController.text.isEmpty) titleController.text = 'Transfert entre comptes';
        break;
    }
  }

  void setSelectedAccount(AccountModel account) {
    _selectedAccount.value = account;
    _selectedCurrency.value = account.currency;

    // Reset to account if it's the same as from account
    if (selectedToAccount?.id == account.id) {
      _selectedToAccount.value = null;
    }
  }

  void setSelectedToAccount(AccountModel account) {
    _selectedToAccount.value = account;
  }

  void setSelectedCategory(CategoryModel category) {
    _selectedCategory.value = category;
  }

  void setSelectedBudget(BudgetModel? budget) {
    _selectedBudget.value = budget;
  }

  void setSelectedCurrency(Currency currency) {
    _selectedCurrency.value = currency;
  }

  void setSelectedDate(DateTime date) {
    _selectedDate.value = date;
  }

  void setSelectedTime(TimeOfDay time) {
    _selectedTime.value = time;
  }

  void setTransactionStatus(TransactionStatus status) {
    _transactionStatus.value = status;
  }

  Future<void> selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setSelectedDate(picked);
    }
  }

  Future<void> selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: Get.context!,
      initialTime: selectedTime,
    );

    if (picked != null) {
      setSelectedTime(picked);
    }
  }

  Future<void> getCurrentLocation() async {
    // TODO: Implement geolocation
    Get.snackbar('Info', 'Fonctionnalité de géolocalisation à venir');
  }

  void addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      _tags.add(tag);
    }
  }

  void removeTag(String tag) {
    _tags.remove(tag);
  }

  void showAddTagDialog() {
    final tagController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Ajouter un tag'),
        content: TextField(
          controller: tagController,
          decoration: const InputDecoration(
            hintText: 'Nom du tag',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              addTag(value.trim());
              Get.back();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final tag = tagController.text.trim();
              if (tag.isNotEmpty) {
                addTag(tag);
                Get.back();
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  Future<void> saveTransaction() async {
    if (!formKey.currentState!.validate()) return;

    if (selectedAccount == null) {
      Get.snackbar('Erreur', 'Veuillez sélectionner un compte');
      return;
    }

    if (transactionType == TransactionType.transfer && selectedToAccount == null) {
      Get.snackbar('Erreur', 'Veuillez sélectionner un compte de destination');
      return;
    }

    if (transactionType != TransactionType.transfer && selectedCategory == null) {
      Get.snackbar('Erreur', 'Veuillez sélectionner une catégorie');
      return;
    }

    try {
      _isLoading.value = true;

      final amount = double.tryParse(amountController.text.replaceAll(',', ''));
      if (amount == null || amount <= 0) {
        Get.snackbar('Erreur', 'Veuillez saisir un montant valide');
        return;
      }

      // Combine date and time
      final combinedDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      final transaction = TransactionModel(
        id: '',
        title: titleController.text.trim(),
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        amount: amount,
        currency: selectedCurrency,
        type: transactionType,
        status: transactionStatus,
        accountId: selectedAccount!.id,
        toAccountId: selectedToAccount?.id,
        categoryId: selectedCategory?.id,
        budgetId: selectedBudget?.id,
        date: combinedDateTime,
        location: locationController.text.trim().isEmpty
            ? null
            : locationController.text.trim(),
        tags: List.from(tags),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: '',
      );

      await _transactionsService.createTransaction(transaction);

      Get.back();
      Get.snackbar(
        'Succès',
        '${transactionType.label} ajoutée avec succès',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la sauvegarde');
    } finally {
      _isLoading.value = false;
    }
  }

  // Validators
  String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez saisir un titre';
    }
    if (value.trim().length < 2) {
      return 'Le titre doit contenir au moins 2 caractères';
    }
    return null;
  }

  String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez saisir un montant';
    }

    final amount = double.tryParse(value.replaceAll(',', ''));
    if (amount == null) {
      return 'Veuillez saisir un montant valide';
    }

    if (amount <= 0) {
      return 'Le montant doit être supérieur à 0';
    }

    if (amount > 999999999) {
      return 'Montant trop élevé';
    }

    return null;
  }

  String? validateDescription(String? value) {
    // Description is optional
    return null;
  }

  // Utility methods
  void clearForm() {
    titleController.clear();
    amountController.clear();
    descriptionController.clear();
    locationController.clear();
    _selectedCategory.value = null;
    _selectedBudget.value = null;
    _selectedDate.value = DateTime.now();
    _selectedTime.value = TimeOfDay.now();
    _transactionStatus.value = TransactionStatus.completed;
    _tags.clear();
  }

  void prefillQuickTransaction(TransactionType type, {String? title, double? amount}) {
    setTransactionType(type);
    if (title != null) titleController.text = title;
    if (amount != null) amountController.text = amount.toString();
  }
}