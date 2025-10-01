import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/advanced_automation_service.dart';
import '../../../data/services/storage_service.dart';
import '../models/automation_rule_model.dart';

/// Controller pour la gestion des règles d'automatisation
class AutomationController extends GetxController {
  final AdvancedAutomationService _automationService = AdvancedAutomationService();

  // Observables
  final _isLoading = false.obs;
  final _hasError = false.obs;
  final _errorMessage = ''.obs;
  final _rules = <AutomationRuleModel>[].obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;
  String get errorMessage => _errorMessage.value;
  List<AutomationRuleModel> get rules => _rules;
  List<AutomationRuleModel> get activeRules => _rules.where((r) => r.isActive).toList();

  String? _currentEntityId;
  String? get currentEntityId => _currentEntityId;

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

      await loadRules();
    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = e.toString();
    }
  }

  // =====================================================
  // Gestion des règles d'automatisation
  // =====================================================

  /// Charge toutes les règles d'automatisation
  Future<void> loadRules() async {
    if (_currentEntityId == null) return;

    try {
      _isLoading.value = true;
      _hasError.value = false;
      final rules = await _automationService.getRulesByEntity(_currentEntityId!);
      _rules.assignAll(rules);
    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = 'Erreur lors du chargement des règles: $e';
      Get.snackbar(
        'Erreur',
        'Erreur lors du chargement: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Crée une nouvelle règle d'automatisation
  Future<bool> createRule(AutomationRuleModel rule) async {
    try {
      _isLoading.value = true;
      final success = await _automationService.createRule(rule);
      if (success) {
        await loadRules();
        Get.snackbar(
          'Succès',
          'Règle créée avec succès',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
      return success;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de la création: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Met à jour une règle d'automatisation
  Future<bool> updateRule(AutomationRuleModel rule) async {
    try {
      _isLoading.value = true;
      final success = await _automationService.updateRule(rule);
      if (success) {
        await loadRules();
        Get.snackbar(
          'Succès',
          'Règle mise à jour',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
      return success;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de la mise à jour: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Supprime une règle d'automatisation
  Future<bool> deleteRule(String ruleId) async {
    try {
      _isLoading.value = true;
      final success = await _automationService.deleteRule(ruleId);
      if (success) {
        await loadRules();
        Get.snackbar(
          'Succès',
          'Règle supprimée avec succès',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
      return success;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de la suppression: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Active/désactive une règle
  Future<bool> toggleRuleStatus(String ruleId) async {
    try {
      final rule = _rules.firstWhere((r) => r.id == ruleId);
      final updatedRule = rule.copyWith(isActive: !rule.isActive);
      return await updateRule(updatedRule);
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors du changement de statut: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  /// Rafraîchit toutes les données
  Future<void> refreshData() async {
    await loadRules();
  }

  /// Réessaie l'initialisation en cas d'erreur
  Future<void> retryInitialization() async {
    await _initializeController();
  }

  // =====================================================
  // Statistiques sur les règles
  // =====================================================

  int get totalRules => _rules.length;
  int get activeRulesCount => activeRules.length;
  int get scheduledRulesCount => _rules.where((r) => r.triggerType == TriggerType.scheduled).length;
  int get eventBasedRulesCount => _rules.where((r) => r.triggerType == TriggerType.eventBased).length;
  int get categoryBasedRulesCount => _rules.where((r) => r.triggerType == TriggerType.categoryBased).length;
}
