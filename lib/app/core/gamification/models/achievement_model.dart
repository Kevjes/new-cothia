import 'package:cloud_firestore/cloud_firestore.dart';

enum AchievementType {
  badge,
  milestone,
  streak,
  challenge,
  level
}

enum AchievementCategory {
  finance,
  tasks,
  habits,
  general,
  social
}

enum AchievementDifficulty {
  bronze,
  silver,
  gold,
  platinum,
  diamond
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final AchievementType type;
  final AchievementCategory category;
  final AchievementDifficulty difficulty;
  final int pointsReward;
  final Map<String, dynamic> criteria;
  final bool isHidden;
  final bool isPremium;
  final DateTime? unlockedAt;
  final int progress;
  final int maxProgress;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.type,
    required this.category,
    required this.difficulty,
    required this.pointsReward,
    required this.criteria,
    this.isHidden = false,
    this.isPremium = false,
    this.unlockedAt,
    this.progress = 0,
    required this.maxProgress,
  });

  bool get isUnlocked => unlockedAt != null;
  bool get isCompleted => progress >= maxProgress;
  double get progressPercentage => maxProgress > 0 ? (progress / maxProgress).clamp(0.0, 1.0) : 0.0;

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      iconPath: map['iconPath'] ?? '',
      type: AchievementType.values.firstWhere(
        (e) => e.toString() == 'AchievementType.${map['type']}',
        orElse: () => AchievementType.badge,
      ),
      category: AchievementCategory.values.firstWhere(
        (e) => e.toString() == 'AchievementCategory.${map['category']}',
        orElse: () => AchievementCategory.general,
      ),
      difficulty: AchievementDifficulty.values.firstWhere(
        (e) => e.toString() == 'AchievementDifficulty.${map['difficulty']}',
        orElse: () => AchievementDifficulty.bronze,
      ),
      pointsReward: map['pointsReward'] ?? 0,
      criteria: Map<String, dynamic>.from(map['criteria'] ?? {}),
      isHidden: map['isHidden'] ?? false,
      isPremium: map['isPremium'] ?? false,
      unlockedAt: map['unlockedAt'] != null
          ? (map['unlockedAt'] as Timestamp).toDate()
          : null,
      progress: map['progress'] ?? 0,
      maxProgress: map['maxProgress'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconPath': iconPath,
      'type': type.toString().split('.').last,
      'category': category.toString().split('.').last,
      'difficulty': difficulty.toString().split('.').last,
      'pointsReward': pointsReward,
      'criteria': criteria,
      'isHidden': isHidden,
      'isPremium': isPremium,
      'unlockedAt': unlockedAt != null ? Timestamp.fromDate(unlockedAt!) : null,
      'progress': progress,
      'maxProgress': maxProgress,
    };
  }

  Achievement copyWith({
    String? id,
    String? name,
    String? description,
    String? iconPath,
    AchievementType? type,
    AchievementCategory? category,
    AchievementDifficulty? difficulty,
    int? pointsReward,
    Map<String, dynamic>? criteria,
    bool? isHidden,
    bool? isPremium,
    DateTime? unlockedAt,
    int? progress,
    int? maxProgress,
  }) {
    return Achievement(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconPath: iconPath ?? this.iconPath,
      type: type ?? this.type,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      pointsReward: pointsReward ?? this.pointsReward,
      criteria: criteria ?? this.criteria,
      isHidden: isHidden ?? this.isHidden,
      isPremium: isPremium ?? this.isPremium,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
      maxProgress: maxProgress ?? this.maxProgress,
    );
  }
}