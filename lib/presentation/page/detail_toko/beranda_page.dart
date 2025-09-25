import 'package:flutter/material.dart';
import 'package:okgreen/core/constants/app_colors.dart';
import 'package:okgreen/core/constants/app_icons.dart';
import 'package:okgreen/presentation/page/detail_toko/beli_barang_page.dart';
import 'package:okgreen/presentation/page/detail_toko/jual_barang_page.dart';
import 'package:okgreen/presentation/page/detail_toko/product_detail_page.dart';
import 'package:okgreen/presentation/page/detail_toko/setting_page.dart';
import 'package:okgreen/presentation/page/detail_toko/notification_page.dart'; // Tambahan
import 'package:okgreen/presentation/widget/bottom_navbar.dart';
import 'package:okgreen/presentation/widget/product_card.dart';
import 'package:okgreen/presentation/widget/top_wave.dart';
import 'package:okgreen/service/auth_service.dart';
import 'package:okgreen/service/product_service.dart';
import 'package:okgreen/service/notification_service.dart'; // Tambahan
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  _BerandaPageState createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  int _currentCarouselIndex = 0;
  String _userName = 'Pengguna';
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService(); // Tambahan
  
  // Product data
  List<Map<String, dynamic>> products = [];
  bool isLoadingProducts = true;
  
  // Tambahan untuk notification
  int _unreadNotificationCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadProducts();
    _loadNotificationCount(); // Tambahan
  }

  // Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      
      if (userDataString != null) {
        final userData = json.decode(userDataString);
        setState(() {
          _userName = userData['name'] ?? userData['user']?['name'] ?? 'Pengguna';
        });
      }
      
      // Refresh notification count juga
      await _loadNotificationCount();
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _userName = 'Pengguna';
      });
    }
  }

  // Tambahan method untuk load notification count
  Future<void> _loadNotificationCount() async {
    try {
      final count = await _notificationService.getUnreadCount();
      if (mounted) {
        setState(() {
          _unreadNotificationCount = count;
        });
      }
    } catch (e) {
      print('Error loading notification count: $e');
    }
  }

  // Load products from service - same as BeliBarangPage
  Future<void> _loadProducts() async {
    setState(() {
      isLoadingProducts = true;
    });

    try {
      final productData = await ProductService.getAllProducts();
      setState(() {
        products = productData;
        isLoadingProducts = false;
      });
    } catch (e) {
      print('Error loading products: $e');
      setState(() {
        products = [];
        isLoadingProducts = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data produk'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Get 4 random products
  List<Map<String, dynamic>> _getRandomProducts() {
    if (products.isEmpty) return [];
    List<Map<String, dynamic>> shuffledProducts = List.from(products);
    shuffledProducts.shuffle();
    return shuffledProducts.take(4).toList();
  }

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => JualBarangPage()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BeliBarangPage()),
        );
        break;
    }
  }

  // Update method notification tap
  void _onNotificationTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NotificationPage()),
    ).then((_) {
      // Refresh notification count setelah kembali dari halaman notifikasi
      _loadNotificationCount();
    });
  }

  void _onSettingsTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsPage()),
    ).then((_) {
      _loadUserData();
    });
  }

  void _onProductTap(Map<String, dynamic> product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(
          product: product,
          previousPage: 'beranda',
        ),
      ),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => BeliBarangPage()),
    );
  }

  Widget _buildPlaceholderCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.image,
          size: 50,
          color: Colors.grey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          ClipPath(
            clipper: TopWaveClipper(),
            child: Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Hello, $_userName',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          // Update bagian notification dengan badge
                          Stack(
                            children: [
                              HeaderIcon(
                                icon: HeaderIcons.notification,
                                onTap: _onNotificationTap,
                              ),
                              if (_unreadNotificationCount > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    constraints: BoxConstraints(
                                      minWidth: 20,
                                      minHeight: 20,
                                    ),
                                    child: Text(
                                      _unreadNotificationCount > 99 ? '99+' : _unreadNotificationCount.toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          HeaderIcon(
                            icon: HeaderIcons.profile,
                            onTap: _onSettingsTap,
                            isProfileIcon: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),

                          SizedBox(
                            height: 160,
                            child: Stack(
                              children: [
                                PageView(
                                  controller: _pageController,
                                  onPageChanged: (index) {
                                    setState(() {
                                      _currentCarouselIndex = index;
                                    });
                                  },
                                  children: [
                                    _buildPlaceholderCard(),
                                    _buildPlaceholderCard(),
                                    _buildPlaceholderCard(),
                                  ],
                                ),
                                Positioned(
                                  bottom: 12,
                                  left: 0,
                                  right: 0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(3, (index) {
                                      return AnimatedContainer(
                                        duration: Duration(milliseconds: 300),
                                        margin: EdgeInsets.symmetric(horizontal: 4),
                                        width: _currentCarouselIndex == index ? 24 : 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: _currentCarouselIndex == index
                                              ? AppColors.primary
                                              : AppColors.primary.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => BeliBarangPage()),
                                  );
                                },
                                child: Text(
                                  'Lihat Semua',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          isLoadingProducts 
                              ? const Center(child: CircularProgressIndicator())
                              : GridView.builder(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 15,
                                    mainAxisSpacing: 15,
                                    childAspectRatio: 0.8,
                                  ),
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: products.take(4).length,
                                  itemBuilder: (context, index) {
                                    final product = products[index];
                                    final stock = (product['stock'] ?? 0) is int ? product['stock'] as int : 0;
                                    final price = product['price']?.toString() ?? '0';

                                    return GestureDetector(
                                      onTap: () => _onProductTap(product),
                                      child: Stack(
                                        children: [
                                          ProductCard(
                                            productName: product['name'] ?? 'Produk',
                                            description: product['description'] ?? '',
                                            price: price,
                                            stock: stock,
                                            textColor: AppColors.primary,
                                          ),

                                          if (stock <= 5 && stock > 0)
                                            Positioned(
                                              top: 8,
                                              left: 8,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}