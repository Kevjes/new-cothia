import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/automation_service.dart';
import '../../../data/services/storage_service.dart';

class AutomationController extends GetxController {
  final AutomationService _automationService = AutomationService();

  // Observables
  final _isExecuting = false.obs;
  final _lastExecutionResults = <Map<String, dynamic>>[].obs;
  final _nextExecutions = <Map<String, dynamic>>[].obs;
  final _hasError = false.obs;
  final _errorMessage = ''.obs;

  // Getters
  bool get isExecuting => _isExecuting.value;
  List<Map<String, dynamic>> get lastExecutionResults => _lastExecutionResults;
  List<Map<String, dynamic>> get nextExecutions => _nextExecutions;
  bool get hasError => _hasError.value;
  String get errorMessage => _errorMessage.value;

  String? _currentEntityId;

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      final storageService = await StorageService.getInstance();
      _currentEntityId = storageService.getPersonalEntityId();

      if (_currentEntityId == null || _currentEntityId!.isEmpty) {
        throw Exception('Entity ID not found');
      }

      await loadNextExecutions();
    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = e.toString();
    }
  }

  /// Charge les prochaines exécutions d'automatisations
  Future<void> loadNextExecutions() async {
    if (_currentEntityId == null) return;

    try {
      _hasError.value = false;
      final executions = await _automationService.getNextExecutionDates(_currentEntityId!);
      _nextExecutions.assignAll(executions);
    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = 'Erreur lors du chargement des prochaines exécutions: $e';
    }
  }

  /// Exécute toutes les automatisations manuellement
  Future<void> executeAllAutomations({bool showProgress = true}) async {
    if (_currentEntityId == null) {
      Get.snackbar(
        'Erreur',
        'Entity ID non initialisé',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      _isExecuting.value = true;
      _hasError.value = false;

      if (showProgress) {
        Get.snackbar(
          'Exécution',
          'Exécution des automatisations en cours...',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }

      final results = await _automationService.executeAutomaticTransfers(_currentEntityId!);
      _lastExecutionResults.assignAll(results);

      // Recharger les prochaines exécutions
      await loadNextExecutions();

      // Afficher les résultats
      final successCount = results.where((r) => r['success'] == true).length;
      final totalCount = results.length;

      if (showProgress) {
        if (successCount == totalCount && totalCount > 0) {
          Get.snackbar(
            'Succès',
            '$successCount automatisation(s) exécutée(s) avec succès',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else if (successCount > 0) {
          Get.snackbar(
            'Partiellement réussi',
            '$successCount/$totalCount automatisations réussies',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        } else if (totalCount == 0) {
          Get.snackbar(
            'Information',
            'Aucune automatisation à exécuter aujourd\'hui',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.blue,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Erreurs',
            'Échec de toutes les automatisations',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }

    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = e.toString();

      if (showProgress) {
        Get.snackbar(
          'Erreur',
          'Erreur lors de l\'exécution des automatisations: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      _isExecuting.value = false;
    }
  }

  /// Simule l'exécution d'une automatisation spécifique (prévisualisation)
  Future<void> previewAutomation(String budgetId, String budgetName) async {
    try {
      // On devrait récupérer le budget, mais pour simplifier, on affiche juste un message
      Get.dialog(
        AlertDialog(
          title: const Text('Aperçu de l\'automatisation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Budget: $budgetName'),
              const SizedBox(height: 8),
              const Text('Cette fonctionnalité permettra de prévisualiser l\'exécution de l\'automatisation avant de la lancer.'),
              const SizedBox(height: 8),
              const Text('Détails:'),
              const Text('• Montant à transférer'),
              const Text('• Comptes source et destination'),
              const Text('• Impacts sur les soldes'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Fermer'),
            ),
          ],
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de la prévisualisation: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Affiche les détails des dernières exécutions
  void showExecutionResults() {
    if (_lastExecutionResults.isEmpty) {
      Get.snackbar(
        'Information',
        'Aucune exécution récente',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Résultats des automatisations'),
        content: Container(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: _lastExecutionResults.length,
            itemBuilder: (context, index) {
              final result = _lastExecutionResults[index];
              final isSuccess = result['success'] == true;

              return ListTile(
                leading: Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  color: isSuccess ? Colors.green : Colors.red,
                ),
                title: Text(result['budgetName'] ?? 'Budget inconnu'),
                subtitle: Text(result['message'] ?? 'Aucun message'),
                trailing: isSuccess
                    ? const Icon(Icons.arrow_forward, color: Colors.blue)
                    : null,
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Fermer'),
          ),
          if (_lastExecutionResults.any((r) => r['success'] == true))
            ElevatedButton(
              onPressed: () {
                Get.back();
                // Naviguer vers les transactions récentes
                Get.toNamed('/finance/transactions');
              },
              child: const Text('Voir les transactions'),
            ),
        ],
      ),
    );
  }

  /// Programme l'exécution automatique quotidienne (pour le futur)
  Future<void> scheduleAutomaticExecution() async {
    // Cette méthode sera implémentée quand nous aurons un système de tâches en arrière-plan
    Get.snackbar(
      'Information',
      'La programmation automatique sera disponible dans une prochaine version',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  /// Rafraîchit toutes les données
  Future<void> refreshData() async {
    await loadNextExecutions();
  }

  /// Nettoie les résultats d'exécution
  void clearExecutionResults() {
    _lastExecutionResults.clear();
  }

  // Statistiques rapides
  int get totalPendingAutomations => _nextExecutions.length;

  double get totalPendingAmount {
    return _nextExecutions.fold(0.0, (sum, execution) {
      return sum + ((execution['amount'] as num?)?.toDouble() ?? 0.0);
    });
  }

  int get automationsToday {
    final today = DateTime.now();
    return _nextExecutions.where((execution) {
      final nextExecution = execution['nextExecution'] as DateTime?;
      if (nextExecution == null) return false;
      return nextExecution.year == today.year &&
             nextExecution.month == today.month &&
             nextExecution.day == today.day;
    }).length;
  }
}