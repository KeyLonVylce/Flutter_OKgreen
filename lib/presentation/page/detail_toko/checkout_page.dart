import 'package:flutter/material.dart';
import 'package:okgreen/core/constants/app_colors.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> selectedProducts;
  final Function(List<Map<String, dynamic>>)? onCheckoutSuccess;

  const CheckoutPage({
    super.key,
    required this.selectedProducts,
    this.onCheckoutSuccess,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String selectedDeliveryMethod = 'Antar ke Alamat';
  String selectedPaymentMethod = 'DANA';
  Map<String, int> productQuantities = {};

  @override
  void initState() {
    super.initState();
    // Initialize quantities for each product
    for (var product in widget.selectedProducts) {
      productQuantities[product['name']] = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate total price based on quantities
    double totalPrice = 0;
    for (var product in widget.selectedProducts) {
      String priceStr = product['price'] ?? 'Rp 0';
      String cleanPrice = priceStr.replaceAll('Rp ', '').replaceAll('.', '');
      double price = double.tryParse(cleanPrice) ?? 0;
      int quantity = productQuantities[product['name']] ?? 1;
      totalPrice += (price * quantity);
    }
    
    // Delivery fee based on selected method
    double deliveryFee = selectedDeliveryMethod == 'Antar ke Alamat' ? 5000 : 0;
    double finalPrice = totalPrice + deliveryFee;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Delivery Info Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Alamat Pengiriman',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'Ganti Alamat',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ahmad Fadli, 12345',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Jl. Raya Cimahi No. 123,\nCimahi, Jawa Barat,\nIndonesia 40512',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Phone: 081234567890',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Delivery Method Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Metode Pengiriman',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDeliveryOption('Antar ke Alamat', 'Rp 5.000'),
                  const SizedBox(height: 8),
                  _buildDeliveryOption('Ambil Barang di Tempat', 'Gratis'),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Selected Products Section with quantity controls
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Produk yang Dipilih',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Product list with quantity controls
                  ...widget.selectedProducts.map((product) {
                    String priceStr = product['price'] ?? 'Rp 0';
                    String cleanPrice = priceStr.replaceAll('Rp ', '').replaceAll('.', '');
                    double price = double.tryParse(cleanPrice) ?? 0;
                    int quantity = productQuantities[product['name']] ?? 1;
                    double subtotal = price * quantity;
                    int availableStock = product['stock'] ?? 0;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Product image placeholder
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    product['name'] ?? 'Product',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              
                              // Product details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['name'] ?? 'Product',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      product['description'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Stok tersedia: $availableStock',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: availableStock > 10 ? Colors.green[600] : Colors.orange[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Rp ${price.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Quantity controls and subtotal
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Quantity controls
                              Row(
                                children: [
                                  const Text(
                                    'Qty: ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey[300]!),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            if (quantity > 1) {
                                              setState(() {
                                                productQuantities[product['name']] = quantity - 1;
                                              });
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: quantity > 1 ? Colors.transparent : Colors.grey[200],
                                            ),
                                            child: Text(
                                              '-', 
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: quantity > 1 ? Colors.black : Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            border: Border.symmetric(
                                              vertical: BorderSide(color: Colors.grey[300]!),
                                            ),
                                          ),
                                          child: Text(
                                            quantity.toString(),
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            if (quantity < availableStock) {
                                              setState(() {
                                                productQuantities[product['name']] = quantity + 1;
                                              });
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Stok tidak mencukupi. Maksimal $availableStock'),
                                                  duration: const Duration(seconds: 2),
                                                ),
                                              );
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: quantity < availableStock ? Colors.transparent : Colors.grey[200],
                                            ),
                                            child: Text(
                                              '+', 
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: quantity < availableStock ? Colors.black : Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              
                              // Subtotal
                              Text(
                                'Rp ${subtotal.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Payment Method Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Metode Pembayaran',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPaymentOption('DANA'),
                      const SizedBox(width: 40),
                      _buildPaymentOption('QRIS'),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Price Summary Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildPriceLine('Subtotal', 'Rp ${totalPrice.toStringAsFixed(0)}'),
                  const SizedBox(height: 8),
                  _buildPriceLine('Ongkir', deliveryFee > 0 ? 'Rp ${deliveryFee.toStringAsFixed(0)}' : 'Gratis'),
                  const Divider(height: 24),
                  _buildPriceLine('Total', 'Rp ${finalPrice.toStringAsFixed(0)}', isTotal: true),
                ],
              ),
            ),
            
            const SizedBox(height: 100), // Extra space for checkout button
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            // Handle order placement
            _showOrderSuccessDialog();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            elevation: 2,
          ),
          child: const Text(
            'Buat Pesanan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryOption(String method, String cost) {
    bool isSelected = selectedDeliveryMethod == method;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDeliveryMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : Colors.grey[400],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                method,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  color: isSelected ? AppColors.primary : Colors.black87,
                ),
              ),
            ),
            Text(
              cost,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.primary : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String method) {
    bool isSelected = selectedPaymentMethod == method;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
        ),
        child: Text(
          method,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.primary : Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildPriceLine(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? AppColors.primary : Colors.black87,
          ),
        ),
      ],
    );
  }

  void _showOrderSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.green[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                color: Colors.green[600],
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pesanan Berhasil!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'Pesanan Anda telah berhasil dibuat. Kami akan segera memproses pesanan Anda.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                
                // Prepare purchased products with quantities for stock update
                List<Map<String, dynamic>> purchasedProducts = [];
                for (var product in widget.selectedProducts) {
                  Map<String, dynamic> purchasedProduct = Map.from(product);
                  purchasedProduct['purchasedQuantity'] = productQuantities[product['name']] ?? 1;
                  purchasedProducts.add(purchasedProduct);
                }
                
                // Call the success callback to update stock
                if (widget.onCheckoutSuccess != null) {
                  widget.onCheckoutSuccess!(purchasedProducts);
                }
                
                Navigator.of(context).pop(); // Go back to previous page
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('OK'),
            ),
          ),
        ],
      ),
    );
  }
}