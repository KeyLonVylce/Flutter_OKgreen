import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static const String baseUrl = 'http://your-api-url.com/api';
  
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Mendapatkan semua notifikasi
  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/notifications'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      throw Exception('Gagal mengambil notifikasi');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Membuat notifikasi login (menggunakan endpoint store existing)
  Future<bool> createLoginNotification(int userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/notifications'),
        headers: headers,
        body: json.encode({
          'user_id': userId,
          'message': 'Akunmu login di perangkat baru.',
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['status'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error creating login notification: $e');
      return false;
    }
  }

  // Tandai notifikasi sebagai dibaca
  Future<bool> markAsRead(int notificationId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/notifications/$notificationId/read'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  // Hitung jumlah notifikasi belum dibaca (dari data existing)
  Future<int> getUnreadCount() async {
    try {
      final notifications = await getNotifications();
      return notifications.where((notif) => notif['status'] == 'unread').length;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }
}