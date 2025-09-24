import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType {
  income,   // Entrée
  expense,  // Dépense
  transfer, // Transfert
}

extension TransactionTypeExtension on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.income:
        return 'Revenu';
      case TransactionType.expense:
        return 'Dépense';
      case TransactionType.transfer:
        return 'Transfert';
    }
  }
}

enum TransactionStatus {
  planned,   // Prévue
  pending,   // En attente
  validated, // Validée
  cancelled, // Annulée
}

extension TransactionStatusExtension on TransactionStatus {
  String get displayName {
    switch (this) {
      case TransactionStatus.planned:
        return 'Prévue';
      case TransactionStatus.pending:
        return 'En attente';
      case TransactionStatus.validated:
        return 'Validée';
      case TransactionStatus.cancelled:
        return 'Annulée';
    }
  }
}

class TransactionModel {
  final String id;
  final String title;
  final String? description;
  final double amount;
  final TransactionType type;
  final TransactionStatus status;
  final String entityId;
  final String? sourceAccountId;      // Pour dépenses et transferts
  final String? destinationAccountId; // Pour entrées et transferts
  final String? categoryId;           // Catégorie optionnelle
  final String? budgetId;            // Budget lié optionnel
  final String? projectId;           // Projet lié optionnel
  final DateTime transactionDate;
  final DateTime? scheduledDate;     // Pour transactions planifiées
  final bool isRecurring;
  final String? recurringRule;       // Règle de récurrence
  final List<String> tags;
  final Map<String, dynamic>? metadata; // Données supplémentaires
  final DateTime createdAt;
  final DateTime updatedAt;

  TransactionModel({
    required this.id,
    required this.title,
    this.description,
    required this.amount,
    required this.type,
    required this.status,
    required this.entityId,
    this.sourceAccountId,
    this.destinationAccountId,
    this.categoryId,
    this.budgetId,
    this.projectId,
    required this.transactionDate,
    this.scheduledDate,
    this.isRecurring = false,
    this.recurringRule,
    this.tags = const [],
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  // Getters utiles
  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;
  bool get isTransfer => type == TransactionType.transfer;

  bool get isPlanned => status == TransactionStatus.planned;
  bool get isPending => status == TransactionStatus.pending;
  bool get isValidated => status == TransactionStatus.validated;
  bool get isCancelled => status == TransactionStatus.cancelled;

  String get typeDisplayName {
    switch (type) {
      case TransactionType.income:
        return 'Entrée';
      case TransactionType.expense:
        return 'Dépense';
      case TransactionType.transfer:
        return 'Transfert';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case TransactionStatus.planned:
        return 'Prévue';
      case TransactionStatus.pending:
        return 'En attente';
      case TransactionStatus.validated:
        return 'Validée';
      case TransactionStatus.cancelled:
        return 'Annulée';
    }
  }

  // Validation des règles métier
  bool get isValid {
    switch (type) {
      case TransactionType.income:
        return destinationAccountId != null;
      case TransactionType.expense:
        return sourceAccountId != null;
      case TransactionType.transfer:
        return sourceAccountId != null && destinationAccountId != null;
    }
  }

  // Getter pour compatibilité
  DateTime get date => transactionDate;


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'type': type.name,
      'status': status.name,
      'entityId': entityId,
      'sourceAccountId': sourceAccountId,
      'destinationAccountId': destinationAccountId,
      'categoryId': categoryId,
      'budgetId': budgetId,
      'projectId': projectId,
      'transactionDate': transactionDate.toIso8601String(),
      'scheduledDate': scheduledDate?.toIso8601String(),
      'isRecurring': isRecurring,
      'recurringRule': recurringRule,
      'tags': tags,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      amount: (json['amount'] ?? 0.0).toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.expense,
      ),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TransactionStatus.pending,
      ),
      entityId: json['entityId'] ?? '',
      sourceAccountId: json['sourceAccountId'],
      destinationAccountId: json['destinationAccountId'],
      categoryId: json['categoryId'],
      budgetId: json['budgetId'],
      projectId: json['projectId'],
      transactionDate: json['transactionDate'] != null
          ? DateTime.parse(json['transactionDate'])
          : DateTime.now(),
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.parse(json['scheduledDate'])
          : null,
      isRecurring: json['isRecurring'] ?? false,
      recurringRule: json['recurringRule'],
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

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      amount: (data['amount'] ?? 0.0).toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => TransactionType.expense,
      ),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => TransactionStatus.pending,
      ),
      entityId: data['entityId'] ?? '',
      sourceAccountId: data['sourceAccountId'],
      destinationAccountId: data['destinationAccountId'],
      categoryId: data['categoryId'],
      budgetId: data['budgetId'],
      projectId: data['projectId'],
      transactionDate: (data['transactionDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      scheduledDate: (data['scheduledDate'] as Timestamp?)?.toDate(),
      isRecurring: data['isRecurring'] ?? false,
      recurringRule: data['recurringRule'],
      tags: List<String>.from(data['tags'] ?? []),
      metadata: data['metadata'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'amount': amount,
      'type': type.name,
      'status': status.name,
      'entityId': entityId,
      'sourceAccountId': sourceAccountId,
      'destinationAccountId': destinationAccountId,
      'categoryId': categoryId,
      'budgetId': budgetId,
      'projectId': projectId,
      'transactionDate': Timestamp.fromDate(transactionDate),
      'scheduledDate': scheduledDate != null ? Timestamp.fromDate(scheduledDate!) : null,
      'isRecurring': isRecurring,
      'recurringRule': recurringRule,
      'tags': tags,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  TransactionModel copyWith({
    String? id,
    String? title,
    String? description,
    double? amount,
    TransactionType? type,
    TransactionStatus? status,
    String? entityId,
    String? sourceAccountId,
    String? destinationAccountId,
    String? categoryId,
    String? budgetId,
    String? projectId,
    DateTime? transactionDate,
    DateTime? scheduledDate,
    bool? isRecurring,
    String? recurringRule,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      status: status ?? this.status,
      entityId: entityId ?? this.entityId,
      sourceAccountId: sourceAccountId ?? this.sourceAccountId,
      destinationAccountId: destinationAccountId ?? this.destinationAccountId,
      categoryId: categoryId ?? this.categoryId,
      budgetId: budgetId ?? this.budgetId,
      projectId: projectId ?? this.projectId,
      transactionDate: transactionDate ?? this.transactionDate,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringRule: recurringRule ?? this.recurringRule,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'TransactionModel(id: $id, title: $title, amount: $amount, type: $type, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}