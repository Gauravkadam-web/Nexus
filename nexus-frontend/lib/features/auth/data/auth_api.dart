import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_response.dart';
import '../domain/user_model.dart';

class AuthApi {
  final ApiClient _client = ApiClient();

  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] as String? ?? e.response?.data?['error'] as String? ?? e.message ?? 'Login failed';
      return ApiResponse(success: false, error: errorMsg);
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> register({
    required String name,
    required String email,
    required String password,
    String? organizationId,
    String? role,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          if (organizationId != null) 'organizationId': organizationId,
          if (role != null) 'role': role,
        },
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] as String? ?? e.response?.data?['error'] as String? ?? e.message ?? 'Registration failed';
      return ApiResponse(success: false, error: errorMsg);
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<UserModel>> getProfile() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.me);
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => UserModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] as String? ?? e.response?.data?['error'] as String? ?? e.message ?? 'Failed to get profile';
      return ApiResponse(success: false, error: errorMsg);
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }
}
