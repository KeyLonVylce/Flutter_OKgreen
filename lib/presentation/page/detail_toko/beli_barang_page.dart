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
    {'name': 'iPhone 12 Pro', 'price': '\$699', 'icon': Icons.phone_iphone, 'description': 'iPhone 12 Pro - TechStore', 'image': '📱'},
    {'name': 'Nike Air Force', 'price': '\$85', 'icon': Icons.sports_soccer, 'description': 'Nike Air Force - ShoesHub', 'image': '👟'},
    {'name': 'MacBook Air M1', 'price': '\$899', 'icon': Icons.laptop_mac, 'description': 'MacBook Air M1 - LaptopWorld', 'image': '💻'},
    {'name': 'Samsung Galaxy', 'price': '\$549', 'icon': Icons.smartphone, 'description': 'Samsung Galaxy - PhoneShop', 'image': '📱'},
    {'name': 'iPad Pro 11"', 'price': '\$749', 'icon': Icons.tablet_mac, 'description': 'iPad Pro 11" - TabletStore', 'image': '📲'},
    {'name': 'AirPods Pro', 'price': '\$199', 'icon': Icons.headphones, 'description': 'AirPods Pro - AudioHub', 'image': '🎧'},
    {'name': 'Dell Monitor', 'price': '\$299', 'icon': Icons.computer, 'description': 'Dell Monitor - TechGear', 'image': '🖥️'},
    {'name': 'Gaming Chair', 'price': '\$159', 'icon': Icons.chair, 'description': 'Gaming Chair - FurnitureShop', 'image': '🪑'},
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
      final existingIndex = selectedProducts.indexWhere(
        (item) => item['name'] == product['name']
      );
      
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
                
                // Products grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 0.75, // Made cards taller
                      ),
                      itemCount: 8,
                      itemBuilder: (context, index) {
                        return _buildProductCard(index);
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

  Widget _buildProductCard(int index) {
    final product = products[index % products.length];
    bool isSelected = _isProductSelected(product);
    
    return GestureDetector(
      onTap: () => _toggleProductSelection(product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelected 
            ? Border.all(color: AppColors.primary, width: 2)
            : Border.all(color: Colors.grey[200]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Product content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon/Image container
                  Container(
                    width: double.infinity,
                    height: 80,
                    decoration: BoxDecoration(
                      color: isSelected 
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        product['icon'] as IconData,
                        size: 40,
                        color: isSelected ? AppColors.primary : Colors.grey[600],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Product name
                  Text(
                    product['name']!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Product description
                  Text(
                    product['description']!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const Spacer(),
                  
                  // Price
                  Text(
                    product['price']!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primary : Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
            
            // Checkmark for selected items
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
      ),
    );
  }
}