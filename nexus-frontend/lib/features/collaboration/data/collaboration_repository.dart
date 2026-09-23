import 'dart:typed_data';
import '../domain/collaboration_models.dart';
import 'collaboration_api.dart';

class CollaborationRepository {
  final CollaborationApi _api = CollaborationApi();

  Future<({bool success, List<MessageModel> messages, String? error})> getMessages(String caseId) async {
    final res = await _api.getMessages(caseId);
    if (res.success && res.data != null) {
      return (success: true, messages: res.data!, error: null);
    }
    return (success: false, messages: <MessageModel>[], error: res.error);
  }

  Future<({bool success, MessageModel? message, String? error})> sendMessage({
    required String caseId,
    required String content,
    String messageType = 'UPDATE',
    bool visibleToRequester = true,
  }) async {
    final res = await _api.sendMessage(
      caseId: caseId,
      content: content,
      messageType: messageType,
      visibleToRequester: visibleToRequester,
    );
    if (res.success && res.data != null) {
      return (success: true, message: res.data, error: null);
    }
    return (success: false, message: null, error: res.error);
  }

  Future<({bool success, InternalNoteModel? note, String? error})> addInternalNote({
    required String caseId,
    required String content,
  }) async {
    final res = await _api.addInternalNote(caseId: caseId, content: content);
    if (res.success && res.data != null) {
      return (success: true, note: res.data, error: null);
    }
    return (success: false, note: null, error: res.error);
  }

  Future<({bool success, List<InternalNoteModel> notes, String? error})> getInternalNotes(String caseId) async {
    final res = await _api.getInternalNotes(caseId);
    if (res.success && res.data != null) {
      return (success: true, notes: res.data!, error: null);
    }
    return (success: false, notes: <InternalNoteModel>[], error: res.error);
  }

  Future<({bool success, List<AttachmentModel> attachments, String? error})> getAttachments(String caseId) async {
    final res = await _api.getAttachments(caseId);
    if (res.success && res.data != null) {
      return (success: true, attachments: res.data!, error: null);
    }
    return (success: false, attachments: <AttachmentModel>[], error: res.error);
  }

  Future<({bool success, AttachmentModel? attachment, String? error})> uploadAttachment({
    required String caseId,
    required String filename,
    required Uint8List bytes,
  }) async {
    final res = await _api.uploadAttachment(caseId: caseId, filename: filename, bytes: bytes);
    if (res.success && res.data != null) {
      return (success: true, attachment: res.data, error: null);
    }
    return (success: false, attachment: null, error: res.error);
  }

  Future<({bool success, Map<String, dynamic>? workload, String? error})> getTeamWorkload() async {
    final res = await _api.getTeamWorkload();
    if (res.success && res.data != null) {
      return (success: true, workload: res.data, error: null);
    }
    return (success: false, workload: null, error: res.error);
  }
}
