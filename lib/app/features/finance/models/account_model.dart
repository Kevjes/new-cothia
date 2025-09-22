import 'currency.dart';

class AccountModel {
  final String id;
  final String name;
  final String description;
  final double balance;
  final Currency currency;
  final String? color;
  final String? icon;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;
  final bool isActive;

  AccountModel({
    required this.id,
    required this.name,
    required this.description,
    required this.balance,
    required this.currency,
    this.color,
    this.icon,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    this.isActive = true,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      balance: (json['balance'] ?? 0.0).toDouble(),
      currency: Currency.fromString(json['currency'] ?? 'FCFA'),
      color: json['color'],
      icon: json['icon'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      userId: json['userId'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  factory AccountModel.fromMap(Map<String, dynamic> map, String id) {
    return AccountModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      balance: (map['balance'] ?? 0.0).toDouble(),
      currency: map['currency'] is Map ? Currency.fromMap(map['currency']) : Currency.fromString(map['currency'] ?? 'FCFA'),
      color: map['color'],
      icon: map['icon'],
      createdAt: map['createdAt'] != null ? (map['createdAt'].toDate() ?? DateTime.now()) : DateTime.now(),
      updatedAt: map['updatedAt'] != null ? (map['updatedAt'].toDate() ?? DateTime.now()) : DateTime.now(),
      userId: map['userId'] ?? '',
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'balance': balance,
      'currency': currency.code,
      'color': color,
      'icon': icon,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'userId': userId,
      'isActive': isActive,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'balance': balance,
      'currency': currency.toMap(),
      'color': color,
      'icon': icon,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'userId': userId,
      'isActive': isActive,
      'isDefault': false,
    };
  }

  AccountModel copyWith({
    String? id,
    String? name,
    String? description,
    double? balance,
    Currency? currency,
    String? color,
    String? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    bool? isActive,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      isActive: isActive ?? this.isActive,
    );
  }

  String get formattedBalance => currency.formatAmount(balance);

  @override
  String toString() {
    return 'AccountModel(id: $id, name: $name, balance: $formattedBalance)';
  }
}