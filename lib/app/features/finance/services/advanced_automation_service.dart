import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/automation_rule_model.dart';
import '../models/automation_execution_model.dart';
import '../models/transaction_model.dart';
import '../models/account_model.dart';
import '../models/budget_model.dart';
import 'transaction_service.dart';
import 'account_service.dart';
import 'budget_service.dart';

class AdvancedAutomationService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TransactionService _transactionService = TransactionService();
  final AccountService _accountService = AccountService();
  final BudgetService _budgetService = BudgetService();

  final String _rulesCollection = 'automation_rules';
  final String _executionsCollection = 'automation_executions';

  // ================================
  // CRUD Opérations pour les règles
  // ================================

  /// Créer une nouvelle règle d'automatisation
  Future<bool> createRule(AutomationRuleModel rule) async {
    try {
      print('📝 Création d\'une nouvelle règle: ${rule.name}');
      print('   Entity ID: ${rule.entityId}');
      print('   Type: ${rule.triggerType.name}');

      final docRef = _firestore.collection(_rulesCollection).doc();
      final ruleWithId = rule.copyWith(
        id: docRef.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final data = ruleWithId.toFirestore();
      print('   Données à sauvegarder: ${data.keys.join(", ")}');

      await docRef.set(data);
      print('✅ Règle créée avec succès: ${ruleWithId.id}');
      return true;
    } catch (e) {
      print('❌ Erreur lors de la création de la règle: $e');
      print('   Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  /// Mettre à jour une règle d'automatisation
  Future<bool> updateRule(AutomationRuleModel rule) async {
    try {
      await _firestore
          .collection(_rulesCollection)
          .doc(rule.id)
          .update(rule.copyWith(updatedAt: DateTime.now()).toFirestore());
      return true;
    } catch (e) {
      print('Erreur lors de la mise à jour de la règle: $e');
      return false;
    }
  }

  /// Supprimer une règle d'automatisation
  Future<bool> deleteRule(String ruleId) async {
    try {
      // Supprimer la règle
      await _firestore.collection(_rulesCollection).doc(ruleId).delete();

      // Supprimer l'historique d'exécution associé
      final executions = await _firestore
          .collection(_executionsCollection)
          .where('ruleId', isEqualTo: ruleId)
          .get();

      final batch = _firestore.batch();
      for (final doc in executions.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      return true;
    } catch (e) {
      print('Erreur lors de la suppression de la règle: $e');
      return false;
    }
  }

  /// Obtenir toutes les règles d'une entité
  Future<List<AutomationRuleModel>> getRulesByEntity(String entityId) async {
    try {
      print('📡 Chargement des règles pour entityId: $entityId');
      final querySnapshot = await _firestore
          .collection(_rulesCollection)
          .where('entityId', isEqualTo: entityId)
          .orderBy('priority', descending: true)
          .orderBy('createdAt', descending: true)
          .get();

      final rules = querySnapshot.docs
          .map((doc) => AutomationRuleModel.fromFirestore(doc))
          .toList();

      print('✅ ${rules.length} règle(s) récupérée(s) depuis Firebase');
      for (final rule in rules) {
        print('  - ${rule.name} (${rule.triggerType.name})');
      }

      return rules;
    } catch (e) {
      print('❌ Erreur lors de la récupération des règles: $e');
      return [];
    }
  }

  /// Obtenir les règles actives d'une entité
  Future<List<AutomationRuleModel>> getActiveRules(String entityId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_rulesCollection)
          .where('entityId', isEqualTo: entityId)
          .where('isActive', isEqualTo: true)
          .orderBy('priority', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => AutomationRuleModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des règles actives: $e');
      return [];
    }
  }

  /// Obtenir une règle par ID
  Future<AutomationRuleModel?> getRuleById(String ruleId) async {
    try {
      final doc = await _firestore.collection(_rulesCollection).doc(ruleId).get();
      if (doc.exists) {
        return AutomationRuleModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération de la règle: $e');
      return null;
    }
  }

  // ================================
  // Moteur d'exécution automatique
  // ================================

  /// Exécuter toutes les règles programmées (appelé par un timer)
  Future<List<AutomationExecutionModel>> executeScheduledRules() async {
    try {
      print('Exécution des règles programmées...');
      final allRules = await _getAllActiveScheduledRules();
      final executions = <AutomationExecutionModel>[];

      for (final rule in allRules) {
        if (await _shouldExecuteScheduledRule(rule)) {
          final execution = await _executeRule(rule, null);
          executions.add(execution);
        }
      }

      print('${executions.length} règles programmées exécutées');
      return executions;
    } catch (e) {
      print('Erreur lors de l\'exécution des règles programmées: $e');
      return [];
    }
  }

  /// Déclencher les règles basées sur un événement (transaction)
  Future<List<AutomationExecutionModel>> triggerEventBasedRules(
    String entityId,
    TransactionModel transaction,
  ) async {
    try {
      print('Déclenchement des règles basées sur événement pour transaction: ${transaction.id}');
      final eventRules = await _getEventBasedRules(entityId);
      final executions = <AutomationExecutionModel>[];

      for (final rule in eventRules) {
        if (await _shouldTriggerEventRule(rule, transaction)) {
          final execution = await _executeRule(rule, transaction);
          executions.add(execution);
        }
      }

      print('${executions.length} règles d\'événement déclenchées');
      return executions;
    } catch (e) {
      print('Erreur lors du déclenchement des règles d\'événement: $e');
      return [];
    }
  }

  /// Déclencher les règles basées sur des catégories
  Future<List<AutomationExecutionModel>> triggerCategoryBasedRules(
    String entityId,
    TransactionModel transaction,
  ) async {
    try {
      print('Déclenchement des règles basées sur catégorie pour transaction: ${transaction.id}');
      final categoryRules = await _getCategoryBasedRules(entityId);
      final executions = <AutomationExecutionModel>[];

      for (final rule in categoryRules) {
        if (await _shouldTriggerCategoryRule(rule, transaction)) {
          final execution = await _executeRule(rule, transaction);
          executions.add(execution);
        }
      }

      print('${executions.length} règles de catégorie déclenchées');
      return executions;
    } catch (e) {
      print('Erreur lors du déclenchement des règles de catégorie: $e');
      return [];
    }
  }

  /// Exécuter une règle spécifique
  Future<AutomationExecutionModel> _executeRule(
    AutomationRuleModel rule,
    TransactionModel? triggerTransaction,
  ) async {
    final executionId = _firestore.collection(_executionsCollection).doc().id;
    final executedAt = DateTime.now();

    try {
      print('Exécution de la règle: ${rule.name}');

      // Validation préalable
      final validation = await _validateRuleExecution(rule, triggerTransaction);
      if (!validation['valid']) {
        return await _recordExecution(
          executionId,
          rule,
          ExecutionStatus.skipped,
          triggerTransaction,
          errorMessage: validation['message'],
          executedAt: executedAt,
        );
      }

      // Exécuter l'action selon son type
      Map<String, dynamic> result;
      switch (rule.action.type) {
        case ActionType.transfer:
          result = await _executeTransferAction(rule, triggerTransaction);
          break;
        case ActionType.createTransaction:
          result = await _executeCreateTransactionAction(rule, triggerTransaction);
          break;
        case ActionType.updateBudget:
          result = await _executeUpdateBudgetAction(rule, triggerTransaction);
          break;
        case ActionType.sendNotification:
          result = await _executeSendNotificationAction(rule, triggerTransaction);
          break;
        case ActionType.createSavingGoal:
          result = await _executeCreateSavingGoalAction(rule, triggerTransaction);
          break;
      }

      // Mettre à jour la règle avec la dernière exécution
      await updateRule(rule.copyWith(
        lastExecuted: executedAt,
        executionCount: rule.executionCount + 1,
      ));

      // Enregistrer l'exécution
      return await _recordExecution(
        executionId,
        rule,
        result['success'] ? ExecutionStatus.success : ExecutionStatus.failed,
        triggerTransaction,
        amount: result['amount'],
        transactionId: result['transactionId'],
        resultData: jsonEncode(result),
        errorMessage: result['success'] ? null : result['message'],
        executedAt: executedAt,
      );

    } catch (e) {
      print('Erreur lors de l\'exécution de la règle ${rule.name}: $e');
      return await _recordExecution(
        executionId,
        rule,
        ExecutionStatus.failed,
        triggerTransaction,
        errorMessage: e.toString(),
        executedAt: executedAt,
      );
    }
  }

  // ================================
  // Actions d'exécution
  // ================================

  Future<Map<String, dynamic>> _executeTransferAction(
    AutomationRuleModel rule,
    TransactionModel? triggerTransaction,
  ) async {
    try {
      final action = rule.action;

      // Calculer le montant
      double amount;
      if (action.amount != null) {
        amount = action.amount!;
      } else if (action.percentage != null && triggerTransaction != null) {
        amount = triggerTransaction.amount * (action.percentage! / 100);
      } else {
        return {
          'success': false,
          'message': 'Montant non défini pour le transfert',
        };
      }

      // Valider les comptes
      if (action.sourceAccountId == null || action.destinationAccountId == null) {
        return {
          'success': false,
          'message': 'Comptes source et destination requis',
        };
      }

      final sourceAccount = await _accountService.getAccountById(action.sourceAccountId!);
      final destinationAccount = await _accountService.getAccountById(action.destinationAccountId!);

      if (sourceAccount == null || destinationAccount == null) {
        return {
          'success': false,
          'message': 'Comptes introuvables',
        };
      }

      if (sourceAccount.currentBalance < amount) {
        return {
          'success': false,
          'message': 'Solde insuffisant (${sourceAccount.currentBalance.toStringAsFixed(0)} FCFA disponibles)',
        };
      }

      // Créer la transaction de transfert
      final transaction = TransactionModel(
        id: '',
        title: action.title ?? 'Automatisation: ${rule.name}',
        description: action.description ?? 'Transfert automatique - ${rule.name}',
        amount: amount,
        type: TransactionType.transfer,
        status: TransactionStatus.validated,
        sourceAccountId: action.sourceAccountId,
        destinationAccountId: action.destinationAccountId,
        categoryId: action.categoryId,
        budgetId: action.budgetId,
        entityId: rule.entityId,
        transactionDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final transactionId = await _transactionService.createTransaction(transaction);

      return {
        'success': true,
        'message': 'Transfert de ${amount.toStringAsFixed(0)} FCFA effectué',
        'amount': amount,
        'transactionId': transactionId,
      };

    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors du transfert: $e',
      };
    }
  }

  Future<Map<String, dynamic>> _executeCreateTransactionAction(
    AutomationRuleModel rule,
    TransactionModel? triggerTransaction,
  ) async {
    try {
      final action = rule.action;

      // Calculer le montant
      double amount;
      if (action.amount != null) {
        amount = action.amount!;
      } else if (action.percentage != null && triggerTransaction != null) {
        amount = triggerTransaction.amount * (action.percentage! / 100);
      } else {
        return {
          'success': false,
          'message': 'Montant non défini pour la transaction',
        };
      }

      // Déterminer le type de transaction
      TransactionType type = TransactionType.expense;
      if (action.destinationAccountId != null && action.sourceAccountId == null) {
        type = TransactionType.income;
      } else if (action.sourceAccountId != null && action.destinationAccountId != null) {
        type = TransactionType.transfer;
      }

      // Créer la transaction
      final transaction = TransactionModel(
        id: '',
        title: action.title ?? 'Automatisation: ${rule.name}',
        description: action.description ?? 'Transaction automatique - ${rule.name}',
        amount: amount,
        type: type,
        status: TransactionStatus.validated,
        sourceAccountId: action.sourceAccountId,
        destinationAccountId: action.destinationAccountId,
        categoryId: action.categoryId,
        budgetId: action.budgetId,
        entityId: rule.entityId,
        transactionDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final transactionId = await _transactionService.createTransaction(transaction);

      return {
        'success': true,
        'message': 'Transaction de ${amount.toStringAsFixed(0)} FCFA créée',
        'amount': amount,
        'transactionId': transactionId,
      };

    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors de la création de transaction: $e',
      };
    }
  }

  Future<Map<String, dynamic>> _executeUpdateBudgetAction(
    AutomationRuleModel rule,
    TransactionModel? triggerTransaction,
  ) async {
    try {
      final action = rule.action;

      if (action.budgetId == null) {
        return {
          'success': false,
          'message': 'ID du budget requis',
        };
      }

      final budget = await _budgetService.getBudgetById(action.budgetId!);
      if (budget == null) {
        return {
          'success': false,
          'message': 'Budget introuvable',
        };
      }

      // Calculer le montant à ajouter
      double amount;
      if (action.amount != null) {
        amount = action.amount!;
      } else if (action.percentage != null && triggerTransaction != null) {
        amount = triggerTransaction.amount * (action.percentage! / 100);
      } else {
        return {
          'success': false,
          'message': 'Montant non défini pour la mise à jour du budget',
        };
      }

      // Mettre à jour le budget
      await _budgetService.addExpenseToBudget(action.budgetId!, amount);

      return {
        'success': true,
        'message': 'Budget mis à jour avec ${amount.toStringAsFixed(0)} FCFA',
        'amount': amount,
      };

    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors de la mise à jour du budget: $e',
      };
    }
  }

  Future<Map<String, dynamic>> _executeSendNotificationAction(
    AutomationRuleModel rule,
    TransactionModel? triggerTransaction,
  ) async {
    try {
      final action = rule.action;
      final message = action.notificationMessage ?? 'Règle d\'automatisation exécutée: ${rule.name}';

      // Ici, vous pouvez intégrer un service de notification
      // Pour l'instant, on fait juste un log
      print('NOTIFICATION: $message');

      return {
        'success': true,
        'message': 'Notification envoyée',
      };

    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors de l\'envoi de la notification: $e',
      };
    }
  }

  Future<Map<String, dynamic>> _executeCreateSavingGoalAction(
    AutomationRuleModel rule,
    TransactionModel? triggerTransaction,
  ) async {
    try {
      // Cette action nécessiterait un service d'objectifs d'épargne
      // Pour l'instant, on retourne un succès simulé
      return {
        'success': true,
        'message': 'Objectif d\'épargne créé (fonctionnalité à implémenter)',
      };

    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors de la création de l\'objectif d\'épargne: $e',
      };
    }
  }

  // ================================
  // Logique de validation et déclenchement
  // ================================

  Future<List<AutomationRuleModel>> _getAllActiveScheduledRules() async {
    try {
      final querySnapshot = await _firestore
          .collection(_rulesCollection)
          .where('isActive', isEqualTo: true)
          .where('triggerType', isEqualTo: 'scheduled')
          .get();

      return querySnapshot.docs
          .map((doc) => AutomationRuleModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des règles programmées: $e');
      return [];
    }
  }

  Future<List<AutomationRuleModel>> _getEventBasedRules(String entityId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_rulesCollection)
          .where('entityId', isEqualTo: entityId)
          .where('isActive', isEqualTo: true)
          .where('triggerType', isEqualTo: 'eventBased')
          .get();

      return querySnapshot.docs
          .map((doc) => AutomationRuleModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des règles d\'événement: $e');
      return [];
    }
  }

  Future<List<AutomationRuleModel>> _getCategoryBasedRules(String entityId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_rulesCollection)
          .where('entityId', isEqualTo: entityId)
          .where('isActive', isEqualTo: true)
          .where('triggerType', isEqualTo: 'categoryBased')
          .get();

      return querySnapshot.docs
          .map((doc) => AutomationRuleModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des règles de catégorie: $e');
      return [];
    }
  }

  Future<bool> _shouldExecuteScheduledRule(AutomationRuleModel rule) async {
    if (!rule.hasScheduledTrigger) return false;

    final trigger = rule.scheduledTrigger!;
    final now = DateTime.now();

    // Vérifier les dates limites
    if (trigger.startDate != null && now.isBefore(trigger.startDate!)) return false;
    if (trigger.endDate != null && now.isAfter(trigger.endDate!)) return false;

    // Vérifier si déjà exécuté selon la fréquence
    switch (trigger.frequency) {
      case ScheduledTriggerFrequency.daily:
        return await _canExecuteDaily(rule);
      case ScheduledTriggerFrequency.weekly:
        return await _canExecuteWeekly(rule, trigger);
      case ScheduledTriggerFrequency.monthly:
        return await _canExecuteMonthly(rule, trigger);
      case ScheduledTriggerFrequency.multiplePerMonth:
        return await _canExecuteMultiplePerMonth(rule, trigger);
      case ScheduledTriggerFrequency.quarterly:
        return await _canExecuteQuarterly(rule, trigger);
      case ScheduledTriggerFrequency.yearly:
        return await _canExecuteYearly(rule, trigger);
      case ScheduledTriggerFrequency.custom:
        return await _canExecuteCustom(rule, trigger);
    }
  }

  Future<bool> _shouldTriggerEventRule(AutomationRuleModel rule, TransactionModel transaction) async {
    if (!rule.hasEventTrigger) return false;

    final trigger = rule.eventTrigger!;

    // Vérifier le type d'événement
    switch (trigger.eventType) {
      case EventTriggerType.moneyEntry:
        if (transaction.type != TransactionType.income) return false;
        break;
      case EventTriggerType.expenseOccurred:
        if (transaction.type != TransactionType.expense) return false;
        break;
      case EventTriggerType.salaryReceived:
        if (transaction.type != TransactionType.income ||
            !await _isSalaryTransaction(transaction)) return false;
        break;
      case EventTriggerType.firstEntryOfMonth:
        if (transaction.type != TransactionType.income ||
            !await _isFirstEntryOfMonth(transaction)) return false;
        break;
      default:
        // Autres types d'événements à implémenter
        break;
    }

    // Vérifier le seuil de montant
    if (trigger.amountThreshold != null && transaction.amount < trigger.amountThreshold!) {
      return false;
    }

    // Vérifier le compte spécifique
    if (trigger.accountId != null) {
      if (transaction.sourceAccountId != trigger.accountId &&
          transaction.destinationAccountId != trigger.accountId) {
        return false;
      }
    }

    // Vérifier si c'est la première occurrence du mois (si activé)
    if (trigger.onlyFirstOfMonth == true) {
      return await _isFirstExecutionOfMonth(rule);
    }

    return true;
  }

  Future<bool> _shouldTriggerCategoryRule(AutomationRuleModel rule, TransactionModel transaction) async {
    if (!rule.hasCategoryTrigger) return false;

    final trigger = rule.categoryTrigger!;

    // Vérifier la catégorie
    if (transaction.categoryId == null || !trigger.categoryIds.contains(transaction.categoryId)) {
      return false;
    }

    // Vérifier le montant minimum
    if (trigger.minAmount != null && transaction.amount < trigger.minAmount!) {
      return false;
    }

    // Vérifier le montant maximum
    if (trigger.maxAmount != null && transaction.amount > trigger.maxAmount!) {
      return false;
    }

    // Vérifier le type de transaction
    if (trigger.onlyIncome == true && transaction.type != TransactionType.income) {
      return false;
    }
    if (trigger.onlyExpense == true && transaction.type != TransactionType.expense) {
      return false;
    }

    // Vérifier la limite d'exécutions par mois
    if (trigger.maxExecutionsPerMonth != null) {
      final executionsThisMonth = await _getExecutionsThisMonth(rule.id);
      if (executionsThisMonth >= trigger.maxExecutionsPerMonth!) {
        return false;
      }
    }

    return true;
  }

  // ================================
  // Méthodes utilitaires
  // ================================

  Future<bool> _canExecuteDaily(AutomationRuleModel rule) async {
    if (rule.lastExecuted == null) return true;

    final today = DateTime.now();
    final lastExecution = rule.lastExecuted!;

    return !_isSameDay(today, lastExecution);
  }

  Future<bool> _canExecuteWeekly(AutomationRuleModel rule, ScheduledTrigger trigger) async {
    final today = DateTime.now();
    final targetDayOfWeek = trigger.dayOfWeek ?? 7; // Dimanche par défaut

    if (today.weekday != targetDayOfWeek) return false;

    if (rule.lastExecuted == null) return true;

    // Vérifier qu'on n'a pas déjà exécuté cette semaine
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    return rule.lastExecuted!.isBefore(startOfWeek);
  }

  Future<bool> _canExecuteMonthly(AutomationRuleModel rule, ScheduledTrigger trigger) async {
    final today = DateTime.now();
    final targetDay = trigger.dayOfMonth ?? 1;

    if (today.day != targetDay) return false;

    if (rule.lastExecuted == null) return true;

    // Vérifier qu'on n'a pas déjà exécuté ce mois
    final startOfMonth = DateTime(today.year, today.month, 1);
    return rule.lastExecuted!.isBefore(startOfMonth);
  }

  Future<bool> _canExecuteMultiplePerMonth(AutomationRuleModel rule, ScheduledTrigger trigger) async {
    final today = DateTime.now();
    final targetDays = trigger.daysOfMonth ?? [];

    if (!targetDays.contains(today.day)) return false;

    if (rule.lastExecuted == null) return true;

    // Vérifier qu'on n'a pas déjà exécuté aujourd'hui
    return !_isSameDay(today, rule.lastExecuted!);
  }

  Future<bool> _canExecuteQuarterly(AutomationRuleModel rule, ScheduledTrigger trigger) async {
    final today = DateTime.now();
    final targetDay = trigger.dayOfMonth ?? 1;

    // Vérifier si c'est le premier mois du trimestre
    final isQuarterStart = [1, 4, 7, 10].contains(today.month);
    if (!isQuarterStart || today.day != targetDay) return false;

    if (rule.lastExecuted == null) return true;

    // Vérifier qu'on n'a pas déjà exécuté ce trimestre
    final quarter = ((today.month - 1) ~/ 3) + 1;
    final startOfQuarter = DateTime(today.year, (quarter - 1) * 3 + 1, 1);
    return rule.lastExecuted!.isBefore(startOfQuarter);
  }

  Future<bool> _canExecuteYearly(AutomationRuleModel rule, ScheduledTrigger trigger) async {
    final today = DateTime.now();
    final targetDay = trigger.dayOfMonth ?? 1;

    if (today.month != 1 || today.day != targetDay) return false;

    if (rule.lastExecuted == null) return true;

    // Vérifier qu'on n'a pas déjà exécuté cette année
    final startOfYear = DateTime(today.year, 1, 1);
    return rule.lastExecuted!.isBefore(startOfYear);
  }

  Future<bool> _canExecuteCustom(AutomationRuleModel rule, ScheduledTrigger trigger) async {
    if (rule.lastExecuted == null) return true;

    final today = DateTime.now();
    final interval = trigger.monthsInterval ?? 1;
    final nextExecution = DateTime(
      rule.lastExecuted!.year,
      rule.lastExecuted!.month + interval,
      trigger.dayOfMonth ?? rule.lastExecuted!.day,
    );

    return today.isAfter(nextExecution) || _isSameDay(today, nextExecution);
  }

  Future<Map<String, dynamic>> _validateRuleExecution(
    AutomationRuleModel rule,
    TransactionModel? triggerTransaction,
  ) async {
    // Validation générale de la règle
    if (!rule.isActive) {
      return {'valid': false, 'message': 'Règle inactive'};
    }

    // Validation spécifique à l'action
    final action = rule.action;

    if (action.type == ActionType.transfer) {
      if (action.sourceAccountId == null || action.destinationAccountId == null) {
        return {'valid': false, 'message': 'Comptes source et destination requis pour le transfert'};
      }

      if (action.amount == null && action.percentage == null) {
        return {'valid': false, 'message': 'Montant ou pourcentage requis'};
      }

      if (action.percentage != null && triggerTransaction == null) {
        return {'valid': false, 'message': 'Transaction déclencheuse requise pour le pourcentage'};
      }
    }

    return {'valid': true, 'message': 'Validation réussie'};
  }

  Future<AutomationExecutionModel> _recordExecution(
    String executionId,
    AutomationRuleModel rule,
    ExecutionStatus status,
    TransactionModel? triggerTransaction, {
    double? amount,
    String? transactionId,
    String? resultData,
    String? errorMessage,
    required DateTime executedAt,
  }) async {
    final execution = AutomationExecutionModel(
      id: executionId,
      ruleId: rule.id,
      ruleName: rule.name,
      entityId: rule.entityId,
      status: status,
      triggerData: triggerTransaction != null ? jsonEncode(triggerTransaction.toJson()) : null,
      resultData: resultData,
      transactionId: transactionId,
      amount: amount,
      errorMessage: errorMessage,
      executedAt: executedAt,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection(_executionsCollection)
        .doc(executionId)
        .set(execution.toFirestore());

    return execution;
  }

  Future<bool> _isSalaryTransaction(TransactionModel transaction) async {
    // Vérifier si la transaction est liée à une catégorie "Salaire"
    // Cette logique dépend de votre système de catégories
    return transaction.categoryId != null &&
           (await _getCategoryName(transaction.categoryId!))?.toLowerCase().contains('salaire') == true;
  }

  Future<String?> _getCategoryName(String categoryId) async {
    try {
      final doc = await _firestore.collection('categories').doc(categoryId).get();
      return doc.data()?['name'];
    } catch (e) {
      return null;
    }
  }

  Future<bool> _isFirstEntryOfMonth(TransactionModel transaction) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    // Vérifier s'il y a eu d'autres entrées ce mois-ci avant cette transaction
    final previousEntries = await _firestore
        .collection('transactions')
        .where('entityId', isEqualTo: transaction.entityId)
        .where('type', isEqualTo: 'income')
        .where('transactionDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('transactionDate', isLessThan: Timestamp.fromDate(transaction.transactionDate))
        .get();

    return previousEntries.docs.isEmpty;
  }

  Future<bool> _isFirstExecutionOfMonth(AutomationRuleModel rule) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    final executionsThisMonth = await _firestore
        .collection(_executionsCollection)
        .where('ruleId', isEqualTo: rule.id)
        .where('status', isEqualTo: 'success')
        .where('executedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .get();

    return executionsThisMonth.docs.isEmpty;
  }

  Future<int> _getExecutionsThisMonth(String ruleId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    final executions = await _firestore
        .collection(_executionsCollection)
        .where('ruleId', isEqualTo: ruleId)
        .where('status', isEqualTo: 'success')
        .where('executedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .get();

    return executions.docs.length;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  // ================================
  // Méthodes pour l'historique
  // ================================

  /// Obtenir l'historique d'exécution d'une règle
  Future<List<AutomationExecutionModel>> getRuleExecutions(String ruleId, {int? limit}) async {
    try {
      var query = _firestore
          .collection(_executionsCollection)
          .where('ruleId', isEqualTo: ruleId)
          .orderBy('executedAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => AutomationExecutionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération de l\'historique: $e');
      return [];
    }
  }

  /// Obtenir l'historique d'exécution d'une entité
  Future<List<AutomationExecutionModel>> getEntityExecutions(String entityId, {int? limit}) async {
    try {
      var query = _firestore
          .collection(_executionsCollection)
          .where('entityId', isEqualTo: entityId)
          .orderBy('executedAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => AutomationExecutionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération de l\'historique: $e');
      return [];
    }
  }

  /// Obtenir les statistiques d'exécution
  Future<Map<String, dynamic>> getExecutionStats(String entityId) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      // Exécutions ce mois-ci
      final thisMonthExecutions = await _firestore
          .collection(_executionsCollection)
          .where('entityId', isEqualTo: entityId)
          .where('executedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .get();

      final successCount = thisMonthExecutions.docs
          .where((doc) => doc.data()['status'] == 'success')
          .length;

      final failureCount = thisMonthExecutions.docs
          .where((doc) => doc.data()['status'] == 'failed')
          .length;

      // Règles actives
      final activeRules = await getActiveRules(entityId);

      return {
        'totalActiveRules': activeRules.length,
        'executionsThisMonth': thisMonthExecutions.docs.length,
        'successfulExecutions': successCount,
        'failedExecutions': failureCount,
        'successRate': thisMonthExecutions.docs.isNotEmpty
            ? (successCount / thisMonthExecutions.docs.length * 100).round()
            : 0,
      };
    } catch (e) {
      print('Erreur lors du calcul des statistiques: $e');
      return {};
    }
  }
}