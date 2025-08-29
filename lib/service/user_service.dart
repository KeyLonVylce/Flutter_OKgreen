import 'package:dio/dio.dart';
import 'api_client.dart';
import 'api_response.dart';

class UserService {
  final ApiClient _apiClient = ApiClient();

  // Update user profile berdasarkan API PUT /users/{id}
  Future<ApiResponse<Map<String, dynamic>>> updateProfile({
    required int userId,
    String? name,
    String? email,
    String? phone,
    String? address,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (phone != null) data['phone'] = phone;
      if (address != null) data['address'] = address;

      final response = await _apiClient.dio.put('/users/$userId', data: data);

      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: response.data['message'] ?? 'Profil berhasil diperbarui',
          data: response.data['data'] ?? response.data,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'Gagal memperbarui profil',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Private method untuk handle error
  ApiResponse<T> _handleError<T>(DioException e) {
    String message = 'Terjadi kesalahan';
    
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        message = data['message'] ?? message;
        // Handle validation errors
        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            message = firstError.first.toString();
          }
        }
      }
    } else {
      message = e.message ?? message;
    }

    return ApiResponse<T>(
      success: false,
      message: message,
      statusCode: e.response?.statusCode,
    );
  }
}
