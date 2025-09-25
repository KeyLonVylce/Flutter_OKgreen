import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductService {
  // Base URL API - sesuaikan dengan URL server Anda
  static const String baseUrl = 'http://localhost:8000/api'; // atau IP server Anda
  
  // Model untuk Product dengan image support
  static Map<String, dynamic> _createProductFromWasteType(Map<String, dynamic> data) {
    // Handle multiple photos from sell_waste_transactions
    List<String> imageUrls = [];
    if (data['sell_waste_transactions'] != null) {
      for (var transaction in data['sell_waste_transactions']) {
        if (transaction['photo'] != null && transaction['photo'].isNotEmpty) {
          // Handle photo sebagai JSON array atau string
          var photos = transaction['photo'];
          if (photos is String) {
            try {
              var photoList = json.decode(photos);
              if (photoList is List) {
                imageUrls.addAll(photoList.map((p) => '$baseUrl/storage/$p').toList());
              }
            } catch (e) {
              // Jika bukan JSON, treat sebagai single path
              imageUrls.add('$baseUrl/storage/$photos');
            }
          } else if (photos is List) {
            imageUrls.addAll(photos.map((p) => '$baseUrl/storage/$p').toList());
          }
        }
      }
    }
    
    // Fallback: check if there's direct image field
    if (imageUrls.isEmpty && data['image'] != null) {
      imageUrls.add('$baseUrl/storage/${data['image']}');
    }
    
    return {
      'id': data['id'],
      'name': data['type_name'],
      'price': 'Rp ${_formatPrice(data['price_per_kg'] ?? 5000)}',
      'description': data['description'] ?? 'Sampah daur ulang berkualitas',
      'category': data['waste_category']['category_name'] ?? 'Lainnya',
      'condition': 'Baik',
      'weight': '1 kg',
      'seller': 'EcoWaste Store',
      'stock': data['stock'] ?? 0,
      'images': imageUrls, // Multiple images
      'image': imageUrls.isNotEmpty ? imageUrls.first : null, // Primary image for backward compatibility
      'waste_category_id': data['waste_category_id'],
      'price_per_kg': data['price_per_kg'] ?? 5000,
    };
  }
  
  static String _formatPrice(dynamic price) {
    if (price is int) {
      return price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );
    }
    return price.toString();
  }
  
  // Fetch semua waste types dengan kategori dan foto dari sell transactions
  static Future<List<Map<String, dynamic>>> getAllProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/waste-types?include_photos=true'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> wasteTypes = data['data'] ?? data;
        
        List<Map<String, dynamic>> products = [];
        
        for (var wasteType in wasteTypes) {
          // Ambil stock dari waste_stock jika ada
          int stock = await _getStockForWasteType(wasteType['id']);
          wasteType['stock'] = stock;
          
          products.add(_createProductFromWasteType(wasteType));
        }
        
        return products;
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
      // Return dummy data sebagai fallback
      return _getDummyProducts();
    }
  }
  
  // Get stock untuk waste type tertentu
  static Future<int> _getStockForWasteType(int wasteTypeId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/waste-stock/$wasteTypeId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['available_weight'] ?? 0).toInt();
      }
    } catch (e) {
      print('Error fetching stock for waste type $wasteTypeId: $e');
    }
    
    // Random stock sebagai fallback
    return 15 + (DateTime.now().millisecondsSinceEpoch % 36);
  }
  
  // Fetch products berdasarkan kategori
  static Future<List<Map<String, dynamic>>> getProductsByCategory(int categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/waste-types?category_id=$categoryId&include_photos=true'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> wasteTypes = data['data'] ?? data;
        
        List<Map<String, dynamic>> products = [];
        
        for (var wasteType in wasteTypes) {
          int stock = await _getStockForWasteType(wasteType['id']);
          wasteType['stock'] = stock;
          products.add(_createProductFromWasteType(wasteType));
        }
        
        return products;
      } else {
        throw Exception('Failed to load products by category: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products by category: $e');
      return _getDummyProducts().where((p) => p['category'] == 'Plastik').toList();
    }
  }
  
  // Search products
  static Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/waste-types?search=${Uri.encodeComponent(query)}&include_photos=true'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> wasteTypes = data['data'] ?? data;
        
        List<Map<String, dynamic>> products = [];
        
        for (var wasteType in wasteTypes) {
          int stock = await _getStockForWasteType(wasteType['id']);
          wasteType['stock'] = stock;
          products.add(_createProductFromWasteType(wasteType));
        }
        
        return products;
      } else {
        throw Exception('Failed to search products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching products: $e');
      final allProducts = await getAllProducts();
      return allProducts.where((product) => 
        product['name'].toLowerCase().contains(query.toLowerCase()) ||
        product['description'].toLowerCase().contains(query.toLowerCase()) ||
        product['category'].toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
  }
  
  // Get waste categories
  static Future<List<Map<String, dynamic>>> getWasteCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/waste-categories'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? data);
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching categories: $e');
      return [
        {'id': 1, 'category_name': 'Plastik'},
        {'id': 2, 'category_name': 'Kertas'},
        {'id': 3, 'category_name': 'Kaca'},
        {'id': 5, 'category_name': 'Besi'},
        {'id': 6, 'category_name': 'Logam'},
        {'id': 7, 'category_name': 'Alumunium'},
        {'id': 8, 'category_name': 'Khusus'},
      ];
    }
  }
  
  // Upload foto untuk sell waste transaction
  static Future<Map<String, dynamic>?> uploadSellWastePhotos(List<String> photoPaths) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/sell-waste/upload-photos'));
      
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Accept': 'application/json',
      });
      
      for (int i = 0; i < photoPaths.length; i++) {
        request.files.add(await http.MultipartFile.fromPath('photos[]', photoPaths[i]));
      }
      
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        return json.decode(responseData);
      } else {
        throw Exception('Failed to upload photos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading photos: $e');
      return null;
    }
  }
  
  // Submit sell waste request dengan foto
  static Future<Map<String, dynamic>?> submitSellWasteRequest({
    required int wasteCategoryId,
    required int sellWasteTypeId,
    required String sellMethod,
    required double weight,
    String? description,
    List<String> photoPaths = const [],
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/sell-waste'));
      
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Accept': 'application/json',
      });
      
      // Add form fields
      request.fields['waste_category_id'] = wasteCategoryId.toString();
      request.fields['sell_waste_type_id'] = sellWasteTypeId.toString();
      request.fields['sell_method'] = sellMethod;
      request.fields['weight'] = weight.toString();
      if (description != null) {
        request.fields['description'] = description;
      }
      
      // Add photos
      for (int i = 0; i < photoPaths.length; i++) {
        request.files.add(await http.MultipartFile.fromPath('photo[]', photoPaths[i]));
      }
      
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 201) {
        return json.decode(responseData);
      } else {
        throw Exception('Failed to submit sell request: ${response.statusCode}');
      }
    } catch (e) {
      print('Error submitting sell request: $e');
      return null;
    }
  }
  
  // Update stock setelah pembelian
  static Future<bool> updateStock(int wasteTypeId, double weightSold) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/waste-stock/$wasteTypeId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'weight_sold': weightSold,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating stock: $e');
      return false;
    }
  }
  
  // Create buy transaction
  static Future<Map<String, dynamic>?> createBuyTransaction({
    required int userId,
    required List<Map<String, dynamic>> cartItems,
    required double totalAmount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/buy-transactions'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'user_id': userId,
          'total_amount': totalAmount,
          'cart_items': cartItems.map((item) => {
            'waste_type_id': item['id'],
            'quantity': item['purchasedQuantity'] ?? 1,
            'price_per_unit': item['price_per_kg'],
            'subtotal': (item['price_per_kg'] * (item['purchasedQuantity'] ?? 1)),
          }).toList(),
        }),
      );
      
      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create transaction: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating transaction: $e');
      return null;
    }
  }
  
  // Get sell waste types by category
  static Future<List<Map<String, dynamic>>> getSellWasteTypes(int categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sell-waste-types?category_id=$categoryId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? data);
      } else {
        throw Exception('Failed to load sell waste types: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching sell waste types: $e');
      return [
        {'id': 1, 'type_name': 'Botol Plastik', 'points_per_kg': 2000},
        {'id': 2, 'type_name': 'Kantong Plastik', 'points_per_kg': 1500},
        {'id': 3, 'type_name': 'Kemasan Makanan', 'points_per_kg': 1800},
      ];
    }
  }
  
  // Dummy data sebagai fallback dengan sample images
  static List<Map<String, dynamic>> _getDummyProducts() {
    return [
      {
        'id': 1,
        'name': 'Botol Plastik',
        'price': 'Rp 2.500',
        'description': 'Botol air mineral bekas berkualitas',
        'category': 'Plastik',
        'condition': 'Baik',
        'weight': '0.2 kg',
        'seller': 'EcoWaste Store',
        'stock': 25,
        'image': null,
        'images': [],
        'waste_category_id': 1,
        'price_per_kg': 2500,
      },
      {
        'id': 2,
        'name': 'Kertas Bekas',
        'price': 'Rp 8.000',
        'description': 'Koran bekas banyak berkualitas baik',
        'category': 'Kertas',
        'condition': 'Baik',
        'weight': '2 kg',
        'seller': 'EcoWaste Store',
        'stock': 18,
        'image': null,
        'images': [],
        'waste_category_id': 2,
        'price_per_kg': 8000,
      },
      {
        'id': 3,
        'name': 'Botol Kaca',
        'price': 'Rp 5.000',
        'description': 'Botol kaca bekas minuman soda',
        'category': 'Kaca',
        'condition': 'Baik',
        'weight': '0.5 kg',
        'seller': 'EcoWaste Store',
        'stock': 12,
        'image': null,
        'images': [],
        'waste_category_id': 3,
        'price_per_kg': 5000,
      },
      {
        'id': 4,
        'name': 'Besi Beton',
        'price': 'Rp 15.000',
        'description': 'Besi beton dari proyek pembangunan',
        'category': 'Besi',
        'condition': 'Baik',
        'weight': '3 kg',
        'seller': 'EcoWaste Store',
        'stock': 8,
        'image': null,
        'images': [],
        'waste_category_id': 5,
        'price_per_kg': 15000,
      },
    ];
  }
}