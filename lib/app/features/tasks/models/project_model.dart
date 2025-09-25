import 'package:flutter/material.dart';

enum ProjectStatus {
  planning,    // Planification
  active,      // Actif
  onHold,      // En pause
  completed,   // Terminé
  cancelled    // Annulé
}

class ProjectModel {
  final String id;
  final String name;
  final String? description;
  final ProjectStatus status;
  final String entityId;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? deadline;
  final Color color;
  final IconData icon;
  final List<String> tags;
  final double progressPercentage;
  final int totalTasks;
  final int completedTasks;
  final String? linkedBudgetId; // Liaison avec un budget financier
  final double? estimatedBudget;
  final double? actualBudget;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProjectModel({
    required this.id,
    required this.name,
    this.description,
    this.status = ProjectStatus.planning,
    required this.entityId,
    this.startDate,
    this.endDate,
    this.deadline,
    this.color = Colors.blue,
    this.icon = Icons.work,
    this.tags = const [],
    this.progressPercentage = 0.0,
    this.totalTasks = 0,
    this.completedTasks = 0,
    this.linkedBudgetId,
    this.estimatedBudget,
    this.actualBudget,
    required this.createdAt,
    required this.updatedAt,
  });

  // Getters
  String get statusDisplayName {
    switch (status) {
      case ProjectStatus.planning:
        return 'Planification';
      case ProjectStatus.active:
        return 'Actif';
      case ProjectStatus.onHold:
        return 'En pause';
      case ProjectStatus.completed:
        return 'Terminé';
      case ProjectStatus.cancelled:
        return 'Annulé';
    }
  }

  Color get statusColor {
    switch (status) {
      case ProjectStatus.planning:
        return Colors.orange;
      case ProjectStatus.active:
        return Colors.green;
      case ProjectStatus.onHold:
        return Colors.yellow;
      case ProjectStatus.completed:
        return Colors.blue;
      case ProjectStatus.cancelled:
        return Colors.red;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case ProjectStatus.planning:
        return Icons.schedule;
      case ProjectStatus.active:
        return Icons.play_arrow;
      case ProjectStatus.onHold:
        return Icons.pause;
      case ProjectStatus.completed:
        return Icons.check_circle;
      case ProjectStatus.cancelled:
        return Icons.cancel;
    }
  }

  bool get isOverdue {
    if (deadline == null || status == ProjectStatus.completed) return false;
    return DateTime.now().isAfter(deadline!);
  }

  bool get isDueToday {
    if (deadline == null) return false;
    final today = DateTime.now();
    return deadline!.year == today.year &&
           deadline!.month == today.month &&
           deadline!.day == today.day;
  }

  Duration? get timeUntilDeadline {
    if (deadline == null) return null;
    return deadline!.difference(DateTime.now());
  }

  double get taskCompletionRate {
    if (totalTasks == 0) return 0.0;
    return completedTasks / totalTasks;
  }

  double get budgetUsageRate {
    if (estimatedBudget == null || estimatedBudget == 0) return 0.0;
    return (actualBudget ?? 0) / estimatedBudget!;
  }

  // Calcul automatique du progrès basé sur les tâches
  double calculateProgress() {
    return taskCompletionRate * 100;
  }

  // Conversion JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status.name,
      'entityId': entityId,
      'startDate': startDate?.millisecondsSinceEpoch,
      'endDate': endDate?.millisecondsSinceEpoch,
      'deadline': deadline?.millisecondsSinceEpoch,
      'color': color.value,
      'icon': icon.codePoint,
      'tags': tags,
      'progressPercentage': progressPercentage,
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'linkedBudgetId': linkedBudgetId,
      'estimatedBudget': estimatedBudget,
      'actualBudget': actualBudget,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  static ProjectModel fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      status: ProjectStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ProjectStatus.planning,
      ),
      entityId: json['entityId'] ?? '',
      startDate: json['startDate'] != null
        ? DateTime.fromMillisecondsSinceEpoch(json['startDate'])
        : null,
      endDate: json['endDate'] != null
        ? DateTime.fromMillisecondsSinceEpoch(json['endDate'])
        : null,
      deadline: json['deadline'] != null
        ? DateTime.fromMillisecondsSinceEpoch(json['deadline'])
        : null,
      color: Color(json['color'] ?? Colors.blue.value),
      icon: IconData(json['icon'] ?? Icons.work.codePoint, fontFamily: 'MaterialIcons'),
      tags: List<String>.from(json['tags'] ?? []),
      progressPercentage: json['progressPercentage']?.toDouble() ?? 0.0,
      totalTasks: json['totalTasks'] ?? 0,
      completedTasks: json['completedTasks'] ?? 0,
      linkedBudgetId: json['linkedBudgetId'],
      estimatedBudget: json['estimatedBudget']?.toDouble(),
      actualBudget: json['actualBudget']?.toDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt']),
    );
  }

  // Méthode copyWith
  ProjectModel copyWith({
    String? id,
    String? name,
    String? description,
    ProjectStatus? status,
    String? entityId,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? deadline,
    Color? color,
    IconData? icon,
    List<String>? tags,
    double? progressPercentage,
    int? totalTasks,
    int? completedTasks,
    String? linkedBudgetId,
    double? estimatedBudget,
    double? actualBudget,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      entityId: entityId ?? this.entityId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      deadline: deadline ?? this.deadline,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      tags: tags ?? this.tags,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      totalTasks: totalTasks ?? this.totalTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      linkedBudgetId: linkedBudgetId ?? this.linkedBudgetId,
      estimatedBudget: estimatedBudget ?? this.estimatedBudget,
      actualBudget: actualBudget ?? this.actualBudget,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ProjectModel{id: $id, name: $name, status: $status}';
  }
}