import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ================================
// Enums pour les types de déclencheurs
// ================================

enum TriggerType {
  scheduled,    // Déclencheur programmé (dates/heures)
  eventBased,   // Basé sur des événements (ajout d'argent, dépense, etc.)
  categoryBased, // Basé sur des catégories spécifiques
}

enum ScheduledTriggerFrequency {
  daily,           // Quotidien
  weekly,          // Hebdomadaire
  monthly,         // Mensuel (1er du mois, date spécifique)
  multiplePerMonth, // Plusieurs fois par mois (2x, 3x, etc.)
  quarterly,       // Trimestriel
  yearly,          // Annuel
  custom,          // Personnalisé
}

enum EventTriggerType {
  moneyEntry,      // À chaque entrée d'argent
  expenseOccurred, // À chaque dépense
  salaryReceived,  // À chaque salaire reçu
  firstEntryOfMonth, // Première entrée du mois
  budgetExceeded,  // Budget dépassé
  goalReached,     // Objectif atteint
  accountBalanceThreshold, // Seuil de solde atteint
}

enum ActionType {
  transfer,        // Transfert entre comptes
  createTransaction, // Créer une transaction
  updateBudget,    // Mettre à jour un budget
  sendNotification, // Envoyer une notification
  createSavingGoal, // Créer un objectif d'épargne
}

// ================================
// Modèles pour les déclencheurs
// ================================

class ScheduledTrigger {
  final ScheduledTriggerFrequency frequency;
  final int? dayOfMonth;        // Jour du mois (1-31)
  final int? dayOfWeek;         // Jour de la semaine (1-7, lundi-dimanche)
  final List<int>? daysOfMonth; // Pour multiples jours par mois
  final int? monthsInterval;    // Intervalle en mois (pour custom)
  final TimeOfDay? executionTime; // Heure d'exécution
  final DateTime? startDate;    // Date de début
  final DateTime? endDate;      // Date de fin

  ScheduledTrigger({
    required this.frequency,
    this.dayOfMonth,
    this.dayOfWeek,
    this.daysOfMonth,
    this.monthsInterval,
    this.executionTime,
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'frequency': frequency.name,
      'dayOfMonth': dayOfMonth,
      'dayOfWeek': dayOfWeek,
      'daysOfMonth': daysOfMonth,
      'monthsInterval': monthsInterval,
      'executionTime': executionTime != null ? {
        'hour': executionTime!.hour,
        'minute': executionTime!.minute,
      } : null,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    };
  }

  factory ScheduledTrigger.fromJson(Map<String, dynamic> json) {
    return ScheduledTrigger(
      frequency: ScheduledTriggerFrequency.values.firstWhere(
        (e) => e.name == json['frequency'],
        orElse: () => ScheduledTriggerFrequency.monthly,
      ),
      dayOfMonth: json['dayOfMonth'],
      dayOfWeek: json['dayOfWeek'],
      daysOfMonth: json['daysOfMonth'] != null
          ? List<int>.from(json['daysOfMonth'])
          : null,
      monthsInterval: json['monthsInterval'],
      executionTime: json['executionTime'] != null
          ? TimeOfDay(
              hour: json['executionTime']['hour'],
              minute: json['executionTime']['minute'],
            )
          : null,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : null,
    );
  }

  String get displayDescription {
    switch (frequency) {
      case ScheduledTriggerFrequency.daily:
        return 'Tous les jours${executionTime != null ? ' à ${_formatTime(executionTime!)}' : ''}';
      case ScheduledTriggerFrequency.weekly:
        final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
        final dayName = dayOfWeek != null ? days[dayOfWeek! - 1] : 'Dimanche';
        return 'Chaque $dayName${executionTime != null ? ' à ${_formatTime(executionTime!)}' : ''}';
      case ScheduledTriggerFrequency.monthly:
        return 'Chaque ${dayOfMonth ?? 1}${_getOrdinalSuffix(dayOfMonth ?? 1)} du mois';
      case ScheduledTriggerFrequency.multiplePerMonth:
        if (daysOfMonth != null && daysOfMonth!.isNotEmpty) {
          final daysStr = daysOfMonth!.map((day) => day.toString()).join(', ');
          return 'Les $daysStr de chaque mois';
        }
        return 'Plusieurs fois par mois';
      case ScheduledTriggerFrequency.quarterly:
        return 'Chaque trimestre';
      case ScheduledTriggerFrequency.yearly:
        return 'Chaque année';
      case ScheduledTriggerFrequency.custom:
        return 'Personnalisé (tous les ${monthsInterval ?? 1} mois)';
    }
  }

  String _getOrdinalSuffix(int day) {
    if (day == 1) return 'er';
    return 'e';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class EventTrigger {
  final EventTriggerType eventType;
  final double? amountThreshold;    // Seuil de montant
  final String? accountId;          // Compte spécifique
  final String? categoryId;         // Catégorie spécifique
  final List<String>? categoryIds;  // Catégories multiples
  final bool? onlyFirstOfMonth;     // Seulement la première occurrence du mois

  EventTrigger({
    required this.eventType,
    this.amountThreshold,
    this.accountId,
    this.categoryId,
    this.categoryIds,
    this.onlyFirstOfMonth,
  });

  Map<String, dynamic> toJson() {
    return {
      'eventType': eventType.name,
      'amountThreshold': amountThreshold,
      'accountId': accountId,
      'categoryId': categoryId,
      'categoryIds': categoryIds,
      'onlyFirstOfMonth': onlyFirstOfMonth,
    };
  }

  factory EventTrigger.fromJson(Map<String, dynamic> json) {
    return EventTrigger(
      eventType: EventTriggerType.values.firstWhere(
        (e) => e.name == json['eventType'],
        orElse: () => EventTriggerType.moneyEntry,
      ),
      amountThreshold: json['amountThreshold']?.toDouble(),
      accountId: json['accountId'],
      categoryId: json['categoryId'],
      categoryIds: json['categoryIds'] != null
          ? List<String>.from(json['categoryIds'])
          : null,
      onlyFirstOfMonth: json['onlyFirstOfMonth'],
    );
  }

  String get displayDescription {
    switch (eventType) {
      case EventTriggerType.moneyEntry:
        return 'À chaque entrée d\'argent${amountThreshold != null ? ' ≥ ${amountThreshold!.toStringAsFixed(0)} FCFA' : ''}';
      case EventTriggerType.expenseOccurred:
        return 'À chaque dépense${amountThreshold != null ? ' ≥ ${amountThreshold!.toStringAsFixed(0)} FCFA' : ''}';
      case EventTriggerType.salaryReceived:
        return 'À chaque réception de salaire';
      case EventTriggerType.firstEntryOfMonth:
        return 'À la première entrée du mois';
      case EventTriggerType.budgetExceeded:
        return 'Quand le budget est dépassé';
      case EventTriggerType.goalReached:
        return 'Quand l\'objectif est atteint';
      case EventTriggerType.accountBalanceThreshold:
        return 'Quand le solde atteint ${amountThreshold?.toStringAsFixed(0) ?? '0'} FCFA';
    }
  }
}

class CategoryTrigger {
  final List<String> categoryIds;      // Catégories déclencheuses
  final double? minAmount;             // Montant minimum
  final double? maxAmount;             // Montant maximum
  final bool? onlyIncome;              // Seulement les revenus
  final bool? onlyExpense;             // Seulement les dépenses
  final int? maxExecutionsPerMonth;    // Limite d'exécutions par mois

  CategoryTrigger({
    required this.categoryIds,
    this.minAmount,
    this.maxAmount,
    this.onlyIncome,
    this.onlyExpense,
    this.maxExecutionsPerMonth,
  });

  Map<String, dynamic> toJson() {
    return {
      'categoryIds': categoryIds,
      'minAmount': minAmount,
      'maxAmount': maxAmount,
      'onlyIncome': onlyIncome,
      'onlyExpense': onlyExpense,
      'maxExecutionsPerMonth': maxExecutionsPerMonth,
    };
  }

  factory CategoryTrigger.fromJson(Map<String, dynamic> json) {
    return CategoryTrigger(
      categoryIds: List<String>.from(json['categoryIds'] ?? []),
      minAmount: json['minAmount']?.toDouble(),
      maxAmount: json['maxAmount']?.toDouble(),
      onlyIncome: json['onlyIncome'],
      onlyExpense: json['onlyExpense'],
      maxExecutionsPerMonth: json['maxExecutionsPerMonth'],
    );
  }

  String get displayDescription {
    String desc = 'Transactions dans catégories sélectionnées';
    if (minAmount != null) desc += ', ≥ ${minAmount!.toStringAsFixed(0)} FCFA';
    if (maxAmount != null) desc += ', ≤ ${maxAmount!.toStringAsFixed(0)} FCFA';
    if (onlyIncome == true) desc += ', revenus uniquement';
    if (onlyExpense == true) desc += ', dépenses uniquement';
    return desc;
  }
}

// ================================
// Action à exécuter
// ================================

class AutomationAction {
  final ActionType type;
  final String? sourceAccountId;      // Compte source (pour transfert)
  final String? destinationAccountId; // Compte destination (pour transfert)
  final double? amount;               // Montant fixe
  final double? percentage;           // Pourcentage du montant déclencheur
  final String? title;                // Titre de la transaction
  final String? description;          // Description
  final String? categoryId;           // Catégorie de la transaction créée
  final String? budgetId;             // Budget à mettre à jour
  final String? notificationMessage;  // Message de notification

  AutomationAction({
    required this.type,
    this.sourceAccountId,
    this.destinationAccountId,
    this.amount,
    this.percentage,
    this.title,
    this.description,
    this.categoryId,
    this.budgetId,
    this.notificationMessage,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'sourceAccountId': sourceAccountId,
      'destinationAccountId': destinationAccountId,
      'amount': amount,
      'percentage': percentage,
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'budgetId': budgetId,
      'notificationMessage': notificationMessage,
    };
  }

  factory AutomationAction.fromJson(Map<String, dynamic> json) {
    return AutomationAction(
      type: ActionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ActionType.transfer,
      ),
      sourceAccountId: json['sourceAccountId'],
      destinationAccountId: json['destinationAccountId'],
      amount: json['amount']?.toDouble(),
      percentage: json['percentage']?.toDouble(),
      title: json['title'],
      description: json['description'],
      categoryId: json['categoryId'],
      budgetId: json['budgetId'],
      notificationMessage: json['notificationMessage'],
    );
  }

  String get displayDescription {
    switch (type) {
      case ActionType.transfer:
        final amountStr = amount != null
            ? '${amount!.toStringAsFixed(0)} FCFA'
            : '${percentage?.toStringAsFixed(1) ?? 0}% du montant';
        return 'Transférer $amountStr';
      case ActionType.createTransaction:
        return 'Créer une transaction: ${title ?? 'Sans titre'}';
      case ActionType.updateBudget:
        return 'Mettre à jour le budget';
      case ActionType.sendNotification:
        return 'Envoyer une notification: ${notificationMessage ?? 'Message par défaut'}';
      case ActionType.createSavingGoal:
        return 'Créer un objectif d\'épargne';
    }
  }
}

// ================================
// Modèle principal d'automatisation
// ================================

class AutomationRuleModel {
  final String id;
  final String name;
  final String? description;
  final String entityId;
  final bool isActive;
  final TriggerType triggerType;
  final ScheduledTrigger? scheduledTrigger;
  final EventTrigger? eventTrigger;
  final CategoryTrigger? categoryTrigger;
  final AutomationAction action;
  final int priority;                 // Priorité d'exécution (1-10)
  final DateTime? lastExecuted;       // Dernière exécution
  final int executionCount;           // Nombre d'exécutions
  final DateTime createdAt;
  final DateTime updatedAt;

  AutomationRuleModel({
    required this.id,
    required this.name,
    this.description,
    required this.entityId,
    this.isActive = true,
    required this.triggerType,
    this.scheduledTrigger,
    this.eventTrigger,
    this.categoryTrigger,
    required this.action,
    this.priority = 5,
    this.lastExecuted,
    this.executionCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  // Getters utiles
  bool get hasScheduledTrigger => triggerType == TriggerType.scheduled && scheduledTrigger != null;
  bool get hasEventTrigger => triggerType == TriggerType.eventBased && eventTrigger != null;
  bool get hasCategoryTrigger => triggerType == TriggerType.categoryBased && categoryTrigger != null;

  String get triggerDescription {
    switch (triggerType) {
      case TriggerType.scheduled:
        return scheduledTrigger?.displayDescription ?? 'Programmé';
      case TriggerType.eventBased:
        return eventTrigger?.displayDescription ?? 'Basé sur un événement';
      case TriggerType.categoryBased:
        return categoryTrigger?.displayDescription ?? 'Basé sur une catégorie';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'entityId': entityId,
      'isActive': isActive,
      'triggerType': triggerType.name,
      'scheduledTrigger': scheduledTrigger?.toJson(),
      'eventTrigger': eventTrigger?.toJson(),
      'categoryTrigger': categoryTrigger?.toJson(),
      'action': action.toJson(),
      'priority': priority,
      'lastExecuted': lastExecuted?.toIso8601String(),
      'executionCount': executionCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AutomationRuleModel.fromJson(Map<String, dynamic> json) {
    return AutomationRuleModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      entityId: json['entityId'] ?? '',
      isActive: json['isActive'] ?? true,
      triggerType: TriggerType.values.firstWhere(
        (e) => e.name == json['triggerType'],
        orElse: () => TriggerType.scheduled,
      ),
      scheduledTrigger: json['scheduledTrigger'] != null
          ? ScheduledTrigger.fromJson(json['scheduledTrigger'])
          : null,
      eventTrigger: json['eventTrigger'] != null
          ? EventTrigger.fromJson(json['eventTrigger'])
          : null,
      categoryTrigger: json['categoryTrigger'] != null
          ? CategoryTrigger.fromJson(json['categoryTrigger'])
          : null,
      action: AutomationAction.fromJson(json['action']),
      priority: json['priority'] ?? 5,
      lastExecuted: json['lastExecuted'] != null
          ? DateTime.parse(json['lastExecuted'])
          : null,
      executionCount: json['executionCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  factory AutomationRuleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AutomationRuleModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      entityId: data['entityId'] ?? '',
      isActive: data['isActive'] ?? true,
      triggerType: TriggerType.values.firstWhere(
        (e) => e.name == data['triggerType'],
        orElse: () => TriggerType.scheduled,
      ),
      scheduledTrigger: data['scheduledTrigger'] != null
          ? ScheduledTrigger.fromJson(data['scheduledTrigger'])
          : null,
      eventTrigger: data['eventTrigger'] != null
          ? EventTrigger.fromJson(data['eventTrigger'])
          : null,
      categoryTrigger: data['categoryTrigger'] != null
          ? CategoryTrigger.fromJson(data['categoryTrigger'])
          : null,
      action: AutomationAction.fromJson(data['action']),
      priority: data['priority'] ?? 5,
      lastExecuted: (data['lastExecuted'] as Timestamp?)?.toDate(),
      executionCount: data['executionCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'entityId': entityId,
      'isActive': isActive,
      'triggerType': triggerType.name,
      'scheduledTrigger': scheduledTrigger?.toJson(),
      'eventTrigger': eventTrigger?.toJson(),
      'categoryTrigger': categoryTrigger?.toJson(),
      'action': action.toJson(),
      'priority': priority,
      'lastExecuted': lastExecuted != null ? Timestamp.fromDate(lastExecuted!) : null,
      'executionCount': executionCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  AutomationRuleModel copyWith({
    String? id,
    String? name,
    String? description,
    String? entityId,
    bool? isActive,
    TriggerType? triggerType,
    ScheduledTrigger? scheduledTrigger,
    EventTrigger? eventTrigger,
    CategoryTrigger? categoryTrigger,
    AutomationAction? action,
    int? priority,
    DateTime? lastExecuted,
    int? executionCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AutomationRuleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      entityId: entityId ?? this.entityId,
      isActive: isActive ?? this.isActive,
      triggerType: triggerType ?? this.triggerType,
      scheduledTrigger: scheduledTrigger ?? this.scheduledTrigger,
      eventTrigger: eventTrigger ?? this.eventTrigger,
      categoryTrigger: categoryTrigger ?? this.categoryTrigger,
      action: action ?? this.action,
      priority: priority ?? this.priority,
      lastExecuted: lastExecuted ?? this.lastExecuted,
      executionCount: executionCount ?? this.executionCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'AutomationRuleModel(id: $id, name: $name, triggerType: $triggerType, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AutomationRuleModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}