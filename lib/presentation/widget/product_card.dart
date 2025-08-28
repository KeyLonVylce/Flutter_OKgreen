import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class ProductCard extends StatelessWidget {
  final String? productName;
  final String description;
  final String price;
  final Color? backgroundColor;
  final Color? textColor;

  const ProductCard({
    super.key,
    this.productName,
    required this.description,
    required this.price,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220, // lebih tinggi biar proporsional
      padding: const EdgeInsets.all(12),
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
          // Area atas seukuran placeholder gambar, tapi isi teks productName
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: (textColor ?? AppColors.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              productName ?? "No Image",
              textAlign: TextAlign.center,
              style: AppTextStyles.price.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor ?? AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 19),
          // Product description
          Text(
            description,
            style: AppTextStyles.smallDescription.copyWith(
              fontSize: 12,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 50),
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
}

// Example usage with fallback data (Product 1-5)
class ProductCardExample extends StatelessWidget {
  const ProductCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    // misalnya data gagal ambil dari API, kita pakai dummy
    final List<Map<String, String>> fallbackProducts = List.generate(
      5,
      (index) => {
        "name": "Product ${index + 1}",
        "description": "Deskripsi singkat untuk Product ${index + 1}",
        "price": "Rp ${(index + 1) * 10000}",
      },
    );

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // tampil 2 kolom
        childAspectRatio: 3 / 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: fallbackProducts.length,
      itemBuilder: (context, index) {
        final product = fallbackProducts[index];
        return ProductCard(
          productName: product["name"],
          description: product["description"]!,
          price: product["price"]!,
          textColor: AppColors.primary,
        );
      },
    );
  }
}
