import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductService {
  // Base URL backend - GANTI SESUAI SETUP ANDA
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  static const String storageUrl = 'http://10.0.2.2:8000/storage/';
  
  // Alternative URLs untuk testing
  static const String altUrl1 = 'http://localhost:8000/api';
  static const String altUrl2 = 'http://192.168.1.100:8000/api'; // Ganti dengan IP local Anda
  static const String altUrl3 = 'http://127.0.0.1:8000/api';

  // Ambil token dari SharedPreferences
  static Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (kDebugMode) {
        print(' Token check: ${token != null ? "Found token (${token!.length} chars)" : "No token found"}');
      }
      
      return token;
    } catch (e) {
      if (kDebugMode) {
        print(' Error getting token: $e');
      }
      return null;
    }
  }

  // Test koneksi ke berbagai URL
  static Future<bool> testConnection() async {
    if (kDebugMode) {
      print('\n TESTING MULTIPLE CONNECTION URLs');
      print('=====================================');
    }

    final List<String> urlsToTest = [
      baseUrl,
      altUrl1,
      altUrl2,
      altUrl3,
    ];

    for (String testUrl in urlsToTest) {
      if (kDebugMode) {
        print('\n Testing: $testUrl/waste-types');
      }

      try {
        final token = await _getToken();
        
        final response = await http.get(
          Uri.parse('$testUrl/waste-types'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 5)); // Shorter timeout untuk testing

        if (kDebugMode) {
          print('Response: ${response.statusCode}');
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            print(' Data preview: ${data.runtimeType} with ${data is List ? data.length : 'unknown'} items');
            return true;
          } else {
            print('Non-200 response: ${response.body}');
          }
        }

      } catch (e) {
        if (kDebugMode) {
          print(' Failed: ${e.toString()}');
          if (e is SocketException) {
            print('   - Network/Socket issue');
          } else if (e.toString().contains('TimeoutException')) {
            print('   - Connection timeout');
          } else {
            print('   - Other error: ${e.runtimeType}');
          }
        }
      }
    }

    if (kDebugMode) {
      print('\n All connection tests failed!');
      print(' Troubleshooting checklist:');
      print('   1. Is your backend server running?');
      print('   2. Check Laravel server: php artisan serve --host=0.0.0.0 --port=8000');
      print('   3. Verify API routes in web.php or api.php');
      print('   4. Check firewall/network settings');
      print('   5. Try different IP addresses above');
    }

    return false;
  }

  // Debug network dan server info
  static Future<void> debugConnection() async {
    if (kDebugMode) {
      print('\n NETWORK DEBUG INFO');
      print('====================');
      print('Platform: ${Platform.operatingSystem}');
      print('Base URL: $baseUrl');
      print('Storage URL: $storageUrl');
      print('User-Agent: Flutter App');
      
      // Test basic HTTP connectivity
      try {
        final response = await http.get(Uri.parse('https://httpbin.org/status/200'))
          .timeout(const Duration(seconds: 3));
        print('Internet connectivity: ${response.statusCode == 200 ? "OK" : "Failed"}');
      } catch (e) {
        print('Internet connectivity: Failed ($e)');
      }
    }
  }

  // Get all products dengan multiple fallbacks
  static Future<List<Map<String, dynamic>>> getAllProducts() async {
    if (kDebugMode) {
      print('\n FETCHING ALL PRODUCTS');
      print('========================');
    }

    // Try multiple URLs jika baseUrl gagal
    final List<String> urlsToTry = [baseUrl, altUrl1, altUrl3];
    
    for (String currentUrl in urlsToTry) {
      try {
        final token = await _getToken();

        if (kDebugMode) {
          print('Trying URL: $currentUrl/waste-types');
          print('Token: ${token != null ? "Available" : "Not available"}');
        }

        final response = await http.get(
          Uri.parse('$currentUrl/waste-types'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'User-Agent': 'Flutter-OkGreen-App',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 10));

        if (kDebugMode) {
          print('Response Status: ${response.statusCode}');
          print('Response Length: ${response.body.length} characters');
        }

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          
          if (kDebugMode) {
            print('SUCCESS! Decoded ${data.length} products');
            print('Sample data structure:');
            if (data.isNotEmpty) {
              final sample = data[0];
              print('   - id: ${sample['id']}');
              print('   - type_name: ${sample['type_name']}');
              print('   - price_per_unit: ${sample['price_per_unit']}');
              print('   - category: ${sample['category']}');
              print('   - stock: ${sample['stock']}');
            }
          }

          // Process data
          final List<Map<String, dynamic>> products = data.map((item) {
            final stockData = item['stock'];
            final stockWeight = stockData != null ? stockData['available_weight'] : '0';
            final stock = int.tryParse(stockWeight?.toString() ?? '0') ?? 0;

            return {
              'id': item['id'],
              'name': item['type_name'] ?? 'Produk Tidak Diketahui',
              'description': item['description'] ?? 'Tidak ada deskripsi',
              'price': 'Rp ${_formatPrice(item['price_per_unit'])}',
              'stock': stock,
              'category': item['category']?['category_name'] ?? 'Kategori Tidak Diketahui',
              'waste_category_id': item['waste_category_id'],
              'image': item['photo'] != null ? '$storageUrl${item['photo']}' : null,
              'images': item['photo'] != null ? ['$storageUrl${item['photo']}'] : null,
              'created_at': item['created_at'],
              'updated_at': item['updated_at'],
              // Raw data for debugging
              'raw_data': item,
            };
          }).cast<Map<String, dynamic>>().toList();

          if (kDebugMode) {
            print(' Successfully processed ${products.length} products');
            for (int i = 0; i < products.length && i < 3; i++) {
              final p = products[i];
              print('   ${i + 1}. ${p['name']} - ${p['price']} (Stock: ${p['stock']})');
            }
          }

          return products;

        } else if (response.statusCode == 401) {
          if (kDebugMode) {
            print('Authentication required - trying without token might work');
          }
          continue;
        } else {
          if (kDebugMode) {
            print('HTTP ${response.statusCode}: ${response.body}');
          }
          continue;
        }

      } on SocketException catch (e) {
        if (kDebugMode) {
          print(' Network error for $currentUrl: $e');
        }
        continue;
      } on TimeoutException catch (e) {
        if (kDebugMode) {
          print('Timeout for $currentUrl: $e');
        }
        continue;
      } catch (e) {
        if (kDebugMode) {
          print(' Unexpected error for $currentUrl: $e');
        }
        continue;
      }
    }

    // Jika semua URL gagal, return mock data untuk testing UI
    if (kDebugMode) {
      print(' All URLs failed, returning mock data for UI testing');
    }
    
    return _getMockData();
  }

  // Get waste categories dengan fallback
  static Future<List<Map<String, dynamic>>> getWasteCategories() async {
    if (kDebugMode) {
      print('\n FETCHING CATEGORIES');
      print('======================');
    }

    final List<String> urlsToTry = [baseUrl, altUrl1, altUrl3];
    
    for (String currentUrl in urlsToTry) {
      try {
        final token = await _getToken();

        if (kDebugMode) {
          print('Trying URL: $currentUrl/waste-categories');
        }

        final response = await http.get(
          Uri.parse('$currentUrl/waste-categories'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 8));

        if (kDebugMode) {
          print('Categories Response: ${response.statusCode}');
        }

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          
          if (kDebugMode) {
            print('SUCCESS! Found ${data.length} categories');
            for (var cat in data) {
              print('   - ${cat['category_name']} (ID: ${cat['id']})');
            }
          }
          
          return data.cast<Map<String, dynamic>>();
        }

      } catch (e) {
        if (kDebugMode) {
          print('Categories error for $currentUrl: $e');
        }
        continue;
      }
    }

    // Return mock categories
    if (kDebugMode) {
      print('Categories failed, returning mock data');
    }
    
    return [
      {'id': 1, 'category_name': 'Plastik'},
      {'id': 2, 'category_name': 'Kertas'},
      {'id': 7, 'category_name': 'Alumunium'},
      {'id': 9, 'category_name': 'plastik'},
    ];
  }

  // Mock data untuk testing UI ketika API tidak tersedia
  static List<Map<String, dynamic>> _getMockData() {
    return [
      {
        'id': 8,
        'name': 'botol plastik',
        'description': 'plis masuk',
        'price': 'Rp 5.000',
        'stock': 0,
        'category': 'plastik',
        'waste_category_id': 9,
        'image': null,
        'images': null,
        'created_at': '2025-09-24T16:05:04.000000Z',
        'updated_at': '2025-09-24T16:05:51.000000Z',
      },
      {
        'id': 9,
        'name': 'gelas kertas',
        'description': 'yess',
        'price': 'Rp 5.000',
        'stock': 18,
        'category': 'Kertas',
        'waste_category_id': 2,
        'image': null,
        'images': null,
        'created_at': '2025-09-24T16:06:48.000000Z',
        'updated_at': '2025-09-25T03:18:00.000000Z',
      },
      {
        'id': 10,
        'name': 'bungkus snack',
        'description': 'ini sampah',
        'price': 'Rp 9.000',
        'stock': 52,
        'category': 'Plastik',
        'waste_category_id': 1,
        'image': null,
        'images': null,
        'created_at': '2025-09-25T03:17:41.000000Z',
        'updated_at': '2025-09-25T03:20:36.000000Z',
      },
      {
        'id': 11,
        'name': 'kaleng minuman',
        'description': 'hai',
        'price': 'Rp 10.000',
        'stock': 20,
        'category': 'Alumunium',
        'waste_category_id': 7,
        'image': null,
        'images': null,
        'created_at': '2025-09-25T03:19:28.000000Z',
        'updated_at': '2025-09-25T03:20:51.000000Z',
      },
    ];
  }

  // Helper functions tetap sama
  static String _formatPrice(dynamic price) {
    if (price == null) return '0';

    try {
      double priceDouble = double.parse(price.toString());
      return priceDouble.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );
    } catch (e) {
      return price.toString();
    }
  }

  static Future<Map<String, dynamic>> getProductById(int id) async {
    try {
      final products = await getAllProducts();
      return products.firstWhere(
        (product) => product['id'] == id,
        orElse: () => throw Exception('Product not found'),
      );
    } catch (e) {
      throw Exception('Failed to fetch product: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    try {
      final allProducts = await getAllProducts();
      return allProducts.where((product) {
        final name = product['name']?.toString().toLowerCase() ?? '';
        final description = product['description']?.toString().toLowerCase() ?? '';
        final category = product['category']?.toString().toLowerCase() ?? '';
        final searchQuery = query.toLowerCase();

        return name.contains(searchQuery) ||
            description.contains(searchQuery) ||
            category.contains(searchQuery);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getProductsByCategory(int categoryId) async {
    try {
      final allProducts = await getAllProducts();
      return allProducts.where((product) {
        return product['waste_category_id'] == categoryId;
      }).toList();
    } catch (e) {
      throw Exception('Failed to filter products: $e');
    }
  }
}