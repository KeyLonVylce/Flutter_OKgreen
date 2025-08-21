import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class ProductCard extends StatelessWidget {
  final String? imagePath;
  final IconData? icon;
  final Color? iconColor;
  final String? productName;
  final String description;
  final String price;
  final Color? backgroundColor;

  const ProductCard({
    super.key,
    this.imagePath,
    this.icon,
    this.iconColor,
    this.productName,
    required this.description,
    required this.price,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image or icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: imagePath != null 
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    imagePath!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to icon if image fails to load
                      return _buildIconContainer();
                    },
                  ),
                )
              : _buildIconContainer(),
          ),
          const Spacer(),
          // Product description
          Text(
            description, 
            style: AppTextStyles.smallDescription.copyWith(
              fontSize: 11,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          // Product price
          Text(
            price, 
            style: AppTextStyles.price.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconContainer() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: (iconColor ?? AppColors.primary).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon ?? Icons.shopping_bag_outlined, 
        color: iconColor ?? AppColors.primary, 
        size: 40,
      ),
    );
  }
}

// Usage example - how to implement the Row with ProductCards
class ProductCardExample extends StatelessWidget {
  const ProductCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
      ],
    );
  }
}