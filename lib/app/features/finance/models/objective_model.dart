import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum ObjectiveStatus {
  active,    // Actif
  completed, // Terminé
  paused,    // En pause
  cancelled, // Annulé
}

enum ObjectivePriority {
  low,    // Basse
  medium, // Moyenne
  high,   // Haute
}

class ObjectiveModel {
  final String id;
  final String name;
  final String? description;
  final double targetAmount;
  final double currentAmount;
  final String entityId;
  final String? categoryId;
  final String currency;
  final ObjectiveStatus status;
  final ObjectivePriority priority;
  final DateTime? targetDate; // Date cible pour atteindre l'objectif
  final String? linkedAccountId; // Compte d'épargne lié
  final IconData icon;
  final Color color;
  final bool isAutoAllocated; // Allocation automatique
  final double? monthlyAllocation; // Montant mensuel automatique
  final List<String> tags;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  ObjectiveModel({
    required this.id,
    required this.name,
    this.description,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.entityId,
    this.categoryId,
    this.currency = 'FCFA',
    this.status = ObjectiveStatus.active,
    this.priority = ObjectivePriority.medium,
    this.targetDate,
    this.linkedAccountId,
    this.icon = Icons.savings,
    this.color = Colors.green,
    this.isAutoAllocated = false,
    this.monthlyAllocation,
    this.tags = const [],
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  // Getters utiles
  bool get isActive => status == ObjectiveStatus.active;
  bool get isCompleted => status == ObjectiveStatus.completed;
  bool get isPaused => status == ObjectiveStatus.paused;
  bool get isCancelled => status == ObjectiveStatus.cancelled;

  double get progressPercentage {
    if (targetAmount == 0) return 0.0;
    return (currentAmount / targetAmount * 100).clamp(0.0, 100.0);
  }

  double get remainingAmount => (targetAmount - currentAmount).clamp(0.0, double.infinity);

  bool get isTargetReached => currentAmount >= targetAmount;

  String get statusDisplayName {
    switch (status) {
      case ObjectiveStatus.active:
        return 'Actif';
      case ObjectiveStatus.completed:
        return 'Terminé';
      case ObjectiveStatus.paused:
        return 'En pause';
      case ObjectiveStatus.cancelled:
        return 'Annulé';
    }
  }

  String get priorityDisplayName {
    switch (priority) {
      case ObjectivePriority.low:
        return 'Basse';
      case ObjectivePriority.medium:
        return 'Moyenne';
      case ObjectivePriority.high:
        return 'Haute';
    }
  }

  Color get priorityColor {
    switch (priority) {
      case ObjectivePriority.low:
        return Colors.green;
      case ObjectivePriority.medium:
        return Colors.orange;
      case ObjectivePriority.high:
        return Colors.red;
    }
  }

  // Calcul du temps estimé pour atteindre l'objectif
  int? get estimatedMonthsToComplete {
    if (monthlyAllocation == null || monthlyAllocation! <= 0) return null;
    if (remainingAmount <= 0) return 0;
    return (remainingAmount / monthlyAllocation!).ceil();
  }

  DateTime? get estimatedCompletionDate {
    final months = estimatedMonthsToComplete;
    if (months == null) return null;
    return DateTime.now().add(Duration(days: months * 30));
  }

  // Vérification si l'objectif est en retard
  bool get isBehindSchedule {
    if (targetDate == null) return false;
    final now = DateTime.now();
    if (now.isAfter(targetDate!)) return !isTargetReached;

    // Calculer le progrès attendu à cette date
    final totalDays = targetDate!.difference(createdAt).inDays;
    final daysPassed = now.difference(createdAt).inDays;
    final expectedProgress = (daysPassed / totalDays * 100).clamp(0.0, 100.0);

    return progressPercentage < expectedProgress - 10; // 10% de tolérance
  }

  // Vérification si l'objectif est en retard (alias pour compatibilité)
  bool get isOverdue {
    if (targetDate == null) return false;
    return DateTime.now().isAfter(targetDate!) && !isTargetReached;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'entityId': entityId,
      'categoryId': categoryId,
      'currency': currency,
      'status': status.name,
      'priority': priority.name,
      'targetDate': targetDate?.toIso8601String(),
      'linkedAccountId': linkedAccountId,
      'iconCodePoint': icon.codePoint,
      'colorValue': color.value,
      'isAutoAllocated': isAutoAllocated,
      'monthlyAllocation': monthlyAllocation,
      'tags': tags,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ObjectiveModel.fromJson(Map<String, dynamic> json) {
    return ObjectiveModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      targetAmount: (json['targetAmount'] ?? 0.0).toDouble(),
      currentAmount: (json['currentAmount'] ?? 0.0).toDouble(),
      entityId: json['entityId'] ?? '',
      categoryId: json['categoryId'],
      currency: json['currency'] ?? 'FCFA',
      status: ObjectiveStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ObjectiveStatus.active,
      ),
      priority: ObjectivePriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => ObjectivePriority.medium,
      ),
      targetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'])
          : null,
      linkedAccountId: json['linkedAccountId'],
      icon: IconData(
        json['iconCodePoint'] ?? Icons.savings.codePoint,
        fontFamily: 'MaterialIcons',
      ),
      color: Color(json['colorValue'] ?? Colors.green.value),
      isAutoAllocated: json['isAutoAllocated'] ?? false,
      monthlyAllocation: json['monthlyAllocation']?.toDouble(),
      tags: List<String>.from(json['tags'] ?? []),
      metadata: json['metadata'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  factory ObjectiveModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ObjectiveModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      targetAmount: (data['targetAmount'] ?? 0.0).toDouble(),
      currentAmount: (data['currentAmount'] ?? 0.0).toDouble(),
      entityId: data['entityId'] ?? '',
      categoryId: data['categoryId'],
      currency: data['currency'] ?? 'FCFA',
      status: ObjectiveStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ObjectiveStatus.active,
      ),
      priority: ObjectivePriority.values.firstWhere(
        (e) => e.name == data['priority'],
        orElse: () => ObjectivePriority.medium,
      ),
      targetDate: (data['targetDate'] as Timestamp?)?.toDate(),
      linkedAccountId: data['linkedAccountId'],
      icon: IconData(
        data['iconCodePoint'] ?? Icons.savings.codePoint,
        fontFamily: 'MaterialIcons',
      ),
      color: Color(data['colorValue'] ?? Colors.green.value),
      isAutoAllocated: data['isAutoAllocated'] ?? false,
      monthlyAllocation: data['monthlyAllocation']?.toDouble(),
      tags: List<String>.from(data['tags'] ?? []),
      metadata: data['metadata'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'entityId': entityId,
      'categoryId': categoryId,
      'currency': currency,
      'status': status.name,
      'priority': priority.name,
      'targetDate': targetDate != null ? Timestamp.fromDate(targetDate!) : null,
      'linkedAccountId': linkedAccountId,
      'iconCodePoint': icon.codePoint,
      'colorValue': color.value,
      'isAutoAllocated': isAutoAllocated,
      'monthlyAllocation': monthlyAllocation,
      'tags': tags,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ObjectiveModel copyWith({
    String? id,
    String? name,
    String? description,
    double? targetAmount,
    double? currentAmount,
    String? entityId,
    String? categoryId,
    String? currency,
    ObjectiveStatus? status,
    ObjectivePriority? priority,
    DateTime? targetDate,
    String? linkedAccountId,
    IconData? icon,
    Color? color,
    bool? isAutoAllocated,
    double? monthlyAllocation,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ObjectiveModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      entityId: entityId ?? this.entityId,
      categoryId: categoryId ?? this.categoryId,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      targetDate: targetDate ?? this.targetDate,
      linkedAccountId: linkedAccountId ?? this.linkedAccountId,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isAutoAllocated: isAutoAllocated ?? this.isAutoAllocated,
      monthlyAllocation: monthlyAllocation ?? this.monthlyAllocation,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ObjectiveModel(id: $id, name: $name, targetAmount: $targetAmount, currentAmount: $currentAmount, progress: ${progressPercentage.toStringAsFixed(1)}%)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ObjectiveModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}