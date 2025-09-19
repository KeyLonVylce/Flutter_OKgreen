import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:okgreen/core/constants/app_colors.dart';
import 'package:okgreen/presentation/page/detail_toko/beranda_page.dart';
import 'package:okgreen/presentation/page/detail_toko/jual_barang_page.dart';
import 'package:okgreen/presentation/page/detail_toko/product_detail_page.dart';
import 'package:okgreen/presentation/widget/bottom_navbar.dart';
import 'package:okgreen/presentation/widget/top_wave.dart';
import 'package:okgreen/presentation/widget/checkout_widget.dart';
import 'package:okgreen/presentation/widget/product_card.dart';
import 'package:okgreen/service/product_service.dart';

class BeliBarangPage extends StatefulWidget {
  const BeliBarangPage({super.key});

  @override
  State<BeliBarangPage> createState() => _BeliBarangPageState();
}

class _BeliBarangPageState extends State<BeliBarangPage> with TickerProviderStateMixin {
  int currentIndex = 2;
  List<Map<String, dynamic>> selectedProducts = [];
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filteredProducts = [];
  List<Map<String, dynamic>> categories = [];
  bool showCheckoutWidget = false;
  bool isInSelectionMode = false;
  bool isLoading = true;
  String searchQuery = '';
  int? selectedCategoryId;

  // Animation controllers
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  int? _holdingIndex;

  // Text editing controller untuk search
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _loadInitialData();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Load data dari service
  Future<void> _loadInitialData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Load products dan categories bersamaan
      final results = await Future.wait([
        ProductService.getAllProducts(),
        ProductService.getWasteCategories(),
      ]);

      setState(() {
        products = results[0] as List<Map<String, dynamic>>;
        categories = results[1] as List<Map<String, dynamic>>;
        filteredProducts = List.from(products);
        isLoading = false;
      });
    } catch (e) {
      print('Error loading initial data: $e');
      setState(() {
        isLoading = false;
      });
      _showErrorSnackbar('Gagal memuat data produk');
    }
  }

  // Refresh data
  Future<void> _refreshData() async {
    await _loadInitialData();
  }

  // Filter products berdasarkan search query dan category
  void _filterProducts() {
    setState(() {
      filteredProducts = products.where((product) {
        // Filter berdasarkan search query
        bool matchesSearch = searchQuery.isEmpty ||
            product['name'].toLowerCase().contains(searchQuery.toLowerCase()) ||
            product['description'].toLowerCase().contains(searchQuery.toLowerCase()) ||
            product['category'].toLowerCase().contains(searchQuery.toLowerCase());

        // Filter berdasarkan category
        bool matchesCategory = selectedCategoryId == null ||
            product['waste_category_id'] == selectedCategoryId;

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  // Search products
  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
    });
    _filterProducts();
  }

  // Filter berdasarkan kategori
  void _onCategorySelected(int? categoryId) {
    setState(() {
      selectedCategoryId = categoryId;
    });
    _filterProducts();
  }

  // Show error message
  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Show success message
  void _showSuccessSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _onTabTapped(int index) {
    if (isInSelectionMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selesaikan dulu pilihan produk'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
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
        // Already on beli barang page
        break;
    }
  }

  void _onProductTap(Map<String, dynamic> product, int index) async {
    if (isInSelectionMode) {
      _toggleProductSelection(product, index);
    } else {
      // Navigate to product detail page
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailPage(product: product),
        ),
      );
      
      // Handle result from product detail page
      if (result != null && result is Map<String, dynamic>) {
        final action = result['action'];
        final productWithQuantity = result['product'];
        
        if (action == 'add_to_cart') {
          _addProductToCart(productWithQuantity);
        } else if (action == 'buy_now') {
          _buyProductNow(productWithQuantity);
        }
      }
    }
  }

  // Method baru untuk menambah ke keranjang dari detail page
  void _addProductToCart(Map<String, dynamic> product) {
    final stock = product['stock'] as int;
    final quantity = product['purchasedQuantity'] as int;
    
    if (stock <= 0) {
      _showErrorSnackbar('Stok produk habis');
      return;
    }
    
    if (quantity > stock) {
      _showErrorSnackbar('Jumlah melebihi stok tersedia');
      return;
    }
    
    setState(() {
      // Check if product already in cart
      final existingIndex = selectedProducts.indexWhere((item) => item['id'] == product['id']);
      
      if (existingIndex >= 0) {
        // Update quantity if already exists
        int currentQty = selectedProducts[existingIndex]['purchasedQuantity'] ?? 1;
        int newQty = currentQty + quantity;
        
        if (newQty <= stock) {
          selectedProducts[existingIndex]['purchasedQuantity'] = newQty;
          _showSuccessSnackbar('Jumlah produk diperbarui di keranjang');
        } else {
          _showErrorSnackbar('Total jumlah melebihi stok tersedia');
          return;
        }
      } else {
        // Add new product
        selectedProducts.add(product);
        _showSuccessSnackbar('Produk ditambahkan ke keranjang');
      }
      
      if (!isInSelectionMode) {
        isInSelectionMode = true;
      }
      
      showCheckoutWidget = selectedProducts.isNotEmpty;
    });
  }

  // Method baru untuk beli langsung dari detail page
  void _buyProductNow(Map<String, dynamic> product) async {
    final stock = product['stock'] as int;
    final quantity = product['purchasedQuantity'] as int;
    
    if (stock <= 0) {
      _showErrorSnackbar('Stok produk habis');
      return;
    }
    
    if (quantity > stock) {
      _showErrorSnackbar('Jumlah melebihi stok tersedia');
      return;
    }
    
    // Clear current cart and add this product
    setState(() {
      selectedProducts.clear();
      selectedProducts.add(product);
      isInSelectionMode = true;
      showCheckoutWidget = true;
    });
    
    // Show success message
    _showSuccessSnackbar('Produk siap untuk checkout');
    
    // Optional: Auto-scroll to show checkout widget
    Future.delayed(const Duration(milliseconds: 500), () {
      // You can add scroll logic here if needed
    });
  }

  void _toggleProductSelection(Map<String, dynamic> product, int index) {
    if (product['stock'] <= 0) {
      _showErrorSnackbar('Stok produk habis');
      return;
    }

    HapticFeedback.selectionClick();
    
    setState(() {
      final existingIndex = selectedProducts.indexWhere((item) => item['id'] == product['id']);

      if (existingIndex >= 0) {
        selectedProducts.removeAt(existingIndex);
        
        if (selectedProducts.isEmpty) {
          isInSelectionMode = false;
        }
      } else {
        Map<String, dynamic> productCopy = Map.from(product);
        selectedProducts.add(productCopy);
        
        if (!isInSelectionMode) {
          isInSelectionMode = true;
        }
      }

      showCheckoutWidget = selectedProducts.isNotEmpty;
    });
  }

  bool _isProductSelected(Map<String, dynamic> product) {
    return selectedProducts.any((item) => item['id'] == product['id']);
  }

  void _hideCheckoutWidget() {
    setState(() {
      showCheckoutWidget = false;
      selectedProducts.clear();
      isInSelectionMode = false;
    });
  }

  void _exitSelectionMode() {
    setState(() {
      isInSelectionMode = false;
      selectedProducts.clear();
      showCheckoutWidget = false;
    });
    _showSuccessSnackbar('Mode pilih dibatalkan');
  }

  void _removeFromCart(Map<String, dynamic> product) {
    setState(() {
      selectedProducts.removeWhere((item) => item['id'] == product['id']);
      if (selectedProducts.isEmpty) {
        showCheckoutWidget = false;
        isInSelectionMode = false;
      }
    });
  }

  // Update stock setelah checkout berhasil
  Future<void> _updateStockAfterCheckout(List<Map<String, dynamic>> purchasedProducts) async {
    for (var purchasedProduct in purchasedProducts) {
      int wasteTypeId = purchasedProduct['id'];
      double weightSold = (purchasedProduct['purchasedQuantity'] ?? 1).toDouble();
      
      // Update stock di database
      bool success = await ProductService.updateStock(wasteTypeId, weightSold);
      
      if (success) {
        // Update local stock
        int productIndex = products.indexWhere((p) => p['id'] == wasteTypeId);
        if (productIndex >= 0) {
          setState(() {
            int newStock = (products[productIndex]['stock'] as int) - weightSold.toInt();
            products[productIndex]['stock'] = newStock >= 0 ? newStock : 0;
          });
        }
      }
    }
    
    setState(() {
      selectedProducts.clear();
      showCheckoutWidget = false;
      isInSelectionMode = false;
    });
    
    _filterProducts(); // Refresh filtered products
    _showSuccessSnackbar('Pembelian berhasil!');
  }

  void _onLongPressStart(int index) {
    setState(() {
      _holdingIndex = index;
    });
    _scaleController.forward();
  }

  void _onLongPressEnd() {
    setState(() {
      _holdingIndex = null;
    });
    _scaleController.reverse();
  }

  void _onProductLongPress(Map<String, dynamic> product, int index) {
    if (product['stock'] <= 0) {
      _showErrorSnackbar('Stok produk habis');
      return;
    }

    HapticFeedback.mediumImpact();

    setState(() {
      if (!isInSelectionMode) {
        isInSelectionMode = true;
        Map<String, dynamic> productCopy = Map.from(product);
        selectedProducts.add(productCopy);
        showCheckoutWidget = true;
      } else {
        _toggleProductSelection(product, index);
      }
    });
  }

  // Build category filter chips
  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length + 1, // +1 untuk "Semua"
        itemBuilder: (context, index) {
          if (index == 0) {
            // "Semua" chip
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
              label: Text(category['category_name']),
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isInSelectionMode) {
          _exitSelectionMode();
          return false;
        }
        return true;
      },
      child: Scaffold(
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
                              Row(
                                children: [
                                  Text(
                                    isInSelectionMode ? 'Mode Pilih' : 'Beli Barang',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (isInSelectionMode) ...[
                                    const SizedBox(width: 12),
                                    GestureDetector(
                                      onTap: _exitSelectionMode,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              Text(
                                isInSelectionMode 
                                    ? '${selectedProducts.length} produk dipilih'
                                    : 'Tahan untuk memilih, ketuk untuk detail',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.notifications,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: showCheckoutWidget ? null : () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Keranjang masih kosong'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Stack(
                                    children: [
                                      const Icon(
                                        Icons.shopping_cart,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      if (selectedProducts.isNotEmpty)
                                        Positioned(
                                          right: -2,
                                          top: -2,
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            constraints: const BoxConstraints(
                                              minWidth: 16,
                                              minHeight: 16,
                                            ),
                                            child: Text(
                                              '${selectedProducts.length}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
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
                              enabled: !isInSelectionMode,
                              onChanged: _onSearchChanged,
                              decoration: InputDecoration(
                                hintText: isInSelectionMode 
                                    ? 'Mode pilih aktif...'
                                    : 'Cari sampah daur ulang...',
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  color: isInSelectionMode 
                                      ? Colors.grey[400] 
                                      : Colors.grey,
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
                        ],
                      ),
                    ),

                    // Category filter
                    if (!isInSelectionMode) _buildCategoryFilter(),

                    const SizedBox(height: 10),

                    // Products grid
                    Expanded(
                      child: isLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : filteredProducts.isEmpty
                              ? _buildEmptyState()
                              : Padding(
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
                                      final isSelected = _isProductSelected(product);
                                      final isHolding = _holdingIndex == index;
                                      final stock = product['stock'] as int;

                                      return AnimatedBuilder(
                                        animation: _scaleAnimation,
                                        builder: (context, child) {
                                          return Transform.scale(
                                            scale: isHolding ? _scaleAnimation.value : 1.0,
                                            child: GestureDetector(
                                              onTap: () => _onProductTap(product, index),
                                              onLongPressStart: (_) => _onLongPressStart(index),
                                              onLongPressEnd: (_) {
                                                _onLongPressEnd();
                                                _onProductLongPress(product, index);
                                              },
                                              onLongPressCancel: _onLongPressEnd,
                                              child: Stack(
                                                children: [
                                                  ProductCard(
                                                    productName: product['name'],
                                                    description: product['description'] ?? '',
                                                    price: product['price'] ?? '',
                                                    stock: stock,
                                                    isSelected: isSelected,
                                                    isInSelectionMode: isInSelectionMode,
                                                    textColor: AppColors.primary,
                                                  ),
                                                  if (isHolding)
                                                    Positioned(
                                                      top: 0,
                                                      right: 0,
                                                      child: Container(
                                                        width: 60,
                                                        height: 60,
                                                        decoration: BoxDecoration(
                                                          color: AppColors.primary.withOpacity(0.9),
                                                          borderRadius: const BorderRadius.only(
                                                            topRight: Radius.circular(16),
                                                            bottomLeft: Radius.circular(20),
                                                          ),
                                                        ),
                                                        child: const Icon(
                                                          Icons.touch_app,
                                                          color: Colors.white,
                                                          size: 20,
                                                        ),
                                                      ),
                                                    ),
                                                  // Stock indicator
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
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                    ),
                  ],
                ),
              ),

              // Checkout Widget Overlay
              if (showCheckoutWidget)
                CheckoutWidget(
                  selectedProducts: selectedProducts,
                  onClose: _hideCheckoutWidget,
                  onRemoveItem: _removeFromCart,
                  onCheckoutSuccess: _updateStockAfterCheckout,
                ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavbar(
          currentIndex: currentIndex,
          onTap: _onTabTapped,
        ),
      ),
    );
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
                ? 'Coba kata kunci lain'
                : 'Produk akan segera ditambahkan',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          if (searchQuery.isNotEmpty || selectedCategoryId != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  searchQuery = '';
                  selectedCategoryId = null;
                });
                _filterProducts();
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