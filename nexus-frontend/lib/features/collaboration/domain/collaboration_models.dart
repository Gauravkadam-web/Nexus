class MessageModel {
  final String id;
  final String caseId;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String content;
  final String messageType;
  final bool visibleToRequester;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.caseId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.content,
    this.messageType = 'UPDATE',
    this.visibleToRequester = true,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String? ?? '',
      caseId: json['caseId'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      senderName: json['senderName'] as String? ?? 'User',
      senderRole: json['senderRole'] as String? ?? 'OPERATOR',
      content: json['content'] as String? ?? '',
      messageType: json['messageType'] as String? ?? 'UPDATE',
      visibleToRequester: json['visibleToRequester'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class InternalNoteModel {
  final String id;
  final String caseId;
  final String authorId;
  final String authorName;
  final String content;
  final DateTime createdAt;

  const InternalNoteModel({
    required this.id,
    required this.caseId,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.createdAt,
  });

  String get authorRole => 'OPERATOR';

  factory InternalNoteModel.fromJson(Map<String, dynamic> json) {
    return InternalNoteModel(
      id: json['id'] as String? ?? '',
      caseId: json['caseId'] as String? ?? '',
      authorId: json['authorId'] as String? ?? '',
      authorName: json['authorName'] as String? ?? 'Operator',
      content: json['content'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class AttachmentModel {
  final String id;
  final String caseId;
  final String filename;
  final String fileType;
  final int fileSize;
  final String? storageUrl;
  final DateTime uploadedAt;

  const AttachmentModel({
    required this.id,
    required this.caseId,
    required this.filename,
    required this.fileType,
    required this.fileSize,
    this.storageUrl,
    required this.uploadedAt,
  });

  String get fileName => filename;

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      id: json['id'] as String? ?? '',
      caseId: json['caseId'] as String? ?? '',
      filename: json['filename'] as String? ?? json['fileName'] as String? ?? 'file',
      fileType: json['fileType'] as String? ?? json['contentType'] as String? ?? 'application/octet-stream',
      fileSize: (json['fileSize'] as num?)?.toInt() ?? 0,
      storageUrl: json['storageUrl'] as String? ?? json['fileUrl'] as String?,
      uploadedAt: json['uploadedAt'] != null || json['createdAt'] != null
          ? DateTime.tryParse((json['uploadedAt'] ?? json['createdAt']).toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
