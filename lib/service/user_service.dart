import 'package:dio/dio.dart';
import 'api_client.dart';
import 'api_response.dart';

class UserService {
  final ApiClient _apiClient = ApiClient();

  // Get current user profile menggunakan endpoint /me
  Future<ApiResponse<Map<String, dynamic>>> getCurrentUser() async {
    try {
      final response = await _apiClient.dio.get('/me');

      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: response.data['message'] ?? 'User data retrieved successfully',
          data: response.data,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'Failed to retrieve user data',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('DioException getting user: ${e.message}');
      print('Response data: ${e.response?.data}');
      return _handleError(e);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> updateProfile({
    required int userId, 
    String? name,
    String? email,
    String? phone,
    String? address,
    String? dateOfBirth,
    String? gender,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      
      if (name != null && name.isNotEmpty) data['name'] = name;
      if (email != null && email.isNotEmpty) data['email'] = email;
      if (phone != null && phone.isNotEmpty) data['phone'] = phone;
      if (address != null && address.isNotEmpty) data['address'] = address;
      if (dateOfBirth != null && dateOfBirth.isNotEmpty) data['date_of_birth'] = dateOfBirth;
      if (gender != null && gender.isNotEmpty) data['gender'] = gender;

      print('Sending data to /me: $data');
      
      // Gunakan endpoint /me untuk user yang sedang login (sesuai routes Laravel)
      final response = await _apiClient.dio.put('/me', data: data);

      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: response.data['message'] ?? 'Profil berhasil diperbarui',
          data: response.data,
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
      print('DioException: ${e.message}'); // Debug log
      print('Response data: ${e.response?.data}'); // Debug log
      print('Request URL: ${e.requestOptions.uri}'); // Debug log
      return _handleError(e);
    }
  }

  // Alternative method using POST dengan method spoofing jika PUT tidak berfungsi
  Future<ApiResponse<Map<String, dynamic>>> updateProfileWithPost({
    required int userId,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? dateOfBirth,
    String? gender,
  }) async {
    try {
      final Map<String, dynamic> data = {
        '_method': 'PUT', // Laravel method spoofing
      };
      
      if (name != null && name.isNotEmpty) data['name'] = name;
      if (email != null && email.isNotEmpty) data['email'] = email;
      if (phone != null && phone.isNotEmpty) data['phone'] = phone;
      if (address != null && address.isNotEmpty) data['address'] = address;
      if (dateOfBirth != null && dateOfBirth.isNotEmpty) data['date_of_birth'] = dateOfBirth;
      if (gender != null && gender.isNotEmpty) data['gender'] = gender;

      print('Sending data to /me (POST): $data'); // Debug log
      
      final response = await _apiClient.dio.post('/me', data: data);

      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: response.data['message'] ?? 'Profil berhasil diperbarui',
          data: response.data,
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
      print('DioException (POST): ${e.message}');
      print('Response data: ${e.response?.data}');
      return _handleError(e);
    }
  }

  ApiResponse<T> _handleError<T>(DioException e) {
    String message = 'Terjadi kesalahan';
    
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        message = data['message'] ?? message;
        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            message = firstError.first.toString();
          }
        }
      }
    } else if (e.type == DioExceptionType.connectionTimeout) {
      message = 'Koneksi timeout';
    } else if (e.type == DioExceptionType.connectionError) {
      message = 'Tidak dapat terhubung ke server';
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