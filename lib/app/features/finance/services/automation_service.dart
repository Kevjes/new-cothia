import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/budget_model.dart';
import '../models/transaction_model.dart';
import '../models/account_model.dart';
import 'budget_service.dart';
import 'transaction_service.dart';
import 'account_service.dart';

class AutomationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final BudgetService _budgetService = BudgetService();
  final TransactionService _transactionService = TransactionService();
  final AccountService _accountService = AccountService();

  /// Exécute toutes les automatisations actives pour une entité
  Future<List<Map<String, dynamic>>> executeAutomaticTransfers(String entityId) async {
    try {
      // 1. Récupérer tous les budgets avec automatisations actives
      final budgetsWithAutomation = await _budgetService.getBudgetsWithAutomation(entityId);
      final results = <Map<String, dynamic>>[];

      for (final budget in budgetsWithAutomation) {
        if (budget.automationRule == null || !budget.automationRule!.isEnabled) {
          continue;
        }

        try {
          final result = await _executeAutomationRule(budget);
          results.add({
            'budgetId': budget.id,
            'budgetName': budget.name,
            'success': result['success'],
            'message': result['message'],
            'transactionId': result['transactionId'],
          });
        } catch (e) {
          results.add({
            'budgetId': budget.id,
            'budgetName': budget.name,
            'success': false,
            'message': 'Erreur: $e',
          });
        }
      }

      return results;
    } catch (e) {
      throw Exception('Erreur lors de l\'exécution des automatisations: $e');
    }
  }

  /// Exécute une règle d'automatisation spécifique
  Future<Map<String, dynamic>> _executeAutomationRule(BudgetModel budget) async {
    final automation = budget.automationRule!;

    // Vérifier si nous sommes au bon jour du mois
    final today = DateTime.now();
    if (today.day != automation.dayOfMonth) {
      return {
        'success': false,
        'message': 'Pas le jour d\'exécution (prévu le ${automation.dayOfMonth})',
      };
    }

    // Vérifier si l'automatisation a déjà été exécutée ce mois-ci
    final hasBeenExecutedThisMonth = await _hasBeenExecutedThisMonth(budget.id, today);
    if (hasBeenExecutedThisMonth) {
      return {
        'success': false,
        'message': 'Déjà exécuté ce mois-ci',
      };
    }

    // Valider les comptes source et destination
    final validation = await _validateAutomationAccounts(automation);
    if (!validation['valid']) {
      return {
        'success': false,
        'message': validation['message'],
      };
    }

    // Créer la transaction automatique
    final transaction = TransactionModel(
      id: '',
      title: 'Automatisation: ${budget.name}',
      description: automation.description ?? 'Transfert automatique du budget ${budget.name}',
      amount: automation.amount,
      type: TransactionType.transfer,
      status: TransactionStatus.validated,
      sourceAccountId: automation.sourceAccountId,
      destinationAccountId: automation.destinationAccountId,
      budgetId: budget.id,
      entityId: budget.entityId,
      transactionDate: today,
      createdAt: today,
      updatedAt: today,
    );

    try {
      // Exécuter la transaction
      final transactionId = await _transactionService.createTransaction(transaction);

      // Mettre à jour le budget selon son type
      if (budget.type == BudgetType.saving) {
        // Pour un budget d'épargne, augmenter le currentAmount
        await _budgetService.addExpenseToBudget(budget.id, automation.amount);
      } else if (budget.type == BudgetType.expense) {
        // Pour un budget de dépense, noter que l'allocation a été faite
        await _budgetService.addExpenseToBudget(budget.id, automation.amount);
      }

      // Enregistrer l'exécution pour éviter la duplication
      await _recordAutomationExecution(budget.id, today);

      return {
        'success': true,
        'message': 'Transfert automatique de ${automation.amount.toStringAsFixed(0)} FCFA exécuté avec succès',
        'transactionId': transactionId,
      };

    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors de l\'exécution: $e',
      };
    }
  }

  /// Vérifie si une automatisation a déjà été exécutée ce mois-ci
  Future<bool> _hasBeenExecutedThisMonth(String budgetId, DateTime date) async {
    try {
      final startOfMonth = DateTime(date.year, date.month, 1);
      final endOfMonth = DateTime(date.year, date.month + 1, 0);

      final executions = await _firestore
          .collection('automation_executions')
          .where('budgetId', isEqualTo: budgetId)
          .where('executedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('executedAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .get();

      return executions.docs.isNotEmpty;
    } catch (e) {
      // En cas d'erreur, considérer comme non exécuté pour éviter de bloquer
      return false;
    }
  }

  /// Enregistre l'exécution d'une automatisation
  Future<void> _recordAutomationExecution(String budgetId, DateTime executedAt) async {
    await _firestore.collection('automation_executions').add({
      'budgetId': budgetId,
      'executedAt': Timestamp.fromDate(executedAt),
      'createdAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Valide que les comptes source et destination existent et sont valides
  Future<Map<String, dynamic>> _validateAutomationAccounts(AutomationRule automation) async {
    try {
      // Vérifier le compte source
      if (automation.sourceAccountId != null) {
        final sourceAccount = await _accountService.getAccountById(automation.sourceAccountId!);
        if (sourceAccount == null) {
          return {
            'valid': false,
            'message': 'Compte source introuvable',
          };
        }

        if (!sourceAccount.isActive) {
          return {
            'valid': false,
            'message': 'Compte source inactif',
          };
        }

        // Vérifier le solde suffisant
        if (sourceAccount.currentBalance < automation.amount) {
          return {
            'valid': false,
            'message': 'Solde insuffisant dans le compte source (${sourceAccount.currentBalance.toStringAsFixed(0)} FCFA disponibles)',
          };
        }
      }

      // Vérifier le compte destination
      if (automation.destinationAccountId != null) {
        final destinationAccount = await _accountService.getAccountById(automation.destinationAccountId!);
        if (destinationAccount == null) {
          return {
            'valid': false,
            'message': 'Compte destination introuvable',
          };
        }

        if (!destinationAccount.isActive) {
          return {
            'valid': false,
            'message': 'Compte destination inactif',
          };
        }
      }

      return {
        'valid': true,
        'message': 'Comptes valides',
      };

    } catch (e) {
      return {
        'valid': false,
        'message': 'Erreur lors de la validation des comptes: $e',
      };
    }
  }

  /// Simule l'exécution d'une automatisation (pour prévisualisation)
  Future<Map<String, dynamic>> simulateAutomationRule(BudgetModel budget) async {
    final automation = budget.automationRule;
    if (automation == null || !automation.isEnabled) {
      return {
        'success': false,
        'message': 'Aucune automatisation active',
      };
    }

    // Valider les comptes
    final validation = await _validateAutomationAccounts(automation);
    if (!validation['valid']) {
      return {
        'success': false,
        'message': validation['message'],
        'preview': false,
      };
    }

    // Créer l'aperçu
    final sourceAccount = automation.sourceAccountId != null
        ? await _accountService.getAccountById(automation.sourceAccountId!)
        : null;

    final destinationAccount = automation.destinationAccountId != null
        ? await _accountService.getAccountById(automation.destinationAccountId!)
        : null;

    return {
      'success': true,
      'message': 'Simulation réussie',
      'preview': true,
      'details': {
        'amount': automation.amount,
        'dayOfMonth': automation.dayOfMonth,
        'sourceAccount': sourceAccount?.name,
        'destinationAccount': destinationAccount?.name,
        'description': automation.description,
        'budgetName': budget.name,
        'budgetType': budget.type.name,
      }
    };
  }

  /// Obtient le prochain jour d'exécution pour toutes les automatisations d'une entité
  Future<List<Map<String, dynamic>>> getNextExecutionDates(String entityId) async {
    try {
      final budgetsWithAutomation = await _budgetService.getBudgetsWithAutomation(entityId);
      final results = <Map<String, dynamic>>[];
      final now = DateTime.now();

      for (final budget in budgetsWithAutomation) {
        if (budget.automationRule == null || !budget.automationRule!.isEnabled) {
          continue;
        }

        final automation = budget.automationRule!;
        DateTime nextExecution;

        if (now.day <= automation.dayOfMonth) {
          // Ce mois-ci
          nextExecution = DateTime(now.year, now.month, automation.dayOfMonth);
        } else {
          // Mois prochain
          nextExecution = DateTime(now.year, now.month + 1, automation.dayOfMonth);
        }

        results.add({
          'budgetId': budget.id,
          'budgetName': budget.name,
          'amount': automation.amount,
          'nextExecution': nextExecution,
          'daysUntilExecution': nextExecution.difference(now).inDays,
        });
      }

      // Trier par date d'exécution
      results.sort((a, b) => (a['nextExecution'] as DateTime).compareTo(b['nextExecution'] as DateTime));

      return results;
    } catch (e) {
      throw Exception('Erreur lors du calcul des prochaines exécutions: $e');
    }
  }
}