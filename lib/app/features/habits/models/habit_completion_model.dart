import 'package:cloud_firestore/cloud_firestore.dart';

enum CompletionStatus {
  completed,   // Complétée
  skipped,     // Sautée volontairement
  failed,      // Échouée
}

extension CompletionStatusExtension on CompletionStatus {
  String get displayName {
    switch (this) {
      case CompletionStatus.completed:
        return 'Complétée';
      case CompletionStatus.skipped:
        return 'Sautée';
      case CompletionStatus.failed:
        return 'Échouée';
    }
  }
}

class HabitCompletionModel {
  final String id;
  final String habitId;
  final String entityId;
  final DateTime date; // Date de la complétion (sans heure pour grouper par jour)
  final DateTime completedAt; // Timestamp exact de la complétion
  final CompletionStatus status;
  final int? quantityCompleted; // Quantité accomplie (ex: 8 pages sur 10)
  final int? targetQuantity; // Quantité cible au moment de la complétion
  final String? notes; // Notes optionnelles
  final int? durationMinutes; // Durée en minutes
  final double? moodRating; // Note de satisfaction (1-5)
  final Map<String, dynamic>? metadata; // Données supplémentaires
  final DateTime createdAt;
  final DateTime updatedAt;

  HabitCompletionModel({
    required this.id,
    required this.habitId,
    required this.entityId,
    required this.date,
    required this.completedAt,
    required this.status,
    this.quantityCompleted,
    this.targetQuantity,
    this.notes,
    this.durationMinutes,
    this.moodRating,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  // Getters utiles
  bool get isCompleted => status == CompletionStatus.completed;
  bool get isSkipped => status == CompletionStatus.skipped;
  bool get isFailed => status == CompletionStatus.failed;

  bool get isPartialCompletion {
    if (quantityCompleted == null || targetQuantity == null) return false;
    return quantityCompleted! < targetQuantity! && quantityCompleted! > 0;
  }

  bool get isFullCompletion {
    if (quantityCompleted == null || targetQuantity == null) return true;
    return quantityCompleted! >= targetQuantity!;
  }

  double get completionPercentage {
    if (quantityCompleted == null || targetQuantity == null || targetQuantity == 0) {
      return isCompleted ? 100.0 : 0.0;
    }
    return (quantityCompleted! / targetQuantity!) * 100;
  }

  String get displayQuantity {
    if (quantityCompleted == null) return '';
    if (targetQuantity == null) return quantityCompleted.toString();
    return '$quantityCompleted/$targetQuantity';
  }

  // Méthodes de conversion
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habitId': habitId,
      'entityId': entityId,
      'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day)),
      'completedAt': Timestamp.fromDate(completedAt),
      'status': status.name,
      'quantityCompleted': quantityCompleted,
      'targetQuantity': targetQuantity,
      'notes': notes,
      'durationMinutes': durationMinutes,
      'moodRating': moodRating,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory HabitCompletionModel.fromJson(Map<String, dynamic> json) {
    return HabitCompletionModel(
      id: json['id'] ?? '',
      habitId: json['habitId'] ?? '',
      entityId: json['entityId'] ?? '',
      date: (json['date'] as Timestamp).toDate(),
      completedAt: (json['completedAt'] as Timestamp).toDate(),
      status: CompletionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CompletionStatus.completed,
      ),
      quantityCompleted: json['quantityCompleted'],
      targetQuantity: json['targetQuantity'],
      notes: json['notes'],
      durationMinutes: json['durationMinutes'],
      moodRating: json['moodRating']?.toDouble(),
      metadata: json['metadata'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  HabitCompletionModel copyWith({
    String? id,
    String? habitId,
    String? entityId,
    DateTime? date,
    DateTime? completedAt,
    CompletionStatus? status,
    int? quantityCompleted,
    int? targetQuantity,
    String? notes,
    int? durationMinutes,
    double? moodRating,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HabitCompletionModel(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      entityId: entityId ?? this.entityId,
      date: date ?? this.date,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      quantityCompleted: quantityCompleted ?? this.quantityCompleted,
      targetQuantity: targetQuantity ?? this.targetQuantity,
      notes: notes ?? this.notes,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      moodRating: moodRating ?? this.moodRating,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Méthode pour créer une completion simple
  static HabitCompletionModel create({
    required String habitId,
    required String entityId,
    CompletionStatus status = CompletionStatus.completed,
    int? quantityCompleted,
    int? targetQuantity,
    String? notes,
    int? durationMinutes,
    double? moodRating,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return HabitCompletionModel(
      id: '', // Sera généré par Firestore
      habitId: habitId,
      entityId: entityId,
      date: today,
      completedAt: now,
      status: status,
      quantityCompleted: quantityCompleted,
      targetQuantity: targetQuantity,
      notes: notes,
      durationMinutes: durationMinutes,
      moodRating: moodRating,
      createdAt: now,
      updatedAt: now,
    );
  }
}