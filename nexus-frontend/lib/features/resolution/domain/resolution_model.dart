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
      id: json['id']?.toString() ?? '',
      caseId: json['caseId']?.toString() ?? '',
      summary: json['summary']?.toString() ??
          json['resolutionNotes']?.toString() ??
          json['whatWasDone']?.toString() ??
          '',
      rootCause: json['rootCause']?.toString() ?? json['findings']?.toString(),
      resolutionAction: json['resolutionAction']?.toString() ?? json['resolutionMessage']?.toString(),
      preventiveAction: json['preventiveAction']?.toString(),
      status: json['status']?.toString() ?? json['requesterDecision']?.toString() ?? 'PROPOSED',
      proposedBy: json['proposedBy']?.toString() ?? json['submittedByName']?.toString() ?? '',
      confirmedBy: json['confirmedBy']?.toString(),
      rejectionReason: json['rejectionReason']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
