import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/automation_controller.dart';
import '../../../controllers/accounts_controller.dart';
import '../../../controllers/categories_controller.dart';
import '../../../models/automation_rule_model.dart';
import '../../../../../core/constants/app_colors.dart';

class AutomationRuleFormPage extends StatefulWidget {
  final AutomationRuleModel? rule;

  const AutomationRuleFormPage({super.key, this.rule});

  @override
  State<AutomationRuleFormPage> createState() => _AutomationRuleFormPageState();
}

class _AutomationRuleFormPageState extends State<AutomationRuleFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _percentageController = TextEditingController();
  final _thresholdController = TextEditingController();

  late AutomationController _automationController;
  late AccountsController _accountsController;
  late CategoriesController _categoriesController;

  // État général
  bool _isActive = true;
  bool _isLoading = false;
  TriggerType _selectedTriggerType = TriggerType.scheduled;
  ActionType _selectedActionType = ActionType.transfer;

  // Triggers programmés
  ScheduledTriggerFrequency _scheduledFrequency = ScheduledTriggerFrequency.monthly;
  int _dayOfMonth = 1;
  int _dayOfWeek = 1;
  List<int> _daysOfMonth = [1, 15];
  TimeOfDay? _executionTime;

  // Triggers basés sur les événements
  EventTriggerType _eventType = EventTriggerType.moneyEntry;
  String? _eventAccountId;
  String? _eventCategoryId;
  bool _onlyFirstOfMonth = false;

  // Triggers basés sur les catégories
  List<String> _selectedCategoryIds = [];
  double? _minAmount;
  double? _maxAmount;
  bool _onlyIncome = false;
  bool _onlyExpense = false;

  // Actions
  String? _sourceAccountId;
  String? _destinationAccountId;
  String? _actionCategoryId;
  bool _useFixedAmount = true;

  @override
  void initState() {
    super.initState();
    _automationController = Get.find<AutomationController>();
    _accountsController = Get.put(AccountsController());
    _categoriesController = Get.put(CategoriesController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _initializeForm();
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _accountsController.loadAccounts(),
        _categoriesController.loadCategories(),
      ]);
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors du chargement: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _initializeForm() {
    if (widget.rule != null) {
      final rule = widget.rule!;
      _nameController.text = rule.name;
      _descriptionController.text = rule.description ?? '';
      _isActive = rule.isActive;
      _selectedTriggerType = rule.triggerType;
      _selectedActionType = rule.action.type;

      // Initialize based on trigger type
      if (rule.scheduledTrigger != null) {
        _scheduledFrequency = rule.scheduledTrigger!.frequency;
        _dayOfMonth = rule.scheduledTrigger!.dayOfMonth ?? 1;
        _dayOfWeek = rule.scheduledTrigger!.dayOfWeek ?? 1;
        _daysOfMonth = rule.scheduledTrigger!.daysOfMonth ?? [1, 15];
        _executionTime = rule.scheduledTrigger!.executionTime;
      }

      if (rule.eventTrigger != null) {
        _eventType = rule.eventTrigger!.eventType;
        _eventAccountId = rule.eventTrigger!.accountId;
        _eventCategoryId = rule.eventTrigger!.categoryId;
        _onlyFirstOfMonth = rule.eventTrigger!.onlyFirstOfMonth ?? false;
        if (rule.eventTrigger!.amountThreshold != null) {
          _thresholdController.text = rule.eventTrigger!.amountThreshold!.toStringAsFixed(0);
        }
      }

      if (rule.categoryTrigger != null) {
        _selectedCategoryIds = rule.categoryTrigger!.categoryIds;
        _minAmount = rule.categoryTrigger!.minAmount;
        _maxAmount = rule.categoryTrigger!.maxAmount;
        _onlyIncome = rule.categoryTrigger!.onlyIncome ?? false;
        _onlyExpense = rule.categoryTrigger!.onlyExpense ?? false;
      }

      // Initialize action fields
      _sourceAccountId = rule.action.sourceAccountId;
      _destinationAccountId = rule.action.destinationAccountId;
      _actionCategoryId = rule.action.categoryId;

      if (rule.action.amount != null) {
        _useFixedAmount = true;
        _amountController.text = rule.action.amount!.toStringAsFixed(0);
      } else if (rule.action.percentage != null) {
        _useFixedAmount = false;
        _percentageController.text = rule.action.percentage!.toStringAsFixed(1);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _percentageController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.rule == null ? 'Nouvelle règle' : 'Modifier la règle'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveRule,
            child: const Text('Sauvegarder', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBasicInfoSection(),
                    const SizedBox(height: 24),
                    _buildTriggerTypeSelector(),
                    const SizedBox(height: 24),
                    _buildTriggerConfiguration(),
                    const SizedBox(height: 24),
                    _buildActionTypeSelector(),
                    const SizedBox(height: 24),
                    _buildActionConfiguration(),
                    const SizedBox(height: 24),
                    _buildActiveSwitch(),
                    const SizedBox(height: 32),
                  ],
                ),
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
              style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom de la règle *',
                hintText: 'Ex: Épargne automatique mensuelle',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le nom est requis';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optionnelle)',
                hintText: 'Décrivez cette automatisation...',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTriggerTypeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type de déclencheur',
              style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Choisissez quand cette règle doit s\'exécuter',
              style: Get.textTheme.bodySmall?.copyWith(color: AppColors.hint),
            ),
            const SizedBox(height: 16),
            SegmentedButton<TriggerType>(
              segments: const [
                ButtonSegment(
                  value: TriggerType.scheduled,
                  label: Text('Programmé'),
                  icon: Icon(Icons.schedule),
                ),
                ButtonSegment(
                  value: TriggerType.eventBased,
                  label: Text('Événement'),
                  icon: Icon(Icons.event),
                ),
                ButtonSegment(
                  value: TriggerType.categoryBased,
                  label: Text('Catégorie'),
                  icon: Icon(Icons.category),
                ),
              ],
              selected: {_selectedTriggerType},
              onSelectionChanged: (Set<TriggerType> selection) {
                setState(() => _selectedTriggerType = selection.first);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTriggerConfiguration() {
    switch (_selectedTriggerType) {
      case TriggerType.scheduled:
        return _buildScheduledTriggerConfig();
      case TriggerType.eventBased:
        return _buildEventTriggerConfig();
      case TriggerType.categoryBased:
        return _buildCategoryTriggerConfig();
    }
  }

  Widget _buildScheduledTriggerConfig() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuration du déclencheur programmé',
              style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ScheduledTriggerFrequency>(
              value: _scheduledFrequency,
              decoration: const InputDecoration(
                labelText: 'Fréquence',
                prefixIcon: Icon(Icons.repeat),
              ),
              items: const [
                DropdownMenuItem(value: ScheduledTriggerFrequency.daily, child: Text('Quotidien')),
                DropdownMenuItem(value: ScheduledTriggerFrequency.weekly, child: Text('Hebdomadaire')),
                DropdownMenuItem(value: ScheduledTriggerFrequency.monthly, child: Text('Mensuel')),
                DropdownMenuItem(value: ScheduledTriggerFrequency.multiplePerMonth, child: Text('Plusieurs fois par mois')),
                DropdownMenuItem(value: ScheduledTriggerFrequency.quarterly, child: Text('Trimestriel')),
                DropdownMenuItem(value: ScheduledTriggerFrequency.yearly, child: Text('Annuel')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _scheduledFrequency = value);
                }
              },
            ),
            const SizedBox(height: 16),
            if (_scheduledFrequency == ScheduledTriggerFrequency.weekly)
              DropdownButtonFormField<int>(
                value: _dayOfWeek,
                decoration: const InputDecoration(
                  labelText: 'Jour de la semaine',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Lundi')),
                  DropdownMenuItem(value: 2, child: Text('Mardi')),
                  DropdownMenuItem(value: 3, child: Text('Mercredi')),
                  DropdownMenuItem(value: 4, child: Text('Jeudi')),
                  DropdownMenuItem(value: 5, child: Text('Vendredi')),
                  DropdownMenuItem(value: 6, child: Text('Samedi')),
                  DropdownMenuItem(value: 7, child: Text('Dimanche')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _dayOfWeek = value);
                  }
                },
              ),
            if (_scheduledFrequency == ScheduledTriggerFrequency.monthly)
              DropdownButtonFormField<int>(
                value: _dayOfMonth,
                decoration: const InputDecoration(
                  labelText: 'Jour du mois',
                  prefixIcon: Icon(Icons.today),
                ),
                items: List.generate(28, (index) => index + 1)
                    .map((day) => DropdownMenuItem(value: day, child: Text('Le $day')))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _dayOfMonth = value);
                  }
                },
              ),
            if (_scheduledFrequency == ScheduledTriggerFrequency.multiplePerMonth)
              _buildMultipleDaysSelector(),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.access_time),
              title: const Text('Heure d\'exécution (optionnelle)'),
              subtitle: Text(_executionTime != null
                  ? '${_executionTime!.hour.toString().padLeft(2, '0')}:${_executionTime!.minute.toString().padLeft(2, '0')}'
                  : 'Non définie'),
              trailing: _executionTime != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _executionTime = null),
                    )
                  : null,
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _executionTime ?? TimeOfDay.now(),
                );
                if (time != null) {
                  setState(() => _executionTime = time);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultipleDaysSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Jours du mois'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(28, (index) {
            final day = index + 1;
            final isSelected = _daysOfMonth.contains(day);
            return FilterChip(
              label: Text(day.toString()),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _daysOfMonth.add(day);
                    _daysOfMonth.sort();
                  } else {
                    _daysOfMonth.remove(day);
                  }
                });
              },
            );
          }),
        ),
        if (_daysOfMonth.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Veuillez sélectionner au moins un jour',
              style: Get.textTheme.bodySmall?.copyWith(color: AppColors.error),
            ),
          ),
      ],
    );
  }

  Widget _buildEventTriggerConfig() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuration du déclencheur d\'événement',
              style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<EventTriggerType>(
              value: _eventType,
              decoration: const InputDecoration(
                labelText: 'Type d\'événement',
                prefixIcon: Icon(Icons.event_note),
              ),
              items: const [
                DropdownMenuItem(
                  value: EventTriggerType.moneyEntry,
                  child: Text('À chaque entrée d\'argent'),
                ),
                DropdownMenuItem(
                  value: EventTriggerType.expenseOccurred,
                  child: Text('À chaque dépense'),
                ),
                DropdownMenuItem(
                  value: EventTriggerType.salaryReceived,
                  child: Text('À chaque réception de salaire'),
                ),
                DropdownMenuItem(
                  value: EventTriggerType.firstEntryOfMonth,
                  child: Text('Première entrée du mois'),
                ),
                DropdownMenuItem(
                  value: EventTriggerType.accountBalanceThreshold,
                  child: Text('Seuil de solde atteint'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _eventType = value);
                }
              },
            ),
            const SizedBox(height: 16),
            if (_eventType != EventTriggerType.firstEntryOfMonth)
              Obx(() {
                final accounts = _accountsController.accounts.where((a) => a.isActive).toList();
                return DropdownButtonFormField<String?>(
                  value: _eventAccountId,
                  decoration: const InputDecoration(
                    labelText: 'Compte spécifique (optionnel)',
                    prefixIcon: Icon(Icons.account_balance),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Tous les comptes')),
                    ...accounts.map((account) {
                      return DropdownMenuItem(
                        value: account.id,
                        child: Text(account.name),
                      );
                    }),
                  ],
                  onChanged: (value) => setState(() => _eventAccountId = value),
                );
              }),
            if (_eventType == EventTriggerType.salaryReceived) ...[
              const SizedBox(height: 16),
              Obx(() {
                final categories = _categoriesController.categories
                    .where((c) => c.isActive && c.isIncomeCategory)
                    .toList();
                return DropdownButtonFormField<String?>(
                  value: _eventCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Catégorie de salaire',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category.id,
                      child: Row(
                        children: [
                          Icon(category.icon, size: 20, color: category.color),
                          const SizedBox(width: 8),
                          Text(category.name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _eventCategoryId = value),
                );
              }),
            ],
            if (_eventType == EventTriggerType.moneyEntry ||
                _eventType == EventTriggerType.expenseOccurred ||
                _eventType == EventTriggerType.accountBalanceThreshold) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _thresholdController,
                decoration: InputDecoration(
                  labelText: _eventType == EventTriggerType.accountBalanceThreshold
                      ? 'Seuil de solde'
                      : 'Montant minimum (optionnel)',
                  hintText: '100000',
                  suffixText: 'FCFA',
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
            if (_eventType == EventTriggerType.firstEntryOfMonth) ...[
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Seulement la première entrée'),
                subtitle: const Text('Ne se déclenche qu\'une seule fois par mois'),
                value: _onlyFirstOfMonth,
                onChanged: (value) => setState(() => _onlyFirstOfMonth = value),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTriggerConfig() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuration du déclencheur par catégorie',
              style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Sélectionnez les catégories qui déclenchent cette règle',
              style: Get.textTheme.bodySmall?.copyWith(color: AppColors.hint),
            ),
            const SizedBox(height: 16),
            Obx(() {
              final categories = _categoriesController.categories.where((c) => c.isActive).toList();
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((category) {
                  final isSelected = _selectedCategoryIds.contains(category.id);
                  return FilterChip(
                    avatar: Icon(category.icon, size: 18, color: category.color),
                    label: Text(category.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCategoryIds.add(category.id);
                        } else {
                          _selectedCategoryIds.remove(category.id);
                        }
                      });
                    },
                  );
                }).toList(),
              );
            }),
            if (_selectedCategoryIds.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Veuillez sélectionner au moins une catégorie',
                  style: Get.textTheme.bodySmall?.copyWith(color: AppColors.error),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _minAmount?.toStringAsFixed(0),
                    decoration: const InputDecoration(
                      labelText: 'Montant min (optionnel)',
                      suffixText: 'FCFA',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _minAmount = double.tryParse(value);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: _maxAmount?.toStringAsFixed(0),
                    decoration: const InputDecoration(
                      labelText: 'Montant max (optionnel)',
                      suffixText: 'FCFA',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _maxAmount = double.tryParse(value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Revenus uniquement'),
              value: _onlyIncome,
              onChanged: (value) {
                setState(() {
                  _onlyIncome = value;
                  if (value) _onlyExpense = false;
                });
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Dépenses uniquement'),
              value: _onlyExpense,
              onChanged: (value) {
                setState(() {
                  _onlyExpense = value;
                  if (value) _onlyIncome = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTypeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type d\'action',
              style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Que doit faire cette règle ?',
              style: Get.textTheme.bodySmall?.copyWith(color: AppColors.hint),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ActionType>(
              value: _selectedActionType,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.play_arrow),
              ),
              items: const [
                DropdownMenuItem(
                  value: ActionType.transfer,
                  child: Text('Transférer de l\'argent'),
                ),
                DropdownMenuItem(
                  value: ActionType.createTransaction,
                  child: Text('Créer une transaction'),
                ),
                DropdownMenuItem(
                  value: ActionType.sendNotification,
                  child: Text('Envoyer une notification'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedActionType = value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionConfiguration() {
    switch (_selectedActionType) {
      case ActionType.transfer:
        return _buildTransferActionConfig();
      case ActionType.createTransaction:
        return _buildTransactionActionConfig();
      case ActionType.sendNotification:
        return _buildNotificationActionConfig();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTransferActionConfig() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuration du transfert',
              style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Obx(() {
              final accounts = _accountsController.accounts.where((a) => a.isActive).toList();
              return Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _sourceAccountId,
                    decoration: const InputDecoration(
                      labelText: 'Compte source (débit) *',
                      prefixIcon: Icon(Icons.account_balance_wallet),
                    ),
                    items: accounts.map((account) {
                      return DropdownMenuItem(
                        value: account.id,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(account.name),
                            Text(
                              '${account.currentBalance.toStringAsFixed(0)} FCFA',
                              style: Get.textTheme.bodySmall?.copyWith(color: AppColors.hint),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    validator: (value) => value == null ? 'Requis' : null,
                    onChanged: (value) => setState(() => _sourceAccountId = value),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _destinationAccountId,
                    decoration: const InputDecoration(
                      labelText: 'Compte destination (crédit) *',
                      prefixIcon: Icon(Icons.savings),
                    ),
                    items: accounts.map((account) {
                      return DropdownMenuItem(
                        value: account.id,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(account.name),
                            Text(
                              '${account.currentBalance.toStringAsFixed(0)} FCFA',
                              style: Get.textTheme.bodySmall?.copyWith(color: AppColors.hint),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    validator: (value) {
                      if (value == null) return 'Requis';
                      if (value == _sourceAccountId) return 'Doit être différent du compte source';
                      return null;
                    },
                    onChanged: (value) => setState(() => _destinationAccountId = value),
                  ),
                ],
              );
            }),
            const SizedBox(height: 16),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Montant fixe')),
                ButtonSegment(value: false, label: Text('Pourcentage')),
              ],
              selected: {_useFixedAmount},
              onSelectionChanged: (Set<bool> selection) {
                setState(() => _useFixedAmount = selection.first);
              },
            ),
            const SizedBox(height: 16),
            if (_useFixedAmount)
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Montant à transférer *',
                  hintText: '50000',
                  suffixText: 'FCFA',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Le montant est requis';
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) return 'Montant invalide';
                  return null;
                },
              )
            else
              TextFormField(
                controller: _percentageController,
                decoration: const InputDecoration(
                  labelText: 'Pourcentage à transférer *',
                  hintText: '10',
                  suffixText: '%',
                  prefixIcon: Icon(Icons.percent),
                  helperText: 'Pourcentage du montant déclencheur',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Le pourcentage est requis';
                  final percentage = double.tryParse(value);
                  if (percentage == null || percentage <= 0 || percentage > 100) {
                    return 'Pourcentage invalide (0-100)';
                  }
                  return null;
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionActionConfig() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuration de la transaction',
              style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: '',
              decoration: const InputDecoration(
                labelText: 'Titre de la transaction *',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
            ),
            const SizedBox(height: 16),
            Obx(() {
              final categories = _categoriesController.categories.where((c) => c.isActive).toList();
              return DropdownButtonFormField<String>(
                value: _actionCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Catégorie *',
                  prefixIcon: Icon(Icons.category),
                ),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category.id,
                    child: Row(
                      children: [
                        Icon(category.icon, size: 20, color: category.color),
                        const SizedBox(width: 8),
                        Text(category.name),
                      ],
                    ),
                  );
                }).toList(),
                validator: (value) => value == null ? 'Requis' : null,
                onChanged: (value) => setState(() => _actionCategoryId = value),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationActionConfig() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuration de la notification',
              style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Message de notification *',
                hintText: 'Votre budget mensuel est dépassé',
                prefixIcon: Icon(Icons.message),
              ),
              maxLines: 2,
              validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSwitch() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Règle active'),
          subtitle: Text(
            _isActive ? 'La règle sera exécutée automatiquement' : 'La règle est désactivée',
            style: Get.textTheme.bodySmall?.copyWith(color: AppColors.hint),
          ),
          value: _isActive,
          onChanged: (value) => setState(() => _isActive = value),
        ),
      ),
    );
  }

  Future<void> _saveRule() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate trigger-specific requirements
    if (_selectedTriggerType == TriggerType.scheduled) {
      if (_scheduledFrequency == ScheduledTriggerFrequency.multiplePerMonth && _daysOfMonth.isEmpty) {
        Get.snackbar(
          'Erreur',
          'Veuillez sélectionner au moins un jour du mois',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
        return;
      }
    } else if (_selectedTriggerType == TriggerType.categoryBased) {
      if (_selectedCategoryIds.isEmpty) {
        Get.snackbar(
          'Erreur',
          'Veuillez sélectionner au moins une catégorie',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
        return;
      }
    }

    try {
      // Build trigger
      ScheduledTrigger? scheduledTrigger;
      EventTrigger? eventTrigger;
      CategoryTrigger? categoryTrigger;

      if (_selectedTriggerType == TriggerType.scheduled) {
        scheduledTrigger = ScheduledTrigger(
          frequency: _scheduledFrequency,
          dayOfMonth: _dayOfMonth,
          dayOfWeek: _dayOfWeek,
          daysOfMonth: _daysOfMonth,
          executionTime: _executionTime,
        );
      } else if (_selectedTriggerType == TriggerType.eventBased) {
        eventTrigger = EventTrigger(
          eventType: _eventType,
          amountThreshold: _thresholdController.text.isNotEmpty
              ? double.tryParse(_thresholdController.text)
              : null,
          accountId: _eventAccountId,
          categoryId: _eventCategoryId,
          onlyFirstOfMonth: _onlyFirstOfMonth,
        );
      } else if (_selectedTriggerType == TriggerType.categoryBased) {
        categoryTrigger = CategoryTrigger(
          categoryIds: _selectedCategoryIds,
          minAmount: _minAmount,
          maxAmount: _maxAmount,
          onlyIncome: _onlyIncome,
          onlyExpense: _onlyExpense,
        );
      }

      // Build action
      final action = AutomationAction(
        type: _selectedActionType,
        sourceAccountId: _sourceAccountId,
        destinationAccountId: _destinationAccountId,
        categoryId: _actionCategoryId,
        amount: _useFixedAmount && _amountController.text.isNotEmpty
            ? double.tryParse(_amountController.text)
            : null,
        percentage: !_useFixedAmount && _percentageController.text.isNotEmpty
            ? double.tryParse(_percentageController.text)
            : null,
      );

      // Create rule
      final rule = AutomationRuleModel(
        id: widget.rule?.id ?? '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        entityId: _automationController.currentEntityId ?? '',
        isActive: _isActive,
        triggerType: _selectedTriggerType,
        scheduledTrigger: scheduledTrigger,
        eventTrigger: eventTrigger,
        categoryTrigger: categoryTrigger,
        action: action,
        createdAt: widget.rule?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      bool success;
      if (widget.rule == null) {
        success = await _automationController.createRule(rule);
      } else {
        success = await _automationController.updateRule(rule);
      }

      if (success) {
        Get.back();
        Get.snackbar(
          'Succès',
          widget.rule == null ? 'Règle créée avec succès' : 'Règle mise à jour',
          backgroundColor: AppColors.success,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de la sauvegarde: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }
}
