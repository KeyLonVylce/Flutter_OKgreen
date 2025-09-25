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
  final String? image; // Single image URL
  final List<String>? images; // Multiple images URLs
  final VoidCallback? onImageTap; // Callback when image is tapped

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
    this.image,
    this.images,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    // Use images list if available, otherwise use single image
    final imageList = images ?? (image != null ? [image!] : <String>[]);
    final hasImages = imageList.isNotEmpty;

    // Determine card background color
    Color cardBackground;
    if (isSelected) {
      cardBackground = Colors.blue[50]!;
    } else {
      cardBackground = backgroundColor ?? AppColors.white;
    }

    return Container(
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: isSelected 
            ? Border.all(color: Colors.blue[600]!, width: 2)
            : Border.all(color: Colors.grey[200]!, width: 1),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image/Product name area
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    color: Colors.grey[100],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: hasImages
                        ? _buildImageDisplay(imageList)
                        : _buildPlaceholderImage(),
                  ),
                ),
              ),
              
              // Product info section
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product name
                      Text(
                        productName ?? "Produk",
                        style: AppTextStyles.price.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected 
                              ? Colors.blue[800]!
                              : (textColor ?? Colors.black87),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Product description
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
                      
                      const SizedBox(height: 8),
                      
                      // Price and stock row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Product price
                          Expanded(
                            child: Text(
                              price,
                              style: AppTextStyles.price.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isSelected 
                                    ? Colors.blue[800]!
                                    : AppColors.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          
                          // Stock badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: stock > 0 
                                  ? Colors.green[50] 
                                  : Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Stok: $stock',
                              style: TextStyle(
                                fontSize: 10,
                                color: stock > 0 
                                    ? Colors.green[700] 
                                    : Colors.red[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
                  color: Colors.blue[600]!,
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
          
          // Out of stock overlay
          if (stock <= 0)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
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

  Widget _buildImageDisplay(List<String> imageList) {
    if (imageList.length == 1) {
      // Single image
      return GestureDetector(
        onTap: onImageTap,
        child: Image.network(
          imageList.first,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildLoadingIndicator();
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorImage();
          },
        ),
      );
    } else {
      // Multiple images - show first image with indicator
      return GestureDetector(
        onTap: onImageTap,
        child: Stack(
          children: [
            Image.network(
              imageList.first,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildLoadingIndicator();
              },
              errorBuilder: (context, error, stackTrace) {
                return _buildErrorImage();
              },
            ),
            // Multiple images indicator
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.photo_library,
                      color: Colors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${imageList.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.recycling,
            size: 40,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            productName ?? 'No Image',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[100],
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildErrorImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: 40,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'Failed to load',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}