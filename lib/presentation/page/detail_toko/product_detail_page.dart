import 'package:flutter/material.dart';
import 'package:okgreen/core/constants/app_colors.dart';
import 'package:okgreen/presentation/page/detail_toko/checkout_page.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;
  final String? previousPage; // Add parameter to track previous page

  const ProductDetailPage({
    super.key,
    required this.product,
    this.previousPage,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int selectedQuantity = 1;
  int maxQuantity = 1;
  
  @override
  void initState() {
    super.initState();
    maxQuantity = (widget.product['stock'] as int).clamp(1, 10);
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final stock = product['stock'] as int;
    final isOutOfStock = stock <= 0;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // App Bar dengan gambar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite_border, color: Colors.white),
                ),
                onPressed: () {
                  // TODO: Implementasi wishlist
                },
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share, color: Colors.white),
                ),
                onPressed: () {
                  // TODO: Implementasi share
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
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
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Placeholder untuk gambar produk
                    Center(
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.recycling,
                          size: 80,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                    // Gradient overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 100,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title dan price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'],
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product['category'] ?? 'Kategori tidak diketahui',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${product['price']}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Stock info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isOutOfStock 
                            ? Colors.red.withOpacity(0.1)
                            : stock <= 5 
                                ? Colors.orange.withOpacity(0.1)
                                : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isOutOfStock 
                              ? Colors.red.withOpacity(0.3)
                              : stock <= 5 
                                  ? Colors.orange.withOpacity(0.3)
                                  : Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isOutOfStock 
                                ? Icons.error_outline
                                : stock <= 5 
                                    ? Icons.warning_amber_outlined
                                    : Icons.check_circle_outline,
                            color: isOutOfStock 
                                ? Colors.red
                                : stock <= 5 
                                    ? Colors.orange
                                    : Colors.green,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isOutOfStock 
                                      ? 'Stok Habis'
                                      : stock <= 5 
                                          ? 'Stok Terbatas'
                                          : 'Stok Tersedia',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: isOutOfStock 
                                        ? Colors.red[700]
                                        : stock <= 5 
                                            ? Colors.orange[700]
                                            : Colors.green[700],
                                  ),
                                ),
                                Text(
                                  '$stock kg tersedia',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Quantity selector (only if in stock)
                    if (!isOutOfStock) ...[
                      Text(
                        'Jumlah',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: selectedQuantity > 1 
                                  ? () => setState(() => selectedQuantity--) 
                                  : null,
                              icon: const Icon(Icons.remove),
                              style: IconButton.styleFrom(
                                backgroundColor: selectedQuantity > 1 
                                    ? AppColors.primary 
                                    : Colors.grey[300],
                                foregroundColor: selectedQuantity > 1 
                                    ? Colors.white 
                                    : Colors.grey[500],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                '$selectedQuantity kg',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: selectedQuantity < maxQuantity 
                                  ? () => setState(() => selectedQuantity++) 
                                  : null,
                              icon: const Icon(Icons.add),
                              style: IconButton.styleFrom(
                                backgroundColor: selectedQuantity < maxQuantity 
                                    ? AppColors.primary 
                                    : Colors.grey[300],
                                foregroundColor: selectedQuantity < maxQuantity 
                                    ? Colors.white 
                                    : Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Description
                    const Text(
                      'Deskripsi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      product['description'] ?? 'Tidak ada deskripsi tersedia untuk produk ini.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 24),

                    const SizedBox(height: 100), // Space for floating button
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // Floating action buttons
      floatingActionButton: isOutOfStock 
          ? null
          : Container(
              margin: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Add to cart button
                  Expanded(
                    child: FloatingActionButton.extended(
                      onPressed: () => _addToCart(context),
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      icon: const Icon(Icons.shopping_cart_outlined),
                      label: const Text(
                        'Tambah ke Keranjang',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Buy now button - Navigate directly to checkout
                  Expanded(
                    child: FloatingActionButton.extended(
                      onPressed: () => _buyNowDirectCheckout(context),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      icon: const Icon(Icons.shopping_bag),
                      label: const Text(
                        'Beli Sekarang',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          const Text(' : '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addToCart(BuildContext context) {
    // Create product copy with quantity
    Map<String, dynamic> productWithQuantity = Map.from(widget.product);
    productWithQuantity['purchasedQuantity'] = selectedQuantity;
    
    // Return product to previous page
    Navigator.pop(context, {
      'action': 'add_to_cart',
      'product': productWithQuantity,
    });
  }

  void _buyNow(BuildContext context) {
    // Create product copy with quantity for immediate checkout
    Map<String, dynamic> productWithQuantity = Map.from(widget.product);
    productWithQuantity['purchasedQuantity'] = selectedQuantity;
    
    // Return product for immediate purchase
    Navigator.pop(context, {
      'action': 'buy_now',
      'product': productWithQuantity,
    });
  }

  // New method for direct checkout navigation
  void _buyNowDirectCheckout(BuildContext context) {
    // Create product copy with quantity
    Map<String, dynamic> productWithQuantity = Map.from(widget.product);
    productWithQuantity['purchasedQuantity'] = selectedQuantity;
    
    // Navigate directly to checkout page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(
          selectedProducts: [productWithQuantity],
          onCheckoutSuccess: (purchasedProducts) {
            // Handle success - navigate back to the appropriate page
            Navigator.of(context).popUntil((route) => route.isFirst);
            
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pembelian berhasil!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      ),
    );
  }
}