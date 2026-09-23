class InvestigationTaskModel {
  final String id;
  final String caseId;
  final String title;
  final String status; // PENDING, IN_PROGRESS, COMPLETED, CANCELLED
  final String? assignedTo;
  final String? assignedToName;
  final int orderIndex;
  final DateTime createdAt;

  const InvestigationTaskModel({
    required this.id,
    required this.caseId,
    required this.title,
    required this.status,
    this.assignedTo,
    this.assignedToName,
    this.orderIndex = 0,
    required this.createdAt,
  });

  bool get isCompleted => status.toUpperCase() == 'COMPLETED';
  String get description => title;
  String get assigneeName => assignedToName ?? assignedTo ?? 'Unassigned';

  factory InvestigationTaskModel.fromJson(Map<String, dynamic> json) {
    return InvestigationTaskModel(
      id: json['id'] as String? ?? '',
      caseId: json['caseId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      assignedTo: json['assignedTo'] as String?,
      assignedToName: json['assignedToName'] as String?,
      orderIndex: (json['orderIndex'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class InvestigationRecordModel {
  final String id;
  final String caseId;
  final String summary;
  final String? findings;
  final String? hypothesis;
  final String loggedBy;
  final String loggedByName;
  final DateTime loggedAt;

  const InvestigationRecordModel({
    required this.id,
    required this.caseId,
    required this.summary,
    this.findings,
    this.hypothesis,
    required this.loggedBy,
    required this.loggedByName,
    required this.loggedAt,
  });

  factory InvestigationRecordModel.fromJson(Map<String, dynamic> json) {
    return InvestigationRecordModel(
      id: json['id'] as String? ?? '',
      caseId: json['caseId'] as String? ?? '',
      summary: json['summary'] as String? ?? json['notes'] as String? ?? '',
      findings: json['findings'] as String?,
      hypothesis: json['hypothesis'] as String?,
      loggedBy: json['loggedBy'] as String? ?? '',
      loggedByName: json['loggedByName'] as String? ?? 'Operator',
      loggedAt: json['loggedAt'] != null
          ? DateTime.tryParse(json['loggedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
