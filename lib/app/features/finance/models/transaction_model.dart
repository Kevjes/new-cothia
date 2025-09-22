import 'currency.dart';

enum TransactionType {
  income('income', 'Entrée'),
  expense('expense', 'Sortie'),
  transfer('transfer', 'Transfert');

  const TransactionType(this.code, this.label);
  final String code;
  final String label;

  static TransactionType fromString(String value) {
    return TransactionType.values.firstWhere(
      (type) => type.code == value,
      orElse: () => TransactionType.expense,
    );
  }
}

class TransactionModel {
  final String id;
  final String title;
  final String? description;
  final double amount;
  final Currency currency;
  final TransactionType type;
  final String accountId;
  final String? toAccountId; // Pour les transferts
  final String? categoryId;
  final String? budgetId;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;
  final Map<String, dynamic>? metadata;

  TransactionModel({
    required this.id,
    required this.title,
    this.description,
    required this.amount,
    required this.currency,
    required this.type,
    required this.accountId,
    this.toAccountId,
    this.categoryId,
    this.budgetId,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    this.metadata,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      amount: (json['amount'] ?? 0.0).toDouble(),
      currency: Currency.fromString(json['currency'] ?? 'FCFA'),
      type: TransactionType.fromString(json['type'] ?? 'expense'),
      accountId: json['accountId'] ?? '',
      toAccountId: json['toAccountId'],
      categoryId: json['categoryId'],
      budgetId: json['budgetId'],
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      userId: json['userId'] ?? '',
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'currency': currency.code,
      'type': type.code,
      'accountId': accountId,
      'toAccountId': toAccountId,
      'categoryId': categoryId,
      'budgetId': budgetId,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'userId': userId,
      'metadata': metadata,
    };
  }

  TransactionModel copyWith({
    String? id,
    String? title,
    String? description,
    double? amount,
    Currency? currency,
    TransactionType? type,
    String? accountId,
    String? toAccountId,
    String? categoryId,
    String? budgetId,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    Map<String, dynamic>? metadata,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      type: type ?? this.type,
      accountId: accountId ?? this.accountId,
      toAccountId: toAccountId ?? this.toAccountId,
      categoryId: categoryId ?? this.categoryId,
      budgetId: budgetId ?? this.budgetId,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      metadata: metadata ?? this.metadata,
    );
  }

  String get formattedAmount => currency.formatAmount(amount);

  String get displayAmount {
    switch (type) {
      case TransactionType.income:
        return '+${formattedAmount}';
      case TransactionType.expense:
        return '-${formattedAmount}';
      case TransactionType.transfer:
        return formattedAmount;
    }
  }

  @override
  String toString() {
    return 'TransactionModel(id: $id, title: $title, amount: $displayAmount, type: ${type.label})';
  }
}