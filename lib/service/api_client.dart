import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal() {
    _initDio();
  }

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    } else if (kDebugMode) {
      return 'http://10.0.2.2:8000/api';
    } else {
      return 'https://your-domain.com/api';
    }
  }
  
  late Dio _dio;

  Dio get dio => _dio;

  void _initDio() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('access_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            if (kDebugMode) {
              print('Token added to request: ${token.substring(0, 20)}...');
            }
          } else {
            if (kDebugMode) {
              print('No token found for request to ${options.path}');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error getting token: $e');
          }
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print('Response [${response.statusCode}]: ${response.requestOptions.path}');
        }
        handler.next(response);
      },
      onError: (error, handler) {
        if (kDebugMode) {
          print('Error [${error.response?.statusCode}]: ${error.requestOptions.path}');
          print('Error message: ${error.message}');
          print('Error data: ${error.response?.data}');
        }
        
        if (error.response?.statusCode == 401) {
          if (kDebugMode) {
            print('Token expired or invalid, clearing tokens');
          }
          _clearTokens();
        }
        handler.next(error);
      },
    ));

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        logPrint: (object) => print(object),
      ));
    }
  }

  Future<void> _clearTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('user_data');
      if (kDebugMode) {
        print('Tokens cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing tokens: $e');
      }
    }
  }

  Future<void> setToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', token);
      if (kDebugMode) {
        print('Token saved successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving token: $e');
      }
    }
  }

  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('access_token');
    } catch (e) {
      if (kDebugMode) {
        print('Error getting token: $e');
      }
      return null;
    }
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    await _clearTokens();
    _initDio();
  }

  Future<List<Map<String, dynamic>>> getWasteCategories() async {
    try {
      final response = await _dio.get('/waste-categories');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> getSellWasteTypes(String categoryId) async {
    try {
      final response = await _dio.get('/sell-waste/types/$categoryId');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw e;
    }
  }

  Future<Map<String, dynamic>> submitSellRequest({
    required String wasteCategoryId,
    required String sellWasteTypeId,
    required String sellMethod,
    required double weight,
    String? description,
    required List<File> photos,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'waste_category_id': wasteCategoryId,
        'sell_waste_type_id': sellWasteTypeId,
        'sell_method': sellMethod,
        'weight': weight.toString(),
        'description': description ?? '',
      });

      for (int i = 0; i < photos.length; i++) {
        String fileName = photos[i].path.split('/').last;
        formData.files.add(MapEntry(
          'photo[]',
          await MultipartFile.fromFile(photos[i].path, filename: fileName),
        ));
      }

      final response = await _dio.post('/sell-waste', data: formData);
      return response.data;
    } catch (e) {
      throw e;
    }
  }
}