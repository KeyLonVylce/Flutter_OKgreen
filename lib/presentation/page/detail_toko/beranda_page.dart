import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:okgreen/core/constants/app_colors.dart';
import 'package:okgreen/core/constants/app_icons.dart';
import 'package:okgreen/presentation/page/detail_toko/jelajahi_barang.dart';
import 'package:okgreen/presentation/page/detail_toko/jual_barang_page.dart';
import 'package:okgreen/presentation/page/detail_toko/product_detail_page.dart';
import 'package:okgreen/presentation/page/detail_toko/setting_page.dart';
import 'package:okgreen/presentation/page/detail_toko/notification_page.dart';
import 'package:okgreen/presentation/widget/bottom_navbar.dart';
import 'package:okgreen/presentation/widget/product_card.dart';
import 'package:okgreen/presentation/widget/top_wave.dart';
import 'package:okgreen/service/auth_service.dart';
import 'package:okgreen/service/product_service.dart';
import 'package:okgreen/service/notification_service.dart';
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
  final NotificationService _notificationService = NotificationService();
  
  // Product data
  List<Map<String, dynamic>> products = [];
  bool isLoadingProducts = true;
  String _loadingError = '';
  
  // User points data
  int _userPoints = 0;
  bool isLoadingPoints = true;
  
  // Notification
  int _unreadNotificationCount = 0;

  // EcoCard images list
  final List<String> _ecoCardImages = [
    'assets/EcoCard1.jpg',
    'assets/EcoCard2.jpg',
    'assets/EcoCard3.jpg',
    'assets/EcoCard4.jpg',
    'assets/EcoCard5.jpg',
    'assets/EcoCard6.jpg',
  ];

  @override
  void initState() {
    super.initState();
    
    // Test koneksi API saat debug
    if (kDebugMode) {
      print('=== INIT BerandaPage ===');
      _testApiConnection();
    }
    
    _loadUserData();
    _loadProducts();
    _loadNotificationCount();
    _loadUserPoints();
  }

  // Test API connection
  Future<void> _testApiConnection() async {
    try {
      print('Testing API connection...');
      final isConnected = await ProductService.testConnection();
      print('API connection test result: $isConnected');
      
      if (isConnected) {
        await ProductService.debugConnection();
      }
    } catch (e) {
      print('Error testing API connection: $e');
    }
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
      
      await _loadNotificationCount();
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _userName = 'Pengguna';
      });
    }
  }

  // Load user points
  Future<void> _loadUserPoints() async {
    setState(() {
      isLoadingPoints = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _userPoints = 0;
        isLoadingPoints = false;
      });
    } catch (e) {
      print('Error loading user points: $e');
      setState(() {
        _userPoints = 0;
        isLoadingPoints = false;
      });
    }
  }

  // Load notification count
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

  // Load products from database
  Future<void> _loadProducts() async {
    setState(() {
      isLoadingProducts = true;
      _loadingError = '';
    });

    try {
      if (kDebugMode) {
        print('Loading products from database...');
      }
      
      final productData = await ProductService.getAllProducts();
      
      if (kDebugMode) {
        print('Loaded ${productData.length} products from database');
        if (productData.isNotEmpty) {
          print('Sample product: ${productData[0]}');
        }
      }
      
      setState(() {
        products = productData;
        isLoadingProducts = false;
      });
    } catch (e) {
      print('Error loading products: $e');
      setState(() {
        products = [];
        isLoadingProducts = false;
        _loadingError = 'Gagal memuat data produk dari server';
      });
      
      if (mounted) {
        _showErrorSnackBar('Gagal memuat data produk. Periksa koneksi internet Anda.');
      }
    }
  }

  // Refresh all data
  Future<void> _refreshData() async {
    if (kDebugMode) {
      print('Refreshing all data...');
    }
    
    await Future.wait([
      _loadUserData(),
      _loadProducts(),
      _loadNotificationCount(),
      _loadUserPoints(),
    ]);
  }

  // Navigation handlers
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
          MaterialPageRoute(builder: (context) => JelajahiProdukPage()),
        );
        break;
    }
  }

  void _onNotificationTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NotificationPage()),
    ).then((_) {
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
    if (kDebugMode) {
      print('Product tapped: ${product['name']}');
      print('Product data: $product');
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(
          product: product,
          previousPage: 'beranda',
        ),
      ),
    );
  }

  // Show error snackbar
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Coba Lagi',
            textColor: Colors.white,
            onPressed: () {
              _loadProducts();
            },
          ),
        ),
      );
    }
  }

  // Build EcoCard with images
  Widget _buildEcoCard(int index) {
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          _ecoCardImages[index % _ecoCardImages.length],
          width: double.infinity,
          height: 160,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
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
            );
          },
        ),
      ),
    );
  }

  // Build points card
  Widget _buildPointsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Poin Kamu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          isLoadingPoints
              ? const Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Memuat...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _userPoints.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Text(
                        'poin',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
          const SizedBox(height: 12),
          Text(
            'Jual sampah untuk mendapatkan lebih banyak poin!',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Build products section
  Widget _buildProductsSection() {
    if (isLoadingProducts) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Memuat produk dari database...',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    if (_loadingError.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
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
                onPressed: _loadProducts,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (products.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'Belum ada produk tersedia',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Produk dari database akan muncul di sini',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.8,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.take(4).length,
      itemBuilder: (context, index) {
        final product = products[index];
        return GestureDetector(
          onTap: () => _onProductTap(product),
          child: ProductCard(
            productName: product['name'] ?? 'Produk',
            description: product['description'] ?? '',
            price: product['price'] ?? 'Rp 0',
            stock: product['stock'] ?? 0,
            textColor: AppColors.primary,
            image: product['image'],
            images: product['images'],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Stack(
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
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
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 20,
                                        minHeight: 20,
                                      ),
                                      child: Text(
                                        _unreadNotificationCount > 99 ? '99+' : _unreadNotificationCount.toString(),
                                        style: const TextStyle(
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

                            // Carousel with EcoCard images
                            SizedBox(
                              height: 160,
                              child: Stack(
                                children: [
                                  PageView.builder(
                                    controller: _pageController,
                                    itemCount: _ecoCardImages.length,
                                    onPageChanged: (index) {
                                      setState(() {
                                        _currentCarouselIndex = index;
                                      });
                                    },
                                    itemBuilder: (context, index) {
                                      return _buildEcoCard(index);
                                    },
                                  ),
                                  Positioned(
                                    bottom: 12,
                                    left: 0,
                                    right: 0,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(_ecoCardImages.length, (index) {
                                        return AnimatedContainer(
                                          duration: const Duration(milliseconds: 300),
                                          margin: const EdgeInsets.symmetric(horizontal: 4),
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

                            const SizedBox(height: 20),

                            // Points Card
                            _buildPointsCard(),

                            const SizedBox(height: 30),

                            // Section header with "Lihat Semua"
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Produk Terbaru',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => JelajahiProdukPage()),
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

                            // Products from database
                            _buildProductsSection(),

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