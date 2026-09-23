import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_response.dart';
import '../domain/collaboration_models.dart';

class CollaborationApi {
  final ApiClient _client = ApiClient();

  Future<ApiResponse<List<MessageModel>>> getMessages(String caseId) async {
    try {
      final response = await _client.dio.get(ApiEndpoints.caseMessages(caseId));
      final rawList = response.data['data'] as List<dynamic>? ?? [];
      final list = rawList.map((e) => MessageModel.fromJson(e as Map<String, dynamic>)).toList();
      return ApiResponse(success: true, data: list);
    } on DioException catch (e) {
      return ApiResponse(success: false, error: e.message ?? 'Failed to load messages');
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<MessageModel>> sendMessage({
    required String caseId,
    required String content,
    String messageType = 'UPDATE',
    bool visibleToRequester = true,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.caseMessages(caseId),
        data: {
          'content': content,
          'messageType': messageType,
          'visibleToRequester': visibleToRequester,
        },
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => MessageModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse(success: false, error: e.message ?? 'Failed to send message');
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<InternalNoteModel>> addInternalNote({
    required String caseId,
    required String content,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.caseNotes(caseId),
        data: {'content': content},
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => InternalNoteModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse(success: false, error: e.message ?? 'Failed to add note');
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<List<InternalNoteModel>>> getInternalNotes(String caseId) async {
    try {
      final response = await _client.dio.get(ApiEndpoints.caseNotes(caseId));
      final rawList = response.data['data'] as List<dynamic>? ?? [];
      final list = rawList.map((e) => InternalNoteModel.fromJson(e as Map<String, dynamic>)).toList();
      return ApiResponse(success: true, data: list);
    } on DioException catch (e) {
      return ApiResponse(success: false, error: e.message ?? 'Failed to load internal notes');
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<List<AttachmentModel>>> getAttachments(String caseId) async {
    try {
      final response = await _client.dio.get(ApiEndpoints.caseAttachments(caseId));
      final rawList = response.data['data'] as List<dynamic>? ?? [];
      final list = rawList.map((e) => AttachmentModel.fromJson(e as Map<String, dynamic>)).toList();
      return ApiResponse(success: true, data: list);
    } on DioException catch (e) {
      return ApiResponse(success: false, error: e.message ?? 'Failed to load attachments');
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<AttachmentModel>> uploadAttachment({
    required String caseId,
    required String filename,
    required Uint8List bytes,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      });
      final response = await _client.dio.post(
        ApiEndpoints.caseAttachments(caseId),
        data: formData,
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => AttachmentModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse(success: false, error: e.message ?? 'Failed to upload attachment');
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getTeamWorkload() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.teamWorkload);
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      return ApiResponse(success: false, error: e.message ?? 'Failed to load workload');
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }
}
