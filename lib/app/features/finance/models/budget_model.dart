import 'package:cloud_firestore/cloud_firestore.dart';

enum BudgetType {
  expense, // Plafond de dépense
  saving,  // Plancher d'épargne
}

enum BudgetPeriod {
  weekly,   // Hebdomadaire
  monthly,  // Mensuel
  quarterly, // Trimestriel
  yearly,   // Annuel
}

class AutomationRule {
  final bool isEnabled;
  final String? sourceAccountId;
  final String? destinationAccountId;
  final double amount;
  final int dayOfMonth; // Jour du mois d'exécution
  final String? description;

  AutomationRule({
    required this.isEnabled,
    this.sourceAccountId,
    this.destinationAccountId,
    required this.amount,
    this.dayOfMonth = 1,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'isEnabled': isEnabled,
      'sourceAccountId': sourceAccountId,
      'destinationAccountId': destinationAccountId,
      'amount': amount,
      'dayOfMonth': dayOfMonth,
      'description': description,
    };
  }

  factory AutomationRule.fromJson(Map<String, dynamic> json) {
    return AutomationRule(
      isEnabled: json['isEnabled'] ?? false,
      sourceAccountId: json['sourceAccountId'],
      destinationAccountId: json['destinationAccountId'],
      amount: (json['amount'] ?? 0.0).toDouble(),
      dayOfMonth: json['dayOfMonth'] ?? 1,
      description: json['description'],
    );
  }
}

class BudgetModel {
  final String id;
  final String name;
  final String? description;
  final BudgetType type;
  final BudgetPeriod period;
  final double targetAmount;
  final double currentAmount;
  final String entityId;
  final String? categoryId; // Catégorie associée
  final List<String> categoryIds; // Catégories associées (pour compatibilité)
  final double spentAmount; // Montant dépensé
  final double limitAmount; // Limite du budget (alias pour targetAmount)
  final String currency;
  final bool isActive;
  final AutomationRule? automationRule;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  BudgetModel({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.period,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.entityId,
    this.categoryId,
    this.categoryIds = const [],
    this.spentAmount = 0.0,
    double? limitAmount,
    this.currency = 'FCFA',
    this.isActive = true,
    this.automationRule,
    required this.startDate,
    this.endDate,
    required this.createdAt,
    required this.updatedAt,
  }) : limitAmount = limitAmount ?? targetAmount;

  // Getters utiles
  bool get isExpenseBudget => type == BudgetType.expense;
  bool get isSavingBudget => type == BudgetType.saving;
  bool get hasAutomation => automationRule?.isEnabled == true;

  double get progressPercentage {
    if (targetAmount == 0) return 0.0;
    return (currentAmount / targetAmount * 100).clamp(0.0, 100.0);
  }

  double get remainingAmount {
    if (isExpenseBudget) {
      return (targetAmount - currentAmount).clamp(0.0, double.infinity);
    } else {
      return (targetAmount - currentAmount);
    }
  }

  bool get isOverBudget => isExpenseBudget && currentAmount > targetAmount;
  bool get isUnderTarget => isSavingBudget && currentAmount < targetAmount;

  // Compatibility getters
  bool get isExceeded => isOverBudget;

  String get typeDisplayName {
    switch (type) {
      case BudgetType.expense:
        return 'Budget dépense';
      case BudgetType.saving:
        return 'Budget épargne';
    }
  }

  String get periodDisplayName {
    switch (period) {
      case BudgetPeriod.weekly:
        return 'Hebdomadaire';
      case BudgetPeriod.monthly:
        return 'Mensuel';
      case BudgetPeriod.quarterly:
        return 'Trimestriel';
      case BudgetPeriod.yearly:
        return 'Annuel';
    }
  }

  // Calcul de la période actuelle
  DateTime get currentPeriodStart {
    final now = DateTime.now();
    switch (period) {
      case BudgetPeriod.weekly:
        final weekday = now.weekday;
        return now.subtract(Duration(days: weekday - 1));
      case BudgetPeriod.monthly:
        return DateTime(now.year, now.month, 1);
      case BudgetPeriod.quarterly:
        final quarter = ((now.month - 1) ~/ 3) + 1;
        return DateTime(now.year, (quarter - 1) * 3 + 1, 1);
      case BudgetPeriod.yearly:
        return DateTime(now.year, 1, 1);
    }
  }

  DateTime get currentPeriodEnd {
    final now = DateTime.now();
    switch (period) {
      case BudgetPeriod.weekly:
        final weekday = now.weekday;
        return now.add(Duration(days: 7 - weekday));
      case BudgetPeriod.monthly:
        return DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));
      case BudgetPeriod.quarterly:
        final quarter = ((now.month - 1) ~/ 3) + 1;
        return DateTime(now.year, quarter * 3 + 1, 1).subtract(const Duration(days: 1));
      case BudgetPeriod.yearly:
        return DateTime(now.year + 1, 1, 1).subtract(const Duration(days: 1));
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'period': period.name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'spentAmount': spentAmount,
      'limitAmount': limitAmount,
      'entityId': entityId,
      'categoryId': categoryId,
      'categoryIds': categoryIds,
      'currency': currency,
      'isActive': isActive,
      'automationRule': automationRule?.toJson(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      type: BudgetType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => BudgetType.expense,
      ),
      period: BudgetPeriod.values.firstWhere(
        (e) => e.name == json['period'],
        orElse: () => BudgetPeriod.monthly,
      ),
      targetAmount: (json['targetAmount'] ?? 0.0).toDouble(),
      currentAmount: (json['currentAmount'] ?? 0.0).toDouble(),
      spentAmount: (json['spentAmount'] ?? 0.0).toDouble(),
      limitAmount: (json['limitAmount'] ?? json['targetAmount'] ?? 0.0).toDouble(),
      entityId: json['entityId'] ?? '',
      categoryId: json['categoryId'],
      categoryIds: List<String>.from(json['categoryIds'] ?? []),
      currency: json['currency'] ?? 'FCFA',
      isActive: json['isActive'] ?? true,
      automationRule: json['automationRule'] != null
          ? AutomationRule.fromJson(json['automationRule'])
          : null,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  factory BudgetModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BudgetModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      type: BudgetType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => BudgetType.expense,
      ),
      period: BudgetPeriod.values.firstWhere(
        (e) => e.name == data['period'],
        orElse: () => BudgetPeriod.monthly,
      ),
      targetAmount: (data['targetAmount'] ?? 0.0).toDouble(),
      currentAmount: (data['currentAmount'] ?? 0.0).toDouble(),
      spentAmount: (data['spentAmount'] ?? 0.0).toDouble(),
      limitAmount: (data['limitAmount'] ?? data['targetAmount'] ?? 0.0).toDouble(),
      entityId: data['entityId'] ?? '',
      categoryId: data['categoryId'],
      categoryIds: List<String>.from(data['categoryIds'] ?? []),
      currency: data['currency'] ?? 'FCFA',
      isActive: data['isActive'] ?? true,
      automationRule: data['automationRule'] != null
          ? AutomationRule.fromJson(data['automationRule'])
          : null,
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'type': type.name,
      'period': period.name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'spentAmount': spentAmount,
      'limitAmount': limitAmount,
      'entityId': entityId,
      'categoryId': categoryId,
      'categoryIds': categoryIds,
      'currency': currency,
      'isActive': isActive,
      'automationRule': automationRule?.toJson(),
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  BudgetModel copyWith({
    String? id,
    String? name,
    String? description,
    BudgetType? type,
    BudgetPeriod? period,
    double? targetAmount,
    double? currentAmount,
    double? spentAmount,
    double? limitAmount,
    String? entityId,
    String? categoryId,
    List<String>? categoryIds,
    String? currency,
    bool? isActive,
    AutomationRule? automationRule,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      period: period ?? this.period,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      limitAmount: limitAmount ?? this.limitAmount,
      entityId: entityId ?? this.entityId,
      categoryId: categoryId ?? this.categoryId,
      categoryIds: categoryIds ?? this.categoryIds,
      currency: currency ?? this.currency,
      isActive: isActive ?? this.isActive,
      automationRule: automationRule ?? this.automationRule,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'BudgetModel(id: $id, name: $name, type: $type, targetAmount: $targetAmount, currentAmount: $currentAmount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BudgetModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}