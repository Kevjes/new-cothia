import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum HabitType {
  good,    // Bonne habitude à acquérir
  bad,     // Mauvaise habitude à abandonner
}

extension HabitTypeExtension on HabitType {
  String get displayName {
    switch (this) {
      case HabitType.good:
        return 'Bonne habitude';
      case HabitType.bad:
        return 'Mauvaise habitude';
    }
  }

  Color get color {
    switch (this) {
      case HabitType.good:
        return Colors.green;
      case HabitType.bad:
        return Colors.red;
    }
  }
}

enum HabitFrequency {
  daily,        // Quotidienne
  weekly,       // Hebdomadaire
  specificDays, // Jours spécifiques
  monthly,      // Mensuelle
}

extension HabitFrequencyExtension on HabitFrequency {
  String get displayName {
    switch (this) {
      case HabitFrequency.daily:
        return 'Quotidienne';
      case HabitFrequency.weekly:
        return 'Hebdomadaire';
      case HabitFrequency.specificDays:
        return 'Jours spécifiques';
      case HabitFrequency.monthly:
        return 'Mensuelle';
    }
  }
}

enum HabitStatus {
  active,    // Active
  paused,    // En pause
  archived,  // Archivée
}

extension HabitStatusExtension on HabitStatus {
  String get displayName {
    switch (this) {
      case HabitStatus.active:
        return 'Active';
      case HabitStatus.paused:
        return 'En pause';
      case HabitStatus.archived:
        return 'Archivée';
    }
  }
}

class HabitModel {
  final String id;
  final String name;
  final String? description;
  final HabitType type;
  final HabitFrequency frequency;
  final HabitStatus status;
  final String entityId; // Toujours l'entité personnelle pour les habitudes
  final String? routineId; // Lié à une routine optionnelle
  final IconData icon;
  final Color color;
  final int targetQuantity; // Quantité cible (ex: 10 pages, 30 minutes)
  final String? unit; // Unité (pages, minutes, fois, etc.)
  final List<int> specificDays; // Jours spécifiques (1-7 pour lun-dim)
  final TimeOfDay? reminderTime; // Heure de rappel globale (pour compatibilité)
  final Map<int, TimeOfDay>? specificTimes; // Heures spécifiques par jour (1-7 pour lun-dim)
  final bool hasReminder;
  final double? financialImpact; // Impact financier pour mauvaises habitudes
  final DateTime startDate;
  final DateTime? endDate; // Date de fin optionnelle
  final int currentStreak; // Chaîne actuelle
  final int bestStreak; // Meilleure chaîne
  final int totalCompletions; // Nombre total de complétions
  final Map<String, dynamic>? metadata; // Données supplémentaires
  final DateTime createdAt;
  final DateTime updatedAt;

  HabitModel({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.frequency,
    this.status = HabitStatus.active,
    required this.entityId,
    this.routineId,
    required this.icon,
    required this.color,
    this.targetQuantity = 1,
    this.unit,
    this.specificDays = const [],
    this.reminderTime,
    this.specificTimes,
    this.hasReminder = false,
    this.financialImpact,
    required this.startDate,
    this.endDate,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.totalCompletions = 0,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  // Getters utiles
  bool get isGoodHabit => type == HabitType.good;
  bool get isBadHabit => type == HabitType.bad;
  bool get isActive => status == HabitStatus.active;
  bool get hasFinancialImpact => financialImpact != null && financialImpact! > 0;

  String get displayTarget {
    if (targetQuantity == 1 && unit == null) return '';
    return '$targetQuantity${unit != null ? ' $unit' : ''}';
  }

  String get frequencyDescription {
    switch (frequency) {
      case HabitFrequency.daily:
        return 'Tous les jours';
      case HabitFrequency.weekly:
        return 'Chaque semaine';
      case HabitFrequency.specificDays:
        final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
        final selectedDays = specificDays.map((day) => days[day - 1]).join(', ');
        return selectedDays;
      case HabitFrequency.monthly:
        return 'Chaque mois';
    }
  }

  // Vérifier si l'habitude doit être faite aujourd'hui
  bool get isScheduledForToday {
    final today = DateTime.now();
    final dayOfWeek = today.weekday; // 1-7 (lun-dim)

    switch (frequency) {
      case HabitFrequency.daily:
        return true;
      case HabitFrequency.weekly:
        // À implémenter selon la logique métier
        return true;
      case HabitFrequency.specificDays:
        return specificDays.contains(dayOfWeek);
      case HabitFrequency.monthly:
        // À implémenter selon la logique métier
        return today.day == startDate.day;
    }
  }

  // Méthodes de conversion
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'frequency': frequency.name,
      'status': status.name,
      'entityId': entityId,
      'routineId': routineId,
      'icon': icon.codePoint,
      'color': color.value,
      'targetQuantity': targetQuantity,
      'unit': unit,
      'specificDays': specificDays,
      'reminderTime': reminderTime != null ? {
        'hour': reminderTime!.hour,
        'minute': reminderTime!.minute,
      } : null,
      'specificTimes': specificTimes?.map((day, time) => MapEntry(
        day.toString(),
        {
          'hour': time.hour,
          'minute': time.minute,
        },
      )),
      'hasReminder': hasReminder,
      'financialImpact': financialImpact,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'totalCompletions': totalCompletions,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      type: HabitType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => HabitType.good,
      ),
      frequency: HabitFrequency.values.firstWhere(
        (e) => e.name == json['frequency'],
        orElse: () => HabitFrequency.daily,
      ),
      status: HabitStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => HabitStatus.active,
      ),
      entityId: json['entityId'] ?? '',
      routineId: json['routineId'],
      icon: IconData(json['icon'] ?? Icons.star.codePoint, fontFamily: 'MaterialIcons'),
      color: Color(json['color'] ?? Colors.blue.value),
      targetQuantity: json['targetQuantity'] ?? 1,
      unit: json['unit'],
      specificDays: List<int>.from(json['specificDays'] ?? []),
      reminderTime: json['reminderTime'] != null
          ? TimeOfDay(
              hour: json['reminderTime']['hour'],
              minute: json['reminderTime']['minute'],
            )
          : null,
      specificTimes: json['specificTimes'] != null
          ? (json['specificTimes'] as Map<String, dynamic>).map(
              (dayStr, timeMap) => MapEntry(
                int.parse(dayStr),
                TimeOfDay(
                  hour: timeMap['hour'],
                  minute: timeMap['minute'],
                ),
              ),
            )
          : null,
      hasReminder: json['hasReminder'] ?? false,
      financialImpact: json['financialImpact']?.toDouble(),
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: json['endDate'] != null ? (json['endDate'] as Timestamp).toDate() : null,
      currentStreak: json['currentStreak'] ?? 0,
      bestStreak: json['bestStreak'] ?? 0,
      totalCompletions: json['totalCompletions'] ?? 0,
      metadata: json['metadata'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  HabitModel copyWith({
    String? id,
    String? name,
    String? description,
    HabitType? type,
    HabitFrequency? frequency,
    HabitStatus? status,
    String? entityId,
    String? routineId,
    IconData? icon,
    Color? color,
    int? targetQuantity,
    String? unit,
    List<int>? specificDays,
    TimeOfDay? reminderTime,
    Map<int, TimeOfDay>? specificTimes,
    bool? hasReminder,
    double? financialImpact,
    DateTime? startDate,
    DateTime? endDate,
    int? currentStreak,
    int? bestStreak,
    int? totalCompletions,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HabitModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      status: status ?? this.status,
      entityId: entityId ?? this.entityId,
      routineId: routineId ?? this.routineId,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      targetQuantity: targetQuantity ?? this.targetQuantity,
      unit: unit ?? this.unit,
      specificDays: specificDays ?? this.specificDays,
      reminderTime: reminderTime ?? this.reminderTime,
      specificTimes: specificTimes ?? this.specificTimes,
      hasReminder: hasReminder ?? this.hasReminder,
      financialImpact: financialImpact ?? this.financialImpact,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      totalCompletions: totalCompletions ?? this.totalCompletions,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}