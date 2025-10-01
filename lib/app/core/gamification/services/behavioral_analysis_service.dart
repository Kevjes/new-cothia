import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../features/finance/controllers/finance_controller.dart';
import '../../../features/tasks/controllers/tasks_controller.dart';
import '../../../features/habits/controllers/habits_controller.dart';
import 'gamification_service.dart';

enum BehaviorPattern {
  consistent,
  inconsistent,
  improving,
  declining,
  procrastinator,
  overachiever,
  perfectionist,
  rusher
}

class BehavioralInsight {
  final String id;
  final String title;
  final String description;
  final BehaviorPattern pattern;
  final double confidence;
  final List<String> recommendations;
  final Map<String, dynamic> data;
  final DateTime detectedAt;

  BehavioralInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.pattern,
    required this.confidence,
    required this.recommendations,
    required this.data,
    required this.detectedAt,
  });
}

class BehavioralAnalysisService extends GetxService {
  final GamificationService _gamificationService = Get.find<GamificationService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Analyse le comportement utilisateur et génère des insights
  Future<List<BehavioralInsight>> analyzeBehavior() async {
    final insights = <BehavioralInsight>[];

    try {
      // Analyser les patterns de chaque module
      insights.addAll(await _analyzeFinanceBehavior());
      insights.addAll(await _analyzeTaskBehavior());
      insights.addAll(await _analyzeHabitBehavior());
      insights.addAll(await _analyzeGamificationBehavior());
      insights.addAll(await _analyzeCrossModuleBehavior());

      // Sauvegarder les insights pour historique
      await _saveInsights(insights);

    } catch (e) {
      print('Erreur lors de l\'analyse comportementale: $e');
    }

    return insights;
  }

  /// Analyse les patterns financiers
  Future<List<BehavioralInsight>> _analyzeFinanceBehavior() async {
    final insights = <BehavioralInsight>[];

    try {
      final financeController = Get.find<FinanceController>();

      // Analyser les patterns de dépenses
      final spendingInsight = await _analyzeSpendingPatterns();
      if (spendingInsight != null) insights.add(spendingInsight);

      // Analyser la consistance budgétaire
      final budgetInsight = await _analyzeBudgetConsistency();
      if (budgetInsight != null) insights.add(budgetInsight);

      // Analyser les objectifs financiers
      final goalInsight = await _analyzeFinancialGoals();
      if (goalInsight != null) insights.add(goalInsight);

    } catch (e) {
      print('Erreur analyse finance: $e');
    }

    return insights;
  }

  /// Analyse les patterns de tâches
  Future<List<BehavioralInsight>> _analyzeTaskBehavior() async {
    final insights = <BehavioralInsight>[];

    try {
      final tasksController = Get.find<TasksController>();

      // Analyser la procrastination
      final procrastinationInsight = await _analyzeProcrastination();
      if (procrastinationInsight != null) insights.add(procrastinationInsight);

      // Analyser l'efficacité
      final efficiencyInsight = await _analyzeTaskEfficiency();
      if (efficiencyInsight != null) insights.add(efficiencyInsight);

      // Analyser les patterns de completion
      final completionInsight = await _analyzeCompletionPatterns();
      if (completionInsight != null) insights.add(completionInsight);

    } catch (e) {
      print('Erreur analyse tâches: $e');
    }

    return insights;
  }

  /// Analyse les patterns d'habitudes
  Future<List<BehavioralInsight>> _analyzeHabitBehavior() async {
    final insights = <BehavioralInsight>[];

    try {
      final habitsController = Get.find<HabitsController>();

      // Analyser la consistance des habitudes
      final consistencyInsight = await _analyzeHabitConsistency();
      if (consistencyInsight != null) insights.add(consistencyInsight);

      // Analyser les patterns de streak
      final streakInsight = await _analyzeStreakPatterns();
      if (streakInsight != null) insights.add(streakInsight);

      // Analyser l'abandon d'habitudes
      final abandonInsight = await _analyzeHabitAbandonment();
      if (abandonInsight != null) insights.add(abandonInsight);

    } catch (e) {
      print('Erreur analyse habitudes: $e');
    }

    return insights;
  }

  /// Analyse les patterns de gamification
  Future<List<BehavioralInsight>> _analyzeGamificationBehavior() async {
    final insights = <BehavioralInsight>[];

    try {
      final profile = await _gamificationService.getUserProfile();
      if (profile == null) return insights;

      // Analyser l'engagement
      final engagementInsight = await _analyzeEngagement(profile);
      if (engagementInsight != null) insights.add(engagementInsight);

      // Analyser la progression
      final progressInsight = await _analyzeProgress(profile);
      if (progressInsight != null) insights.add(progressInsight);

    } catch (e) {
      print('Erreur analyse gamification: $e');
    }

    return insights;
  }

  /// Analyse les correlations inter-modules
  Future<List<BehavioralInsight>> _analyzeCrossModuleBehavior() async {
    final insights = <BehavioralInsight>[];

    try {
      // Analyser la corrélation habitudes-finances
      final habitFinanceInsight = await _analyzeHabitFinanceCorrelation();
      if (habitFinanceInsight != null) insights.add(habitFinanceInsight);

      // Analyser la corrélation tâches-productivité
      final taskProductivityInsight = await _analyzeTaskProductivityCorrelation();
      if (taskProductivityInsight != null) insights.add(taskProductivityInsight);

      // Analyser l'utilisation globale
      final usageInsight = await _analyzeGlobalUsage();
      if (usageInsight != null) insights.add(usageInsight);

    } catch (e) {
      print('Erreur analyse cross-module: $e');
    }

    return insights;
  }

  /// Analyse les patterns de dépenses
  Future<BehavioralInsight?> _analyzeSpendingPatterns() async {
    // Simuler l'analyse (à implémenter avec vraies données)
    final now = DateTime.now();
    final lastWeek = now.subtract(const Duration(days: 7));

    // Exemple de logique d'analyse
    final weeklySpending = 1500.0; // À récupérer des vraies données
    final previousWeekSpending = 1200.0;

    final increase = (weeklySpending - previousWeekSpending) / previousWeekSpending;

    if (increase > 0.2) {
      return BehavioralInsight(
        id: 'spending_increase_${now.millisecondsSinceEpoch}',
        title: 'Augmentation des dépenses détectée',
        description: 'Vos dépenses ont augmenté de ${(increase * 100).toInt()}% cette semaine',
        pattern: BehaviorPattern.declining,
        confidence: 0.85,
        recommendations: [
          'Révisez vos budgets pour identifier les postes de dépenses élevés',
          'Activez des alertes budget pour mieux contrôler vos dépenses',
          'Analysez les catégories qui ont le plus augmenté',
        ],
        data: {
          'current_spending': weeklySpending,
          'previous_spending': previousWeekSpending,
          'increase_percentage': increase * 100,
        },
        detectedAt: now,
      );
    }

    return null;
  }

  /// Analyse la consistance budgétaire
  Future<BehavioralInsight?> _analyzeBudgetConsistency() async {
    // Simuler l'analyse
    final budgetRespectRate = 0.75; // 75% de respect des budgets

    if (budgetRespectRate < 0.6) {
      return BehavioralInsight(
        id: 'budget_consistency_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Difficultés avec les budgets',
        description: 'Vous respectez seulement ${(budgetRespectRate * 100).toInt()}% de vos budgets',
        pattern: BehaviorPattern.inconsistent,
        confidence: 0.9,
        recommendations: [
          'Réajustez vos budgets pour qu\'ils soient plus réalistes',
          'Utilisez des automatisations pour respecter vos limites',
          'Divisez vos gros budgets en sous-catégories plus précises',
        ],
        data: {
          'respect_rate': budgetRespectRate,
          'failed_budgets': 3,
          'total_budgets': 5,
        },
        detectedAt: DateTime.now(),
      );
    }

    return null;
  }

  /// Analyse les objectifs financiers
  Future<BehavioralInsight?> _analyzeFinancialGoals() async {
    // Logique d'analyse des objectifs
    return null;
  }

  /// Analyse la procrastination
  Future<BehavioralInsight?> _analyzeProcrastination() async {
    // Simuler détection de procrastination
    final averageDelayDays = 3.5;

    if (averageDelayDays > 2) {
      return BehavioralInsight(
        id: 'procrastination_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Pattern de procrastination détecté',
        description: 'Vos tâches sont en moyenne reportées de $averageDelayDays jours',
        pattern: BehaviorPattern.procrastinator,
        confidence: 0.8,
        recommendations: [
          'Divisez vos grandes tâches en sous-tâches plus petites',
          'Utilisez la technique Pomodoro pour vous concentrer',
          'Planifiez vos tâches les plus importantes le matin',
          'Activez des rappels pour vos échéances importantes',
        ],
        data: {
          'average_delay': averageDelayDays,
          'overdue_tasks': 5,
          'completed_late': 8,
        },
        detectedAt: DateTime.now(),
      );
    }

    return null;
  }

  /// Analyse l'efficacité des tâches
  Future<BehavioralInsight?> _analyzeTaskEfficiency() async {
    // Logique d'analyse de l'efficacité
    return null;
  }

  /// Analyse les patterns de completion
  Future<BehavioralInsight?> _analyzeCompletionPatterns() async {
    // Logique d'analyse des patterns de completion
    return null;
  }

  /// Analyse la consistance des habitudes
  Future<BehavioralInsight?> _analyzeHabitConsistency() async {
    // Simuler analyse de consistance
    final consistencyRate = 0.65; // 65% de consistance

    if (consistencyRate < 0.7) {
      return BehavioralInsight(
        id: 'habit_consistency_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Consistance des habitudes à améliorer',
        description: 'Votre taux de consistance est de ${(consistencyRate * 100).toInt()}%',
        pattern: BehaviorPattern.inconsistent,
        confidence: 0.75,
        recommendations: [
          'Commencez par 1-2 habitudes seulement',
          'Choisissez des moments fixes dans votre journée',
          'Utilisez des déclencheurs pour ancrer vos habitudes',
          'Récompensez-vous après chaque habitude accomplie',
        ],
        data: {
          'consistency_rate': consistencyRate,
          'successful_days': 13,
          'total_days': 20,
        },
        detectedAt: DateTime.now(),
      );
    }

    return null;
  }

  /// Analyse les patterns de streak
  Future<BehavioralInsight?> _analyzeStreakPatterns() async {
    // Logique d'analyse des streaks
    return null;
  }

  /// Analyse l'abandon d'habitudes
  Future<BehavioralInsight?> _analyzeHabitAbandonment() async {
    // Logique d'analyse de l'abandon
    return null;
  }

  /// Analyse l'engagement gamification
  Future<BehavioralInsight?> _analyzeEngagement(dynamic profile) async {
    // Logique d'analyse de l'engagement
    return null;
  }

  /// Analyse la progression
  Future<BehavioralInsight?> _analyzeProgress(dynamic profile) async {
    // Logique d'analyse de la progression
    return null;
  }

  /// Analyse corrélation habitudes-finances
  Future<BehavioralInsight?> _analyzeHabitFinanceCorrelation() async {
    // Logique d'analyse de corrélation
    return null;
  }

  /// Analyse corrélation tâches-productivité
  Future<BehavioralInsight?> _analyzeTaskProductivityCorrelation() async {
    // Logique d'analyse de corrélation
    return null;
  }

  /// Analyse l'utilisation globale
  Future<BehavioralInsight?> _analyzeGlobalUsage() async {
    // Simuler analyse d'utilisation
    final modulesUsedToday = 2; // Sur 4 modules disponibles

    if (modulesUsedToday >= 3) {
      return BehavioralInsight(
        id: 'global_usage_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Utilisation excellente de l\'application',
        description: 'Vous utilisez activement $modulesUsedToday/4 modules aujourd\'hui',
        pattern: BehaviorPattern.consistent,
        confidence: 0.9,
        recommendations: [
          'Continuez cette excellente utilisation équilibrée',
          'Explorez les fonctionnalités avancées des modules que vous utilisez',
          'Essayez les nouvelles fonctionnalités débloquées',
        ],
        data: {
          'modules_used_today': modulesUsedToday,
          'total_modules': 4,
          'usage_rate': modulesUsedToday / 4,
        },
        detectedAt: DateTime.now(),
      );
    }

    return null;
  }

  /// Sauvegarde les insights pour l'historique
  Future<void> _saveInsights(List<BehavioralInsight> insights) async {
    try {
      final userId = _gamificationService.currentUserId;
      if (userId == null) return;

      final batch = _firestore.batch();

      for (final insight in insights) {
        final docRef = _firestore
            .collection('behavioral_insights')
            .doc(userId)
            .collection('insights')
            .doc(insight.id);

        batch.set(docRef, {
          'title': insight.title,
          'description': insight.description,
          'pattern': insight.pattern.toString(),
          'confidence': insight.confidence,
          'recommendations': insight.recommendations,
          'data': insight.data,
          'detectedAt': insight.detectedAt,
        });
      }

      await batch.commit();
    } catch (e) {
      print('Erreur sauvegarde insights: $e');
    }
  }

  /// Récupère l'historique des insights
  Future<List<BehavioralInsight>> getInsightHistory({int limit = 20}) async {
    try {
      final userId = _gamificationService.currentUserId;
      if (userId == null) return [];

      final snapshot = await _firestore
          .collection('behavioral_insights')
          .doc(userId)
          .collection('insights')
          .orderBy('detectedAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return BehavioralInsight(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          pattern: BehaviorPattern.values.firstWhere(
            (p) => p.toString() == data['pattern'],
            orElse: () => BehaviorPattern.consistent,
          ),
          confidence: (data['confidence'] ?? 0.0).toDouble(),
          recommendations: List<String>.from(data['recommendations'] ?? []),
          data: Map<String, dynamic>.from(data['data'] ?? {}),
          detectedAt: (data['detectedAt'] as Timestamp).toDate(),
        );
      }).toList();
    } catch (e) {
      print('Erreur récupération historique: $e');
      return [];
    }
  }
}