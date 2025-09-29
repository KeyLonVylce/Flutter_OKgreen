import 'dart:convert';
import 'package:http/http.dart' as http;

class PointService {
  // Base URL - sesuaikan dengan URL backend Laravel Anda
  static const String baseUrl = 'https://your-api-url.com/api';
  
  // Token autentikasi - ambil dari storage atau state management
  static String? _authToken;
  
  static void setAuthToken(String token) {
    _authToken = token;
  }
  
  static Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (_authToken != null) 'Authorization': 'Bearer $_authToken',
    };
  }

  // Get current user points and history
  static Future<PointDataResponse> getPointsAndHistory({int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/my-points?page=$page'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PointDataResponse.fromJson(data);
      } else {
        throw Exception('Gagal mengambil data poin: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}

// Model untuk response
class PointDataResponse {
  final int totalPoints;
  final List<PointHistoryItem> histories;
  final PaginationMeta meta;

  PointDataResponse({
    required this.totalPoints,
    required this.histories,
    required this.meta,
  });

  factory PointDataResponse.fromJson(Map<String, dynamic> json) {
    // Parse histories dari pagination data
    final historiesData = json['histories'];
    List<PointHistoryItem> historyList = [];
    PaginationMeta meta;

    if (historiesData is Map && historiesData.containsKey('data')) {
      // Data sudah dalam format pagination
      historyList = (historiesData['data'] as List)
          .map((item) => PointHistoryItem.fromJson(item))
          .toList();
      
      meta = PaginationMeta(
        currentPage: historiesData['current_page'] ?? 1,
        lastPage: historiesData['last_page'] ?? 1,
        perPage: historiesData['per_page'] ?? 15,
        total: historiesData['total'] ?? 0,
      );
    } else if (historiesData is List) {
      // Data dalam format array biasa
      historyList = historiesData
          .map((item) => PointHistoryItem.fromJson(item))
          .toList();
      
      meta = PaginationMeta(
        currentPage: 1,
        lastPage: 1,
        perPage: historyList.length,
        total: historyList.length,
      );
    } else {
      meta = PaginationMeta(
        currentPage: 1,
        lastPage: 1,
        perPage: 0,
        total: 0,
      );
    }

    return PointDataResponse(
      totalPoints: json['userPoints'] ?? 0,
      histories: historyList,
      meta: meta,
    );
  }
}

// Model untuk item point history
class PointHistoryItem {
  final int id;
  final int userId;
  final String source; // 'transaction', 'purchase', 'redeem'
  final int? referenceId;
  final int pointsChange;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  PointHistoryItem({
    required this.id,
    required this.userId,
    required this.source,
    this.referenceId,
    required this.pointsChange,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PointHistoryItem.fromJson(Map<String, dynamic> json) {
    return PointHistoryItem(
      id: json['id'],
      userId: json['user_id'],
      source: json['source'] ?? 'unknown',
      referenceId: json['reference_id'],
      pointsChange: json['points_change'] ?? 0,
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // Helper untuk menentukan apakah poin bertambah atau berkurang
  bool get isPositive => pointsChange > 0;

  // Helper untuk mendapatkan label source
  String get sourceLabel {
    switch (source.toLowerCase()) {
      case 'transaction':
      case 'sell':
        return 'Penjualan Sampah';
      case 'purchase':
      case 'buy':
        return 'Pembelian Produk';
      case 'redeem':
      case 'reward':
        return 'Penukaran Poin';
      case 'adjustment':
        return 'Penyesuaian';
      default:
        return source;
    }
  }

  // Helper untuk mendapatkan icon source
  String get sourceIcon {
    switch (source.toLowerCase()) {
      case 'transaction':
      case 'sell':
        return '💰';
      case 'purchase':
      case 'buy':
        return '🛒';
      case 'redeem':
      case 'reward':
        return '🎁';
      case 'adjustment':
        return '⚙️';
      default:
        return '📝';
    }
  }
}

// Model untuk pagination meta
class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  bool get hasNextPage => currentPage < lastPage;
  bool get hasPreviousPage => currentPage > 1;
}