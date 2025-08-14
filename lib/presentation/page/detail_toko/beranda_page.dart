import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../widget/product_card.dart';
import '../../widget/bottom_navbar.dart';

class BerandaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Text('Hello, Dika Indrashy Wijaya', style: AppTextStyles.greeting),
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
              ],
            ),
          ),
          BottomNavbar(
            currentIndex: 0,
            onTap: (index) {
              print("Tapped: $index");
            },
          ),
        ],
      ),
    );
  }
}
