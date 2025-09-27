import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/routine_model.dart';

class RoutineService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'routines';
  final String _completionsCollection = 'routine_completions';

  // ================================
  // CRUD Opérations pour les routines
  // ================================

  /// Créer une nouvelle routine
  Future<bool> createRoutine(RoutineModel routine) async {
    try {
      final docRef = _firestore.collection(_collection).doc();
      final routineWithId = routine.copyWith(id: docRef.id);
      await docRef.set(routineWithId.toJson());
      return true;
    } catch (e) {
      print('Erreur lors de la création de la routine: $e');
      return false;
    }
  }

  /// Mettre à jour une routine
  Future<bool> updateRoutine(RoutineModel routine) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(routine.id)
          .update(routine.copyWith(updatedAt: DateTime.now()).toJson());
      return true;
    } catch (e) {
      print('Erreur lors de la mise à jour de la routine: $e');
      return false;
    }
  }

  /// Supprimer une routine
  Future<bool> deleteRoutine(String routineId) async {
    try {
      // Supprimer aussi toutes les complétions associées
      final completions = await _firestore
          .collection(_completionsCollection)
          .where('routineId', isEqualTo: routineId)
          .get();

      final batch = _firestore.batch();

      // Supprimer la routine
      batch.delete(_firestore.collection(_collection).doc(routineId));

      // Supprimer toutes les complétions
      for (final doc in completions.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('Erreur lors de la suppression de la routine: $e');
      return false;
    }
  }

  /// Obtenir toutes les routines d'une entité
  Future<List<RoutineModel>> getRoutinesByEntity(String entityId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('entityId', isEqualTo: entityId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => RoutineModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des routines: $e');
      return [];
    }
  }

  /// Obtenir une routine par ID
  Future<RoutineModel?> getRoutineById(String routineId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(routineId).get();
      if (doc.exists) {
        return RoutineModel.fromJson({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération de la routine: $e');
      return null;
    }
  }

  /// Obtenir les routines actives d'une entité
  Future<List<RoutineModel>> getActiveRoutines(String entityId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('entityId', isEqualTo: entityId)
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => RoutineModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des routines actives: $e');
      return [];
    }
  }

  /// Obtenir les routines par type
  Future<List<RoutineModel>> getRoutinesByType(String entityId, RoutineType type) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('entityId', isEqualTo: entityId)
          .where('type', isEqualTo: type.name)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => RoutineModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des routines par type: $e');
      return [];
    }
  }

  /// Obtenir les routines prévues pour aujourd'hui
  Future<List<RoutineModel>> getTodayRoutines(String entityId) async {
    try {
      final routines = await getActiveRoutines(entityId);
      final today = DateTime.now().weekday;

      return routines.where((routine) {
        return routine.activeDays.contains(today);
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des routines du jour: $e');
      return [];
    }
  }

  // ================================
  // Gestion des habitudes dans les routines
  // ================================

  /// Ajouter une habitude à une routine
  Future<bool> addHabitToRoutine(String routineId, String habitId, {int? duration}) async {
    try {
      final routine = await getRoutineById(routineId);
      if (routine == null) return false;

      final newHabit = RoutineHabitItem(
        habitId: habitId,
        order: routine.habits.length,
        duration: duration,
      );

      final updatedHabits = [...routine.habits, newHabit];
      final updatedRoutine = routine.copyWith(
        habits: updatedHabits,
        estimatedDuration: updatedHabits.fold(0, (total, item) => total! + (item.duration ?? 5)),
      );

      return await updateRoutine(updatedRoutine);
    } catch (e) {
      print('Erreur lors de l\'ajout de l\'habitude à la routine: $e');
      return false;
    }
  }

  /// Retirer une habitude d'une routine
  Future<bool> removeHabitFromRoutine(String routineId, String habitId) async {
    try {
      final routine = await getRoutineById(routineId);
      if (routine == null) return false;

      final updatedHabits = routine.habits.where((h) => h.habitId != habitId).toList();

      // Réorganiser les ordres
      for (int i = 0; i < updatedHabits.length; i++) {
        updatedHabits[i] = updatedHabits[i].copyWith(order: i);
      }

      final updatedRoutine = routine.copyWith(
        habits: updatedHabits,
        estimatedDuration: updatedHabits.fold(0, (total, item) => total! + (item.duration ?? 5)),
      );

      return await updateRoutine(updatedRoutine);
    } catch (e) {
      print('Erreur lors de la suppression de l\'habitude de la routine: $e');
      return false;
    }
  }

  /// Réorganiser les habitudes dans une routine
  Future<bool> reorderHabitsInRoutine(String routineId, List<RoutineHabitItem> orderedHabits) async {
    try {
      final routine = await getRoutineById(routineId);
      if (routine == null) return false;

      // Mettre à jour les ordres
      final updatedHabits = <RoutineHabitItem>[];
      for (int i = 0; i < orderedHabits.length; i++) {
        updatedHabits.add(orderedHabits[i].copyWith(order: i));
      }

      final updatedRoutine = routine.copyWith(habits: updatedHabits);
      return await updateRoutine(updatedRoutine);
    } catch (e) {
      print('Erreur lors de la réorganisation des habitudes: $e');
      return false;
    }
  }

  // ================================
  // Complétions de routines
  // ================================

  /// Enregistrer une complétion de routine
  Future<bool> recordRoutineCompletion(String routineId, String entityId, {
    List<String>? completedHabits,
    int? durationMinutes,
    double? satisfactionRating,
    String? notes,
  }) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final completion = {
        'routineId': routineId,
        'entityId': entityId,
        'date': Timestamp.fromDate(today),
        'completedAt': Timestamp.fromDate(now),
        'completedHabits': completedHabits ?? [],
        'durationMinutes': durationMinutes,
        'satisfactionRating': satisfactionRating,
        'notes': notes,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      };

      await _firestore.collection(_completionsCollection).add(completion);

      // Mettre à jour les statistiques de la routine
      await _updateRoutineStatistics(routineId);
      return true;
    } catch (e) {
      print('Erreur lors de l\'enregistrement de la complétion de routine: $e');
      return false;
    }
  }

  /// Vérifier si une routine a été complétée aujourd'hui
  Future<bool> isRoutineCompletedToday(String routineId) async {
    try {
      final today = DateTime.now();
      final dateOnly = DateTime(today.year, today.month, today.day);

      final querySnapshot = await _firestore
          .collection(_completionsCollection)
          .where('routineId', isEqualTo: routineId)
          .where('date', isEqualTo: Timestamp.fromDate(dateOnly))
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Erreur lors de la vérification de la complétion: $e');
      return false;
    }
  }

  /// Obtenir les complétions d'une routine
  Future<List<Map<String, dynamic>>> getRoutineCompletions(String routineId, {int? limit}) async {
    try {
      var query = _firestore
          .collection(_completionsCollection)
          .where('routineId', isEqualTo: routineId)
          .orderBy('date', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    } catch (e) {
      print('Erreur lors de la récupération des complétions de routine: $e');
      return [];
    }
  }

  // ================================
  // Statistiques et analyses
  // ================================

  /// Mettre à jour les statistiques d'une routine
  Future<void> _updateRoutineStatistics(String routineId) async {
    try {
      final routine = await getRoutineById(routineId);
      if (routine == null) return;

      final completions = await getRoutineCompletions(routineId);
      final now = DateTime.now();

      final updatedRoutine = routine.copyWith(
        completionCount: completions.length,
        lastCompletedAt: completions.isNotEmpty ?
          (completions.first['completedAt'] as Timestamp).toDate() : null,
        updatedAt: now,
      );

      await updateRoutine(updatedRoutine);
    } catch (e) {
      print('Erreur lors de la mise à jour des statistiques de routine: $e');
    }
  }

  /// Obtenir les statistiques d'une routine
  Future<Map<String, dynamic>> getRoutineStatistics(String routineId) async {
    try {
      final routine = await getRoutineById(routineId);
      if (routine == null) return {};

      final completions = await getRoutineCompletions(routineId);
      final now = DateTime.now();

      final thisWeek = completions.where((c) {
        final date = (c['date'] as Timestamp).toDate();
        return date.isAfter(now.subtract(const Duration(days: 7)));
      }).length;

      final thisMonth = completions.where((c) {
        final date = (c['date'] as Timestamp).toDate();
        return date.isAfter(now.subtract(const Duration(days: 30)));
      }).length;

      return {
        'totalCompletions': completions.length,
        'thisWeek': thisWeek,
        'thisMonth': thisMonth,
        'averageDuration': _calculateAverageDuration(completions),
        'averageSatisfaction': _calculateAverageSatisfaction(completions),
        'lastCompleted': routine.lastCompletedAt?.toIso8601String(),
      };
    } catch (e) {
      print('Erreur lors du calcul des statistiques de routine: $e');
      return {};
    }
  }

  double _calculateAverageDuration(List<Map<String, dynamic>> completions) {
    final durationsWithData = completions
        .where((c) => c['durationMinutes'] != null)
        .map((c) => (c['durationMinutes'] as num).toDouble())
        .toList();

    if (durationsWithData.isEmpty) return 0.0;
    return durationsWithData.reduce((a, b) => a + b) / durationsWithData.length;
  }

  double _calculateAverageSatisfaction(List<Map<String, dynamic>> completions) {
    final ratingsWithData = completions
        .where((c) => c['satisfactionRating'] != null)
        .map((c) => (c['satisfactionRating'] as num).toDouble())
        .toList();

    if (ratingsWithData.isEmpty) return 0.0;
    return ratingsWithData.reduce((a, b) => a + b) / ratingsWithData.length;
  }

  /// Rechercher des routines
  Future<List<RoutineModel>> searchRoutines(String entityId, String query) async {
    try {
      final allRoutines = await getRoutinesByEntity(entityId);
      return allRoutines.where((routine) =>
        routine.name.toLowerCase().contains(query.toLowerCase()) ||
        (routine.description?.toLowerCase().contains(query.toLowerCase()) ?? false)
      ).toList();
    } catch (e) {
      print('Erreur lors de la recherche de routines: $e');
      return [];
    }
  }

  // ================================
  // Templates de routines
  // ================================

  /// Créer des routines par défaut
  Future<bool> createDefaultRoutines(String entityId) async {
    try {
      final morningRoutine = RoutineModel(
        id: '',
        name: 'Routine Matinale',
        description: 'Ma routine pour bien commencer la journée',
        type: RoutineType.morning,
        entityId: entityId,
        color: RoutineType.morning.color,
        icon: RoutineType.morning.icon,
        startTime: const TimeOfDay(hour: 7, minute: 0),
        estimatedDuration: 30,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final eveningRoutine = RoutineModel(
        id: '',
        name: 'Routine du Soir',
        description: 'Ma routine pour terminer la journée en beauté',
        type: RoutineType.evening,
        entityId: entityId,
        color: RoutineType.evening.color,
        icon: RoutineType.evening.icon,
        startTime: const TimeOfDay(hour: 21, minute: 0),
        estimatedDuration: 25,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success1 = await createRoutine(morningRoutine);
      final success2 = await createRoutine(eveningRoutine);

      return success1 && success2;
    } catch (e) {
      print('Erreur lors de la création des routines par défaut: $e');
      return false;
    }
  }
}