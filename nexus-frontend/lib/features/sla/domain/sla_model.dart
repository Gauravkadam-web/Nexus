class CaseSlaModel {
  final String caseId;
  final String policyName;
  final int responseTargetMinutes;
  final int resolutionTargetMinutes;
  final int responseRemainingMinutes;
  final int resolutionRemainingMinutes;
  final double consumedPercent;
  final bool isBreached;
  final bool isAtRisk;
  final String riskReason;

  const CaseSlaModel({
    required this.caseId,
    required this.policyName,
    required this.responseTargetMinutes,
    required this.resolutionTargetMinutes,
    required this.responseRemainingMinutes,
    required this.resolutionRemainingMinutes,
    required this.consumedPercent,
    required this.isBreached,
    required this.isAtRisk,
    this.riskReason = 'None',
  });

  factory CaseSlaModel.fromJson(Map<String, dynamic> json) {
    return CaseSlaModel(
      caseId: json['caseId'] as String? ?? '',
      policyName: json['policyName'] as String? ?? 'Standard SLA',
      responseTargetMinutes: (json['responseTargetMinutes'] as num?)?.toInt() ?? 60,
      resolutionTargetMinutes: (json['resolutionTargetMinutes'] as num?)?.toInt() ?? 240,
      responseRemainingMinutes: (json['responseRemainingMinutes'] as num?)?.toInt() ?? 30,
      resolutionRemainingMinutes: (json['resolutionRemainingMinutes'] as num?)?.toInt() ?? 120,
      consumedPercent: (json['consumedPercent'] as num?)?.toDouble() ?? 50.0,
      isBreached: json['isBreached'] as bool? ?? false,
      isAtRisk: json['isAtRisk'] as bool? ?? false,
      riskReason: json['riskReason'] as String? ?? 'None',
    );
  }
}

class SlaRiskCaseModel {
  final String caseId;
  final String caseNumber;
  final String title;
  final String priority;
  final String status;
  final String assignedOperator;
  final int remainingMinutes;
  final double breachProbability;
  final String riskFactor;

  const SlaRiskCaseModel({
    required this.caseId,
    required this.caseNumber,
    required this.title,
    required this.priority,
    required this.status,
    required this.assignedOperator,
    required this.remainingMinutes,
    required this.breachProbability,
    required this.riskFactor,
  });

  factory SlaRiskCaseModel.fromJson(Map<String, dynamic> json) {
    return SlaRiskCaseModel(
      caseId: json['caseId'] as String? ?? json['id'] as String? ?? '',
      caseNumber: json['caseNumber'] as String? ?? json['number'] as String? ?? 'NEX-2026',
      title: json['title'] as String? ?? json['caseTitle'] as String? ?? '',
      priority: json['priority'] as String? ?? json['severity'] as String? ?? 'HIGH',
      status: json['status'] as String? ?? 'INVESTIGATING',
      assignedOperator: json['assignedOperator'] as String? ?? json['assignedToName'] as String? ?? 'Unassigned',
      remainingMinutes: (json['remainingMinutes'] as num?)?.toInt() ?? 25,
      breachProbability: (json['breachProbability'] as num?)?.toDouble() ?? 0.85,
      riskFactor: json['riskFactor'] as String? ?? json['reason'] as String? ?? 'High latency / Inactivity',
    );
  }
}
