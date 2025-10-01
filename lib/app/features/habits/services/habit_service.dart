import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/habit_model.dart';
import '../models/habit_completion_model.dart';

class HabitService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'habits';
  final String _completionsCollection = 'habit_completions';

  // ================================
  // CRUD Opérations pour les habitudes
  // ================================

  /// Créer une nouvelle habitude
  Future<bool> createHabit(HabitModel habit) async {
    try {
      print('DEBUG Service: Creating habit in Firebase');
      print('DEBUG Service: Collection: $_collection');
      print('DEBUG Service: Habit entityId: ${habit.entityId}');

      final docRef = _firestore.collection(_collection).doc();
      final habitWithId = habit.copyWith(id: docRef.id);

      print('DEBUG Service: Document ID: ${docRef.id}');
      print('DEBUG Service: Final habit data: ${habitWithId.toJson()}');

      await docRef.set(habitWithId.toJson());

      print('DEBUG Service: Habit saved successfully');
      return true;
    } catch (e) {
      print('DEBUG Service: Error creating habit: $e');
      print('DEBUG Service: Error type: ${e.runtimeType}');
      return false;
    }
  }

  /// Mettre à jour une habitude
  Future<bool> updateHabit(HabitModel habit) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(habit.id)
          .update(habit.copyWith(updatedAt: DateTime.now()).toJson());
      return true;
    } catch (e) {
      print('Erreur lors de la mise à jour de l\'habitude: $e');
      return false;
    }
  }

  /// Supprimer une habitude
  Future<bool> deleteHabit(String habitId) async {
    try {
      // Supprimer aussi toutes les complétions associées
      final completions = await _firestore
          .collection(_completionsCollection)
          .where('habitId', isEqualTo: habitId)
          .get();

      final batch = _firestore.batch();

      // Supprimer l'habitude
      batch.delete(_firestore.collection(_collection).doc(habitId));

      // Supprimer toutes les complétions
      for (final doc in completions.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('Erreur lors de la suppression de l\'habitude: $e');
      return false;
    }
  }

  /// Obtenir toutes les habitudes d'une entité
  Future<List<HabitModel>> getHabitsByEntity(String entityId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('entityId', isEqualTo: entityId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => HabitModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des habitudes: $e');
      return [];
    }
  }

  /// Obtenir une habitude par ID
  Future<HabitModel?> getHabitById(String habitId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(habitId).get();
      if (doc.exists) {
        return HabitModel.fromJson({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération de l\'habitude: $e');
      return null;
    }
  }

  /// Obtenir les habitudes actives d'une entité
  Future<List<HabitModel>> getActiveHabits(String entityId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('entityId', isEqualTo: entityId)
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => HabitModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des habitudes actives: $e');
      return [];
    }
  }

  /// Obtenir les habitudes prévues pour aujourd'hui
  Future<List<HabitModel>> getTodayHabits(String entityId) async {
    try {
      final habits = await getActiveHabits(entityId);
      final today = DateTime.now().weekday;

      return habits.where((habit) {
        switch (habit.frequency) {
          case HabitFrequency.daily:
            return true;
          case HabitFrequency.specificDays:
            return habit.specificDays.contains(today);
          case HabitFrequency.weekly:
            // Pour hebdomadaire, vérifier si c'est le jour défini dans specificDays
            return habit.specificDays.isNotEmpty && habit.specificDays.contains(today);
          case HabitFrequency.monthly:
            // Pour mensuel, vérifier si c'est le jour du mois défini
            final currentDay = DateTime.now().day;
            return habit.specificDays.isNotEmpty && habit.specificDays.contains(currentDay);
        }
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des habitudes du jour: $e');
      return [];
    }
  }

  // ================================
  // CRUD Opérations pour les complétions
  // ================================

  /// Enregistrer une complétion d'habitude
  Future<bool> recordCompletion(HabitCompletionModel completion) async {
    try {
      final docRef = _firestore.collection(_completionsCollection).doc();
      final completionWithId = completion.copyWith(id: docRef.id);
      await docRef.set(completionWithId.toJson());

      // Mettre à jour les statistiques de l'habitude
      await _updateHabitStatistics(completion.habitId);
      return true;
    } catch (e) {
      print('Erreur lors de l\'enregistrement de la complétion: $e');
      return false;
    }
  }

  /// Mettre à jour une complétion
  Future<bool> updateCompletion(HabitCompletionModel completion) async {
    try {
      await _firestore
          .collection(_completionsCollection)
          .doc(completion.id)
          .update(completion.copyWith(updatedAt: DateTime.now()).toJson());

      // Mettre à jour les statistiques de l'habitude
      await _updateHabitStatistics(completion.habitId);
      return true;
    } catch (e) {
      print('Erreur lors de la mise à jour de la complétion: $e');
      return false;
    }
  }

  /// Supprimer une complétion
  Future<bool> deleteCompletion(String completionId, String habitId) async {
    try {
      await _firestore.collection(_completionsCollection).doc(completionId).delete();

      // Mettre à jour les statistiques de l'habitude
      await _updateHabitStatistics(habitId);
      return true;
    } catch (e) {
      print('Erreur lors de la suppression de la complétion: $e');
      return false;
    }
  }

  /// Obtenir les complétions d'une habitude
  Future<List<HabitCompletionModel>> getHabitCompletions(String habitId, {int? limit}) async {
    try {
      var query = _firestore
          .collection(_completionsCollection)
          .where('habitId', isEqualTo: habitId)
          .orderBy('date', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => HabitCompletionModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des complétions: $e');
      return [];
    }
  }

  /// Obtenir la complétion d'une habitude pour une date donnée
  Future<HabitCompletionModel?> getCompletionForDate(String habitId, DateTime date) async {
    try {
      final dateOnly = DateTime(date.year, date.month, date.day);
      final querySnapshot = await _firestore
          .collection(_completionsCollection)
          .where('habitId', isEqualTo: habitId)
          .where('date', isEqualTo: Timestamp.fromDate(dateOnly))
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return HabitCompletionModel.fromJson({...doc.data(), 'id': doc.id});
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération de la complétion: $e');
      return null;
    }
  }

  /// Vérifier si une habitude a été complétée aujourd'hui
  Future<bool> isCompletedToday(String habitId) async {
    final completion = await getCompletionForDate(habitId, DateTime.now());
    return completion != null && completion.isCompleted;
  }

  // ================================
  // Statistiques et analyses
  // ================================

  /// Mettre à jour les statistiques d'une habitude
  Future<void> _updateHabitStatistics(String habitId) async {
    try {
      final habit = await getHabitById(habitId);
      if (habit == null) return;

      final completions = await getHabitCompletions(habitId);
      final completedCompletions = completions.where((c) => c.isCompleted).toList();

      // Calculer la chaîne actuelle
      int currentStreak = 0;
      final today = DateTime.now();

      for (int i = 0; i < 365; i++) { // Vérifier les 365 derniers jours max
        final checkDate = today.subtract(Duration(days: i));
        final completion = await getCompletionForDate(habitId, checkDate);

        if (completion != null && completion.isCompleted) {
          currentStreak++;
        } else if (habit.isScheduledForToday) {
          // Si l'habitude était prévue ce jour-là et n'a pas été faite, arrêter la chaîne
          break;
        }
      }

      // Calculer la meilleure chaîne en analysant tout l'historique
      int bestStreak = currentStreak;
      int tempStreak = 0;
      DateTime checkDate = today;

      // Parcourir jusqu'à 365 jours en arrière pour trouver la meilleure série
      for (int i = 0; i < 365; i++) {
        checkDate = today.subtract(Duration(days: i));
        final completion = await getCompletionForDate(habitId, checkDate);

        if (completion != null && completion.isCompleted) {
          tempStreak++;
          if (tempStreak > bestStreak) {
            bestStreak = tempStreak;
          }
        } else if (habit.isScheduledForToday) {
          // Réinitialiser le compteur temporaire si l'habitude était prévue mais pas faite
          tempStreak = 0;
        }
      }

      // Mettre à jour l'habitude avec les nouvelles statistiques
      final updatedHabit = habit.copyWith(
        currentStreak: currentStreak,
        bestStreak: bestStreak > habit.bestStreak ? bestStreak : habit.bestStreak,
        totalCompletions: completedCompletions.length,
        updatedAt: DateTime.now(),
      );

      await updateHabit(updatedHabit);
    } catch (e) {
      print('Erreur lors de la mise à jour des statistiques: $e');
    }
  }

  /// Obtenir les statistiques d'une habitude
  Future<Map<String, dynamic>> getHabitStatistics(String habitId) async {
    try {
      final habit = await getHabitById(habitId);
      if (habit == null) return {};

      final completions = await getHabitCompletions(habitId);
      final completedCompletions = completions.where((c) => c.isCompleted).toList();

      final now = DateTime.now();
      final thisWeek = completedCompletions.where((c) =>
        c.date.isAfter(now.subtract(const Duration(days: 7)))).length;
      final thisMonth = completedCompletions.where((c) =>
        c.date.isAfter(now.subtract(const Duration(days: 30)))).length;

      return {
        'totalCompletions': completedCompletions.length,
        'currentStreak': habit.currentStreak,
        'bestStreak': habit.bestStreak,
        'thisWeek': thisWeek,
        'thisMonth': thisMonth,
        'completionRate': completions.isNotEmpty ?
          (completedCompletions.length / completions.length) * 100 : 0.0,
      };
    } catch (e) {
      print('Erreur lors du calcul des statistiques: $e');
      return {};
    }
  }

  /// Obtenir les habitudes par type
  Future<List<HabitModel>> getHabitsByType(String entityId, HabitType type) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('entityId', isEqualTo: entityId)
          .where('type', isEqualTo: type.name)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => HabitModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des habitudes par type: $e');
      return [];
    }
  }

  /// Rechercher des habitudes
  Future<List<HabitModel>> searchHabits(String entityId, String query) async {
    try {
      final allHabits = await getHabitsByEntity(entityId);
      return allHabits.where((habit) =>
        habit.name.toLowerCase().contains(query.toLowerCase()) ||
        (habit.description?.toLowerCase().contains(query.toLowerCase()) ?? false)
      ).toList();
    } catch (e) {
      print('Erreur lors de la recherche: $e');
      return [];
    }
  }

  // ================================
  // Intégration avec les finances
  // ================================

  /// Calculer l'économie potentielle d'une mauvaise habitude évitée
  Future<double> calculateFinancialSavings(String habitId, DateTime startDate, DateTime endDate) async {
    try {
      final habit = await getHabitById(habitId);
      if (habit == null || habit.type != HabitType.bad || habit.financialImpact == null) {
        return 0.0;
      }

      final completions = await _firestore
          .collection(_completionsCollection)
          .where('habitId', isEqualTo: habitId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .where('status', isEqualTo: 'completed')
          .get();

      // Pour les mauvaises habitudes, "completed" signifie qu'on a évité l'habitude
      return completions.docs.length * habit.financialImpact!;
    } catch (e) {
      print('Erreur lors du calcul des économies: $e');
      return 0.0;
    }
  }
}