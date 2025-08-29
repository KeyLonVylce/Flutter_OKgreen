import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';
import 'api_response.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  
  // Register
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    String? address,
  }) async {
    try {
      final response = await _apiClient.dio.post('/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: response.data['message'] ?? 'Registrasi berhasil',
          data: response.data,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'Registrasi gagal',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Login
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post('/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Simpan token ke SharedPreferences jika ada
        if (data['access_token'] != null || data['token'] != null) {
          final token = data['access_token'] ?? data['token'];
          await _saveToken(token);
        }

        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: data['message'] ?? 'Login berhasil',
          data: data,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'Login gagal',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Logout (hapus token lokal)
  Future<ApiResponse<void>> logout() async {
    try {
      // Hapus token dari local storage
      await _clearTokens();

      return ApiResponse<void>(
        success: true,
        message: 'Logout berhasil',
        statusCode: 200,
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Logout gagal',
      );
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return token != null;
  }

  // Get stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // Private methods
  Future<void> _saveToken(String accessToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
  }

  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

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
