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

enum TransactionStatus {
  pending('pending', 'En attente', 'Transaction en cours de traitement'),
  completed('completed', 'Terminée', 'Transaction finalisée'),
  cancelled('cancelled', 'Annulée', 'Transaction annulée'),
  failed('failed', 'Échouée', 'Transaction échouée');

  const TransactionStatus(this.code, this.label, this.description);
  final String code;
  final String label;
  final String description;

  static TransactionStatus fromString(String value) {
    return TransactionStatus.values.firstWhere(
      (status) => status.code == value,
      orElse: () => TransactionStatus.completed,
    );
  }
}

enum TransactionRecurrence {
  none('none', 'Aucune'),
  daily('daily', 'Quotidienne'),
  weekly('weekly', 'Hebdomadaire'),
  monthly('monthly', 'Mensuelle'),
  quarterly('quarterly', 'Trimestrielle'),
  yearly('yearly', 'Annuelle');

  const TransactionRecurrence(this.code, this.label);
  final String code;
  final String label;

  static TransactionRecurrence fromString(String value) {
    return TransactionRecurrence.values.firstWhere(
      (recurrence) => recurrence.code == value,
      orElse: () => TransactionRecurrence.none,
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
  final TransactionStatus status;
  final String accountId;
  final String? toAccountId; // Pour les transferts
  final String? categoryId;
  final String? budgetId;
  final DateTime date; // Date et heure de la transaction
  final TransactionRecurrence recurrence;
  final DateTime? scheduledDate; // Pour les transactions programmées
  final String? receiptUrl; // URL du reçu/justificatif
  final List<String> tags; // Tags pour organisation
  final double? latitude; // Géolocalisation
  final double? longitude;
  final String? location; // Nom du lieu
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
    this.status = TransactionStatus.completed,
    required this.accountId,
    this.toAccountId,
    this.categoryId,
    this.budgetId,
    required this.date,
    this.recurrence = TransactionRecurrence.none,
    this.scheduledDate,
    this.receiptUrl,
    this.tags = const [],
    this.latitude,
    this.longitude,
    this.location,
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
      status: TransactionStatus.fromString(json['status'] ?? 'completed'),
      accountId: json['accountId'] ?? '',
      toAccountId: json['toAccountId'],
      categoryId: json['categoryId'],
      budgetId: json['budgetId'],
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      recurrence: TransactionRecurrence.fromString(json['recurrence'] ?? 'none'),
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.parse(json['scheduledDate'])
          : null,
      receiptUrl: json['receiptUrl'],
      tags: json['tags'] != null
          ? List<String>.from(json['tags'])
          : [],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      location: json['location'],
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
      'status': status.code,
      'accountId': accountId,
      'toAccountId': toAccountId,
      'categoryId': categoryId,
      'budgetId': budgetId,
      'date': date.toIso8601String(),
      'recurrence': recurrence.code,
      'scheduledDate': scheduledDate?.toIso8601String(),
      'receiptUrl': receiptUrl,
      'tags': tags,
      'latitude': latitude,
      'longitude': longitude,
      'location': location,
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
    TransactionStatus? status,
    String? accountId,
    String? toAccountId,
    String? categoryId,
    String? budgetId,
    DateTime? date,
    TransactionRecurrence? recurrence,
    DateTime? scheduledDate,
    String? receiptUrl,
    List<String>? tags,
    double? latitude,
    double? longitude,
    String? location,
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
      status: status ?? this.status,
      accountId: accountId ?? this.accountId,
      toAccountId: toAccountId ?? this.toAccountId,
      categoryId: categoryId ?? this.categoryId,
      budgetId: budgetId ?? this.budgetId,
      date: date ?? this.date,
      recurrence: recurrence ?? this.recurrence,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      tags: tags ?? this.tags,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      location: location ?? this.location,
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

  bool get isPending => status == TransactionStatus.pending;
  bool get isCompleted => status == TransactionStatus.completed;
  bool get isFailed => status == TransactionStatus.failed;
  bool get isCancelled => status == TransactionStatus.cancelled;

  bool get isRecurring => recurrence != TransactionRecurrence.none;
  bool get isScheduled => scheduledDate != null;
  bool get hasReceipt => receiptUrl != null && receiptUrl!.isNotEmpty;
  bool get hasLocation => latitude != null && longitude != null;
  bool get isLinkedToBudget => budgetId != null && budgetId!.isNotEmpty;

  String get statusDisplay {
    switch (status) {
      case TransactionStatus.pending:
        return '⏳ ${status.label}';
      case TransactionStatus.completed:
        return '✅ ${status.label}';
      case TransactionStatus.cancelled:
        return '❌ ${status.label}';
      case TransactionStatus.failed:
        return '⚠️ ${status.label}';
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'À l\'instant';
    }
  }

  @override
  String toString() {
    return 'TransactionModel(id: $id, title: $title, amount: $displayAmount, type: ${type.label}, status: ${status.label})';
  }
}