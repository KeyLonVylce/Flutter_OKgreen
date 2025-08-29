import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class ProductCard extends StatelessWidget {
  final String? productName;
  final String description;
  final String price;
  final int stock;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isSelected;
  final bool isInSelectionMode;

  const ProductCard({
    super.key,
    this.productName,
    required this.description,
    required this.price,
    required this.stock,
    this.backgroundColor,
    this.textColor,
    this.isSelected = false,
    this.isInSelectionMode = false,
  });

  @override
  Widget build(BuildContext context) {
    // Determine card background color - NO TRANSPARENCY
    Color cardBackground;
    if (isSelected) {
      cardBackground = Colors.blue[50]!; // Light blue instead of transparent green
    } else {
      cardBackground = backgroundColor ?? AppColors.white;
    }

    return Container(
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: isSelected 
            ? Border.all(color: Colors.blue[600]!, width: 2) // Blue border instead of primary
            : null,
        boxShadow: [
          BoxShadow(
            color: isSelected 
                ? Colors.blue.withOpacity(0.2)
                : Colors.black.withOpacity(0.08),
            blurRadius: isSelected ? 15 : 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Main card content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name area (replacing image placeholder)
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      // Use solid colors instead of transparency
                      color: isSelected 
                          ? Colors.blue[100]! // Solid light blue
                          : Colors.grey[100]!,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected 
                          ? Border.all(color: Colors.blue[300]!) // Solid blue border
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      productName ?? "No Image",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.price.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected 
                            ? Colors.blue[800]! // Solid blue text
                            : (textColor ?? Colors.grey[700]),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Product description and stock
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          description,
                          style: AppTextStyles.smallDescription.copyWith(
                            fontSize: 12,
                            height: 1.3,
                            color: isSelected 
                                ? Colors.grey[800] 
                                : Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Stock info
                      Text(
                        'Stok: $stock',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: stock > 0 ? Colors.green[600] : Colors.red[600],
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Product price
                      Text(
                        price,
                        style: AppTextStyles.price.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected 
                              ? Colors.blue[800]! // Solid blue instead of primary
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Corner indicator for stock status
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: stock > 0 
                    ? (isSelected ? Colors.blue[600]! : Colors.blue[500]!) // Solid blue colors
                    : Colors.red[400]!,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Center(
                child: Icon(
                  stock > 0 ? Icons.inventory : Icons.remove_shopping_cart,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),

          // Selection indicator (checkmark)
          if (isSelected)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.blue[600]!, // Solid blue instead of primary
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
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

          // Selection mode indicator (when in selection mode but not selected)
          if (isInSelectionMode && !isSelected)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[400]!, width: 1),
                ),
                child: Icon(
                  Icons.add,
                  color: Colors.grey[600],
                  size: 16,
                ),
              ),
            ),
          
          // Out of stock overlay - SOLID WHITE instead of transparent
          if (stock <= 0)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white, // Solid white instead of transparent
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red[500],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'HABIS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}