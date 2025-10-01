import 'package:cloud_firestore/cloud_firestore.dart';

enum AccountType {
  checking, // Compte courant
  savings,  // Épargne
  cash,     // Espèces
  credit,   // Crédit
  virtual,  // Compte virtuel
}

class AccountModel {
  final String id;
  final String name;
  final AccountType type;
  final String entityId; // Lié à une entité
  final double initialBalance;
  final double currentBalance;
  final double projectedBalance; // Avec transactions en attente
  final String currency;
  final String? description;
  final String? bankName;
  final String? accountNumber;
  final bool isActive;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  AccountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.entityId,
    required this.initialBalance,
    required this.currentBalance,
    required this.projectedBalance,
    this.currency = 'EUR',
    this.description,
    this.bankName,
    this.accountNumber,
    this.isActive = true,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Getters utiles
  bool get isBankAccount => type == AccountType.checking || type == AccountType.savings;
  bool get isCash => type == AccountType.cash;
  bool get isVirtual => type == AccountType.virtual;
  bool get isCredit => type == AccountType.credit;

  String get typeDisplayName {
    switch (type) {
      case AccountType.checking:
        return 'Compte courant';
      case AccountType.savings:
        return 'Épargne';
      case AccountType.cash:
        return 'Espèces';
      case AccountType.credit:
        return 'Crédit';
      case AccountType.virtual:
        return 'Compte virtuel';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'entityId': entityId,
      'initialBalance': initialBalance,
      'currentBalance': currentBalance,
      'projectedBalance': projectedBalance,
      'currency': currency,
      'description': description,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'isActive': isActive,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: AccountType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AccountType.checking,
      ),
      entityId: json['entityId'] ?? '',
      initialBalance: (json['initialBalance'] ?? 0.0).toDouble(),
      currentBalance: (json['currentBalance'] ?? 0.0).toDouble(),
      projectedBalance: (json['projectedBalance'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'EUR',
      description: json['description'],
      bankName: json['bankName'],
      accountNumber: json['accountNumber'],
      isActive: json['isActive'] ?? true,
      isFavorite: json['isFavorite'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  factory AccountModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AccountModel(
      id: doc.id,
      name: data['name'] ?? '',
      type: AccountType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => AccountType.checking,
      ),
      entityId: data['entityId'] ?? '',
      initialBalance: (data['initialBalance'] ?? 0.0).toDouble(),
      currentBalance: (data['currentBalance'] ?? 0.0).toDouble(),
      projectedBalance: (data['projectedBalance'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'EUR',
      description: data['description'],
      bankName: data['bankName'],
      accountNumber: data['accountNumber'],
      isActive: data['isActive'] ?? true,
      isFavorite: data['isFavorite'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type.name,
      'entityId': entityId,
      'initialBalance': initialBalance,
      'currentBalance': currentBalance,
      'projectedBalance': projectedBalance,
      'currency': currency,
      'description': description,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'isActive': isActive,
      'isFavorite': isFavorite,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  AccountModel copyWith({
    String? id,
    String? name,
    AccountType? type,
    String? entityId,
    double? initialBalance,
    double? currentBalance,
    double? projectedBalance,
    String? currency,
    String? description,
    String? bankName,
    String? accountNumber,
    bool? isActive,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      entityId: entityId ?? this.entityId,
      initialBalance: initialBalance ?? this.initialBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      projectedBalance: projectedBalance ?? this.projectedBalance,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      isActive: isActive ?? this.isActive,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'AccountModel(id: $id, name: $name, type: $type, currentBalance: $currentBalance $currency)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AccountModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}