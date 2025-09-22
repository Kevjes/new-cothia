import 'currency.dart';

enum RuleFrequency {
  onEachTransaction('on_each_transaction', 'À chaque transaction'),
  daily('daily', 'Quotidien'),
  weekly('weekly', 'Hebdomadaire'),
  monthly('monthly', 'Mensuel'),
  custom('custom', 'Personnalisé');

  const RuleFrequency(this.code, this.label);
  final String code;
  final String label;

  static RuleFrequency fromString(String value) {
    return RuleFrequency.values.firstWhere(
      (frequency) => frequency.code == value,
      orElse: () => RuleFrequency.onEachTransaction,
    );
  }
}

enum RuleCondition {
  allTransactions('all_transactions', 'Toutes les transactions'),
  incomeOnly('income_only', 'Revenus seulement'),
  expenseOnly('expense_only', 'Dépenses seulement'),
  specificCategory('specific_category', 'Catégorie spécifique'),
  amountThreshold('amount_threshold', 'Seuil de montant');

  const RuleCondition(this.code, this.label);
  final String code;
  final String label;

  static RuleCondition fromString(String value) {
    return RuleCondition.values.firstWhere(
      (condition) => condition.code == value,
      orElse: () => RuleCondition.allTransactions,
    );
  }
}

enum TransferType {
  fixedAmount('fixed_amount', 'Montant fixe'),
  percentage('percentage', 'Pourcentage');

  const TransferType(this.code, this.label);
  final String code;
  final String label;

  static TransferType fromString(String value) {
    return TransferType.values.firstWhere(
      (type) => type.code == value,
      orElse: () => TransferType.fixedAmount,
    );
  }
}

class TransferRuleModel {
  final String id;
  final String name;
  final String? description;
  final String fromAccountId;
  final String toAccountId;
  final RuleFrequency frequency;
  final RuleCondition condition;
  final TransferType transferType;
  final double value; // Montant fixe ou pourcentage
  final Currency currency;
  final List<String>? categoryIds; // Pour la condition specific_category
  final double? amountThreshold; // Pour la condition amount_threshold
  final DateTime? lastExecuted;
  final DateTime? nextExecution;
  final int executionCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;
  final bool isActive;
  final Map<String, dynamic>? metadata;

  TransferRuleModel({
    required this.id,
    required this.name,
    this.description,
    required this.fromAccountId,
    required this.toAccountId,
    required this.frequency,
    required this.condition,
    required this.transferType,
    required this.value,
    required this.currency,
    this.categoryIds,
    this.amountThreshold,
    this.lastExecuted,
    this.nextExecution,
    this.executionCount = 0,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    this.isActive = true,
    this.metadata,
  });

  factory TransferRuleModel.fromJson(Map<String, dynamic> json) {
    return TransferRuleModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      fromAccountId: json['fromAccountId'] ?? '',
      toAccountId: json['toAccountId'] ?? '',
      frequency: RuleFrequency.fromString(json['frequency'] ?? 'on_each_transaction'),
      condition: RuleCondition.fromString(json['condition'] ?? 'all_transactions'),
      transferType: TransferType.fromString(json['transferType'] ?? 'fixed_amount'),
      value: (json['value'] ?? 0.0).toDouble(),
      currency: Currency.fromString(json['currency'] ?? 'FCFA'),
      categoryIds: json['categoryIds'] != null ? List<String>.from(json['categoryIds']) : null,
      amountThreshold: json['amountThreshold']?.toDouble(),
      lastExecuted: json['lastExecuted'] != null ? DateTime.parse(json['lastExecuted']) : null,
      nextExecution: json['nextExecution'] != null ? DateTime.parse(json['nextExecution']) : null,
      executionCount: json['executionCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      userId: json['userId'] ?? '',
      isActive: json['isActive'] ?? true,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'fromAccountId': fromAccountId,
      'toAccountId': toAccountId,
      'frequency': frequency.code,
      'condition': condition.code,
      'transferType': transferType.code,
      'value': value,
      'currency': currency.code,
      'categoryIds': categoryIds,
      'amountThreshold': amountThreshold,
      'lastExecuted': lastExecuted?.toIso8601String(),
      'nextExecution': nextExecution?.toIso8601String(),
      'executionCount': executionCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'userId': userId,
      'isActive': isActive,
      'metadata': metadata,
    };
  }

  TransferRuleModel copyWith({
    String? id,
    String? name,
    String? description,
    String? fromAccountId,
    String? toAccountId,
    RuleFrequency? frequency,
    RuleCondition? condition,
    TransferType? transferType,
    double? value,
    Currency? currency,
    List<String>? categoryIds,
    double? amountThreshold,
    DateTime? lastExecuted,
    DateTime? nextExecution,
    int? executionCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return TransferRuleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      fromAccountId: fromAccountId ?? this.fromAccountId,
      toAccountId: toAccountId ?? this.toAccountId,
      frequency: frequency ?? this.frequency,
      condition: condition ?? this.condition,
      transferType: transferType ?? this.transferType,
      value: value ?? this.value,
      currency: currency ?? this.currency,
      categoryIds: categoryIds ?? this.categoryIds,
      amountThreshold: amountThreshold ?? this.amountThreshold,
      lastExecuted: lastExecuted ?? this.lastExecuted,
      nextExecution: nextExecution ?? this.nextExecution,
      executionCount: executionCount ?? this.executionCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }

  String get formattedValue {
    switch (transferType) {
      case TransferType.fixedAmount:
        return currency.formatAmount(value);
      case TransferType.percentage:
        return '${value.toStringAsFixed(1)}%';
    }
  }

  double calculateTransferAmount(double transactionAmount) {
    switch (transferType) {
      case TransferType.fixedAmount:
        return value;
      case TransferType.percentage:
        return transactionAmount * (value / 100);
    }
  }

  bool shouldExecuteForTransaction(double transactionAmount, String? categoryId) {
    switch (condition) {
      case RuleCondition.allTransactions:
        return true;
      case RuleCondition.incomeOnly:
        return true; // À vérifier dans le contexte
      case RuleCondition.expenseOnly:
        return true; // À vérifier dans le contexte
      case RuleCondition.specificCategory:
        return categoryIds?.contains(categoryId) ?? false;
      case RuleCondition.amountThreshold:
        return amountThreshold != null && transactionAmount >= amountThreshold!;
    }
  }

  @override
  String toString() {
    return 'TransferRuleModel(id: $id, name: $name, value: $formattedValue, frequency: ${frequency.label})';
  }
}