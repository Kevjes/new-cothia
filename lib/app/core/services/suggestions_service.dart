import 'package:get/get.dart';
import '../../features/finance/controllers/finance_controller.dart';
import '../../features/finance/controllers/transactions_controller.dart';
import '../../features/finance/controllers/budgets_controller.dart';
import '../../features/finance/controllers/objectives_controller.dart';
import '../../features/tasks/controllers/tasks_controller.dart';
import '../../features/habits/controllers/habits_controller.dart';
import '../../features/habits/models/habit_model.dart';
import '../models/suggestion_model.dart';

/// Service intelligent pour générer des suggestions basées sur l'analyse des données utilisateur
class SuggestionsService extends GetxService {
  final _suggestions = <SuggestionModel>[].obs;
  final _isAnalyzing = false.obs;

  List<SuggestionModel> get suggestions => _suggestions;
  bool get isAnalyzing => _isAnalyzing.value;

  @override
  void onInit() {
    super.onInit();
    _initializeService();
  }

  Future<void> _initializeService() async {
    // Analyser les données toutes les heures
    await generateSuggestions();

    // Programmer l'analyse périodique
    _schedulePeriodicAnalysis();
  }

  /// Génère des suggestions intelligentes basées sur l'analyse des données
  Future<void> generateSuggestions() async {
    if (_isAnalyzing.value) return;

    try {
      _isAnalyzing.value = true;
      _suggestions.clear();

      // Analyse financière
      await _analyzeFinancialPatterns();

      // Analyse des tâches et productivité
      await _analyzeTaskPatterns();

      // Analyse des habitudes
      await _analyzeHabitPatterns();

      // Analyse inter-modules (corrélations)
      await _analyzeCrossModulePatterns();

      // Prioriser et filtrer les suggestions
      _prioritizeSuggestions();

    } catch (e) {
      print('Erreur lors de la génération des suggestions: $e');
    } finally {
      _isAnalyzing.value = false;
    }
  }

  /// Analyse les patterns financiers et génère des suggestions
  Future<void> _analyzeFinancialPatterns() async {
    try {
      final financeController = Get.find<FinanceController>();
      final transactionsController = Get.find<TransactionsController>();

      // Analyse des dépenses par catégorie
      final expenseAnalysis = _analyzeExpenseCategories(transactionsController.transactions);
      if (expenseAnalysis.isNotEmpty) {
        _suggestions.addAll(expenseAnalysis);
      }

      // Analyse des comptes et soldes
      final balanceAnalysis = _analyzeAccountBalances();
      if (balanceAnalysis.isNotEmpty) {
        _suggestions.addAll(balanceAnalysis);
      }

      // Suggestions d'optimisation budgétaire
      final budgetOptimization = _analyzeBudgetOptimization();
      if (budgetOptimization.isNotEmpty) {
        _suggestions.addAll(budgetOptimization);
      }

      // Analyse des objectifs financiers
      final objectiveAnalysis = _analyzeFinancialObjectives();
      if (objectiveAnalysis.isNotEmpty) {
        _suggestions.addAll(objectiveAnalysis);
      }

    } catch (e) {
      print('Erreur analyse financière: $e');
    }
  }

  /// Analyse les patterns de tâches et productivité
  Future<void> _analyzeTaskPatterns() async {
    try {
      final tasksController = Get.find<TasksController>();

      // Analyse de procrastination
      final procrastinationAnalysis = _analyzeProcrastination(tasksController.tasks);
      if (procrastinationAnalysis.isNotEmpty) {
        _suggestions.addAll(procrastinationAnalysis);
      }

      // Analyse de charge de travail
      final workloadAnalysis = _analyzeWorkload(tasksController.tasks);
      if (workloadAnalysis.isNotEmpty) {
        _suggestions.addAll(workloadAnalysis);
      }

      // Suggestions d'organisation
      final organizationSuggestions = _analyzeTaskOrganization(tasksController.tasks);
      if (organizationSuggestions.isNotEmpty) {
        _suggestions.addAll(organizationSuggestions);
      }

    } catch (e) {
      print('Erreur analyse tâches: $e');
    }
  }

  /// Analyse les patterns d'habitudes
  Future<void> _analyzeHabitPatterns() async {
    try {
      final habitsController = Get.find<HabitsController>();

      // Analyse de consistance des habitudes
      final consistencyAnalysis = _analyzeHabitConsistency(habitsController.habits);
      if (consistencyAnalysis.isNotEmpty) {
        _suggestions.addAll(consistencyAnalysis);
      }

      // Suggestions d'amélioration
      final improvementSuggestions = _analyzeHabitImprovement(habitsController.habits);
      if (improvementSuggestions.isNotEmpty) {
        _suggestions.addAll(improvementSuggestions);
      }

    } catch (e) {
      print('Erreur analyse habitudes: $e');
    }
  }

  /// Analyse les corrélations entre modules
  Future<void> _analyzeCrossModulePatterns() async {
    try {
      // Corrélation habitudes <-> finances
      final habitFinanceCorrelation = _analyzeHabitFinanceCorrelation();
      if (habitFinanceCorrelation.isNotEmpty) {
        _suggestions.addAll(habitFinanceCorrelation);
      }

      // Corrélation tâches <-> finances
      final taskFinanceCorrelation = _analyzeTaskFinanceCorrelation();
      if (taskFinanceCorrelation.isNotEmpty) {
        _suggestions.addAll(taskFinanceCorrelation);
      }

      // Corrélation productivité <-> bien-être
      final productivityWellbeingCorrelation = _analyzeProductivityWellbeingCorrelation();
      if (productivityWellbeingCorrelation.isNotEmpty) {
        _suggestions.addAll(productivityWellbeingCorrelation);
      }

    } catch (e) {
      print('Erreur analyse inter-modules: $e');
    }
  }

  /// Analyse des dépenses par catégorie
  List<SuggestionModel> _analyzeExpenseCategories(List transactions) {
    final suggestions = <SuggestionModel>[];

    try {
      final now = DateTime.now();
      final thisMonth = transactions.where((t) =>
        t.date.year == now.year &&
        t.date.month == now.month &&
        t.type.name == 'expense'
      ).toList();

      final lastMonth = transactions.where((t) =>
        t.date.year == (now.month == 1 ? now.year - 1 : now.year) &&
        t.date.month == (now.month == 1 ? 12 : now.month - 1) &&
        t.type.name == 'expense'
      ).toList();

      if (thisMonth.isNotEmpty && lastMonth.isNotEmpty) {
        final thisMonthTotal = thisMonth.fold(0.0, (sum, t) => sum + t.amount);
        final lastMonthTotal = lastMonth.fold(0.0, (sum, t) => sum + t.amount);

        final increase = ((thisMonthTotal - lastMonthTotal) / lastMonthTotal * 100);

        if (increase > 20) {
          suggestions.add(SuggestionModel(
            id: 'expense_increase_alert',
            type: SuggestionType.financial,
            priority: SuggestionPriority.high,
            title: 'Augmentation des dépenses détectée',
            description: 'Vos dépenses ont augmenté de ${increase.toStringAsFixed(1)}% ce mois. Analysez vos habitudes de dépense.',
            action: SuggestionAction(
              type: ActionType.navigation,
              route: '/finance/analytics',
              label: 'Voir les analyses',
            ),
            metadata: {
              'increase_percentage': increase,
              'current_month_total': thisMonthTotal,
              'last_month_total': lastMonthTotal,
            },
          ));
        }
      }

      // Analyse par catégorie spécifique
      final categoryExpenses = <String, double>{};
      for (final transaction in thisMonth) {
        final category = transaction.categoryId ?? 'Non catégorisé';
        categoryExpenses[category] = (categoryExpenses[category] ?? 0) + transaction.amount;
      }

      // Détecter les catégories avec des dépenses élevées
      final totalExpenses = categoryExpenses.values.fold(0.0, (a, b) => a + b);
      categoryExpenses.forEach((category, amount) {
        final percentage = (amount / totalExpenses) * 100;
        if (percentage > 30) {
          suggestions.add(SuggestionModel(
            id: 'category_high_spending_$category',
            type: SuggestionType.financial,
            priority: SuggestionPriority.medium,
            title: 'Dépenses élevées: $category',
            description: 'La catégorie "$category" représente ${percentage.toStringAsFixed(1)}% de vos dépenses ce mois.',
            action: SuggestionAction(
              type: ActionType.navigation,
              route: '/finance/budgets',
              label: 'Créer un budget',
            ),
            metadata: {
              'category': category,
              'amount': amount,
              'percentage': percentage,
            },
          ));
        }
      });

    } catch (e) {
      print('Erreur analyse catégories: $e');
    }

    return suggestions;
  }

  /// Analyse des soldes de comptes
  List<SuggestionModel> _analyzeAccountBalances() {
    final suggestions = <SuggestionModel>[];

    try {
      final financeController = Get.find<FinanceController>();

      // Détecter les comptes avec des soldes faibles
      for (final account in financeController.accounts) {
        if (account.currentBalance < 50000 && account.type.name == 'bank') {
          suggestions.add(SuggestionModel(
            id: 'low_balance_${account.id}',
            type: SuggestionType.financial,
            priority: SuggestionPriority.high,
            title: 'Solde faible détecté',
            description: 'Le compte "${account.name}" a un solde de ${account.currentBalance.toStringAsFixed(0)} FCFA.',
            action: SuggestionAction(
              type: ActionType.navigation,
              route: '/finance/accounts',
              label: 'Voir les comptes',
            ),
            metadata: {
              'account_id': account.id,
              'account_name': account.name,
              'balance': account.currentBalance,
            },
          ));
        }
      }

    } catch (e) {
      print('Erreur analyse soldes: $e');
    }

    return suggestions;
  }

  /// Analyse de l'optimisation budgétaire
  List<SuggestionModel> _analyzeBudgetOptimization() {
    final suggestions = <SuggestionModel>[];

    try {
      final financeController = Get.find<FinanceController>();

      // Analyser les budgets dépassés
      final budgetsController = Get.find<BudgetsController>();
      for (final budget in budgetsController.budgets) {
        if (budget.currentAmount > budget.limitAmount) {
          final overspent = budget.currentAmount - budget.limitAmount;
          suggestions.add(SuggestionModel(
            id: 'budget_overspent_${budget.id}',
            type: SuggestionType.financial,
            priority: SuggestionPriority.high,
            title: 'Budget dépassé: ${budget.name}',
            description: 'Vous avez dépassé de ${overspent.toStringAsFixed(0)} FCFA le budget "${budget.name}".',
            action: SuggestionAction(
              type: ActionType.navigation,
              route: '/finance/budgets',
              label: 'Ajuster le budget',
            ),
            metadata: {
              'budget_id': budget.id,
              'budget_name': budget.name,
              'overspent_amount': overspent,
            },
          ));
        }
      }

    } catch (e) {
      print('Erreur analyse budgets: $e');
    }

    return suggestions;
  }

  /// Analyse des objectifs financiers
  List<SuggestionModel> _analyzeFinancialObjectives() {
    final suggestions = <SuggestionModel>[];

    try {
      final financeController = Get.find<FinanceController>();

      final objectivesController = Get.find<ObjectivesController>();
      for (final objective in objectivesController.objectives) {
        // Objectifs en retard
        if (objective.targetDate != null && objective.targetDate!.isBefore(DateTime.now()) && !objective.isCompleted) {
          suggestions.add(SuggestionModel(
            id: 'objective_overdue_${objective.id}',
            type: SuggestionType.financial,
            priority: SuggestionPriority.medium,
            title: 'Objectif en retard',
            description: 'L\'objectif "${objective.name}" devait être atteint avant le ${_formatDate(objective.targetDate!)}.',
            action: SuggestionAction(
              type: ActionType.navigation,
              route: '/finance/objectives',
              label: 'Réviser l\'objectif',
            ),
            metadata: {
              'objective_id': objective.id,
              'objective_name': objective.name,
              'target_date': objective.targetDate?.toIso8601String(),
            },
          ));
        }

        // Suggestions d'accélération
        if (objective.monthlyAllocation != null && objective.monthlyAllocation! > 0) {
          final remainingMonths = objective.estimatedMonthsToComplete ?? 0;
          if (remainingMonths > 12) {
            final suggestedIncrease = objective.monthlyAllocation! * 0.2;
            suggestions.add(SuggestionModel(
              id: 'objective_accelerate_${objective.id}',
              type: SuggestionType.financial,
              priority: SuggestionPriority.low,
              title: 'Accélérer votre objectif',
              description: 'Augmentez votre allocation mensuelle de ${suggestedIncrease.toStringAsFixed(0)} FCFA pour atteindre "${objective.name}" plus rapidement.',
              action: SuggestionAction(
                type: ActionType.navigation,
                route: '/finance/objectives',
                label: 'Ajuster l\'allocation',
              ),
              metadata: {
                'objective_id': objective.id,
                'suggested_increase': suggestedIncrease,
                'current_allocation': objective.monthlyAllocation,
              },
            ));
          }
        }
      }

    } catch (e) {
      print('Erreur analyse objectifs: $e');
    }

    return suggestions;
  }

  /// Analyse de procrastination
  List<SuggestionModel> _analyzeProcrastination(List tasks) {
    final suggestions = <SuggestionModel>[];

    try {
      final now = DateTime.now();
      final overdueTasks = tasks.where((task) =>
        task.deadline != null &&
        task.deadline!.isBefore(now) &&
        task.status.name != 'completed'
      ).toList();

      if (overdueTasks.length > 5) {
        suggestions.add(SuggestionModel(
          id: 'procrastination_alert',
          type: SuggestionType.productivity,
          priority: SuggestionPriority.high,
          title: 'Tendance à la procrastination',
          description: 'Vous avez ${overdueTasks.length} tâches en retard. Considérez revoir votre planification.',
          action: SuggestionAction(
            type: ActionType.navigation,
            route: '/tasks',
            label: 'Voir les tâches',
          ),
          metadata: {
            'overdue_count': overdueTasks.length,
          },
        ));
      }

    } catch (e) {
      print('Erreur analyse procrastination: $e');
    }

    return suggestions;
  }

  /// Analyse de charge de travail
  List<SuggestionModel> _analyzeWorkload(List tasks) {
    final suggestions = <SuggestionModel>[];

    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));

      final weekTasks = tasks.where((task) =>
        task.deadline != null &&
        task.deadline!.isAfter(weekStart) &&
        task.deadline!.isBefore(weekEnd) &&
        task.status.name != 'completed'
      ).toList();

      if (weekTasks.length > 15) {
        suggestions.add(SuggestionModel(
          id: 'workload_high',
          type: SuggestionType.productivity,
          priority: SuggestionPriority.medium,
          title: 'Charge de travail élevée',
          description: 'Vous avez ${weekTasks.length} tâches prévues cette semaine. Considérez déléguer ou reporter certaines tâches.',
          action: SuggestionAction(
            type: ActionType.navigation,
            route: '/tasks/analytics',
            label: 'Analyser la charge',
          ),
          metadata: {
            'week_tasks_count': weekTasks.length,
          },
        ));
      }

    } catch (e) {
      print('Erreur analyse charge: $e');
    }

    return suggestions;
  }

  /// Analyse de l'organisation des tâches
  List<SuggestionModel> _analyzeTaskOrganization(List tasks) {
    final suggestions = <SuggestionModel>[];

    try {
      final uncategorizedTasks = tasks.where((task) =>
        task.categoryId == null || task.categoryId!.isEmpty
      ).toList();

      if (uncategorizedTasks.length > 10) {
        suggestions.add(SuggestionModel(
          id: 'task_organization',
          type: SuggestionType.productivity,
          priority: SuggestionPriority.low,
          title: 'Améliorer l\'organisation',
          description: '${uncategorizedTasks.length} tâches ne sont pas catégorisées. Créez des catégories pour mieux vous organiser.',
          action: SuggestionAction(
            type: ActionType.navigation,
            route: '/tasks/categories',
            label: 'Gérer les catégories',
          ),
          metadata: {
            'uncategorized_count': uncategorizedTasks.length,
          },
        ));
      }

    } catch (e) {
      print('Erreur analyse organisation: $e');
    }

    return suggestions;
  }

  /// Analyse de consistance des habitudes
  List<SuggestionModel> _analyzeHabitConsistency(List habits) {
    final suggestions = <SuggestionModel>[];

    try {
      for (final habit in habits) {
        // Calculer le taux de réussite des 7 derniers jours
        final recentSuccessRate = _calculateRecentSuccessRate(habit);

        if (recentSuccessRate < 0.5 && habit.isActive) {
          suggestions.add(SuggestionModel(
            id: 'habit_consistency_${habit.id}',
            type: SuggestionType.habit,
            priority: SuggestionPriority.medium,
            title: 'Habitude en difficulté',
            description: 'L\'habitude "${habit.name}" n\'a été respectée qu\'à ${(recentSuccessRate * 100).toStringAsFixed(0)}% cette semaine.',
            action: SuggestionAction(
              type: ActionType.navigation,
              route: '/habits',
              label: 'Voir l\'habitude',
            ),
            metadata: {
              'habit_id': habit.id,
              'habit_name': habit.name,
              'success_rate': recentSuccessRate,
            },
          ));
        }
      }

    } catch (e) {
      print('Erreur analyse consistance: $e');
    }

    return suggestions;
  }

  /// Analyse d'amélioration des habitudes
  List<SuggestionModel> _analyzeHabitImprovement(List habits) {
    final suggestions = <SuggestionModel>[];

    try {
      final activeHabitsCount = habits.where((h) => h.isActive).length;

      if (activeHabitsCount == 0) {
        suggestions.add(SuggestionModel(
          id: 'habit_start_journey',
          type: SuggestionType.habit,
          priority: SuggestionPriority.medium,
          title: 'Commencez votre parcours d\'habitudes',
          description: 'Créez votre première habitude pour améliorer votre quotidien.',
          action: SuggestionAction(
            type: ActionType.navigation,
            route: '/habits/create',
            label: 'Créer une habitude',
          ),
          metadata: {},
        ));
      } else if (activeHabitsCount > 10) {
        suggestions.add(SuggestionModel(
          id: 'habit_too_many',
          type: SuggestionType.habit,
          priority: SuggestionPriority.low,
          title: 'Trop d\'habitudes actives',
          description: 'Vous avez $activeHabitsCount habitudes actives. Concentrez-vous sur les plus importantes.',
          action: SuggestionAction(
            type: ActionType.navigation,
            route: '/habits',
            label: 'Prioriser les habitudes',
          ),
          metadata: {
            'active_habits_count': activeHabitsCount,
          },
        ));
      }

    } catch (e) {
      print('Erreur analyse amélioration: $e');
    }

    return suggestions;
  }

  /// Analyse de corrélation habitudes-finances
  List<SuggestionModel> _analyzeHabitFinanceCorrelation() {
    final suggestions = <SuggestionModel>[];

    try {
      final habitsController = Get.find<HabitsController>();
      final badHabits = habitsController.habits.where((h) =>
        h.type == HabitType.bad && h.financialImpact != null && h.financialImpact! > 0
      ).toList();

      double totalFinancialImpact = 0;
      for (final habit in badHabits) {
        totalFinancialImpact += habit.financialImpact! * 30; // Impact mensuel
      }

      if (totalFinancialImpact > 10000) {
        suggestions.add(SuggestionModel(
          id: 'bad_habits_financial_impact',
          type: SuggestionType.crossModule,
          priority: SuggestionPriority.high,
          title: 'Impact financier des mauvaises habitudes',
          description: 'Vos mauvaises habitudes vous coûtent environ ${totalFinancialImpact.toStringAsFixed(0)} FCFA par mois.',
          action: SuggestionAction(
            type: ActionType.navigation,
            route: '/habits',
            label: 'Améliorer les habitudes',
          ),
          metadata: {
            'monthly_impact': totalFinancialImpact,
            'bad_habits_count': badHabits.length,
          },
        ));
      }

    } catch (e) {
      print('Erreur corrélation habitudes-finances: $e');
    }

    return suggestions;
  }

  /// Analyse de corrélation tâches-finances
  List<SuggestionModel> _analyzeTaskFinanceCorrelation() {
    final suggestions = <SuggestionModel>[];

    // Analyser les projets avec budgets associés
    // Cette analyse sera étendue quand nous aurons plus de données

    return suggestions;
  }

  /// Analyse de corrélation productivité-bien-être
  List<SuggestionModel> _analyzeProductivityWellbeingCorrelation() {
    final suggestions = <SuggestionModel>[];

    // Analyser la relation entre tâches complétées et habitudes de bien-être
    // Cette analyse sera étendue avec plus de données comportementales

    return suggestions;
  }

  /// Priorise et filtre les suggestions
  void _prioritizeSuggestions() {
    // Trier par priorité
    _suggestions.sort((a, b) => a.priority.index.compareTo(b.priority.index));

    // Limiter le nombre de suggestions affichées
    if (_suggestions.length > 10) {
      _suggestions.removeRange(10, _suggestions.length);
    }

    // Éliminer les doublons
    final uniqueSuggestions = <String, SuggestionModel>{};
    for (final suggestion in _suggestions) {
      uniqueSuggestions[suggestion.id] = suggestion;
    }
    _suggestions.assignAll(uniqueSuggestions.values.toList());
  }

  /// Programme l'analyse périodique
  void _schedulePeriodicAnalysis() {
    // Analyser toutes les 6 heures
    Future.delayed(const Duration(hours: 6), () {
      generateSuggestions();
      _schedulePeriodicAnalysis();
    });
  }

  /// Marque une suggestion comme lue
  void markSuggestionAsRead(String suggestionId) {
    _suggestions.removeWhere((s) => s.id == suggestionId);
  }

  /// Applique une suggestion
  Future<void> applySuggestion(SuggestionModel suggestion) async {
    try {
      switch (suggestion.action.type) {
        case ActionType.navigation:
          Get.toNamed(suggestion.action.route);
          break;
        case ActionType.automation:
          await _executeAutomation(suggestion);
          break;
        case ActionType.reminder:
          _scheduleReminder(suggestion);
          break;
      }

      markSuggestionAsRead(suggestion.id);
    } catch (e) {
      print('Erreur application suggestion: $e');
    }
  }

  /// Exécute une automatisation
  Future<void> _executeAutomation(SuggestionModel suggestion) async {
    // Implémentation des automatisations basées sur les suggestions
    print('Exécution automatisation: ${suggestion.id}');
  }

  /// Programme un rappel
  void _scheduleReminder(SuggestionModel suggestion) {
    // Implémentation des rappels
    print('Programmation rappel: ${suggestion.id}');
  }

  /// Calcule le taux de réussite récent d'une habitude
  double _calculateRecentSuccessRate(dynamic habit) {
    // Simulation - à remplacer par la vraie logique de calcul
    return 0.7; // 70% de réussite par défaut
  }

  /// Formate une date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}