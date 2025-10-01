import 'package:cloud_firestore/cloud_firestore.dart';

enum ExecutionStatus {
  success,    // Exécution réussie
  failed,     // Exécution échouée
  skipped,    // Exécution ignorée (conditions non remplies)
  pending,    // En attente d'exécution
}

class AutomationExecutionModel {
  final String id;
  final String ruleId;              // ID de la règle d'automatisation
  final String ruleName;            // Nom de la règle (pour historique)
  final String entityId;            // ID de l'entité
  final ExecutionStatus status;     // Statut de l'exécution
  final String? triggerData;        // Données du déclencheur (JSON)
  final String? resultData;         // Résultat de l'exécution (JSON)
  final String? transactionId;      // ID de la transaction créée (si applicable)
  final double? amount;             // Montant traité
  final String? errorMessage;       // Message d'erreur (si applicable)
  final DateTime executedAt;        // Date/heure d'exécution
  final DateTime createdAt;

  AutomationExecutionModel({
    required this.id,
    required this.ruleId,
    required this.ruleName,
    required this.entityId,
    required this.status,
    this.triggerData,
    this.resultData,
    this.transactionId,
    this.amount,
    this.errorMessage,
    required this.executedAt,
    required this.createdAt,
  });

  // Getters utiles
  bool get isSuccess => status == ExecutionStatus.success;
  bool get isFailed => status == ExecutionStatus.failed;
  bool get isSkipped => status == ExecutionStatus.skipped;
  bool get isPending => status == ExecutionStatus.pending;

  String get statusDisplayName {
    switch (status) {
      case ExecutionStatus.success:
        return 'Réussie';
      case ExecutionStatus.failed:
        return 'Échouée';
      case ExecutionStatus.skipped:
        return 'Ignorée';
      case ExecutionStatus.pending:
        return 'En attente';
    }
  }

  String get displayMessage {
    if (errorMessage != null) return errorMessage!;

    switch (status) {
      case ExecutionStatus.success:
        if (amount != null) {
          return 'Exécutée avec succès - ${amount!.toStringAsFixed(0)} FCFA';
        }
        return 'Exécutée avec succès';
      case ExecutionStatus.failed:
        return 'Échec de l\'exécution';
      case ExecutionStatus.skipped:
        return 'Conditions non remplies';
      case ExecutionStatus.pending:
        return 'En attente d\'exécution';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ruleId': ruleId,
      'ruleName': ruleName,
      'entityId': entityId,
      'status': status.name,
      'triggerData': triggerData,
      'resultData': resultData,
      'transactionId': transactionId,
      'amount': amount,
      'errorMessage': errorMessage,
      'executedAt': executedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AutomationExecutionModel.fromJson(Map<String, dynamic> json) {
    return AutomationExecutionModel(
      id: json['id'] ?? '',
      ruleId: json['ruleId'] ?? '',
      ruleName: json['ruleName'] ?? '',
      entityId: json['entityId'] ?? '',
      status: ExecutionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ExecutionStatus.pending,
      ),
      triggerData: json['triggerData'],
      resultData: json['resultData'],
      transactionId: json['transactionId'],
      amount: json['amount']?.toDouble(),
      errorMessage: json['errorMessage'],
      executedAt: json['executedAt'] != null
          ? DateTime.parse(json['executedAt'])
          : DateTime.now(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  factory AutomationExecutionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AutomationExecutionModel(
      id: doc.id,
      ruleId: data['ruleId'] ?? '',
      ruleName: data['ruleName'] ?? '',
      entityId: data['entityId'] ?? '',
      status: ExecutionStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ExecutionStatus.pending,
      ),
      triggerData: data['triggerData'],
      resultData: data['resultData'],
      transactionId: data['transactionId'],
      amount: data['amount']?.toDouble(),
      errorMessage: data['errorMessage'],
      executedAt: (data['executedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ruleId': ruleId,
      'ruleName': ruleName,
      'entityId': entityId,
      'status': status.name,
      'triggerData': triggerData,
      'resultData': resultData,
      'transactionId': transactionId,
      'amount': amount,
      'errorMessage': errorMessage,
      'executedAt': Timestamp.fromDate(executedAt),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  AutomationExecutionModel copyWith({
    String? id,
    String? ruleId,
    String? ruleName,
    String? entityId,
    ExecutionStatus? status,
    String? triggerData,
    String? resultData,
    String? transactionId,
    double? amount,
    String? errorMessage,
    DateTime? executedAt,
    DateTime? createdAt,
  }) {
    return AutomationExecutionModel(
      id: id ?? this.id,
      ruleId: ruleId ?? this.ruleId,
      ruleName: ruleName ?? this.ruleName,
      entityId: entityId ?? this.entityId,
      status: status ?? this.status,
      triggerData: triggerData ?? this.triggerData,
      resultData: resultData ?? this.resultData,
      transactionId: transactionId ?? this.transactionId,
      amount: amount ?? this.amount,
      errorMessage: errorMessage ?? this.errorMessage,
      executedAt: executedAt ?? this.executedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'AutomationExecutionModel(id: $id, ruleId: $ruleId, status: $status, executedAt: $executedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AutomationExecutionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}