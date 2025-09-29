import 'package:flutter/material.dart';
import 'package:okgreen/core/constants/app_colors.dart';
import 'package:okgreen/presentation/page/detail_toko/beranda_page.dart';
import 'package:okgreen/presentation/page/detail_toko/point_history_page.dart';
import 'package:okgreen/presentation/page/detail_toko/jelajahi_barang.dart';
import 'package:okgreen/presentation/widget/bottom_navbar.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  int _currentIndex = 3; // Riwayat tab

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    switch (index) {
      case 0: // Beranda
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BerandaPage()),
        );
        break;
      case 1: // Jual Barang
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const JualBarangPage()),
        );
        break;
      case 2: // Jelajahi Produk
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const JelajahiProdukPage()),
        );
        break;
      case 3: // Riwayat (current page)
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Kembali ke Beranda
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const BerandaPage()),
            );
          },
        ),
        title: const Text(
          'Riwayat',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            
            // Filter Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildFilterTab('Semua', true),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFilterTab('Pembelian', false),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFilterTab('Penjualan', false),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // History Items
            _buildHistoryItem(
              title: 'Pembelian Tas Ramah Lingkungan',
              subtitle: 'Toko EcoFriendly Store',
              amount: 'Rp 85.000',
              date: '15 Sep 2025',
              type: 'buy',
              status: 'Selesai',
            ),
            
            _buildHistoryItem(
              title: 'Penjualan Botol Bekas',
              subtitle: '5 botol plastik @ Rp 2.000',
              amount: '+ Rp 10.000',
              date: '12 Sep 2025',
              type: 'sell',
              status: 'Berhasil',
            ),
            
            _buildHistoryItem(
              title: 'Tukar Poin Voucher Belanja',
              subtitle: 'Voucher Rp 25.000',
              amount: '- 250 Poin',
              date: '10 Sep 2025',
              type: 'points',
              status: 'Berhasil',
            ),
            
            _buildHistoryItem(
              title: 'Pembelian Produk Organik',
              subtitle: 'Toko Green Market',
              amount: 'Rp 125.000',
              date: '8 Sep 2025',
              type: 'buy',
              status: 'Selesai',
            ),
            
            _buildHistoryItem(
              title: 'Penjualan Kardus Bekas',
              subtitle: '10 kg kardus @ Rp 1.500/kg',
              amount: '+ Rp 15.000',
              date: '5 Sep 2025',
              type: 'sell',
              status: 'Berhasil',
            ),
            
            const SizedBox(height: 80), // Extra padding untuk bottom navbar
          ],
        ),
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildFilterTab(String title, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? AppColors.primary : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.grey[600],
          fontSize: 14,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildHistoryItem({
    required String title,
    required String subtitle,
    required String amount,
    required String date,
    required String type,
    required String status,
  }) {
    Color typeColor;
    IconData typeIcon;
    
    switch (type) {
      case 'buy':
        typeColor = Colors.blue;
        typeIcon = Icons.shopping_bag_outlined;
        break;
      case 'sell':
        typeColor = Colors.green;
        typeIcon = Icons.sell_outlined;
        break;
      case 'points':
        typeColor = Colors.orange;
        typeIcon = Icons.stars_outlined;
        break;
      default:
        typeColor = Colors.grey;
        typeIcon = Icons.history;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              typeIcon,
              color: typeColor,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Amount
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: type == 'sell' ? Colors.green : 
                     type == 'points' ? Colors.orange : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}