import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/suggestions_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/suggestion_model.dart';

class SuggestionsPage extends GetView<SuggestionsController> {
  const SuggestionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Suggestions Intelligentes'),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        elevation: 0,
        actions: [
          Obx(() => controller.isAnalyzing
            ? Container(
                margin: const EdgeInsets.only(right: 16),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              )
            : IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: controller.refreshSuggestions,
              ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading && controller.suggestions.isEmpty) {
          return _buildLoadingState();
        }

        if (controller.hasError) {
          return _buildErrorState();
        }

        if (controller.suggestions.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: controller.refreshSuggestions,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAnalysisStatus(),
                const SizedBox(height: 20),
                _buildFilters(),
                const SizedBox(height: 20),
                _buildPrioritySuggestions(),
                const SizedBox(height: 24),
                _buildSuggestionsByCategory(),
                const SizedBox(height: 24),
                _buildStats(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Analyse de vos données en cours...'),
          SizedBox(height: 8),
          Text(
            'Génération de suggestions personnalisées',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            const Text(
              'Erreur lors du chargement',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.retryInitialization,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.lightbulb_outline,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aucune suggestion disponible',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Continuez à utiliser l\'application pour obtenir des suggestions personnalisées basées sur vos données.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.refreshSuggestions,
              icon: const Icon(Icons.analytics),
              label: const Text('Analyser mes données'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisStatus() {
    return Obx(() => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: controller.isAnalyzing
            ? AppColors.primary.withOpacity(0.3)
            : Colors.green.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: controller.isAnalyzing
                ? AppColors.primary.withOpacity(0.1)
                : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              controller.isAnalyzing ? Icons.analytics : Icons.check_circle,
              color: controller.isAnalyzing ? AppColors.primary : Colors.green,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.isAnalyzing ? 'Analyse en cours...' : 'Analyse terminée',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  controller.isAnalyzing
                    ? 'L\'IA analyse vos données pour générer des suggestions'
                    : '${controller.suggestions.length} suggestions générées',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (controller.isAnalyzing)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    ));
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Filtres',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Obx(() => controller.selectedFilters.isNotEmpty
              ? TextButton(
                  onPressed: controller.clearFilters,
                  child: const Text('Tout effacer'),
                )
              : const SizedBox.shrink(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() => Wrap(
          spacing: 8,
          children: SuggestionType.values.map((type) {
            final isSelected = controller.selectedFilters.contains(type);
            final count = controller.suggestions.where((s) => s.type == type).length;

            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(type.emoji),
                  const SizedBox(width: 4),
                  Text(type.displayName),
                  if (count > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        count.toString(),
                        style: TextStyle(
                          color: isSelected ? AppColors.primary : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              selected: isSelected,
              onSelected: count > 0 ? (_) => controller.toggleFilter(type) : null,
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
            );
          }).toList(),
        )),
      ],
    );
  }

  Widget _buildPrioritySuggestions() {
    return Obx(() {
      final prioritySuggestions = controller.prioritySuggestions;

      if (prioritySuggestions.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.priority_high, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Suggestions Prioritaires',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...prioritySuggestions.map((suggestion) =>
            _buildSuggestionCard(suggestion, isPriority: true)
          ).toList(),
        ],
      );
    });
  }

  Widget _buildSuggestionsByCategory() {
    return Obx(() {
      final categories = [
        ('Financier', controller.financialSuggestions, Icons.account_balance_wallet, AppColors.success),
        ('Productivité', controller.productivitySuggestions, Icons.bolt, AppColors.warning),
        ('Habitudes', controller.habitSuggestions, Icons.trending_up, AppColors.info),
        ('Inter-modules', controller.crossModuleSuggestions, Icons.link, AppColors.secondary),
      ];

      return Column(
        children: categories.map((category) {
          final title = category.$1;
          final suggestions = category.$2;
          final icon = category.$3;
          final color = category.$4;

          if (suggestions.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      suggestions.length.toString(),
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...suggestions.map((suggestion) => _buildSuggestionCard(suggestion)).toList(),
              const SizedBox(height: 24),
            ],
          );
        }).toList(),
      );
    });
  }

  Widget _buildSuggestionCard(SuggestionModel suggestion, {bool isPriority = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: isPriority
          ? Border.all(color: Colors.red.withOpacity(0.3), width: 2)
          : Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: isPriority
          ? [
              BoxShadow(
                color: Colors.red.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
          : null,
      ),
      child: InkWell(
        onTap: () => controller.showSuggestionDetails(suggestion),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Type emoji
                  Text(
                    suggestion.type.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),

                  // Title and priority
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          suggestion.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(suggestion.priority).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            suggestion.priority.displayName,
                            style: TextStyle(
                              color: _getPriorityColor(suggestion.priority),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Actions
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                    onSelected: (value) {
                      switch (value) {
                        case 'apply':
                          controller.applySuggestion(suggestion);
                          break;
                        case 'dismiss':
                          controller.dismissSuggestion(suggestion);
                          break;
                        case 'details':
                          controller.showSuggestionDetails(suggestion);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'apply',
                        child: Row(
                          children: [
                            const Icon(Icons.check, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(suggestion.action.label),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'details',
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Détails'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'dismiss',
                        child: Row(
                          children: [
                            Icon(Icons.close, color: Colors.grey),
                            SizedBox(width: 8),
                            Text('Ignorer'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Description
              Text(
                suggestion.description,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 16),

              // Action button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => controller.applySuggestion(suggestion),
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: Text(suggestion.action.label),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Obx(() {
      final stats = controller.stats;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistiques des Suggestions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total',
                    stats.totalSuggestions.toString(),
                    Icons.lightbulb,
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    'Appliquées',
                    stats.appliedSuggestions.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    'Taux',
                    '${(stats.applicationRate * 100).toStringAsFixed(0)}%',
                    Icons.trending_up,
                    AppColors.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

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
}