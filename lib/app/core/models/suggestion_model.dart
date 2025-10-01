/// Modèle pour les suggestions intelligentes du système
class SuggestionModel {
  final String id;
  final SuggestionType type;
  final SuggestionPriority priority;
  final String title;
  final String description;
  final SuggestionAction action;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime? expiresAt;

  SuggestionModel({
    required this.id,
    required this.type,
    required this.priority,
    required this.title,
    required this.description,
    required this.action,
    required this.metadata,
    DateTime? createdAt,
    this.expiresAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory SuggestionModel.fromJson(Map<String, dynamic> json) {
    return SuggestionModel(
      id: json['id'],
      type: SuggestionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SuggestionType.general,
      ),
      priority: SuggestionPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => SuggestionPriority.medium,
      ),
      title: json['title'],
      description: json['description'],
      action: SuggestionAction.fromJson(json['action']),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'priority': priority.name,
      'title': title,
      'description': description,
      'action': action.toJson(),
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  SuggestionModel copyWith({
    String? id,
    SuggestionType? type,
    SuggestionPriority? priority,
    String? title,
    String? description,
    SuggestionAction? action,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return SuggestionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      title: title ?? this.title,
      description: description ?? this.description,
      action: action ?? this.action,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  String toString() {
    return 'SuggestionModel(id: $id, type: $type, priority: $priority, title: $title)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SuggestionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Types de suggestions
enum SuggestionType {
  financial('financial', 'Financier', '💰'),
  productivity('productivity', 'Productivité', '⚡'),
  habit('habit', 'Habitudes', '🎯'),
  crossModule('cross_module', 'Inter-modules', '🔗'),
  general('general', 'Général', 'ℹ️');

  const SuggestionType(this.key, this.displayName, this.emoji);

  final String key;
  final String displayName;
  final String emoji;
}

/// Priorités des suggestions
enum SuggestionPriority {
  low('low', 'Faible', 0),
  medium('medium', 'Moyenne', 1),
  high('high', 'Élevée', 2),
  critical('critical', 'Critique', 3);

  const SuggestionPriority(this.key, this.displayName, this.level);

  final String key;
  final String displayName;
  final int level;
}

/// Action associée à une suggestion
class SuggestionAction {
  final ActionType type;
  final String route;
  final String label;
  final Map<String, dynamic>? parameters;

  SuggestionAction({
    required this.type,
    required this.route,
    required this.label,
    this.parameters,
  });

  factory SuggestionAction.fromJson(Map<String, dynamic> json) {
    return SuggestionAction(
      type: ActionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ActionType.navigation,
      ),
      route: json['route'],
      label: json['label'],
      parameters: json['parameters'] != null
        ? Map<String, dynamic>.from(json['parameters'])
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'route': route,
      'label': label,
      'parameters': parameters,
    };
  }

  SuggestionAction copyWith({
    ActionType? type,
    String? route,
    String? label,
    Map<String, dynamic>? parameters,
  }) {
    return SuggestionAction(
      type: type ?? this.type,
      route: route ?? this.route,
      label: label ?? this.label,
      parameters: parameters ?? this.parameters,
    );
  }

  @override
  String toString() {
    return 'SuggestionAction(type: $type, route: $route, label: $label)';
  }
}

/// Types d'actions pour les suggestions
enum ActionType {
  navigation('navigation', 'Navigation'),
  automation('automation', 'Automatisation'),
  reminder('reminder', 'Rappel');

  const ActionType(this.key, this.displayName);

  final String key;
  final String displayName;
}

/// Résultat d'une suggestion appliquée
class SuggestionResult {
  final String suggestionId;
  final bool success;
  final String? message;
  final DateTime appliedAt;
  final Map<String, dynamic>? resultData;

  SuggestionResult({
    required this.suggestionId,
    required this.success,
    this.message,
    DateTime? appliedAt,
    this.resultData,
  }) : appliedAt = appliedAt ?? DateTime.now();

  factory SuggestionResult.fromJson(Map<String, dynamic> json) {
    return SuggestionResult(
      suggestionId: json['suggestionId'],
      success: json['success'],
      message: json['message'],
      appliedAt: DateTime.parse(json['appliedAt']),
      resultData: json['resultData'] != null
        ? Map<String, dynamic>.from(json['resultData'])
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'suggestionId': suggestionId,
      'success': success,
      'message': message,
      'appliedAt': appliedAt.toIso8601String(),
      'resultData': resultData,
    };
  }
}

/// Statistiques des suggestions
class SuggestionStats {
  final int totalSuggestions;
  final int appliedSuggestions;
  final int ignoredSuggestions;
  final Map<SuggestionType, int> suggestionsByType;
  final Map<SuggestionPriority, int> suggestionsByPriority;
  final double applicationRate;

  SuggestionStats({
    required this.totalSuggestions,
    required this.appliedSuggestions,
    required this.ignoredSuggestions,
    required this.suggestionsByType,
    required this.suggestionsByPriority,
  }) : applicationRate = totalSuggestions > 0
          ? appliedSuggestions / totalSuggestions
          : 0.0;

  factory SuggestionStats.empty() {
    return SuggestionStats(
      totalSuggestions: 0,
      appliedSuggestions: 0,
      ignoredSuggestions: 0,
      suggestionsByType: {},
      suggestionsByPriority: {},
    );
  }
}