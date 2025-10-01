import 'dart:async';
import 'package:get/get.dart';
import 'advanced_automation_service.dart';
import '../models/transaction_model.dart';

class AutomationExecutionEngine extends GetxService {
  late final AdvancedAutomationService _automationService;
  Timer? _scheduledTimer;
  bool _isRunning = false;

  // Configuration
  static const Duration _checkInterval = Duration(minutes: 30); // Vérifier toutes les 30 minutes
  static const Duration _dailyCheckTime = Duration(hours: 6); // Vérification quotidienne à 6h

  @override
  void onInit() {
    super.onInit();
    _automationService = Get.find<AdvancedAutomationService>();
    _startScheduledExecution();
    print('Moteur d\'exécution automatique démarré');
  }

  @override
  void onClose() {
    _stopScheduledExecution();
    super.onClose();
  }

  // ================================
  // Exécution programmée
  // ================================

  /// Démarrer l'exécution programmée des règles
  void _startScheduledExecution() {
    _scheduledTimer = Timer.periodic(_checkInterval, (timer) {
      _executeScheduledRulesIfNeeded();
    });
  }

  /// Arrêter l'exécution programmée
  void _stopScheduledExecution() {
    _scheduledTimer?.cancel();
    _scheduledTimer = null;
  }

  /// Exécuter les règles programmées si nécessaire
  Future<void> _executeScheduledRulesIfNeeded() async {
    if (_isRunning) {
      print('Exécution déjà en cours, passage ignoré');
      return;
    }

    try {
      _isRunning = true;
      final now = DateTime.now();

      // Exécuter les règles programmées
      print('Vérification des règles programmées à ${now.toString()}');
      final executions = await _automationService.executeScheduledRules();

      if (executions.isNotEmpty) {
        print('${executions.length} règles programmées exécutées');

        // Optionnel : Envoyer une notification ou log
        for (final execution in executions) {
          print('Règle ${execution.ruleName}: ${execution.statusDisplayName}');
          if (execution.errorMessage != null) {
            print('  Erreur: ${execution.errorMessage}');
          }
        }
      }

    } catch (e) {
      print('Erreur lors de l\'exécution programmée: $e');
    } finally {
      _isRunning = false;
    }
  }

  /// Forcer l'exécution des règles programmées (pour test ou débogage)
  Future<void> forceExecuteScheduledRules() async {
    print('Exécution forcée des règles programmées...');
    await _executeScheduledRulesIfNeeded();
  }

  // ================================
  // Déclenchement par événements
  // ================================

  /// Déclencher les règles basées sur une transaction
  Future<void> triggerRulesForTransaction(TransactionModel transaction) async {
    if (_isRunning) {
      print('Moteur occupé, déclenchement reporté');
      return;
    }

    try {
      _isRunning = true;
      print('Déclenchement des règles pour transaction: ${transaction.id}');

      // Exécuter les règles basées sur les événements
      final eventExecutions = await _automationService.triggerEventBasedRules(
        transaction.entityId,
        transaction,
      );

      // Exécuter les règles basées sur les catégories
      final categoryExecutions = await _automationService.triggerCategoryBasedRules(
        transaction.entityId,
        transaction,
      );

      final totalExecutions = eventExecutions.length + categoryExecutions.length;

      if (totalExecutions > 0) {
        print('$totalExecutions règles déclenchées par la transaction ${transaction.id}');

        // Log des résultats
        for (final execution in [...eventExecutions, ...categoryExecutions]) {
          print('  Règle ${execution.ruleName}: ${execution.statusDisplayName}');
          if (execution.errorMessage != null) {
            print('    Erreur: ${execution.errorMessage}');
          } else if (execution.amount != null) {
            print('    Montant: ${execution.amount!.toStringAsFixed(0)} FCFA');
          }
        }
      }

    } catch (e) {
      print('Erreur lors du déclenchement des règles: $e');
    } finally {
      _isRunning = false;
    }
  }

  // ================================
  // Déclenchements spéciaux
  // ================================

  /// Déclencher les règles pour la première entrée du mois
  Future<void> triggerFirstEntryOfMonthRules(String entityId) async {
    try {
      print('Déclenchement des règles "première entrée du mois" pour entité: $entityId');

      // Cette fonction serait appelée par le service des transactions
      // lors de la première transaction de revenus du mois

      // Pour l'instant, on utilise la logique générale des événements
      // avec une transaction fictive pour déclencher les règles appropriées

    } catch (e) {
      print('Erreur lors du déclenchement des règles de première entrée: $e');
    }
  }

  /// Déclencher les règles lorsqu'un budget est dépassé
  Future<void> triggerBudgetExceededRules(String entityId, String budgetId) async {
    try {
      print('Déclenchement des règles "budget dépassé" pour budget: $budgetId');

      // Cette fonction serait appelée par le service des budgets
      // lors du dépassement d'un budget

    } catch (e) {
      print('Erreur lors du déclenchement des règles de budget dépassé: $e');
    }
  }

  /// Déclencher les règles lorsqu'un objectif est atteint
  Future<void> triggerGoalReachedRules(String entityId, String goalId) async {
    try {
      print('Déclenchement des règles "objectif atteint" pour objectif: $goalId');

      // Cette fonction serait appelée par le service des objectifs
      // lors de l\'atteinte d'un objectif

    } catch (e) {
      print('Erreur lors du déclenchement des règles d\'objectif atteint: $e');
    }
  }

  /// Déclencher les règles de seuil de solde
  Future<void> triggerBalanceThresholdRules(String entityId, String accountId, double newBalance) async {
    try {
      print('Déclenchement des règles de seuil pour compte $accountId: ${newBalance.toStringAsFixed(0)} FCFA');

      // Cette fonction serait appelée par le service des comptes
      // lors du changement de solde d'un compte

    } catch (e) {
      print('Erreur lors du déclenchement des règles de seuil: $e');
    }
  }

  // ================================
  // Méthodes utilitaires
  // ================================

  /// Vérifier si le moteur est en cours d'exécution
  bool get isRunning => _isRunning;

  /// Obtenir les statistiques du moteur
  Map<String, dynamic> getEngineStats() {
    return {
      'isRunning': _isRunning,
      'timerActive': _scheduledTimer?.isActive ?? false,
      'checkInterval': _checkInterval.inMinutes,
      'nextCheck': _scheduledTimer != null
          ? DateTime.now().add(Duration(
              milliseconds: _checkInterval.inMilliseconds -
              (DateTime.now().millisecondsSinceEpoch % _checkInterval.inMilliseconds)
            ))
          : null,
    };
  }

  /// Redémarrer le moteur
  void restart() {
    print('Redémarrage du moteur d\'exécution automatique...');
    _stopScheduledExecution();
    _startScheduledExecution();
  }

  /// Arrêter temporairement le moteur
  void pause() {
    print('Mise en pause du moteur d\'exécution automatique...');
    _stopScheduledExecution();
  }

  /// Reprendre le moteur
  void resume() {
    print('Reprise du moteur d\'exécution automatique...');
    _startScheduledExecution();
  }

  // ================================
  // Méthodes de test et débogage
  // ================================

  /// Simuler l'exécution d'une règle spécifique
  Future<void> testRule(String ruleId) async {
    try {
      print('Test de la règle: $ruleId');

      final rule = await _automationService.getRuleById(ruleId);
      if (rule == null) {
        print('Règle introuvable: $ruleId');
        return;
      }

      print('Règle trouvée: ${rule.name}');
      print('Type de déclencheur: ${rule.triggerType}');
      print('Active: ${rule.isActive}');

      if (rule.hasScheduledTrigger) {
        print('Déclencheur programmé: ${rule.scheduledTrigger!.displayDescription}');
      }

      if (rule.hasEventTrigger) {
        print('Déclencheur d\'événement: ${rule.eventTrigger!.displayDescription}');
      }

      if (rule.hasCategoryTrigger) {
        print('Déclencheur de catégorie: ${rule.categoryTrigger!.displayDescription}');
      }

      print('Action: ${rule.action.displayDescription}');

    } catch (e) {
      print('Erreur lors du test de la règle: $e');
    }
  }

  /// Obtenir un rapport complet du moteur
  Future<Map<String, dynamic>> getEngineReport() async {
    try {
      // Cette méthode pourrait retourner un rapport détaillé
      // incluant les statistiques, les prochaines exécutions, etc.

      return {
        'engineStats': getEngineStats(),
        'lastUpdate': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'lastUpdate': DateTime.now().toIso8601String(),
      };
    }
  }
}