import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/suggestions_service.dart';
import '../../../core/models/suggestion_model.dart';

/// Contrôleur pour la gestion des suggestions intelligentes
class SuggestionsController extends GetxController {
  final SuggestionsService _suggestionsService = Get.find<SuggestionsService>();

  // Observables
  final _isLoading = false.obs;
  final _hasError = false.obs;
  final _errorMessage = ''.obs;
  final _selectedFilters = <SuggestionType>{}.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;
  String get errorMessage => _errorMessage.value;
  bool get isAnalyzing => _suggestionsService.isAnalyzing;
  Set<SuggestionType> get selectedFilters => _selectedFilters;

  List<SuggestionModel> get suggestions => _suggestionsService.suggestions;

  List<SuggestionModel> get filteredSuggestions {
    if (_selectedFilters.isEmpty) {
      return suggestions;
    }
    return suggestions.where((suggestion) => _selectedFilters.contains(suggestion.type)).toList();
  }

  List<SuggestionModel> get prioritySuggestions {
    return filteredSuggestions
        .where((s) => s.priority == SuggestionPriority.high || s.priority == SuggestionPriority.critical)
        .take(3)
        .toList();
  }

  List<SuggestionModel> get financialSuggestions {
    return filteredSuggestions.where((s) => s.type == SuggestionType.financial).toList();
  }

  List<SuggestionModel> get productivitySuggestions {
    return filteredSuggestions.where((s) => s.type == SuggestionType.productivity).toList();
  }

  List<SuggestionModel> get habitSuggestions {
    return filteredSuggestions.where((s) => s.type == SuggestionType.habit).toList();
  }

  List<SuggestionModel> get crossModuleSuggestions {
    return filteredSuggestions.where((s) => s.type == SuggestionType.crossModule).toList();
  }

  SuggestionStats get stats => _calculateStats();

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      _isLoading.value = true;
      _hasError.value = false;

      // Les suggestions sont déjà gérées par le service
      // Pas besoin d'initialisation supplémentaire

    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  /// Rafraîchit les suggestions
  Future<void> refreshSuggestions() async {
    try {
      _isLoading.value = true;
      _hasError.value = false;

      await _suggestionsService.generateSuggestions();

      Get.snackbar(
        'Suggestions',
        'Suggestions mises à jour avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = e.toString();

      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour les suggestions',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Applique une suggestion
  Future<void> applySuggestion(SuggestionModel suggestion) async {
    try {
      await _suggestionsService.applySuggestion(suggestion);

      Get.snackbar(
        'Suggestion appliquée',
        suggestion.title,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'appliquer la suggestion: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  /// Rejette une suggestion
  void dismissSuggestion(SuggestionModel suggestion) {
    _suggestionsService.markSuggestionAsRead(suggestion.id);

    Get.snackbar(
      'Suggestion ignorée',
      suggestion.title,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.grey.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
  }

  /// Affiche les détails d'une suggestion
  void showSuggestionDetails(SuggestionModel suggestion) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Text(suggestion.type.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                suggestion.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Priority badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getPriorityColor(suggestion.priority),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                suggestion.priority.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              suggestion.description,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),

            // Metadata if available
            if (suggestion.metadata.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Détails:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...suggestion.metadata.entries.take(3).map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• ${_formatMetadataKey(entry.key)}: ${_formatMetadataValue(entry.value)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              dismissSuggestion(suggestion);
            },
            child: const Text('Ignorer'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              applySuggestion(suggestion);
            },
            child: Text(suggestion.action.label),
          ),
        ],
      ),
    );
  }

  /// Toggle un filtre de type
  void toggleFilter(SuggestionType type) {
    if (_selectedFilters.contains(type)) {
      _selectedFilters.remove(type);
    } else {
      _selectedFilters.add(type);
    }
  }

  /// Efface tous les filtres
  void clearFilters() {
    _selectedFilters.clear();
  }

  /// Calcule les statistiques des suggestions
  SuggestionStats _calculateStats() {
    final allSuggestions = suggestions;
    final typeMap = <SuggestionType, int>{};
    final priorityMap = <SuggestionPriority, int>{};

    for (final suggestion in allSuggestions) {
      typeMap[suggestion.type] = (typeMap[suggestion.type] ?? 0) + 1;
      priorityMap[suggestion.priority] = (priorityMap[suggestion.priority] ?? 0) + 1;
    }

    return SuggestionStats(
      totalSuggestions: allSuggestions.length,
      appliedSuggestions: 0, // À implémenter avec un système de tracking
      ignoredSuggestions: 0, // À implémenter avec un système de tracking
      suggestionsByType: typeMap,
      suggestionsByPriority: priorityMap,
    );
  }

  /// Obtient la couleur pour une priorité
  Color _getPriorityColor(SuggestionPriority priority) {
    switch (priority) {
      case SuggestionPriority.low:
        return Colors.green;
      case SuggestionPriority.medium:
        return Colors.orange;
      case SuggestionPriority.high:
        return Colors.red;
      case SuggestionPriority.critical:
        return Colors.deepPurple;
    }
  }

  /// Formate les clés de métadonnées pour l'affichage
  String _formatMetadataKey(String key) {
    switch (key) {
      case 'increase_percentage':
        return 'Augmentation';
      case 'current_month_total':
        return 'Total ce mois';
      case 'last_month_total':
        return 'Total mois dernier';
      case 'category':
        return 'Catégorie';
      case 'amount':
        return 'Montant';
      case 'percentage':
        return 'Pourcentage';
      case 'account_name':
        return 'Compte';
      case 'balance':
        return 'Solde';
      case 'budget_name':
        return 'Budget';
      case 'overspent_amount':
        return 'Dépassement';
      case 'objective_name':
        return 'Objectif';
      case 'suggested_increase':
        return 'Augmentation suggérée';
      case 'current_allocation':
        return 'Allocation actuelle';
      case 'overdue_count':
        return 'Tâches en retard';
      case 'week_tasks_count':
        return 'Tâches cette semaine';
      case 'uncategorized_count':
        return 'Non catégorisées';
      case 'habit_name':
        return 'Habitude';
      case 'success_rate':
        return 'Taux de réussite';
      case 'monthly_impact':
        return 'Impact mensuel';
      case 'bad_habits_count':
        return 'Mauvaises habitudes';
      case 'active_habits_count':
        return 'Habitudes actives';
      default:
        return key.replaceAll('_', ' ').toUpperCase();
    }
  }

  /// Formate les valeurs de métadonnées pour l'affichage
  String _formatMetadataValue(dynamic value) {
    if (value is double) {
      if (value > 1000) {
        return '${value.toStringAsFixed(0)} FCFA';
      } else if (value < 1) {
        return '${(value * 100).toStringAsFixed(1)}%';
      } else {
        return value.toStringAsFixed(1);
      }
    } else if (value is int) {
      return value.toString();
    } else {
      return value.toString();
    }
  }

  /// Réessaye l'initialisation en cas d'erreur
  void retryInitialization() {
    _initializeController();
  }
}