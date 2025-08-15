import 'package:flutter/material.dart';
import 'package:okgreen/core/constants/app_colors.dart';
import 'package:okgreen/core/constants/app_text_styles.dart';
import 'package:okgreen/presentation/page/detail_toko/beli_barang_page.dart';
import 'package:okgreen/presentation/page/detail_toko/edukasi_page.dart';
import 'package:okgreen/presentation/page/detail_toko/jual_barang_page.dart';
import 'package:okgreen/presentation/widget/EcoProductCard.dart';
import 'package:okgreen/presentation/widget/bottom_navbar.dart';
import 'package:okgreen/presentation/widget/product_card.dart';
import 'package:okgreen/presentation/widget/top_wave.dart';



class BerandaPage extends StatefulWidget {
  @override
  _BerandaPageState createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  int _currentIndex = 0;
  PageController _pageController = PageController();
  int _currentCarouselIndex = 0;

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Navigate to other pages based on index
    switch (index) {
      case 0:
        // Already on beranda page
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
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => EdukasiPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // TopWave background
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
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header with greeting and icons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hello, Dika Indradhy Wijaya',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 20,
                            ),
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
                          
                          // Carousel dengan EcoProductCard
                          Container(
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
                                    EcoProductCard(),
                                    EcoProductCard(),
                                    EcoProductCard(),
                                  ],
                                ),
                                
                                // Dots indicator
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
                          
                          // Product Cards
                          Row(
                            children: [
                              Expanded(
                                child: ProductCard(
                                  icon: Icons.local_drink,
                                  iconColor: AppColors.red,
                                  description: 'Lorem ipsum dolor sit amet,\nconsectetur',
                                  price: '\$17.00',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ProductCard(
                                  icon: Icons.shopping_bag_outlined,
                                  iconColor: AppColors.blue,
                                  description: 'Lorem ipsum dolor sit amet,\nconsectetur',
                                  price: '\$17.00',
                                ),
                              ),
                            ],
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