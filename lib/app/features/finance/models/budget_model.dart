import 'currency.dart';

enum BudgetType {
  budget('budget', 'Budget'),
  objective('objective', 'Objectif');

  const BudgetType(this.code, this.label);
  final String code;
  final String label;

  static BudgetType fromString(String value) {
    return BudgetType.values.firstWhere(
      (type) => type.code == value,
      orElse: () => BudgetType.budget,
    );
  }
}

enum BudgetPeriod {
  weekly('weekly', 'Hebdomadaire', 7),
  monthly('monthly', 'Mensuel', 30),
  quarterly('quarterly', 'Trimestriel', 90),
  yearly('yearly', 'Annuel', 365),
  custom('custom', 'Personnalisé', 0);

  const BudgetPeriod(this.code, this.label, this.days);
  final String code;
  final String label;
  final int days;

  static BudgetPeriod fromString(String value) {
    return BudgetPeriod.values.firstWhere(
      (period) => period.code == value,
      orElse: () => BudgetPeriod.monthly,
    );
  }
}

class BudgetModel {
  final String id;
  final String name;
  final String? description;
  final BudgetType type;
  final double amount;
  final double spent;
  final Currency currency;
  final BudgetPeriod period;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> categoryIds;
  final String? accountId;
  final bool isRecurrent;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;
  final bool isActive;
  final String? icon;
  final String? color;
  final Map<String, dynamic>? metadata;

  BudgetModel({
    required this.id,
    required this.name,
    this.description,
    this.type = BudgetType.budget,
    required this.amount,
    this.spent = 0.0,
    required this.currency,
    required this.period,
    required this.startDate,
    required this.endDate,
    this.categoryIds = const [],
    this.accountId,
    this.isRecurrent = false,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    this.isActive = true,
    this.icon,
    this.color,
    this.metadata,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      type: BudgetType.fromString(json['type'] ?? 'budget'),
      amount: (json['amount'] ?? 0.0).toDouble(),
      spent: (json['spent'] ?? 0.0).toDouble(),
      currency: Currency.fromString(json['currency'] ?? 'FCFA'),
      period: BudgetPeriod.fromString(json['period'] ?? 'monthly'),
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['endDate'] ?? DateTime.now().toIso8601String()),
      categoryIds: List<String>.from(json['categoryIds'] ?? []),
      accountId: json['accountId'],
      isRecurrent: json['isRecurrent'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      userId: json['userId'] ?? '',
      isActive: json['isActive'] ?? true,
      icon: json['icon'],
      color: json['color'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.code,
      'amount': amount,
      'spent': spent,
      'currency': currency.code,
      'period': period.code,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'categoryIds': categoryIds,
      'accountId': accountId,
      'isRecurrent': isRecurrent,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'userId': userId,
      'isActive': isActive,
      'icon': icon,
      'color': color,
      'metadata': metadata,
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map, String id) {
    return BudgetModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'],
      type: BudgetType.fromString(map['type'] ?? 'budget'),
      amount: (map['amount'] ?? 0.0).toDouble(),
      spent: (map['spent'] ?? 0.0).toDouble(),
      currency: map['currency'] is Map ? Currency.fromMap(map['currency']) : Currency.fromString(map['currency'] ?? 'FCFA'),
      period: BudgetPeriod.fromString(map['period'] ?? 'monthly'),
      startDate: map['startDate'] != null ? (map['startDate'].toDate() ?? DateTime.now()) : DateTime.now(),
      endDate: map['endDate'] != null ? (map['endDate'].toDate() ?? DateTime.now()) : DateTime.now(),
      categoryIds: List<String>.from(map['categoryIds'] ?? []),
      accountId: map['accountId'],
      isRecurrent: map['isRecurrent'] ?? false,
      createdAt: map['createdAt'] != null ? (map['createdAt'].toDate() ?? DateTime.now()) : DateTime.now(),
      updatedAt: map['updatedAt'] != null ? (map['updatedAt'].toDate() ?? DateTime.now()) : DateTime.now(),
      userId: map['userId'] ?? '',
      isActive: map['isActive'] ?? true,
      icon: map['icon'],
      color: map['color'],
      metadata: map['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'type': type.code,
      'amount': amount,
      'spent': spent,
      'currency': currency.toMap(),
      'period': period.code,
      'startDate': startDate,
      'endDate': endDate,
      'categoryIds': categoryIds,
      'accountId': accountId,
      'isRecurrent': isRecurrent,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'userId': userId,
      'isActive': isActive,
      'icon': icon,
      'color': color,
      'metadata': metadata,
    };
  }

  BudgetModel copyWith({
    String? id,
    String? name,
    String? description,
    BudgetType? type,
    double? amount,
    double? spent,
    Currency? currency,
    BudgetPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? categoryIds,
    String? accountId,
    bool? isRecurrent,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    bool? isActive,
    String? icon,
    String? color,
    Map<String, dynamic>? metadata,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      spent: spent ?? this.spent,
      currency: currency ?? this.currency,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      categoryIds: categoryIds ?? this.categoryIds,
      accountId: accountId ?? this.accountId,
      isRecurrent: isRecurrent ?? this.isRecurrent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      isActive: isActive ?? this.isActive,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      metadata: metadata ?? this.metadata,
    );
  }

  String get formattedAmount => currency.formatAmount(amount);
  String get formattedSpent => currency.formatAmount(spent);

  double get remainingAmount => amount - spent;
  String get formattedRemaining => currency.formatAmount(remainingAmount);

  double get spentPercentage => amount > 0 ? (spent / amount * 100).clamp(0, 100) : 0;

  bool get isOverBudget => spent > amount;
  bool get isCurrentlyActive => DateTime.now().isBefore(endDate) && DateTime.now().isAfter(startDate);

  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }

  bool get isObjective => type == BudgetType.objective;
  bool get isBudget => type == BudgetType.budget;

  String get progressText {
    if (isObjective) {
      return '$formattedSpent / $formattedAmount économisé';
    } else {
      return '$formattedSpent / $formattedAmount dépensé';
    }
  }

  String get typeLabel => type.label;

  DateTime? get nextRenewalDate {
    if (!isRecurrent) return null;

    switch (period) {
      case BudgetPeriod.weekly:
        return endDate.add(Duration(days: 7));
      case BudgetPeriod.monthly:
        return DateTime(endDate.year, endDate.month + 1, endDate.day);
      case BudgetPeriod.quarterly:
        return DateTime(endDate.year, endDate.month + 3, endDate.day);
      case BudgetPeriod.yearly:
        return DateTime(endDate.year + 1, endDate.month, endDate.day);
      case BudgetPeriod.custom:
        return null;
    }
  }

  @override
  String toString() {
    return 'BudgetModel(id: $id, name: $name, type: ${type.label}, spent: $formattedSpent/$formattedAmount)';
  }
}