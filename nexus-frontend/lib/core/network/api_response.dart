/// Standard API response envelope matching Spring Boot ApiResponse<T>
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final Map<String, dynamic>? meta;

  const ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.meta,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      error: json['error'] as String?,
      meta: json['meta'] as Map<String, dynamic>?,
    );
  }

  /// Safely extracts a List<dynamic> from a raw List or Spring Data Page payload.
  static List<dynamic> extractList(dynamic rawData) {
    if (rawData == null) return [];
    if (rawData is List) return rawData;
    if (rawData is Map<String, dynamic>) {
      if (rawData['content'] is List) {
        return rawData['content'] as List<dynamic>;
      }
      if (rawData['data'] is List) {
        return rawData['data'] as List<dynamic>;
      }
    }
    return [];
  }
}
