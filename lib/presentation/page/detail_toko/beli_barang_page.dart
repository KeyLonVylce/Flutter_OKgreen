import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For haptic feedback
import 'package:okgreen/core/constants/app_colors.dart';
import 'package:okgreen/presentation/page/detail_toko/beranda_page.dart';
import 'package:okgreen/presentation/page/detail_toko/jual_barang_page.dart';
import 'package:okgreen/presentation/widget/bottom_navbar.dart';
import 'package:okgreen/presentation/widget/top_wave.dart';
import 'package:okgreen/presentation/widget/checkout_widget.dart';
import 'package:okgreen/presentation/widget/product_card.dart';

class BeliBarangPage extends StatefulWidget {
  const BeliBarangPage({super.key});

  @override
  State<BeliBarangPage> createState() => _BeliBarangPageState();
}

class _BeliBarangPageState extends State<BeliBarangPage> with TickerProviderStateMixin {
  int currentIndex = 2; // Beli Barang tab
  List<Map<String, dynamic>> selectedProducts = [];
  bool showCheckoutWidget = false;
  bool isInSelectionMode = false; // Track selection mode

  // Animation controllers for hold feedback
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  
  // Track which item is being held
  int? _holdingIndex;
  
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

    // Initialize stock for each product
    _initializeStock();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  // Initialize random stock for each product
  void _initializeStock() {
    for (var product in products) {
      // Random stock between 15-50
      product['stock'] = 15 + (DateTime.now().millisecondsSinceEpoch % 36);
    }
  }

  // Updated products data with recycled items and different prices
  final List<Map<String, dynamic>> products = [
    {
      'name': 'Kaleng Bekas',
      'price': 'Rp 5.000',
      'description': 'Kaleng coca cola bekas - RecycleShop',
      'image': null,
      'category': 'Metal',
      'condition': 'Baik',
      'weight': '0.5 kg',
      'seller': 'RecycleShop',
      'stock': 0, // Will be randomized in initState
    },
    {
      'name': 'Botol Plastik',
      'price': 'Rp 2.500',
      'description': 'Botol air mineral bekas - EcoStore',
      'image': null,
      'category': 'Plastik',
      'condition': 'Sangat Baik',
      'weight': '0.2 kg',
      'seller': 'EcoStore',
      'stock': 0,
    },
    {
      'name': 'Kotak Rokok',
      'price': 'Rp 3.000',
      'description': 'Kotak rokok kosong - WasteHub',
      'image': null,
      'category': 'Kertas',
      'condition': 'Baik',
      'weight': '0.1 kg',
      'seller': 'WasteHub',
      'stock': 0,
    },
    {
      'name': 'Kantong Plastik',
      'price': 'Rp 1.500',
      'description': 'Kantong belanja bekas - GreenMarket',
      'image': null,
      'category': 'Plastik',
      'condition': 'Baik',
      'weight': '0.05 kg',
      'seller': 'GreenMarket',
      'stock': 0,
    },
    {
      'name': 'Kertas Koran',
      'price': 'Rp 8.000',
      'description': 'Kumpulan koran bekas - PaperRecycle',
      'image': null,
      'category': 'Kertas',
      'condition': 'Baik',
      'weight': '2 kg',
      'seller': 'PaperRecycle',
      'stock': 0,
    },
    {
      'name': 'Kardus Bekas',
      'price': 'Rp 12.000',
      'description': 'Kardus packaging bekas - BoxShop',
      'image': null,
      'category': 'Kertas',
      'condition': 'Sangat Baik',
      'weight': '1.5 kg',
      'seller': 'BoxShop',
      'stock': 0,
    },
    {
      'name': 'Ban Motor',
      'price': 'Rp 25.000',
      'description': 'Ban motor bekas - TireRecycle',
      'image': null,
      'category': 'Karet',
      'condition': 'Baik',
      'weight': '3 kg',
      'seller': 'TireRecycle',
      'stock': 0,
    },
    {
      'name': 'Elektronik Rusak',
      'price': 'Rp 15.000',
      'description': 'Spare part elektronik - TechWaste',
      'image': null,
      'category': 'Elektronik',
      'condition': 'Rusak',
      'weight': '0.8 kg',
      'seller': 'TechWaste',
      'stock': 0,
    },
  ];

  void _onTabTapped(int index) {
    // Don't allow navigation when in selection mode
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
    // Navigate to other pages based on index
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

  // Normal tap - navigate to product detail OR select in selection mode
  void _onProductTap(Map<String, dynamic> product, int index) {
    if (isInSelectionMode) {
      // In selection mode, tap to select/deselect
      _toggleProductSelection(product, index);
    } else {
      // Normal mode - navigate to product detail page
      // TODO: Navigate to product detail page when ready
      print("Navigate to ${product['name']} detail");
      // Navigator.push(context, MaterialPageRoute(builder: (context) => ProductPage(product: product)));
    }
  }

  // Toggle product selection
  void _toggleProductSelection(Map<String, dynamic> product, int index) {
    // Check if product has stock
    if (product['stock'] <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stok produk habis'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Haptic feedback for selection
    HapticFeedback.selectionClick();
    
    setState(() {
      final existingIndex =
          selectedProducts.indexWhere((item) => item['name'] == product['name']);

      if (existingIndex >= 0) {
        // Product already selected, remove it
        selectedProducts.removeAt(existingIndex);
        
        // Exit selection mode if no items selected
        if (selectedProducts.isEmpty) {
          isInSelectionMode = false;
        }
      } else {
        // Product not selected, add it to cart
        Map<String, dynamic> productCopy = Map.from(product);
        selectedProducts.add(productCopy);
        
        // Enter selection mode if not already in it
        if (!isInSelectionMode) {
          isInSelectionMode = true;
        }
      }

      // Show/hide checkout widget based on selection
      showCheckoutWidget = selectedProducts.isNotEmpty;
    });
  }

  bool _isProductSelected(Map<String, dynamic> product) {
    return selectedProducts.any((item) => item['name'] == product['name']);
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
  }

  // Remove item from checkout widget
  void _removeFromCart(Map<String, dynamic> product) {
    setState(() {
      selectedProducts.removeWhere((item) => item['name'] == product['name']);
      if (selectedProducts.isEmpty) {
        showCheckoutWidget = false;
        isInSelectionMode = false;
      }
    });
  }

  // Update stock after successful checkout
  void _updateStockAfterCheckout(List<Map<String, dynamic>> purchasedProducts) {
    setState(() {
      for (var purchasedProduct in purchasedProducts) {
        // Find the product in the main products list
        int productIndex = products.indexWhere((p) => p['name'] == purchasedProduct['name']);
        if (productIndex >= 0) {
          // Reduce stock by purchased quantity
          int purchasedQty = purchasedProduct['purchasedQuantity'] ?? 1;
          products[productIndex]['stock'] = (products[productIndex]['stock'] as int) - purchasedQty;
          
          // Ensure stock doesn't go below 0
          if (products[productIndex]['stock'] < 0) {
            products[productIndex]['stock'] = 0;
          }
        }
      }
      
      // Clear cart and exit selection mode
      selectedProducts.clear();
      showCheckoutWidget = false;
      isInSelectionMode = false;
    });
  }

  // Handle long press start
  void _onLongPressStart(int index) {
    setState(() {
      _holdingIndex = index;
    });
    _scaleController.forward();
  }

  // Handle long press end
  void _onLongPressEnd() {
    setState(() {
      _holdingIndex = null;
    });
    _scaleController.reverse();
  }

  // Long press to enter selection mode
  void _onProductLongPress(Map<String, dynamic> product, int index) {
    // Check if product has stock
    if (product['stock'] <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stok produk habis'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Haptic feedback for long press
    HapticFeedback.mediumImpact();

    setState(() {
      // Enter selection mode if not already in it
      if (!isInSelectionMode) {
        isInSelectionMode = true;
        // Select this product
        Map<String, dynamic> productCopy = Map.from(product);
        selectedProducts.add(productCopy);
        showCheckoutWidget = true;
      } else {
        // Already in selection mode, just toggle selection
        _toggleProductSelection(product, index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isInSelectionMode) {
          // Exit selection mode instead of going back
          _exitSelectionMode();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Stack(
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
                  // Header with greeting
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
                                // Show message if no items selected
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
                            enabled: !isInSelectionMode, // Disable search in selection mode
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
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Products grid with improved selection functionality
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          final isSelected = _isProductSelected(product);
                          final isHolding = _holdingIndex == index;
                          final stock = product['stock'] as int;

                          return AnimatedBuilder(
                            animation: _scaleAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: isHolding ? _scaleAnimation.value : 1.0,
                                child: GestureDetector(
                                  // Normal tap - navigate to product detail OR select in selection mode
                                  onTap: () => _onProductTap(product, index),
                                  
                                  // Long press - enter selection mode and select product
                                  onLongPressStart: (_) => _onLongPressStart(index),
                                  onLongPressEnd: (_) {
                                    _onLongPressEnd();
                                    _onProductLongPress(product, index);
                                  },
                                  onLongPressCancel: _onLongPressEnd,
                                  
                                  child: Stack(
                                    children: [
                                      // Product card with improved styling
                                      ProductCard(
                                        productName: product['name'],
                                        description: product['description'] ?? '',
                                        price: product['price'] ?? '',
                                        stock: stock,
                                        isSelected: isSelected,
                                        isInSelectionMode: isInSelectionMode,
                                        textColor: AppColors.primary,
                                      ),
                                      
                                      // Hold indicator (corner overlay during long press)
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
        bottomNavigationBar: BottomNavbar(
          currentIndex: currentIndex,
          onTap: _onTabTapped,
        ),
      ),
    );
  }
}