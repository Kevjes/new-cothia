import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TaskCategoryModel {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final IconData icon;
  final Color color;
  final bool isDefault;
  final String entityId; // Appartient à une entité
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskCategoryModel({
    required this.id,
    this.userId = '',
    required this.name,
    this.description,
    this.icon = Icons.category,
    this.color = Colors.blue,
    this.isDefault = false,
    required this.entityId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Catégories par défaut
  static List<TaskCategoryModel> getDefaultCategories(String entityId, {String userId = ''}) {
    final now = DateTime.now();
    return [
      TaskCategoryModel(
        id: 'work',
        userId: userId,
        name: 'Travail',
        description: 'Tâches professionnelles',
        icon: Icons.work,
        color: Colors.blue,
        isDefault: true,
        entityId: entityId,
        createdAt: now,
        updatedAt: now,
      ),
      TaskCategoryModel(
        id: 'personal',
        userId: userId,
        name: 'Personnel',
        description: 'Tâches personnelles',
        icon: Icons.person,
        color: Colors.green,
        isDefault: true,
        entityId: entityId,
        createdAt: now,
        updatedAt: now,
      ),
      TaskCategoryModel(
        id: 'health',
        userId: userId,
        name: 'Santé',
        description: 'Tâches liées à la santé',
        icon: Icons.health_and_safety,
        color: Colors.red,
        isDefault: true,
        entityId: entityId,
        createdAt: now,
        updatedAt: now,
      ),
      TaskCategoryModel(
        id: 'education',
        userId: userId,
        name: 'Éducation',
        description: 'Apprentissage et formation',
        icon: Icons.school,
        color: Colors.purple,
        isDefault: true,
        entityId: entityId,
        createdAt: now,
        updatedAt: now,
      ),
      TaskCategoryModel(
        id: 'family',
        userId: userId,
        name: 'Famille',
        description: 'Tâches familiales',
        icon: Icons.family_restroom,
        color: Colors.orange,
        isDefault: true,
        entityId: entityId,
        createdAt: now,
        updatedAt: now,
      ),
      TaskCategoryModel(
        id: 'household',
        userId: userId,
        name: 'Maison',
        description: 'Tâches ménagères',
        icon: Icons.home,
        color: Colors.brown,
        isDefault: true,
        entityId: entityId,
        createdAt: now,
        updatedAt: now,
      ),
      TaskCategoryModel(
        id: 'finance',
        userId: userId,
        name: 'Finances',
        description: 'Gestion financière',
        icon: Icons.attach_money,
        color: Colors.teal,
        isDefault: true,
        entityId: entityId,
        createdAt: now,
        updatedAt: now,
      ),
      TaskCategoryModel(
        id: 'social',
        userId: userId,
        name: 'Social',
        description: 'Relations sociales',
        icon: Icons.people,
        color: Colors.pink,
        isDefault: true,
        entityId: entityId,
        createdAt: now,
        updatedAt: now,
      ),
      TaskCategoryModel(
        id: 'shopping',
        userId: userId,
        name: 'Achats',
        description: 'Courses et achats',
        icon: Icons.shopping_cart,
        color: Colors.indigo,
        isDefault: true,
        entityId: entityId,
        createdAt: now,
        updatedAt: now,
      ),
      TaskCategoryModel(
        id: 'other',
        userId: userId,
        name: 'Autre',
        description: 'Autres tâches',
        icon: Icons.more_horiz,
        color: Colors.grey,
        isDefault: true,
        entityId: entityId,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  // Conversion JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'icon': icon.codePoint,
      'color': color.value,
      'isDefault': isDefault,
      'entityId': entityId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  static TaskCategoryModel fromJson(Map<String, dynamic> json) {
    return TaskCategoryModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      icon: IconData(json['icon'] ?? Icons.category.codePoint, fontFamily: 'MaterialIcons'),
      color: Color(json['color'] ?? Colors.blue.value),
      isDefault: json['isDefault'] ?? false,
      entityId: json['entityId'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt']),
    );
  }

  // Méthode copyWith
  TaskCategoryModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    IconData? icon,
    Color? color,
    bool? isDefault,
    String? entityId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskCategoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      entityId: entityId ?? this.entityId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskCategoryModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  // Méthodes Firebase
  Map<String, dynamic> toFirestore() {
    return toJson();
  }

  static TaskCategoryModel fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return fromJson(data);
  }

  @override
  String toString() {
    return 'TaskCategoryModel{id: $id, name: $name}';
  }
}