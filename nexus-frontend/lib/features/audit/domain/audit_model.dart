class AuditLogModel {
  final String id;
  final String? caseId;
  final String? entityId;
  final String entityType;
  final String action;
  final String actorId;
  final String actorName;
  final String? actorEmail;
  final DateTime timestamp;
  final String? detailsJson;
  final Map<String, dynamic>? details;
  final String? ipAddress;

  const AuditLogModel({
    required this.id,
    this.caseId,
    this.entityId,
    required this.entityType,
    required this.action,
    required this.actorId,
    required this.actorName,
    this.actorEmail,
    required this.timestamp,
    this.detailsJson,
    this.details,
    this.ipAddress,
  });

  DateTime get createdAt => timestamp;

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel(
      id: json['id'] as String? ?? '',
      caseId: json['caseId'] as String?,
      entityId: json['entityId'] as String? ?? json['caseId'] as String? ?? '',
      entityType: json['entityType'] as String? ?? 'CASE',
      action: json['action'] as String? ?? 'UPDATED',
      actorId: json['actorId'] as String? ?? '',
      actorName: json['actorName'] as String? ?? 'System',
      actorEmail: json['actorEmail'] as String? ?? json['userEmail'] as String?,
      timestamp: json['timestamp'] != null
          ? (DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now())
          : (json['createdAt'] != null
              ? (DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now())
              : DateTime.now()),
      detailsJson: json['detailsJson'] as String?,
      details: json['details'] is Map<String, dynamic> ? json['details'] as Map<String, dynamic> : null,
      ipAddress: json['ipAddress'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'caseId': caseId,
      'entityId': entityId,
      'entityType': entityType,
      'action': action,
      'actorId': actorId,
      'actorName': actorName,
      'actorEmail': actorEmail,
      'timestamp': timestamp.toIso8601String(),
      'detailsJson': detailsJson,
      'details': details,
      'ipAddress': ipAddress,
    };
  }
}
