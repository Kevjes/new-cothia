import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum RoutineType {
  morning,   // Routine matinale
  evening,   // Routine du soir
  custom,    // Routine personnalisée
}

extension RoutineTypeExtension on RoutineType {
  String get displayName {
    switch (this) {
      case RoutineType.morning:
        return 'Routine matinale';
      case RoutineType.evening:
        return 'Routine du soir';
      case RoutineType.custom:
        return 'Routine personnalisée';
    }
  }

  IconData get icon {
    switch (this) {
      case RoutineType.morning:
        return Icons.wb_sunny;
      case RoutineType.evening:
        return Icons.nights_stay;
      case RoutineType.custom:
        return Icons.list_alt;
    }
  }

  Color get color {
    switch (this) {
      case RoutineType.morning:
        return Colors.orange;
      case RoutineType.evening:
        return Colors.indigo;
      case RoutineType.custom:
        return Colors.purple;
    }
  }
}

enum RoutineStatus {
  active,    // Active
  paused,    // En pause
  archived,  // Archivée
}

extension RoutineStatusExtension on RoutineStatus {
  String get displayName {
    switch (this) {
      case RoutineStatus.active:
        return 'Active';
      case RoutineStatus.paused:
        return 'En pause';
      case RoutineStatus.archived:
        return 'Archivée';
    }
  }
}

class RoutineHabitItem {
  final String habitId;
  final int order; // Ordre dans la routine
  final int? duration; // Durée estimée en minutes
  final bool isOptional; // Si l'habitude est optionnelle dans la routine

  RoutineHabitItem({
    required this.habitId,
    required this.order,
    this.duration,
    this.isOptional = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'habitId': habitId,
      'order': order,
      'duration': duration,
      'isOptional': isOptional,
    };
  }

  factory RoutineHabitItem.fromJson(Map<String, dynamic> json) {
    return RoutineHabitItem(
      habitId: json['habitId'] ?? '',
      order: json['order'] ?? 0,
      duration: json['duration'],
      isOptional: json['isOptional'] ?? false,
    );
  }

  RoutineHabitItem copyWith({
    String? habitId,
    int? order,
    int? duration,
    bool? isOptional,
  }) {
    return RoutineHabitItem(
      habitId: habitId ?? this.habitId,
      order: order ?? this.order,
      duration: duration ?? this.duration,
      isOptional: isOptional ?? this.isOptional,
    );
  }
}

class RoutineModel {
  final String id;
  final String name;
  final String? description;
  final RoutineType type;
  final RoutineStatus status;
  final String entityId; // Toujours l'entité personnelle pour les routines
  final List<RoutineHabitItem> habits; // Liste ordonnée des habitudes
  final TimeOfDay? startTime; // Heure de début suggérée
  final int? estimatedDuration; // Durée totale estimée en minutes
  final List<int> activeDays; // Jours actifs (1-7 pour lun-dim)
  final bool hasReminder;
  final TimeOfDay? reminderTime; // Heure de rappel
  final Color color;
  final IconData icon;
  final int completionCount; // Nombre de fois complétée
  final DateTime? lastCompletedAt; // Dernière fois complétée
  final Map<String, dynamic>? metadata; // Données supplémentaires
  final DateTime createdAt;
  final DateTime updatedAt;

  RoutineModel({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    this.status = RoutineStatus.active,
    required this.entityId,
    this.habits = const [],
    this.startTime,
    this.estimatedDuration,
    this.activeDays = const [1, 2, 3, 4, 5, 6, 7], // Par défaut tous les jours
    this.hasReminder = false,
    this.reminderTime,
    required this.color,
    required this.icon,
    this.completionCount = 0,
    this.lastCompletedAt,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  // Getters utiles
  bool get isActive => status == RoutineStatus.active;
  bool get hasHabits => habits.isNotEmpty;
  int get habitCount => habits.length;

  String get displayDuration {
    if (estimatedDuration == null) return '';
    final hours = estimatedDuration! ~/ 60;
    final minutes = estimatedDuration! % 60;
    if (hours > 0) {
      return '${hours}h${minutes > 0 ? ' ${minutes}min' : ''}';
    }
    return '${minutes}min';
  }

  String get activeDaysDescription {
    if (activeDays.length == 7) return 'Tous les jours';
    if (activeDays.length == 5 && !activeDays.contains(6) && !activeDays.contains(7)) {
      return 'En semaine';
    }
    if (activeDays.length == 2 && activeDays.contains(6) && activeDays.contains(7)) {
      return 'Week-end';
    }

    final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return activeDays.map((day) => days[day - 1]).join(', ');
  }

  // Vérifier si la routine est prévue pour aujourd'hui
  bool get isScheduledForToday {
    final today = DateTime.now();
    final dayOfWeek = today.weekday; // 1-7 (lun-dim)
    return activeDays.contains(dayOfWeek);
  }

  // Calculer la durée totale basée sur les habitudes
  int get calculatedDuration {
    return habits.fold(0, (total, item) => total + (item.duration ?? 5));
  }

  // Méthodes de conversion
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'status': status.name,
      'entityId': entityId,
      'habits': habits.map((h) => h.toJson()).toList(),
      'startTime': startTime != null ? {
        'hour': startTime!.hour,
        'minute': startTime!.minute,
      } : null,
      'estimatedDuration': estimatedDuration,
      'activeDays': activeDays,
      'hasReminder': hasReminder,
      'reminderTime': reminderTime != null ? {
        'hour': reminderTime!.hour,
        'minute': reminderTime!.minute,
      } : null,
      'color': color.value,
      'icon': icon.codePoint,
      'completionCount': completionCount,
      'lastCompletedAt': lastCompletedAt != null ? Timestamp.fromDate(lastCompletedAt!) : null,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory RoutineModel.fromJson(Map<String, dynamic> json) {
    return RoutineModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      type: RoutineType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => RoutineType.custom,
      ),
      status: RoutineStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RoutineStatus.active,
      ),
      entityId: json['entityId'] ?? '',
      habits: (json['habits'] as List<dynamic>?)
              ?.map((h) => RoutineHabitItem.fromJson(h))
              .toList() ?? [],
      startTime: json['startTime'] != null
          ? TimeOfDay(
              hour: json['startTime']['hour'],
              minute: json['startTime']['minute'],
            )
          : null,
      estimatedDuration: json['estimatedDuration'],
      activeDays: List<int>.from(json['activeDays'] ?? [1, 2, 3, 4, 5, 6, 7]),
      hasReminder: json['hasReminder'] ?? false,
      reminderTime: json['reminderTime'] != null
          ? TimeOfDay(
              hour: json['reminderTime']['hour'],
              minute: json['reminderTime']['minute'],
            )
          : null,
      color: Color(json['color'] ?? Colors.purple.value),
      icon: IconData(json['icon'] ?? Icons.list_alt.codePoint, fontFamily: 'MaterialIcons'),
      completionCount: json['completionCount'] ?? 0,
      lastCompletedAt: json['lastCompletedAt'] != null
          ? (json['lastCompletedAt'] as Timestamp).toDate()
          : null,
      metadata: json['metadata'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  RoutineModel copyWith({
    String? id,
    String? name,
    String? description,
    RoutineType? type,
    RoutineStatus? status,
    String? entityId,
    List<RoutineHabitItem>? habits,
    TimeOfDay? startTime,
    int? estimatedDuration,
    List<int>? activeDays,
    bool? hasReminder,
    TimeOfDay? reminderTime,
    Color? color,
    IconData? icon,
    int? completionCount,
    DateTime? lastCompletedAt,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoutineModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      entityId: entityId ?? this.entityId,
      habits: habits ?? this.habits,
      startTime: startTime ?? this.startTime,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      activeDays: activeDays ?? this.activeDays,
      hasReminder: hasReminder ?? this.hasReminder,
      reminderTime: reminderTime ?? this.reminderTime,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      completionCount: completionCount ?? this.completionCount,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}