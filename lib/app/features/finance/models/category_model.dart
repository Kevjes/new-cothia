import '../../../core/theme/app_colors.dart';

enum CategoryType {
  income('income', 'Revenus'),
  expense('expense', 'Dépenses');

  const CategoryType(this.code, this.label);
  final String code;
  final String label;

  static CategoryType fromString(String value) {
    return CategoryType.values.firstWhere(
      (type) => type.code == value,
      orElse: () => CategoryType.expense,
    );
  }
}

class CategoryModel {
  final String id;
  final String name;
  final String? description;
  final CategoryType type;
  final String? icon;
  final String color;
  final String? parentId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;
  final bool isActive;
  final bool isDefault;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    this.icon,
    required this.color,
    this.parentId,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    this.isActive = true,
    this.isDefault = false,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      type: CategoryType.fromString(json['type'] ?? 'expense'),
      icon: json['icon'],
      color: json['color'] ?? AppColors.primary.value.toRadixString(16),
      parentId: json['parentId'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      userId: json['userId'] ?? '',
      isActive: json['isActive'] ?? true,
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.code,
      'icon': icon,
      'color': color,
      'parentId': parentId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'userId': userId,
      'isActive': isActive,
      'isDefault': isDefault,
    };
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    CategoryType? type,
    String? icon,
    String? color,
    String? parentId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    bool? isActive,
    bool? isDefault,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      isActive: isActive ?? this.isActive,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  // Catégories par défaut
  static List<CategoryModel> get defaultIncomeCategories => [
    CategoryModel(
      id: 'income_salary',
      name: 'Salaire',
      type: CategoryType.income,
      icon: 'work',
      color: AppColors.success.value.toRadixString(16),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      userId: '',
      isDefault: true,
    ),
    CategoryModel(
      id: 'income_freelance',
      name: 'Freelance',
      type: CategoryType.income,
      icon: 'computer',
      color: AppColors.primary.value.toRadixString(16),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      userId: '',
      isDefault: true,
    ),
    CategoryModel(
      id: 'income_investment',
      name: 'Investissement',
      type: CategoryType.income,
      icon: 'trending_up',
      color: AppColors.secondary.value.toRadixString(16),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      userId: '',
      isDefault: true,
    ),
  ];

  static List<CategoryModel> get defaultExpenseCategories => [
    CategoryModel(
      id: 'expense_food',
      name: 'Alimentation',
      type: CategoryType.expense,
      icon: 'restaurant',
      color: AppColors.warning.value.toRadixString(16),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      userId: '',
      isDefault: true,
    ),
    CategoryModel(
      id: 'expense_transport',
      name: 'Transport',
      type: CategoryType.expense,
      icon: 'directions_car',
      color: AppColors.error.value.toRadixString(16),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      userId: '',
      isDefault: true,
    ),
    CategoryModel(
      id: 'expense_shopping',
      name: 'Achats',
      type: CategoryType.expense,
      icon: 'shopping_cart',
      color: AppColors.accent.value.toRadixString(16),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      userId: '',
      isDefault: true,
    ),
    CategoryModel(
      id: 'expense_health',
      name: 'Santé',
      type: CategoryType.expense,
      icon: 'local_hospital',
      color: AppColors.primaryDark.value.toRadixString(16),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      userId: '',
      isDefault: true,
    ),
  ];

  @override
  String toString() {
    return 'CategoryModel(id: $id, name: $name, type: ${type.label})';
  }
}