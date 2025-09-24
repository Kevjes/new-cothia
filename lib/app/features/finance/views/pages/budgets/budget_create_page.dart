import 'package:cothia_app/app/features/finance/controllers/categories_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/budgets_controller.dart';
import '../../../controllers/accounts_controller.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../models/budget_model.dart';
import '../../../models/category_model.dart';
import '../../../../../core/utils/get_extensions.dart';

class BudgetCreatePage extends StatefulWidget {
  final BudgetModel? budget;
  final BudgetType? initialType;

  const BudgetCreatePage({super.key, this.budget, this.initialType});

  @override
  State<BudgetCreatePage> createState() => _BudgetCreatePageState();
}

class _BudgetCreatePageState extends State<BudgetCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAmountController = TextEditingController();

  late BudgetType _selectedType;
  late BudgetPeriod _selectedPeriod;
  CategoryModel? _selectedCategory;
  late DateTime _startDate;
  DateTime? _endDate;
  late bool _isActive;

  // Automation fields
  bool _hasAutomation = false;
  String? _sourceAccountId;
  String? _destinationAccountId;
  final _automationAmountController = TextEditingController();
  int _dayOfMonth = 1;
  final _automationDescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.budget != null) {
      final budget = widget.budget!;
      _nameController.text = budget.name;
      _descriptionController.text = budget.description ?? '';
      _targetAmountController.text = budget.targetAmount.toStringAsFixed(0);
      _selectedType = budget.type;
      _selectedPeriod = budget.period;
      _startDate = budget.startDate;
      _endDate = budget.endDate;
      _isActive = budget.isActive;

      // Automation
      if (budget.automationRule != null) {
        _hasAutomation = budget.automationRule!.isEnabled;
        _sourceAccountId = budget.automationRule!.sourceAccountId;
        _destinationAccountId = budget.automationRule!.destinationAccountId;
        _automationAmountController.text = budget.automationRule!.amount.toStringAsFixed(0);
        _dayOfMonth = budget.automationRule!.dayOfMonth;
        _automationDescriptionController.text = budget.automationRule!.description ?? '';
      }

      // Category
      if (budget.categoryId != null) {
        final controller = Get.find<CategoriesController>();
        _selectedCategory = controller.categories
            .where((c) => c.id == budget.categoryId)
            .firstOrNull;
      }
    } else {
      _selectedType = widget.initialType ?? BudgetType.expense;
      _selectedPeriod = BudgetPeriod.monthly;
      _startDate = DateTime.now();
      _isActive = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    _automationAmountController.dispose();
    _automationDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.budget != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier budget' : 'Nouveau budget'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveBudget,
            child: Text(
              isEditing ? 'Modifier' : 'Créer',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
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
              _buildPreviewCard(),
              const SizedBox(height: 24),
              _buildBasicInfoSection(),
              const SizedBox(height: 24),
              _buildTypeAndPeriodSection(),
              const SizedBox(height: 24),
              _buildTargetAmountSection(),
              const SizedBox(height: 24),
              _buildCategorySection(),
              const SizedBox(height: 24),
              _buildDatesSection(),
              const SizedBox(height: 24),
              _buildAutomationSection(),
              const SizedBox(height: 24),
              _buildSettingsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    final targetAmount = double.tryParse(_targetAmountController.text) ?? 0.0;
    final progressPercentage = widget.budget != null
        ? widget.budget!.progressPercentage
        : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aperçu',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _selectedType == BudgetType.expense
                      ? AppColors.error.withOpacity(0.1)
                      : AppColors.success.withOpacity(0.1),
                  child: Icon(
                    _selectedType == BudgetType.expense ? Icons.trending_down : Icons.savings,
                    color: _selectedType == BudgetType.expense ? AppColors.error : AppColors.success,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _nameController.text.isEmpty ? 'Nom du budget' : _nameController.text,
                        style: Get.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getPeriodDisplayName(_selectedPeriod),
                        style: Get.textTheme.bodySmall?.copyWith(
                          color: AppColors.hint,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.budget?.currentAmount.toStringAsFixed(0) ?? '0'} FCFA',
                  style: Get.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _selectedType == BudgetType.expense ? AppColors.error : AppColors.success,
                  ),
                ),
                Text(
                  '${targetAmount.toStringAsFixed(0)} FCFA',
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
                valueColor: AlwaysStoppedAnimation<Color>(
                  _selectedType == BudgetType.expense ? AppColors.error : AppColors.success,
                ),
                minHeight: 8,
              ),
            ),
            if (_hasAutomation) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_mode, color: AppColors.info, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Automatisation activée',
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: AppColors.info,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
              decoration: const InputDecoration(
                labelText: 'Nom du budget *',
                hintText: 'Ex: Courses, Épargne maison...',
                prefixIcon: Icon(Icons.edit),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le nom est requis';
                }
                if (value.trim().length < 2) {
                  return 'Le nom doit contenir au moins 2 caractères';
                }
                return null;
              },
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optionnelle)',
                hintText: 'Décrivez l\'objectif de ce budget...',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeAndPeriodSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type et période',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Type de budget',
              style: Get.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<BudgetType>(
              segments: const [
                ButtonSegment<BudgetType>(
                  value: BudgetType.expense,
                  label: Text('Dépenses'),
                  icon: Icon(Icons.trending_down),
                ),
                ButtonSegment<BudgetType>(
                  value: BudgetType.saving,
                  label: Text('Épargne'),
                  icon: Icon(Icons.savings),
                ),
              ],
              selected: {_selectedType},
              onSelectionChanged: (Set<BudgetType> selection) {
                setState(() {
                  _selectedType = selection.first;
                });
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Période',
              style: Get.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<BudgetPeriod>(
              value: _selectedPeriod,
              decoration: const InputDecoration(
                labelText: 'Fréquence du budget',
                prefixIcon: Icon(Icons.schedule),
              ),
              items: BudgetPeriod.values.map((period) {
                return DropdownMenuItem<BudgetPeriod>(
                  value: period,
                  child: Text(_getPeriodDisplayName(period)),
                );
              }).toList(),
              onChanged: (BudgetPeriod? value) {
                if (value != null) {
                  setState(() {
                    _selectedPeriod = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetAmountSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Montant cible',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _targetAmountController,
              decoration: InputDecoration(
                labelText: _selectedType == BudgetType.expense
                    ? 'Montant maximum à dépenser *'
                    : 'Montant à épargner *',
                hintText: '0',
                prefixIcon: const Icon(Icons.attach_money),
                suffixText: 'FCFA',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le montant est requis';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Veuillez entrer un montant valide';
                }
                return null;
              },
              onChanged: (value) => setState(() {}),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    final controller = Get.find<CategoriesController>();
    final availableCategories = controller.categories
        .where((c) => c.isActive && (
          _selectedType == BudgetType.expense ? c.isExpenseCategory : c.isIncomeCategory
        ))
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Catégorie (optionnelle)',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Associez ce budget à une catégorie spécifique',
              style: Get.textTheme.bodySmall?.copyWith(
                color: AppColors.hint,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<CategoryModel?>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Catégorie associée',
                prefixIcon: Icon(Icons.category),
              ),
              items: [
                const DropdownMenuItem<CategoryModel?>(
                  value: null,
                  child: Text('Aucune catégorie'),
                ),
                ...availableCategories.map((category) {
                  return DropdownMenuItem<CategoryModel?>(
                    value: category,
                    child: Row(
                      children: [
                        Icon(category.icon, color: category.color, size: 20),
                        const SizedBox(width: 8),
                        Text(category.name),
                      ],
                    ),
                  );
                }),
              ],
              onChanged: (CategoryModel? value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dates',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectStartDate(),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date de début',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectEndDate(),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date de fin (optionnelle)',
                        prefixIcon: Icon(Icons.event),
                      ),
                      child: Text(
                        _endDate != null
                            ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                            : 'Non définie',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutomationSection() {
    final controller = Get.find<AccountsController>();
    final accounts = controller.accounts.where((a) => a.isActive).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Automatisation',
                    style: Get.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Switch(
                  value: _hasAutomation,
                  onChanged: (value) {
                    setState(() {
                      _hasAutomation = value;
                    });
                  },
                ),
              ],
            ),
            if (_hasAutomation) ...[
              const SizedBox(height: 16),
              Text(
                'Configuration automatique',
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: AppColors.hint,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      value: _sourceAccountId,
                      decoration: const InputDecoration(
                        labelText: 'Compte source',
                        prefixIcon: Icon(Icons.account_balance),
                      ),
                      items: accounts.map((account) {
                        return DropdownMenuItem<String?>(
                          value: account.id,
                          child: Text(account.name),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _sourceAccountId = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      value: _destinationAccountId,
                      decoration: const InputDecoration(
                        labelText: 'Compte destination',
                        prefixIcon: Icon(Icons.savings),
                      ),
                      items: accounts.map((account) {
                        return DropdownMenuItem<String?>(
                          value: account.id,
                          child: Text(account.name),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _destinationAccountId = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _automationAmountController,
                      decoration: const InputDecoration(
                        labelText: 'Montant',
                        prefixIcon: Icon(Icons.attach_money),
                        suffixText: 'FCFA',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _dayOfMonth,
                      decoration: const InputDecoration(
                        labelText: 'Jour du mois',
                        prefixIcon: Icon(Icons.today),
                      ),
                      items: List.generate(28, (index) {
                        final day = index + 1;
                        return DropdownMenuItem<int>(
                          value: day,
                          child: Text(day.toString()),
                        );
                      }),
                      onChanged: (int? value) {
                        if (value != null) {
                          setState(() {
                            _dayOfMonth = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _automationDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description de l\'automatisation',
                  prefixIcon: Icon(Icons.description),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paramètres',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Budget actif'),
              subtitle: Text(
                _isActive
                    ? 'Le budget est actif et visible'
                    : 'Le budget est désactivé',
                style: Get.textTheme.bodySmall?.copyWith(
                  color: AppColors.hint,
                ),
              ),
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  String _getPeriodDisplayName(BudgetPeriod period) {
    switch (period) {
      case BudgetPeriod.weekly:
        return 'Hebdomadaire';
      case BudgetPeriod.monthly:
        return 'Mensuel';
      case BudgetPeriod.quarterly:
        return 'Trimestriel';
      case BudgetPeriod.yearly:
        return 'Annuel';
    }
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      setState(() {
        _startDate = date;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 365)),
      firstDate: _startDate,
      lastDate: DateTime(2030),
    );
    setState(() {
      _endDate = date;
    });
  }

  Future<void> _saveBudget() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final controller = Get.find<BudgetsController>();
    final isEditing = widget.budget != null;

    try {
      AutomationRule? automationRule;
      if (_hasAutomation) {
        final automationAmount = double.tryParse(_automationAmountController.text) ?? 0.0;
        automationRule = AutomationRule(
          isEnabled: true,
          sourceAccountId: _sourceAccountId,
          destinationAccountId: _destinationAccountId,
          amount: automationAmount,
          dayOfMonth: _dayOfMonth,
          description: _automationDescriptionController.text.trim().isEmpty
              ? null
              : _automationDescriptionController.text.trim(),
        );
      }

      final budgetData = BudgetModel(
        id: isEditing ? widget.budget!.id : '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        type: _selectedType,
        period: _selectedPeriod,
        targetAmount: double.parse(_targetAmountController.text),
        currentAmount: isEditing ? widget.budget!.currentAmount : 0.0,
        entityId: controller.currentEntityId ?? '',
        categoryId: _selectedCategory?.id,
        currency: 'FCFA',
        isActive: _isActive,
        automationRule: automationRule,
        startDate: _startDate,
        endDate: _endDate,
        createdAt: isEditing ? widget.budget!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      bool success;
      if (isEditing) {
        success = await controller.updateBudget(budgetData);
      } else {
        success = await controller.createBudget(budgetData);
      }

      if (success) {
        Get.safeBack();
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de la sauvegarde: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }
}