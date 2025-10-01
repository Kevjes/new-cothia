import 'package:get/get.dart';
import '../../features/finance/controllers/finance_controller.dart';
import '../../features/finance/controllers/transactions_controller.dart';
import '../../features/finance/controllers/budgets_controller.dart';
import '../../features/tasks/controllers/tasks_controller.dart';
import '../../features/tasks/services/task_service.dart';
import '../../features/habits/controllers/habits_controller.dart';
import '../../features/habits/services/habit_service.dart';
import '../../features/entities/controllers/entities_controller.dart';
import '../../features/finance/models/transaction_model.dart';
import '../../features/tasks/models/task_model.dart';
import '../../features/habits/models/habit_model.dart';

/// Service de synchronisation inter-modules pour Cothia
/// Gère la synchronisation automatique des données entre modules
class SynchronizationService extends GetxService {
  final _isInitialized = false.obs;
  final _isSyncing = false.obs;
  final _lastSyncTime = Rx<DateTime?>(null);

  bool get isInitialized => _isInitialized.value;
  bool get isSyncing => _isSyncing.value;
  DateTime? get lastSyncTime => _lastSyncTime.value;

  @override
  void onInit() {
    super.onInit();
    _initializeSynchronization();
  }

  Future<void> _initializeSynchronization() async {
    try {
      // Attendre que tous les contrôleurs soient initialisés
      await _waitForControllers();

      // Configurer les listeners pour la synchronisation automatique
      _setupTaskFinanceSync();
      _setupHabitFinanceSync();
      _setupHabitTaskSync();
      _setupEntityCascadeSync();

      _isInitialized.value = true;
      _lastSyncTime.value = DateTime.now();

      print('Service de synchronisation initialisé avec succès');
    } catch (e) {
      print('Erreur initialisation synchronisation: $e');
    }
  }

  /// Attendre que tous les contrôleurs soient disponibles
  Future<void> _waitForControllers() async {
    int attempts = 0;
    const maxAttempts = 10;

    while (attempts < maxAttempts) {
      try {
        Get.find<FinanceController>();
        Get.find<TransactionsController>();
        Get.find<TaskService>();
        Get.find<TasksController>();
        Get.find<HabitsController>();
        Get.find<HabitsController>();
        Get.find<EntitiesController>();
        return; // Tous les contrôleurs sont disponibles
      } catch (e) {
        attempts++;
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    throw Exception('Impossible d\'initialiser les contrôleurs requis');
  }

  /// Configure la synchronisation Tâches ↔ Finances
  void _setupTaskFinanceSync() {
    try {
      final taskService = Get.find<TaskService>();
      final transactionsController = Get.find<TransactionsController>();

      // Écouter les changements de tâches pour créer/valider des transactions liées
      taskService.tasksObservable.listen((tasks) {
        _syncTasksToFinance(tasks);
      });

      print('Synchronisation Tâches ↔ Finances configurée');
    } catch (e) {
      print('Erreur configuration sync tâches-finances: $e');
    }
  }

  /// Configure la synchronisation Habitudes ↔ Finances
  void _setupHabitFinanceSync() {
    try {
      final habitsController = Get.find<HabitsController>();
      final transactionsController = Get.find<TransactionsController>();

      // Écouter les changements d'habitudes pour créer des transactions automatiques
      habitsController.habitsObservable.listen((habits) {
        _syncHabitsToFinance(habits);
      });

      print('Synchronisation Habitudes ↔ Finances configurée');
    } catch (e) {
      print('Erreur configuration sync habitudes-finances: $e');
    }
  }

  /// Configure la synchronisation Habitudes ↔ Tâches
  void _setupHabitTaskSync() {
    try {
      final habitsController = Get.find<HabitsController>();
      final tasksController = Get.find<TasksController>();

      // Écouter les habitudes pour créer des tâches automatiques
      habitsController.habitsObservable.listen((habits) {
        _syncHabitsToTasks(habits);
      });

      print('Synchronisation Habitudes ↔ Tâches configurée');
    } catch (e) {
      print('Erreur configuration sync habitudes-tâches: $e');
    }
  }

  /// Configure la synchronisation en cascade des entités
  void _setupEntityCascadeSync() {
    try {
      final entitiesController = Get.find<EntitiesController>();

      // Écouter les changements d'entité active pour synchroniser tous les modules
      entitiesController.currentEntityObservable.listen((entity) {
        if (entity != null) {
          _syncEntityChange(entity);
        }
      });

      print('Synchronisation en cascade des entités configurée');
    } catch (e) {
      print('Erreur configuration sync entités: $e');
    }
  }

  /// Synchronise les tâches terminées avec le module finance
  Future<void> _syncTasksToFinance(List<TaskModel> tasks) async {
    if (_isSyncing.value) return;

    try {
      _isSyncing.value = true;

      final transactionsController = Get.find<TransactionsController>();
      final financeController = Get.find<FinanceController>();

      // Identifier les tâches récemment terminées avec impact financier
      final completedTasksWithFinancialImpact = tasks.where((task) =>
        task.status == TaskStatus.completed &&
        task.linkedTransactionId != null &&
        task.linkedTransactionId!.isNotEmpty
      ).toList();

      for (final task in completedTasksWithFinancialImpact) {
        // Vérifier si la transaction liée existe et est en attente
        final linkedTransaction = transactionsController.transactions
          .where((t) => t.id == task.linkedTransactionId)
          .firstOrNull;

        if (linkedTransaction != null && linkedTransaction.status == TransactionStatus.pending) {
          // Valider automatiquement la transaction
          await _validateLinkedTransaction(linkedTransaction, task);
        }

        // Créer une transaction de récompense si la tâche en a une (feature à implémenter)
        // if (task.metadata?['rewardAmount'] != null && task.metadata!['rewardAmount'] > 0) {
        //   await _createRewardTransaction(task);
        // }
      }

      // Synchroniser les budgets de projets
      await _syncProjectBudgets(tasks);

    } catch (e) {
      print('Erreur synchronisation tâches-finances: $e');
    } finally {
      _isSyncing.value = false;
      _lastSyncTime.value = DateTime.now();
    }
  }

  /// Synchronise les habitudes avec le module finance
  Future<void> _syncHabitsToFinance(List<HabitModel> habits) async {
    if (_isSyncing.value) return;

    try {
      _isSyncing.value = true;

      final transactionsController = Get.find<TransactionsController>();

      for (final habit in habits) {
        // Gérer l'impact financier des mauvaises habitudes
        if (habit.type == HabitType.bad && habit.financialImpact != null && habit.financialImpact! > 0) {
          await _processNegativeHabitFinancialImpact(habit);
        }

        // Créer des transferts automatiques pour les bonnes habitudes d'épargne
        if (habit.type == HabitType.good && habit.metadata?['linkedBudgetId'] != null) {
          await _processSavingsHabitTransfer(habit);
        }
      }

    } catch (e) {
      print('Erreur synchronisation habitudes-finances: $e');
    } finally {
      _isSyncing.value = false;
      _lastSyncTime.value = DateTime.now();
    }
  }

  /// Synchronise les habitudes avec le module tâches
  Future<void> _syncHabitsToTasks(List<HabitModel> habits) async {
    if (_isSyncing.value) return;

    try {
      _isSyncing.value = true;

      final tasksController = Get.find<TasksController>();

      for (final habit in habits) {
        // Créer des tâches automatiques basées sur les habitudes
        if (habit.isActive) {
          await _createAutomaticTasksFromHabit(habit);
        }

        // Synchroniser les tâches de routine
        if (habit.routineId != null) {
          await _syncRoutineTasks(habit);
        }
      }

    } catch (e) {
      print('Erreur synchronisation habitudes-tâches: $e');
    } finally {
      _isSyncing.value = false;
      _lastSyncTime.value = DateTime.now();
    }
  }

  /// Synchronise le changement d'entité active
  Future<void> _syncEntityChange(dynamic entity) async {
    try {
      _isSyncing.value = true;

      // Recharger toutes les données des modules pour la nouvelle entité
      final financeController = Get.find<FinanceController>();
      final tasksController = Get.find<TasksController>();
      final habitsController = Get.find<HabitsController>();

      await Future.wait([
        financeController.refreshAllData(),
        tasksController.loadTasks(),
        habitsController.loadHabits(),
      ]);

      print('Synchronisation entité terminée pour: ${entity.name}');

    } catch (e) {
      print('Erreur synchronisation changement entité: $e');
    } finally {
      _isSyncing.value = false;
      _lastSyncTime.value = DateTime.now();
    }
  }

  /// Valide une transaction liée à une tâche terminée
  Future<void> _validateLinkedTransaction(TransactionModel transaction, TaskModel task) async {
    try {
      final transactionsController = Get.find<TransactionsController>();

      // Créer une transaction mise à jour avec le statut validé
      final updatedTransaction = transaction.copyWith(
        status: TransactionStatus.validated,
        description: '${transaction.description} - Validée automatiquement (tâche terminée: ${task.title})',
        updatedAt: DateTime.now(),
      );

      await transactionsController.updateTransaction(updatedTransaction.id, updatedTransaction);
      print('Transaction ${transaction.id} validée automatiquement');

    } catch (e) {
      print('Erreur validation transaction liée: $e');
    }
  }

  /// Crée une transaction de récompense pour une tâche terminée
  Future<void> _createRewardTransaction(TaskModel task) async {
    try {
      final transactionsController = Get.find<TransactionsController>();
      final entitiesController = Get.find<EntitiesController>();

      final rewardTransaction = TransactionModel(
        id: '',
        title: 'Récompense: ${task.title}',
        description: 'Récompense automatique pour la tâche terminée',
        amount: (task.metadata?['rewardAmount'] as double?) ?? 0,
        type: TransactionType.income,
        status: TransactionStatus.validated,
        categoryId: 'reward_category',
        entityId: entitiesController.currentEntity?.id ?? '',
        transactionDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await transactionsController.createTransaction(rewardTransaction);
      print('Transaction de récompense créée: ${task.metadata?['rewardAmount']} FCFA');

    } catch (e) {
      print('Erreur création transaction récompense: $e');
    }
  }

  /// Synchronise les budgets des projets avec les tâches
  Future<void> _syncProjectBudgets(List<TaskModel> tasks) async {
    try {
      final financeController = Get.find<FinanceController>();

      // Grouper les tâches par projet
      final tasksByProject = <String, List<TaskModel>>{};
      for (final task in tasks) {
        if (task.projectId != null && task.projectId!.isNotEmpty) {
          tasksByProject.putIfAbsent(task.projectId!, () => []).add(task);
        }
      }

      // Mettre à jour les budgets des projets
      for (final projectId in tasksByProject.keys) {
        final projectTasks = tasksByProject[projectId]!;
        final completedTasks = projectTasks.where((t) => t.status == TaskStatus.completed).length;
        final totalTasks = projectTasks.length;

        if (totalTasks > 0) {
          final progressPercentage = (completedTasks / totalTasks * 100).round();
          // Mettre à jour le progrès du budget lié au projet si il existe
          await _updateProjectBudgetProgress(projectId, progressPercentage);
        }
      }

    } catch (e) {
      print('Erreur synchronisation budgets projets: $e');
    }
  }

  /// Met à jour le progrès d'un budget de projet
  Future<void> _updateProjectBudgetProgress(String projectId, int progressPercentage) async {
    try {
      final financeController = Get.find<FinanceController>();

      // TODO: Implémenter la liaison budget-projet
      // Pour l'instant, on enregistre juste le progrès
      print('Mise à jour progrès budget projet $projectId: $progressPercentage%');
      // La liaison budget-projet sera implémentée quand le BudgetModel aura le champ approprié

    } catch (e) {
      print('Erreur mise à jour progrès budget projet: $e');
    }
  }

  /// Traite l'impact financier négatif d'une mauvaise habitude
  Future<void> _processNegativeHabitFinancialImpact(HabitModel habit) async {
    try {
      // Calculer si l'habitude a eu un impact financier récent
      final today = DateTime.now();
      final lastImpactDate = habit.metadata?['lastFinancialImpactDate'] as DateTime?;

      if (lastImpactDate == null ||
          today.difference(lastImpactDate).inDays >= 1) {

        // Créer une transaction pour l'impact financier négatif
        final transactionsController = Get.find<TransactionsController>();
        final entitiesController = Get.find<EntitiesController>();

        final impactTransaction = TransactionModel(
          id: '',
          title: 'Impact: ${habit.name}',
          description: 'Impact financier de la mauvaise habitude',
          amount: habit.financialImpact!,
          type: TransactionType.expense,
          status: TransactionStatus.validated,
          categoryId: 'bad_habit_category',
          entityId: entitiesController.currentEntity?.id ?? '',
          transactionDate: today,
          createdAt: today,
          updatedAt: today,
        );

        await transactionsController.createTransaction(impactTransaction);
        print('Impact financier négatif enregistré: ${habit.financialImpact} FCFA');
      }

    } catch (e) {
      print('Erreur traitement impact financier négatif: $e');
    }
  }

  /// Traite les transferts automatiques pour les habitudes d'épargne
  Future<void> _processSavingsHabitTransfer(HabitModel habit) async {
    try {
      // Logique pour les transferts automatiques d'épargne basés sur les bonnes habitudes
      print('Traitement transfert épargne pour habitude: ${habit.name}');
      // À implémenter selon les besoins spécifiques

    } catch (e) {
      print('Erreur traitement transfert épargne: $e');
    }
  }

  /// Crée des tâches automatiques basées sur une habitude
  Future<void> _createAutomaticTasksFromHabit(HabitModel habit) async {
    try {
      final tasksController = Get.find<TasksController>();
      final entitiesController = Get.find<EntitiesController>();

      // Vérifier si une tâche pour cette habitude existe déjà aujourd'hui
      final today = DateTime.now();
      final taskService = Get.find<TaskService>();
      final existingTask = taskService.tasks
        .where((t) =>
          t.linkedHabitId == habit.id &&
          t.dueDate != null &&
          t.dueDate!.year == today.year &&
          t.dueDate!.month == today.month &&
          t.dueDate!.day == today.day
        )
        .firstOrNull;

      if (existingTask == null && _shouldCreateTaskForHabit(habit, today)) {
        // Créer une nouvelle tâche automatique
        final automaticTask = TaskModel(
          id: '',
          title: 'Habitude: ${habit.name}',
          description: 'Tâche automatique générée pour l\'habitude ${habit.name}',
          status: TaskStatus.pending,
          priority: TaskPriority.medium,
          categoryId: 'auto_habit_category', // Catégorie par défaut pour les tâches d'habitudes
          entityId: entitiesController.currentEntity?.id ?? '',
          linkedHabitId: habit.id,
          dueDate: DateTime(today.year, today.month, today.day, 23, 59),
          createdAt: today,
          updatedAt: today,
        );

        await tasksController.createTask(automaticTask);
        print('Tâche automatique créée pour habitude: ${habit.name}');
      }

    } catch (e) {
      print('Erreur création tâche automatique: $e');
    }
  }

  /// Détermine si une tâche doit être créée pour une habitude donnée
  bool _shouldCreateTaskForHabit(HabitModel habit, DateTime date) {
    // Logique basée sur la fréquence de l'habitude
    switch (habit.frequency) {
      case HabitFrequency.daily:
        return true;
      case HabitFrequency.weekly:
        // Créer seulement certains jours de la semaine
        return habit.specificDays.contains(date.weekday);
      case HabitFrequency.specificDays:
        return habit.specificDays.contains(date.weekday);
      default:
        return false;
    }
  }

  /// Synchronise les tâches de routine
  Future<void> _syncRoutineTasks(HabitModel habit) async {
    try {
      // Logique pour synchroniser les tâches liées aux routines
      print('Synchronisation tâches routine pour: ${habit.name}');
      // À implémenter selon les besoins spécifiques

    } catch (e) {
      print('Erreur synchronisation tâches routine: $e');
    }
  }

  /// Force la synchronisation manuelle de tous les modules
  Future<void> forceSynchronization() async {
    try {
      _isSyncing.value = true;

      final taskService = Get.find<TaskService>();
      final habitsController = Get.find<HabitsController>();

      // Resynchroniser tous les modules
      await _syncTasksToFinance(taskService.tasks);
      await _syncHabitsToFinance(habitsController.habits);
      await _syncHabitsToTasks(habitsController.habits);

      print('Synchronisation forcée terminée');

    } catch (e) {
      print('Erreur synchronisation forcée: $e');
    } finally {
      _isSyncing.value = false;
      _lastSyncTime.value = DateTime.now();
    }
  }

  /// Obtient le statut de synchronisation
  Map<String, dynamic> getSyncStatus() {
    return {
      'isInitialized': _isInitialized.value,
      'isSyncing': _isSyncing.value,
      'lastSyncTime': _lastSyncTime.value?.toIso8601String(),
      'syncConnections': [
        'Tâches ↔ Finances',
        'Habitudes ↔ Finances',
        'Habitudes ↔ Tâches',
        'Entités (cascade)',
      ],
    };
  }
}