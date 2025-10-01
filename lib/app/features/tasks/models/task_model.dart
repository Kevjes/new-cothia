import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum TaskStatus {
  pending,     // En attente
  inProgress,  // En cours
  completed,   // Terminé
  cancelled,   // Annulé
  rescheduled  // Reprogrammé
}

enum TaskPriority {
  high,        // Haute
  medium,      // Moyenne
  low          // Basse
}

class TaskModel {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final TaskStatus status;
  final TaskPriority priority;
  final String categoryId;
  final String entityId;
  final String? projectId;
  final DateTime? dueDate;
  final DateTime? startDate;
  final DateTime? completedDate;
  final bool isRecurring;
  final String? recurringPattern; // 'daily', 'weekly', 'monthly'
  final List<String> tags;
  final String? linkedTransactionId; // Liaison avec une transaction financière
  final String? linkedHabitId; // Liaison avec une habitude
  final double? estimatedDuration; // En heures
  final double? actualDuration; // En heures
  final String? notes;
  final List<String> attachments; // URLs des fichiers attachés
  final Map<String, dynamic>? metadata; // Données supplémentaires
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskModel({
    required this.id,
    this.userId = '',
    required this.title,
    this.description,
    this.status = TaskStatus.pending,
    this.priority = TaskPriority.medium,
    required this.categoryId,
    required this.entityId,
    this.projectId,
    this.dueDate,
    this.startDate,
    this.completedDate,
    this.isRecurring = false,
    this.recurringPattern,
    this.tags = const [],
    this.linkedTransactionId,
    this.linkedHabitId,
    this.estimatedDuration,
    this.actualDuration,
    this.notes,
    this.attachments = const [],
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  // Getters pour l'affichage
  String get statusDisplayName {
    switch (status) {
      case TaskStatus.pending:
        return 'En attente';
      case TaskStatus.inProgress:
        return 'En cours';
      case TaskStatus.completed:
        return 'Terminé';
      case TaskStatus.cancelled:
        return 'Annulé';
      case TaskStatus.rescheduled:
        return 'Reprogrammé';
    }
  }

  String get priorityDisplayName {
    switch (priority) {
      case TaskPriority.high:
        return 'Haute';
      case TaskPriority.medium:
        return 'Moyenne';
      case TaskPriority.low:
        return 'Basse';
    }
  }

  Color get statusColor {
    switch (status) {
      case TaskStatus.pending:
        return Colors.orange;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.cancelled:
        return Colors.red;
      case TaskStatus.rescheduled:
        return Colors.purple;
    }
  }

  Color get priorityColor {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case TaskStatus.pending:
        return Icons.schedule;
      case TaskStatus.inProgress:
        return Icons.play_arrow;
      case TaskStatus.completed:
        return Icons.check_circle;
      case TaskStatus.cancelled:
        return Icons.cancel;
      case TaskStatus.rescheduled:
        return Icons.update;
    }
  }

  IconData get priorityIcon {
    switch (priority) {
      case TaskPriority.high:
        return Icons.keyboard_double_arrow_up;
      case TaskPriority.medium:
        return Icons.keyboard_arrow_up;
      case TaskPriority.low:
        return Icons.keyboard_arrow_down;
    }
  }

  bool get isOverdue {
    if (dueDate == null || status == TaskStatus.completed) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final today = DateTime.now();
    return dueDate!.year == today.year &&
           dueDate!.month == today.month &&
           dueDate!.day == today.day;
  }

  bool get isDueTomorrow {
    if (dueDate == null) return false;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return dueDate!.year == tomorrow.year &&
           dueDate!.month == tomorrow.month &&
           dueDate!.day == tomorrow.day;
  }

  Duration? get timeUntilDue {
    if (dueDate == null) return null;
    return dueDate!.difference(DateTime.now());
  }

  double get completionRate {
    if (status == TaskStatus.completed) return 1.0;
    if (status == TaskStatus.cancelled) return 0.0;
    if (status == TaskStatus.inProgress && actualDuration != null && estimatedDuration != null) {
      return (actualDuration! / estimatedDuration!).clamp(0.0, 1.0);
    }
    return status == TaskStatus.inProgress ? 0.5 : 0.0;
  }

  // Conversion JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'status': status.name,
      'priority': priority.name,
      'categoryId': categoryId,
      'entityId': entityId,
      'projectId': projectId,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'startDate': startDate?.millisecondsSinceEpoch,
      'completedDate': completedDate?.millisecondsSinceEpoch,
      'isRecurring': isRecurring,
      'recurringPattern': recurringPattern,
      'tags': tags,
      'linkedTransactionId': linkedTransactionId,
      'linkedHabitId': linkedHabitId,
      'estimatedDuration': estimatedDuration,
      'actualDuration': actualDuration,
      'notes': notes,
      'attachments': attachments,
      'metadata': metadata,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  static TaskModel fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.pending,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      categoryId: json['categoryId'] ?? '',
      entityId: json['entityId'] ?? '',
      projectId: json['projectId'],
      dueDate: json['dueDate'] != null
        ? DateTime.fromMillisecondsSinceEpoch(json['dueDate'])
        : null,
      startDate: json['startDate'] != null
        ? DateTime.fromMillisecondsSinceEpoch(json['startDate'])
        : null,
      completedDate: json['completedDate'] != null
        ? DateTime.fromMillisecondsSinceEpoch(json['completedDate'])
        : null,
      isRecurring: json['isRecurring'] ?? false,
      recurringPattern: json['recurringPattern'],
      tags: List<String>.from(json['tags'] ?? []),
      linkedTransactionId: json['linkedTransactionId'],
      linkedHabitId: json['linkedHabitId'],
      estimatedDuration: json['estimatedDuration']?.toDouble(),
      actualDuration: json['actualDuration']?.toDouble(),
      notes: json['notes'],
      attachments: List<String>.from(json['attachments'] ?? []),
      metadata: json['metadata'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt']),
    );
  }

  // Méthode copyWith
  TaskModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    String? categoryId,
    String? entityId,
    String? projectId,
    DateTime? dueDate,
    DateTime? startDate,
    DateTime? completedDate,
    bool? isRecurring,
    String? recurringPattern,
    List<String>? tags,
    String? linkedTransactionId,
    String? linkedHabitId,
    double? estimatedDuration,
    double? actualDuration,
    String? notes,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      categoryId: categoryId ?? this.categoryId,
      entityId: entityId ?? this.entityId,
      projectId: projectId ?? this.projectId,
      dueDate: dueDate ?? this.dueDate,
      startDate: startDate ?? this.startDate,
      completedDate: completedDate ?? this.completedDate,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
      tags: tags ?? this.tags,
      linkedTransactionId: linkedTransactionId ?? this.linkedTransactionId,
      linkedHabitId: linkedHabitId ?? this.linkedHabitId,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      actualDuration: actualDuration ?? this.actualDuration,
      notes: notes ?? this.notes,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  // Méthodes Firebase
  Map<String, dynamic> toFirestore() {
    return toJson();
  }

  static TaskModel fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return fromJson(data);
  }

  @override
  String toString() {
    return 'TaskModel{id: $id, title: $title, status: $status, priority: $priority}';
  }
}