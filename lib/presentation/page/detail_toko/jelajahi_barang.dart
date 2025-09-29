import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:okgreen/core/constants/app_colors.dart';
import 'package:okgreen/presentation/page/detail_toko/beranda_page.dart';
import 'package:okgreen/presentation/page/detail_toko/jual_barang_page.dart';
import 'package:okgreen/presentation/page/detail_toko/product_detail_page.dart';
import 'package:okgreen/presentation/widget/bottom_navbar.dart';
import 'package:okgreen/presentation/widget/top_wave.dart';
import 'package:okgreen/presentation/widget/product_card.dart';
import 'package:okgreen/service/product_service.dart';

class JelajahiProdukPage extends StatefulWidget {
  const JelajahiProdukPage({super.key});

  @override
  State<JelajahiProdukPage> createState() => _JelajahiProdukPageState();
}

class _JelajahiProdukPageState extends State<JelajahiProdukPage> {
  int currentIndex = 2;
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filteredProducts = [];
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;
  String searchQuery = '';
  int? selectedCategoryId;
  String sortBy = 'terbaru'; // terbaru, nama, harga_rendah, harga_tinggi, stok
  String _loadingError = '';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    if (kDebugMode) {
      print('\n======================================');
      print('   JELAJAHI PRODUK PAGE INITIALIZED');
      print('======================================');
    }
    
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Load data dari database API
  Future<void> _loadInitialData() async {
    setState(() {
      isLoading = true;
      _loadingError = '';
      products = [];
      categories = [];
      filteredProducts = [];
    });

    try {
      if (kDebugMode) {
        print('\n--- Loading Products and Categories ---');
        print('Loading from API endpoints...');
      }

      // Load products dan categories bersamaan
      final results = await Future.wait([
        ProductService.getAllProducts(),
        ProductService.getWasteCategories(),
      ]);

      final loadedProducts = results[0];
      final loadedCategories = results[1];

      if (kDebugMode) {
        print('✅ Successfully loaded data:');
        print('  - Products: ${loadedProducts.length}');
        print('  - Categories: ${loadedCategories.length}');
        
        if (loadedProducts.isNotEmpty) {
          print('\nProduct samples:');
          for (int i = 0; i < loadedProducts.length && i < 3; i++) {
            final product = loadedProducts[i];
            print('  ${i + 1}. ${product['name']} - ${product['price']} (Stock: ${product['stock']})');
          }
        }
        
        if (loadedCategories.isNotEmpty) {
          print('\nCategories:');
          for (int i = 0; i < loadedCategories.length; i++) {
            final category = loadedCategories[i];
            print('  ${i + 1}. ${category['category_name']} (ID: ${category['id']})');
          }
        }
      }

      setState(() {
        products = loadedProducts;
        categories = loadedCategories;
        filteredProducts = List.from(products);
        isLoading = false;
      });
      
      _applySortAndFilter();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading data: $e');
        print('This could be due to:');
        print('  - Backend server not running');
        print('  - Network connectivity issues');
        print('  - API endpoints not accessible');
      }
      
      setState(() {
        products = [];
        categories = [];
        filteredProducts = [];
        isLoading = false;
        _loadingError = 'Gagal memuat data dari server. Periksa koneksi internet Anda.';
      });
      _showSnackbar('Gagal memuat data produk dari API', isError: true);
    }
  }

  // Refresh data
  Future<void> _refreshData() async {
    if (kDebugMode) {
      print('\n🔄 REFRESHING DATA...');
    }
    await _loadInitialData();
    if (kDebugMode) {
      print('✅ Data refresh completed');
    }
  }

  // Filter dan sort products
  void _applySortAndFilter() {
    if (kDebugMode) {
      print('\n--- Applying Filters and Sort ---');
      print('Search query: "$searchQuery"');
      print('Selected category ID: $selectedCategoryId');
      print('Sort by: $sortBy');
    }

    setState(() {
      filteredProducts = products.where((product) {
        // Filter berdasarkan search query
        bool matchesSearch = searchQuery.isEmpty ||
            (product['name']?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
            (product['description']?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
            (product['category']?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false);

        // Filter berdasarkan category
        bool matchesCategory = selectedCategoryId == null ||
            product['waste_category_id'] == selectedCategoryId;

        return matchesSearch && matchesCategory;
      }).toList();

      // Sort products
      switch (sortBy) {
        case 'nama':
          filteredProducts.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));
          break;
        case 'harga_rendah':
          filteredProducts.sort((a, b) {
            final priceA = _extractPrice(a['price'] ?? '0');
            final priceB = _extractPrice(b['price'] ?? '0');
            return priceA.compareTo(priceB);
          });
          break;
        case 'harga_tinggi':
          filteredProducts.sort((a, b) {
            final priceA = _extractPrice(a['price'] ?? '0');
            final priceB = _extractPrice(b['price'] ?? '0');
            return priceB.compareTo(priceA);
          });
          break;
        case 'stok':
          filteredProducts.sort((a, b) {
            final stockA = (a['stock'] is int) ? a['stock'] as int : int.tryParse(a['stock'].toString()) ?? 0;
            final stockB = (b['stock'] is int) ? b['stock'] as int : int.tryParse(b['stock'].toString()) ?? 0;
            return stockB.compareTo(stockA);
          });
          break;
        case 'terbaru':
        default:
          // Keep original order (assuming API returns newest first)
          break;
      }
    });

    if (kDebugMode) {
      print('Filter/sort applied. Results: ${filteredProducts.length} products');
    }
  }

  // Extract numeric value from price string (Rp 5.000 -> 5000)
  int _extractPrice(String priceString) {
    final numbers = RegExp(r'\d+').allMatches(priceString.replaceAll('.', ''));
    if (numbers.isNotEmpty) {
      return int.tryParse(numbers.first.group(0) ?? '0') ?? 0;
    }
    return 0;
  }

  // Search products
  void _onSearchChanged(String query) {
    if (kDebugMode) {
      print('Search query changed: "$query"');
    }
    
    setState(() {
      searchQuery = query;
    });
    _applySortAndFilter();
  }

  // Filter berdasarkan kategori
  void _onCategorySelected(int? categoryId) {
    if (kDebugMode) {
      print('Category selected: $categoryId');
    }
    
    setState(() {
      selectedCategoryId = categoryId;
    });
    _applySortAndFilter();
  }

  // Sort products
  void _onSortChanged(String newSortBy) {
    if (kDebugMode) {
      print('Sort changed to: $newSortBy');
    }
    
    setState(() {
      sortBy = newSortBy;
    });
    _applySortAndFilter();
  }

  // Show snackbar message
  void _showSnackbar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: const Duration(seconds: 3),
          action: isError ? SnackBarAction(
            label: 'Coba Lagi',
            textColor: Colors.white,
            onPressed: _loadInitialData,
          ) : null,
        ),
      );
    }
  }

  void _onTabTapped(int index) {
    if (kDebugMode) {
      print('Tab tapped: $index');
    }
    
    setState(() {
      currentIndex = index;
    });
    
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BerandaPage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => JualBarangPage()),
        );
        break;
      case 2:
        break;
    }
  }

  // Navigate to product detail
  void _onProductTap(Map<String, dynamic> product) async {
    if (kDebugMode) {
      print('\n--- Product Tapped ---');
      print('Product: ${product['name']}');
      print('ID: ${product['id']}');
      print('Price: ${product['price']}');
      print('Stock: ${product['stock']}');
      print('Category: ${product['category']}');
      print('Navigating to ProductDetailPage...');
    }
    
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(
          product: product,
          previousPage: 'jelajahi',
        ),
      ),
    );
  }

  // Show sort options
  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Urutkan Berdasarkan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSortOption('terbaru', 'Terbaru', Icons.access_time),
            _buildSortOption('nama', 'Nama A-Z', Icons.sort_by_alpha),
            _buildSortOption('harga_rendah', 'Harga Terendah', Icons.arrow_upward),
            _buildSortOption('harga_tinggi', 'Harga Tertinggi', Icons.arrow_downward),
            _buildSortOption('stok', 'Stok Terbanyak', Icons.inventory),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String value, String label, IconData icon) {
    final isSelected = sortBy == value;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.primary : Colors.grey),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.primary : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? Icon(Icons.check, color: AppColors.primary) : null,
      onTap: () {
        Navigator.pop(context);
        _onSortChanged(value);
      },
    );
  }

  // Build category filter chips
  Widget _buildCategoryFilter() {
    if (categories.isEmpty && !isLoading) {
      return Container(
        height: 50,
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: const Center(
          child: Text(
            'Tidak ada kategori tersedia',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: const Text('Semua'),
                selected: selectedCategoryId == null,
                onSelected: (selected) {
                  _onCategorySelected(null);
                },
                selectedColor: AppColors.primary.withOpacity(0.2),
                checkmarkColor: AppColors.primary,
              ),
            );
          }
          
          final category = categories[index - 1];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category['category_name'] ?? 'Unknown'),
              selected: selectedCategoryId == category['id'],
              onSelected: (selected) {
                _onCategorySelected(selected ? category['id'] : null);
              },
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
            ),
          );
        },
      ),
    );
  }

  // Build products grid
  Widget _buildProductsGrid() {
    if (isLoading) {
      return const Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Memuat produk dari database API...'),
            ],
          ),
        ),
      );
    }

    if (_loadingError.isNotEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                _loadingError,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadInitialData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (filteredProducts.isEmpty) {
      return Expanded(child: _buildEmptyState());
    }

    if (kDebugMode) {
      print('Rendering grid with ${filteredProducts.length} products');
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 0.8,
          ),
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            final product = filteredProducts[index];
            final stockValue = product['stock'];
            final stock = (stockValue is int) ? stockValue : int.tryParse(stockValue.toString()) ?? 0;

            if (kDebugMode && index < 3) {
              print('Rendering product $index: ${product['name']} - Stock: $stock');
            }

            return GestureDetector(
              onTap: () => _onProductTap(product),
              child: Stack(
                children: [
                  ProductCard(
                    productName: product['name'] ?? 'Produk',
                    description: product['description'] ?? '',
                    price: product['price'] ?? 'Rp 0',
                    stock: stock,
                    isSelected: false,
                    isInSelectionMode: false,
                    textColor: AppColors.primary,
                    image: product['image'],
                    images: product['images'],
                  ),
                  
                  // View icon overlay
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.visibility,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  
                  // Stock status indicator
                  if (stock <= 5 && stock > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Stok $stock',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  // Out of stock overlay
                  if (stock <= 0)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text(
                            'HABIS',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Stack(
          children: [
            // Background wave
            ClipPath(
              clipper: TopWaveClipper(),
              child: Container(
                height: 280,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),

            // Content
            SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Jelajahi Produk',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'silahkan mencari barang yang anda minati',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.inventory,
                                color: Colors.white,
                                size: 20,
                              ),
                              Text(
                                '${filteredProducts.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search bar
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search,
                          color: Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            decoration: const InputDecoration(
                              hintText: 'Cari produk dari database...',
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                            child: const Icon(
                              Icons.clear,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _showSortOptions,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.sort,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Category filter
                  _buildCategoryFilter(),

                  // Stats info
                  if (!isLoading && filteredProducts.isNotEmpty && _loadingError.isEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${filteredProducts.length} produk dari API',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _getSortLabel(),
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 10),

                  // Products grid
                  _buildProductsGrid(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  String _getSortLabel() {
    switch (sortBy) {
      case 'nama':
        return 'Diurutkan: A-Z';
      case 'harga_rendah':
        return 'Diurutkan: Harga ↑';
      case 'harga_tinggi':
        return 'Diurutkan: Harga ↓';
      case 'stok':
        return 'Diurutkan: Stok';
      case 'terbaru':
      default:
        return 'Diurutkan: Terbaru';
    }
  }

  // Build empty state widget
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            searchQuery.isNotEmpty ? Icons.search_off : Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery.isNotEmpty 
                ? 'Tidak ada produk ditemukan'
                : 'Belum ada produk tersedia',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isNotEmpty 
                ? 'Coba kata kunci lain atau ubah filter'
                : 'Produk dari database API akan muncul di sini',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          if (searchQuery.isNotEmpty || selectedCategoryId != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (kDebugMode) {
                  print('Resetting all filters');
                }
                _searchController.clear();
                setState(() {
                  searchQuery = '';
                  selectedCategoryId = null;
                });
                _applySortAndFilter();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reset Filter'),
            ),
          ],
        ],
      ),
    );
  }
}