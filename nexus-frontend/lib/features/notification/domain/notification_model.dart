class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type; // SLA_BREACH, SLA_WARNING, CASE_ASSIGNED, CASE_STATUS_CHANGE, ESCALATION
  final String? caseId;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.caseId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? json['subject'] as String? ?? 'Notification',
      message: json['message'] as String? ?? json['body'] as String? ?? '',
      type: json['type'] as String? ?? json['notificationType'] as String? ?? 'GENERAL',
      caseId: json['caseId'] as String?,
      isRead: json['read'] as bool? ?? json['isRead'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
