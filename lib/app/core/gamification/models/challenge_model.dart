import 'package:cloud_firestore/cloud_firestore.dart';

enum ChallengeType {
  daily,
  weekly,
  monthly,
  streak,
  milestone
}

enum ChallengeStatus {
  active,
  completed,
  failed,
  expired
}

class Challenge {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final ChallengeType type;
  final ChallengeStatus status;
  final Map<String, dynamic> criteria;
  final int pointsReward;
  final DateTime startDate;
  final DateTime endDate;
  final int progress;
  final int maxProgress;
  final bool isPremium;
  final List<String> participants;
  final Map<String, dynamic> metadata;

  Challenge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.type,
    this.status = ChallengeStatus.active,
    required this.criteria,
    required this.pointsReward,
    required this.startDate,
    required this.endDate,
    this.progress = 0,
    required this.maxProgress,
    this.isPremium = false,
    this.participants = const [],
    this.metadata = const {},
  });

  bool get isActive => status == ChallengeStatus.active && DateTime.now().isBefore(endDate);
  bool get isCompleted => status == ChallengeStatus.completed;
  bool get isExpired => DateTime.now().isAfter(endDate);
  double get progressPercentage => maxProgress > 0 ? (progress / maxProgress).clamp(0.0, 1.0) : 0.0;

  Duration get timeRemaining {
    if (isExpired) return Duration.zero;
    return endDate.difference(DateTime.now());
  }

  String get timeRemainingText {
    final remaining = timeRemaining;
    if (remaining.inDays > 0) {
      return '${remaining.inDays}j restants';
    } else if (remaining.inHours > 0) {
      return '${remaining.inHours}h restantes';
    } else if (remaining.inMinutes > 0) {
      return '${remaining.inMinutes}min restantes';
    } else {
      return 'Expiré';
    }
  }

  factory Challenge.fromMap(Map<String, dynamic> map) {
    return Challenge(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      iconPath: map['iconPath'] ?? '',
      type: ChallengeType.values.firstWhere(
        (e) => e.toString() == 'ChallengeType.${map['type']}',
        orElse: () => ChallengeType.daily,
      ),
      status: ChallengeStatus.values.firstWhere(
        (e) => e.toString() == 'ChallengeStatus.${map['status']}',
        orElse: () => ChallengeStatus.active,
      ),
      criteria: Map<String, dynamic>.from(map['criteria'] ?? {}),
      pointsReward: map['pointsReward'] ?? 0,
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      progress: map['progress'] ?? 0,
      maxProgress: map['maxProgress'] ?? 1,
      isPremium: map['isPremium'] ?? false,
      participants: List<String>.from(map['participants'] ?? []),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconPath': iconPath,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'criteria': criteria,
      'pointsReward': pointsReward,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'progress': progress,
      'maxProgress': maxProgress,
      'isPremium': isPremium,
      'participants': participants,
      'metadata': metadata,
    };
  }

  Challenge copyWith({
    String? id,
    String? name,
    String? description,
    String? iconPath,
    ChallengeType? type,
    ChallengeStatus? status,
    Map<String, dynamic>? criteria,
    int? pointsReward,
    DateTime? startDate,
    DateTime? endDate,
    int? progress,
    int? maxProgress,
    bool? isPremium,
    List<String>? participants,
    Map<String, dynamic>? metadata,
  }) {
    return Challenge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconPath: iconPath ?? this.iconPath,
      type: type ?? this.type,
      status: status ?? this.status,
      criteria: criteria ?? this.criteria,
      pointsReward: pointsReward ?? this.pointsReward,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      progress: progress ?? this.progress,
      maxProgress: maxProgress ?? this.maxProgress,
      isPremium: isPremium ?? this.isPremium,
      participants: participants ?? this.participants,
      metadata: metadata ?? this.metadata,
    );
  }
}