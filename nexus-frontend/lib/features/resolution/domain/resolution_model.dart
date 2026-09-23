class ResolutionModel {
  final String id;
  final String caseId;
  final String summary;
  final String? rootCause;
  final String? resolutionAction;
  final String? preventiveAction;
  final String status; // PROPOSED, CONFIRMED, REJECTED
  final String proposedBy;
  final String? confirmedBy;
  final String? rejectionReason;
  final DateTime createdAt;

  const ResolutionModel({
    required this.id,
    required this.caseId,
    required this.summary,
    this.rootCause,
    this.resolutionAction,
    this.preventiveAction,
    required this.status,
    required this.proposedBy,
    this.confirmedBy,
    this.rejectionReason,
    required this.createdAt,
  });

  factory ResolutionModel.fromJson(Map<String, dynamic> json) {
    return ResolutionModel(
      id: json['id'] as String? ?? '',
      caseId: json['caseId'] as String? ?? '',
      summary: json['summary'] as String? ?? json['resolutionNotes'] as String? ?? '',
      rootCause: json['rootCause'] as String?,
      resolutionAction: json['resolutionAction'] as String?,
      preventiveAction: json['preventiveAction'] as String?,
      status: json['status'] as String? ?? 'PROPOSED',
      proposedBy: json['proposedBy'] as String? ?? '',
      confirmedBy: json['confirmedBy'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
