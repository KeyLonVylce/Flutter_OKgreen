import 'package:flutter/material.dart';
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

class _BeliBarangPageState extends State<BeliBarangPage> {
  int currentIndex = 2; // Beli Barang tab
  List<Map<String, dynamic>> selectedProducts = [];
  bool showCheckoutWidget = false;

  // Products data
  final List<Map<String, dynamic>> products = [
    {
      'name': 'Product 1',
      'price': 'Rp 10.000',
      'description': 'iPhone 12 Pro - TechStore',
      'image': null, // fallback No Image
    },
    {
      'name': 'Product 1',
      'price': 'Rp 10.000',
      'description': 'Nike Air Force - ShoesHub',
      'image': null,
    },
    {
      'name': 'Product 1',
      'price': 'Rp 10.000',
      'description': 'MacBook Air M1 - LaptopWorld',
      'image': null,
    },
    {
      'name': 'Product 1',
      'price': 'Rp 10.000',
      'description': 'Samsung Galaxy - PhoneShop',
      'image': null,
    },
    {
      'name': 'Product 1"',
      'price': 'Rp 10.000',
      'description': 'iPad Pro 11" - TabletStore',
      'image': null,
    },
    {
      'name': 'Product 1',
      'price': 'Rp 10.000',
      'description': 'AirPods Pro - AudioHub',
      'image': null,
    },
    {
      'name': 'Product 1',
      'price': 'Rp 10.000',
      'description': 'Dell Monitor - TechGear',
      'image': null,
    },
    {
      'name': 'Product 1',
      'price': 'Rp 10.000',
      'description': 'Gaming Chair - FurnitureShop',
      'image': null,
    },
  ];

  void _onTabTapped(int index) {
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

  void _toggleProductSelection(Map<String, dynamic> product) {
    setState(() {
      final existingIndex =
          selectedProducts.indexWhere((item) => item['name'] == product['name']);

      if (existingIndex >= 0) {
        // Product already selected, remove it
        selectedProducts.removeAt(existingIndex);
      } else {
        // Product not selected, add it
        selectedProducts.add(product);
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          const Text(
                            'Beli Barang',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Temukan barang bekas berkualitas',
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
                          Container(
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
                  child: const Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: Colors.grey,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Cari barang yang kamu butuhkan...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Products grid pakai ProductCard
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

                        return GestureDetector(
                          onTap: () => _toggleProductSelection(product),
                          child: Stack(
                            children: [
                              ProductCard(
                                productName: product['name'],
                                description: product['description'] ?? '',
                                price: product['price'] ?? '',
                                // kalau ada image bisa dipakai, kalau null otomatis fallback "No Image"
                                backgroundColor: Colors.white,
                                textColor: isSelected
                                    ? AppColors.primary
                                    : Colors.black,
                              ),
                              if (isSelected)
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                            ],
                          ),
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
            ),
        ],
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
