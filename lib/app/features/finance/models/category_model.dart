import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum CategoryType {
  income,  // Revenus
  expense, // Dépenses
  both,    // Les deux
}

class CategoryModel {
  final String id;
  final String name;
  final String? description;
  final CategoryType type;
  final String entityId;
  final String? parentCategoryId; // Pour les sous-catégories
  final IconData icon;
  final Color color;
  final bool isActive;
  final bool isDefault; // Catégories par défaut du système
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.entityId,
    this.parentCategoryId,
    this.icon = Icons.category,
    this.color = Colors.blue,
    this.isActive = true,
    this.isDefault = false,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  // Getters utiles
  bool get isIncomeCategory => type == CategoryType.income || type == CategoryType.both;
  bool get isExpenseCategory => type == CategoryType.expense || type == CategoryType.both;
  bool get isSubCategory => parentCategoryId != null;
  bool get isParentCategory => parentCategoryId == null;

  String get typeDisplayName {
    switch (type) {
      case CategoryType.income:
        return 'Revenus';
      case CategoryType.expense:
        return 'Dépenses';
      case CategoryType.both:
        return 'Revenus & Dépenses';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'entityId': entityId,
      'parentCategoryId': parentCategoryId,
      'iconCodePoint': icon.codePoint,
      'colorValue': color.value,
      'isActive': isActive,
      'isDefault': isDefault,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      type: CategoryType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CategoryType.expense,
      ),
      entityId: json['entityId'] ?? '',
      parentCategoryId: json['parentCategoryId'],
      icon: IconData(
        json['iconCodePoint'] ?? Icons.category.codePoint,
        fontFamily: 'MaterialIcons',
      ),
      color: Color(json['colorValue'] ?? Colors.blue.value),
      isActive: json['isActive'] ?? true,
      isDefault: json['isDefault'] ?? false,
      sortOrder: json['sortOrder'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      type: CategoryType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => CategoryType.expense,
      ),
      entityId: data['entityId'] ?? '',
      parentCategoryId: data['parentCategoryId'],
      icon: IconData(
        data['iconCodePoint'] ?? Icons.category.codePoint,
        fontFamily: 'MaterialIcons',
      ),
      color: Color(data['colorValue'] ?? Colors.blue.value),
      isActive: data['isActive'] ?? true,
      isDefault: data['isDefault'] ?? false,
      sortOrder: data['sortOrder'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'type': type.name,
      'entityId': entityId,
      'parentCategoryId': parentCategoryId,
      'iconCodePoint': icon.codePoint,
      'colorValue': color.value,
      'isActive': isActive,
      'isDefault': isDefault,
      'sortOrder': sortOrder,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    CategoryType? type,
    String? entityId,
    String? parentCategoryId,
    IconData? icon,
    Color? color,
    bool? isActive,
    bool? isDefault,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      entityId: entityId ?? this.entityId,
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      isDefault: isDefault ?? this.isDefault,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'CategoryModel(id: $id, name: $name, type: $type, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Catégories par défaut du système
class DefaultCategories {
  static List<CategoryModel> get expenseCategories => [
    CategoryModel(
      id: 'default_alimentation',
      name: 'Alimentation',
      type: CategoryType.expense,
      entityId: '',
      icon: Icons.restaurant,
      color: Colors.orange,
      isDefault: true,
      sortOrder: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    CategoryModel(
      id: 'default_logement',
      name: 'Logement',
      type: CategoryType.expense,
      entityId: '',
      icon: Icons.home,
      color: Colors.blue,
      isDefault: true,
      sortOrder: 2,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    CategoryModel(
      id: 'default_transport',
      name: 'Transport',
      type: CategoryType.expense,
      entityId: '',
      icon: Icons.directions_car,
      color: Colors.green,
      isDefault: true,
      sortOrder: 3,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    CategoryModel(
      id: 'default_sante',
      name: 'Santé',
      type: CategoryType.expense,
      entityId: '',
      icon: Icons.local_hospital,
      color: Colors.red,
      isDefault: true,
      sortOrder: 4,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    CategoryModel(
      id: 'default_loisirs',
      name: 'Loisirs',
      type: CategoryType.expense,
      entityId: '',
      icon: Icons.sports_esports,
      color: Colors.purple,
      isDefault: true,
      sortOrder: 5,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    CategoryModel(
      id: 'default_shopping',
      name: 'Shopping',
      type: CategoryType.expense,
      entityId: '',
      icon: Icons.shopping_bag,
      color: Colors.pink,
      isDefault: true,
      sortOrder: 6,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  static List<CategoryModel> get incomeCategories => [
    CategoryModel(
      id: 'default_salaire',
      name: 'Salaire',
      type: CategoryType.income,
      entityId: '',
      icon: Icons.work,
      color: Colors.green,
      isDefault: true,
      sortOrder: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    CategoryModel(
      id: 'default_freelance',
      name: 'Freelance',
      type: CategoryType.income,
      entityId: '',
      icon: Icons.laptop,
      color: Colors.blue,
      isDefault: true,
      sortOrder: 2,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    CategoryModel(
      id: 'default_investissements',
      name: 'Investissements',
      type: CategoryType.income,
      entityId: '',
      icon: Icons.trending_up,
      color: Colors.orange,
      isDefault: true,
      sortOrder: 3,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    CategoryModel(
      id: 'default_autres_revenus',
      name: 'Autres revenus',
      type: CategoryType.income,
      entityId: '',
      icon: Icons.account_balance_wallet,
      color: Colors.teal,
      isDefault: true,
      sortOrder: 4,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];
}