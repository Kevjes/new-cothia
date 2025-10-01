import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/challenge_model.dart';

class ChallengeGeneratorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Génère les challenges par défaut du système
  Future<void> generateDefaultChallenges() async {
    final challenges = _getDefaultChallenges();

    for (final challenge in challenges) {
      try {
        await _firestore
            .collection('challenges')
            .doc(challenge.id)
            .set(challenge.toMap());
      } catch (e) {
        print('Erreur lors de la création du challenge ${challenge.id}: $e');
      }
    }
  }

  /// Génère des challenges hebdomadaires automatiques
  Future<void> generateWeeklyChallenges() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59));

    final weeklyChallenges = [
      Challenge(
        id: 'weekly_transaction_${_getWeekId(now)}',
        name: 'Maître des transactions',
        description: 'Créez 10 transactions cette semaine',
        iconPath: 'assets/icons/transaction.png',
        type: ChallengeType.weekly,
        criteria: {'action': 'transaction_created', 'count': 10},
        pointsReward: 150,
        startDate: startOfWeek,
        endDate: endOfWeek,
        maxProgress: 10,
      ),
      Challenge(
        id: 'weekly_habits_${_getWeekId(now)}',
        name: 'Consistency Champion',
        description: 'Complétez vos habitudes 5 jours cette semaine',
        iconPath: 'assets/icons/habits.png',
        type: ChallengeType.weekly,
        criteria: {'action': 'habit_completed', 'days': 5},
        pointsReward: 200,
        startDate: startOfWeek,
        endDate: endOfWeek,
        maxProgress: 5,
      ),
      Challenge(
        id: 'weekly_tasks_${_getWeekId(now)}',
        name: 'Productivité maximale',
        description: 'Terminez 15 tâches cette semaine',
        iconPath: 'assets/icons/tasks.png',
        type: ChallengeType.weekly,
        criteria: {'action': 'task_completed', 'count': 15},
        pointsReward: 175,
        startDate: startOfWeek,
        endDate: endOfWeek,
        maxProgress: 15,
      ),
    ];

    for (final challenge in weeklyChallenges) {
      try {
        await _firestore
            .collection('challenges')
            .doc(challenge.id)
            .set(challenge.toMap());
      } catch (e) {
        print('Erreur lors de la création du challenge hebdomadaire ${challenge.id}: $e');
      }
    }
  }

  /// Génère des challenges mensuels automatiques
  Future<void> generateMonthlyChallenges() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final monthlyChallenges = [
      Challenge(
        id: 'monthly_budget_${_getMonthId(now)}',
        name: 'Budget Master',
        description: 'Respectez tous vos budgets ce mois-ci',
        iconPath: 'assets/icons/budget.png',
        type: ChallengeType.monthly,
        criteria: {'action': 'budget_respected', 'all': true},
        pointsReward: 500,
        startDate: startOfMonth,
        endDate: endOfMonth,
        maxProgress: 1,
        isPremium: true,
      ),
      Challenge(
        id: 'monthly_streak_${_getMonthId(now)}',
        name: 'Streak Legend',
        description: 'Maintenez un streak de 30 jours',
        iconPath: 'assets/icons/fire.png',
        type: ChallengeType.monthly,
        criteria: {'action': 'streak_maintained', 'days': 30},
        pointsReward: 750,
        startDate: startOfMonth,
        endDate: endOfMonth,
        maxProgress: 30,
        isPremium: true,
      ),
      Challenge(
        id: 'monthly_complete_${_getMonthId(now)}',
        name: 'Perfectionniste',
        description: 'Utilisez tous les modules au moins 20 fois ce mois',
        iconPath: 'assets/icons/complete.png',
        type: ChallengeType.monthly,
        criteria: {'action': 'module_usage', 'all_modules': true, 'min_count': 20},
        pointsReward: 1000,
        startDate: startOfMonth,
        endDate: endOfMonth,
        maxProgress: 4, // 4 modules
        isPremium: true,
      ),
    ];

    for (final challenge in monthlyChallenges) {
      try {
        await _firestore
            .collection('challenges')
            .doc(challenge.id)
            .set(challenge.toMap());
      } catch (e) {
        print('Erreur lors de la création du challenge mensuel ${challenge.id}: $e');
      }
    }
  }

  /// Génère des challenges quotidiens dynamiques
  Future<void> generateDailyChallenges() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final dailyChallenges = [
      Challenge(
        id: 'daily_login_${_getDayId(now)}',
        name: 'Présence quotidienne',
        description: 'Connectez-vous et utilisez l\'app aujourd\'hui',
        iconPath: 'assets/icons/login.png',
        type: ChallengeType.daily,
        criteria: {'action': 'daily_login'},
        pointsReward: 25,
        startDate: startOfDay,
        endDate: endOfDay,
        maxProgress: 1,
      ),
      Challenge(
        id: 'daily_habits_${_getDayId(now)}',
        name: 'Routine parfaite',
        description: 'Complétez toutes vos habitudes aujourd\'hui',
        iconPath: 'assets/icons/routine.png',
        type: ChallengeType.daily,
        criteria: {'action': 'all_habits_completed'},
        pointsReward: 50,
        startDate: startOfDay,
        endDate: endOfDay,
        maxProgress: 1,
      ),
      Challenge(
        id: 'daily_tasks_${_getDayId(now)}',
        name: 'Productif aujourd\'hui',
        description: 'Terminez 5 tâches aujourd\'hui',
        iconPath: 'assets/icons/productive.png',
        type: ChallengeType.daily,
        criteria: {'action': 'task_completed', 'count': 5},
        pointsReward: 40,
        startDate: startOfDay,
        endDate: endOfDay,
        maxProgress: 5,
      ),
    ];

    for (final challenge in dailyChallenges) {
      try {
        await _firestore
            .collection('challenges')
            .doc(challenge.id)
            .set(challenge.toMap());
      } catch (e) {
        print('Erreur lors de la création du challenge quotidien ${challenge.id}: $e');
      }
    }
  }

  /// Retourne les challenges par défaut du système
  List<Challenge> _getDefaultChallenges() {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));

    return [
      Challenge(
        id: 'welcome_challenge',
        name: 'Bienvenue dans Cothia!',
        description: 'Explorez tous les modules de l\'application',
        iconPath: 'assets/icons/welcome.png',
        type: ChallengeType.milestone,
        criteria: {'modules_visited': 4},
        pointsReward: 100,
        startDate: now,
        endDate: now.add(const Duration(days: 30)),
        maxProgress: 4,
      ),
      Challenge(
        id: 'first_week_challenge',
        name: 'Première semaine',
        description: 'Utilisez l\'app 7 jours consécutifs',
        iconPath: 'assets/icons/calendar.png',
        type: ChallengeType.streak,
        criteria: {'consecutive_days': 7},
        pointsReward: 200,
        startDate: now,
        endDate: nextWeek,
        maxProgress: 7,
      ),
      Challenge(
        id: 'finance_explorer',
        name: 'Explorateur financier',
        description: 'Créez votre premier compte, budget et transaction',
        iconPath: 'assets/icons/finance.png',
        type: ChallengeType.milestone,
        criteria: {'finance_items_created': 3},
        pointsReward: 150,
        startDate: now,
        endDate: now.add(const Duration(days: 14)),
        maxProgress: 3,
      ),
      Challenge(
        id: 'habit_builder',
        name: 'Constructeur d\'habitudes',
        description: 'Créez 3 habitudes et maintenez-les 3 jours',
        iconPath: 'assets/icons/habits_builder.png',
        type: ChallengeType.milestone,
        criteria: {'habits_maintained': 3},
        pointsReward: 175,
        startDate: now,
        endDate: now.add(const Duration(days: 21)),
        maxProgress: 3,
      ),
      Challenge(
        id: 'task_master',
        name: 'Maître des tâches',
        description: 'Créez un projet et terminez 10 tâches',
        iconPath: 'assets/icons/task_master.png',
        type: ChallengeType.milestone,
        criteria: {'project_and_tasks': true},
        pointsReward: 125,
        startDate: now,
        endDate: now.add(const Duration(days: 14)),
        maxProgress: 11, // 1 projet + 10 tâches
      ),
    ];
  }

  String _getWeekId(DateTime date) {
    final year = date.year;
    final week = ((date.difference(DateTime(year, 1, 1)).inDays) / 7).ceil();
    return '${year}_W$week';
  }

  String _getMonthId(DateTime date) {
    return '${date.year}_${date.month.toString().padLeft(2, '0')}';
  }

  String _getDayId(DateTime date) {
    return '${date.year}_${date.month.toString().padLeft(2, '0')}_${date.day.toString().padLeft(2, '0')}';
  }
}