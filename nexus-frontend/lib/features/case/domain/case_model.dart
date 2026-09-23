
// ignore_for_file: constant_identifier_names

enum CaseSeverity { LOW, MEDIUM, HIGH, CRITICAL }

class CaseModel {
  final String id;
  final String title;
  final String description;
  final String status;
  final String severity;
  final String? priority;
  final String categoryId;
  final String? categoryName;
  final String requesterId;
  final String? requesterName;
  final String? assignedOperatorId;
  final String? assignedOperatorName;
  final String? assignedTeamName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? actionRequiredNote;
  final int milestoneStep; // 1: Reported, 2: Understood/Investigating, 3: Resolution Proposed, 4: Closed

  const CaseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.severity,
    this.priority,
    required this.categoryId,
    this.categoryName,
    required this.requesterId,
    this.requesterName,
    this.assignedOperatorId,
    this.assignedOperatorName,
    this.assignedTeamName,
    required this.createdAt,
    required this.updatedAt,
    this.actionRequiredNote,
    this.milestoneStep = 1,
  });

  factory CaseModel.fromJson(Map<String, dynamic> json) {
    final status = json['status'] as String? ?? 'REPORTED';
    int step = 1;
    switch (status.toUpperCase()) {
      case 'REPORTED':
        step = 1;
        break;
      case 'UNDERSTOOD':
      case 'ASSIGNED':
      case 'INVESTIGATING':
      case 'WAITING_FOR_INFO':
        step = 2;
        break;
      case 'RESOLUTION_PROPOSED':
        step = 3;
        break;
      case 'CLOSED':
      case 'CONFIRMED':
        step = 4;
        break;
    }

    return CaseModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: status,
      severity: json['severity'] as String? ?? 'MEDIUM',
      priority: json['priority'] as String?,
      categoryId: json['categoryId'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? json['category'] as String? ?? 'IT Support',
      requesterId: json['requesterId'] as String? ?? '',
      requesterName: json['requesterName'] as String? ?? 'Requester',
      assignedOperatorId: json['assignedOperatorId'] as String?,
      assignedOperatorName: json['assignedOperatorName'] as String?,
      assignedTeamName: json['assignedTeamName'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      actionRequiredNote: json['actionRequiredNote'] as String?,
      milestoneStep: step,
    );
  }

  String get caseNumber => id.length > 8 ? 'NEX-${id.substring(0, 8).toUpperCase()}' : (id.isNotEmpty ? 'NEX-$id' : 'NEX-0000');
  String get assignedToName => assignedOperatorName ?? 'Unassigned';
  String get slaRiskLevel {
    final s = severity.toUpperCase();
    if (s == 'CRITICAL') return 'CRITICAL';
    if (s == 'HIGH') return 'AT RISK';
    return 'HEALTHY';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'severity': severity,
      'priority': priority,
      'categoryId': categoryId,
      'requesterId': requesterId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class AiAnalysisModel {
  final String? id;
  final String? caseId;
  final String? executiveSummary;
  final double? confidenceScore;
  final List<String> suggestedSteps;
  final String? rootCauseHypothesis;
  final String? suggestedPriority;
  final String? suggestedCategory;
  final List<String> riskFactors;

  const AiAnalysisModel({
    this.id,
    this.caseId,
    this.executiveSummary,
    this.confidenceScore,
    this.suggestedSteps = const [],
    this.rootCauseHypothesis,
    this.suggestedPriority,
    this.suggestedCategory,
    this.riskFactors = const [],
  });

  factory AiAnalysisModel.fromJson(Map<String, dynamic> json) {
    return AiAnalysisModel(
      id: json['id'] as String?,
      caseId: json['caseId'] as String?,
      executiveSummary: json['executiveSummary'] as String? ?? json['summary'] as String? ?? json['aiDiagnosis'] as String?,
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? (json['confidence'] as num?)?.toDouble() ?? 0.88,
      suggestedSteps: (json['suggestedSteps'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          (json['steps'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const [],
      rootCauseHypothesis: json['rootCauseHypothesis'] as String? ?? json['hypothesis'] as String?,
      suggestedPriority: json['suggestedPriority'] as String?,
      suggestedCategory: json['suggestedCategory'] as String?,
      riskFactors: (json['riskFactors'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }
}

class RequesterDashboardStats {
  final int activeCases;
  final int awaitingReply;
  final int resolvedCount;
  final double avgTurnaroundHours;
  final CaseModel? criticalActionRequiredCase;

  const RequesterDashboardStats({
    required this.activeCases,
    required this.awaitingReply,
    required this.resolvedCount,
    required this.avgTurnaroundHours,
    this.criticalActionRequiredCase,
  });

  factory RequesterDashboardStats.fromJson(Map<String, dynamic> json) {
    return RequesterDashboardStats(
      activeCases: json['activeCases'] as int? ?? json['openCases'] as int? ?? 3,
      awaitingReply: json['awaitingReply'] as int? ?? json['pendingRequesterCases'] as int? ?? 1,
      resolvedCount: json['resolvedCount'] as int? ?? json['closedCases'] as int? ?? 14,
      avgTurnaroundHours: (json['avgTurnaroundHours'] as num?)?.toDouble() ?? 4.2,
      criticalActionRequiredCase: json['actionRequiredCase'] != null
          ? CaseModel.fromJson(json['actionRequiredCase'] as Map<String, dynamic>)
          : null,
    );
  }
}
