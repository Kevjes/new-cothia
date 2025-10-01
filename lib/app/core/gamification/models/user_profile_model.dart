import 'package:cloud_firestore/cloud_firestore.dart';

enum UserLevel {
  novice,
  apprentice,
  expert,
  master,
  legend
}

class UserProfile {
  final String id;
  final String userId;
  final int totalPoints;
  final UserLevel level;
  final int currentLevelPoints;
  final int nextLevelPoints;
  final List<String> unlockedAchievements;
  final List<String> activeChallenge;
  final Map<String, int> categoryStats;
  final DateTime? lastActivityDate;
  final int streakDays;
  final bool isPremium;
  final Map<String, bool> unlockedFeatures;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.userId,
    this.totalPoints = 0,
    this.level = UserLevel.novice,
    this.currentLevelPoints = 0,
    this.nextLevelPoints = 100,
    this.unlockedAchievements = const [],
    this.activeChallenge = const [],
    this.categoryStats = const {},
    this.lastActivityDate,
    this.streakDays = 0,
    this.isPremium = false,
    this.unlockedFeatures = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  double get levelProgress => nextLevelPoints > 0 ? (currentLevelPoints / nextLevelPoints).clamp(0.0, 1.0) : 0.0;

  int get totalAchievements => unlockedAchievements.length;
  int get activeChallengesCount => activeChallenge.length;

  bool hasUnlockedFeature(String featureId) {
    return unlockedFeatures[featureId] ?? false;
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      totalPoints: map['totalPoints'] ?? 0,
      level: UserLevel.values.firstWhere(
        (e) => e.toString() == 'UserLevel.${map['level']}',
        orElse: () => UserLevel.novice,
      ),
      currentLevelPoints: map['currentLevelPoints'] ?? 0,
      nextLevelPoints: map['nextLevelPoints'] ?? 100,
      unlockedAchievements: List<String>.from(map['unlockedAchievements'] ?? []),
      activeChallenge: List<String>.from(map['activeChallenge'] ?? []),
      categoryStats: Map<String, int>.from(map['categoryStats'] ?? {}),
      lastActivityDate: map['lastActivityDate'] != null
          ? (map['lastActivityDate'] as Timestamp).toDate()
          : null,
      streakDays: map['streakDays'] ?? 0,
      isPremium: map['isPremium'] ?? false,
      unlockedFeatures: Map<String, bool>.from(map['unlockedFeatures'] ?? {}),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'totalPoints': totalPoints,
      'level': level.toString().split('.').last,
      'currentLevelPoints': currentLevelPoints,
      'nextLevelPoints': nextLevelPoints,
      'unlockedAchievements': unlockedAchievements,
      'activeChallenge': activeChallenge,
      'categoryStats': categoryStats,
      'lastActivityDate': lastActivityDate != null ? Timestamp.fromDate(lastActivityDate!) : null,
      'streakDays': streakDays,
      'isPremium': isPremium,
      'unlockedFeatures': unlockedFeatures,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserProfile copyWith({
    String? id,
    String? userId,
    int? totalPoints,
    UserLevel? level,
    int? currentLevelPoints,
    int? nextLevelPoints,
    List<String>? unlockedAchievements,
    List<String>? activeChallenge,
    Map<String, int>? categoryStats,
    DateTime? lastActivityDate,
    int? streakDays,
    bool? isPremium,
    Map<String, bool>? unlockedFeatures,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      totalPoints: totalPoints ?? this.totalPoints,
      level: level ?? this.level,
      currentLevelPoints: currentLevelPoints ?? this.currentLevelPoints,
      nextLevelPoints: nextLevelPoints ?? this.nextLevelPoints,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      activeChallenge: activeChallenge ?? this.activeChallenge,
      categoryStats: categoryStats ?? this.categoryStats,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      streakDays: streakDays ?? this.streakDays,
      isPremium: isPremium ?? this.isPremium,
      unlockedFeatures: unlockedFeatures ?? this.unlockedFeatures,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static UserProfile createDefault(String userId) {
    final now = DateTime.now();
    return UserProfile(
      id: '',
      userId: userId,
      totalPoints: 0,
      level: UserLevel.novice,
      currentLevelPoints: 0,
      nextLevelPoints: 100,
      unlockedAchievements: [],
      activeChallenge: [],
      categoryStats: {
        'finance': 0,
        'tasks': 0,
        'habits': 0,
        'general': 0,
      },
      lastActivityDate: now,
      streakDays: 1,
      isPremium: false,
      unlockedFeatures: {
        'basic_dashboard': true,
        'basic_tracking': true,
      },
      createdAt: now,
      updatedAt: now,
    );
  }
}