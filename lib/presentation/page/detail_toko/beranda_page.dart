import 'package:flutter/material.dart';
import 'package:okgreen/core/constants/app_colors.dart';
import 'package:okgreen/core/constants/app_text_styles.dart';
import 'package:okgreen/presentation/widget/product_card.dart';
import 'package:okgreen/presentation/widget/bottom_navbar.dart';

class BerandaPage extends StatefulWidget {
  @override
  _BerandaPageState createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  int _currentIndex = 0;

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    // TODO: Implement navigation to other pages
    print('Navigating to index: $index');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Key Theola', style: AppTextStyles.greeting),
              const SizedBox(height: 24),
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
      bottomNavigationBar: BottomNavbar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}