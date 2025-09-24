import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/objective_model.dart';

class ObjectiveService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'objectives';

  // Créer un nouvel objectif
  Future<String> createObjective(ObjectiveModel objective) async {
    try {
      final docRef = await _firestore.collection(_collection).add(objective.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Erreur lors de la création de l\'objectif: $e');
    }
  }

  // Mettre à jour un objectif existant
  Future<void> updateObjective(String objectiveId, ObjectiveModel objective) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(objectiveId)
          .update(objective.toFirestore());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de l\'objectif: $e');
    }
  }

  // Supprimer un objectif
  Future<void> deleteObjective(String objectiveId) async {
    try {
      await _firestore.collection(_collection).doc(objectiveId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'objectif: $e');
    }
  }

  // Obtenir un objectif par ID
  Future<ObjectiveModel?> getObjectiveById(String objectiveId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(objectiveId).get();
      if (doc.exists) {
        return ObjectiveModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'objectif: $e');
    }
  }

  // Obtenir tous les objectifs d'une entité
  Future<List<ObjectiveModel>> getObjectivesByEntity(String entityId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('entityId', isEqualTo: entityId)
          .orderBy('priority', descending: true)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ObjectiveModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des objectifs: $e');
    }
  }

  // Obtenir les objectifs par statut
  Future<List<ObjectiveModel>> getObjectivesByStatus(String entityId, ObjectiveStatus status) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('entityId', isEqualTo: entityId)
          .where('status', isEqualTo: status.name)
          .orderBy('priority', descending: true)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ObjectiveModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des objectifs par statut: $e');
    }
  }

  // Obtenir les objectifs actifs
  Future<List<ObjectiveModel>> getActiveObjectives(String entityId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('entityId', isEqualTo: entityId)
          .where('status', isEqualTo: ObjectiveStatus.active.name)
          .orderBy('priority', descending: true)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ObjectiveModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des objectifs actifs: $e');
    }
  }

  // Obtenir les objectifs par priorité
  Future<List<ObjectiveModel>> getObjectivesByPriority(String entityId, ObjectivePriority priority) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('entityId', isEqualTo: entityId)
          .where('priority', isEqualTo: priority.name)
          .where('status', isEqualTo: ObjectiveStatus.active.name)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ObjectiveModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des objectifs par priorité: $e');
    }
  }

  // Mettre à jour le montant actuel d'un objectif
  Future<void> updateObjectiveCurrentAmount(String objectiveId, double newAmount) async {
    try {
      await _firestore.collection(_collection).doc(objectiveId).update({
        'currentAmount': newAmount,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du montant de l\'objectif: $e');
    }
  }

  // Ajouter un montant à l'objectif actuel
  Future<void> addToObjectiveAmount(String objectiveId, double amount) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final objectiveRef = _firestore.collection(_collection).doc(objectiveId);
        final objectiveDoc = await transaction.get(objectiveRef);

        if (!objectiveDoc.exists) {
          throw Exception('Objectif non trouvé');
        }

        final currentAmount = (objectiveDoc.data()?['currentAmount'] ?? 0.0).toDouble();
        final targetAmount = (objectiveDoc.data()?['targetAmount'] ?? 0.0).toDouble();
        final newAmount = currentAmount + amount;

        final updates = {
          'currentAmount': newAmount,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        };

        // Auto-compléter l'objectif si le montant cible est atteint
        if (newAmount >= targetAmount) {
          updates['status'] = ObjectiveStatus.completed.name;
        }

        transaction.update(objectiveRef, updates);
      });
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout à l\'objectif: $e');
    }
  }

  // Soustraire un montant de l'objectif actuel
  Future<void> subtractFromObjectiveAmount(String objectiveId, double amount) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final objectiveRef = _firestore.collection(_collection).doc(objectiveId);
        final objectiveDoc = await transaction.get(objectiveRef);

        if (!objectiveDoc.exists) {
          throw Exception('Objectif non trouvé');
        }

        final currentAmount = (objectiveDoc.data()?['currentAmount'] ?? 0.0).toDouble();
        final newAmount = (currentAmount - amount).clamp(0.0, double.infinity);

        transaction.update(objectiveRef, {
          'currentAmount': newAmount,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      });
    } catch (e) {
      throw Exception('Erreur lors de la soustraction de l\'objectif: $e');
    }
  }

  // Marquer un objectif comme terminé
  Future<void> completeObjective(String objectiveId) async {
    try {
      await _firestore.collection(_collection).doc(objectiveId).update({
        'status': ObjectiveStatus.completed.name,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Erreur lors de la finalisation de l\'objectif: $e');
    }
  }

  // Mettre en pause un objectif
  Future<void> pauseObjective(String objectiveId) async {
    try {
      await _firestore.collection(_collection).doc(objectiveId).update({
        'status': ObjectiveStatus.paused.name,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Erreur lors de la mise en pause de l\'objectif: $e');
    }
  }

  // Reprendre un objectif
  Future<void> resumeObjective(String objectiveId) async {
    try {
      await _firestore.collection(_collection).doc(objectiveId).update({
        'status': ObjectiveStatus.active.name,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Erreur lors de la reprise de l\'objectif: $e');
    }
  }

  // Annuler un objectif
  Future<void> cancelObjective(String objectiveId) async {
    try {
      await _firestore.collection(_collection).doc(objectiveId).update({
        'status': ObjectiveStatus.cancelled.name,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Erreur lors de l\'annulation de l\'objectif: $e');
    }
  }

  // Obtenir les statistiques des objectifs
  Future<Map<String, dynamic>> getObjectiveStats(String entityId) async {
    try {
      final objectives = await getObjectivesByEntity(entityId);

      final activeObjectives = objectives.where((o) => o.isActive).toList();
      final completedObjectives = objectives.where((o) => o.isCompleted).toList();
      final pausedObjectives = objectives.where((o) => o.isPaused).toList();
      final cancelledObjectives = objectives.where((o) => o.isCancelled).toList();

      final highPriorityObjectives = activeObjectives.where((o) => o.priority == ObjectivePriority.high).length;
      final mediumPriorityObjectives = activeObjectives.where((o) => o.priority == ObjectivePriority.medium).length;
      final lowPriorityObjectives = activeObjectives.where((o) => o.priority == ObjectivePriority.low).length;

      final totalTargetAmount = activeObjectives.fold(0.0, (sum, o) => sum + o.targetAmount);
      final totalCurrentAmount = activeObjectives.fold(0.0, (sum, o) => sum + o.currentAmount);
      final totalProgress = totalTargetAmount > 0 ? (totalCurrentAmount / totalTargetAmount * 100) : 0.0;

      final behindScheduleObjectives = activeObjectives.where((o) => o.isBehindSchedule).length;
      final nearTargetObjectives = activeObjectives.where((o) => o.progressPercentage >= 80).length;

      return {
        'totalObjectives': objectives.length,
        'activeObjectives': activeObjectives.length,
        'completedObjectives': completedObjectives.length,
        'pausedObjectives': pausedObjectives.length,
        'cancelledObjectives': cancelledObjectives.length,
        'highPriorityObjectives': highPriorityObjectives,
        'mediumPriorityObjectives': mediumPriorityObjectives,
        'lowPriorityObjectives': lowPriorityObjectives,
        'totalTargetAmount': totalTargetAmount,
        'totalCurrentAmount': totalCurrentAmount,
        'totalProgress': totalProgress,
        'behindScheduleObjectives': behindScheduleObjectives,
        'nearTargetObjectives': nearTargetObjectives,
        'completionRate': objectives.isNotEmpty ? (completedObjectives.length / objectives.length * 100) : 0.0,
      };
    } catch (e) {
      throw Exception('Erreur lors du calcul des statistiques des objectifs: $e');
    }
  }

  // Rechercher des objectifs
  Future<List<ObjectiveModel>> searchObjectives(String entityId, String searchTerm) async {
    try {
      final allObjectives = await getObjectivesByEntity(entityId);
      final searchTermLower = searchTerm.toLowerCase();

      return allObjectives.where((objective) {
        return objective.name.toLowerCase().contains(searchTermLower) ||
               (objective.description?.toLowerCase().contains(searchTermLower) ?? false) ||
               objective.tags.any((tag) => tag.toLowerCase().contains(searchTermLower));
      }).toList();
    } catch (e) {
      throw Exception('Erreur lors de la recherche d\'objectifs: $e');
    }
  }

  // Dupliquer un objectif
  Future<String> duplicateObjective(String objectiveId, String newName) async {
    try {
      final originalObjective = await getObjectiveById(objectiveId);
      if (originalObjective == null) {
        throw Exception('Objectif original non trouvé');
      }

      final duplicatedObjective = originalObjective.copyWith(
        id: '',
        name: newName,
        currentAmount: 0.0,
        status: ObjectiveStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return await createObjective(duplicatedObjective);
    } catch (e) {
      throw Exception('Erreur lors de la duplication de l\'objectif: $e');
    }
  }

  // Obtenir les objectifs en retard
  Future<List<ObjectiveModel>> getObjectivesBehindSchedule(String entityId) async {
    try {
      final activeObjectives = await getActiveObjectives(entityId);
      return activeObjectives.where((objective) => objective.isBehindSchedule).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des objectifs en retard: $e');
    }
  }

  // Obtenir les objectifs avec allocation automatique
  Future<List<ObjectiveModel>> getObjectivesWithAutoAllocation(String entityId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('entityId', isEqualTo: entityId)
          .where('isAutoAllocated', isEqualTo: true)
          .where('status', isEqualTo: ObjectiveStatus.active.name)
          .get();

      return querySnapshot.docs
          .map((doc) => ObjectiveModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des objectifs avec allocation automatique: $e');
    }
  }

  // Exécuter l'allocation automatique mensuelle
  Future<List<Map<String, dynamic>>> executeMonthlyAutoAllocation(String entityId) async {
    try {
      final autoObjectives = await getObjectivesWithAutoAllocation(entityId);
      final results = <Map<String, dynamic>>[];

      for (final objective in autoObjectives) {
        if (objective.monthlyAllocation != null && objective.monthlyAllocation! > 0) {
          try {
            await addToObjectiveAmount(objective.id, objective.monthlyAllocation!);
            results.add({
              'objectiveId': objective.id,
              'objectiveName': objective.name,
              'amount': objective.monthlyAllocation!,
              'success': true,
            });
          } catch (e) {
            results.add({
              'objectiveId': objective.id,
              'objectiveName': objective.name,
              'amount': objective.monthlyAllocation!,
              'success': false,
              'error': e.toString(),
            });
          }
        }
      }

      return results;
    } catch (e) {
      throw Exception('Erreur lors de l\'allocation automatique: $e');
    }
  }

  // Écouter les changements des objectifs en temps réel
  Stream<List<ObjectiveModel>> watchObjectivesByEntity(String entityId) {
    return _firestore
        .collection(_collection)
        .where('entityId', isEqualTo: entityId)
        .orderBy('priority', descending: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ObjectiveModel.fromFirestore(doc))
            .toList());
  }

  // Obtenir les objectifs par compte lié
  Future<List<ObjectiveModel>> getObjectivesByAccount(String entityId, String accountId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('entityId', isEqualTo: entityId)
          .where('linkedAccountId', isEqualTo: accountId)
          .get();

      return querySnapshot.docs
          .map((doc) => ObjectiveModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des objectifs par compte: $e');
    }
  }
}