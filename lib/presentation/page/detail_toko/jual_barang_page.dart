import 'package:flutter/material.dart';
import 'package:okgreen/core/constants/app_colors.dart';
import 'package:okgreen/presentation/page/detail_toko/beli_barang_page.dart';
import 'package:okgreen/presentation/page/detail_toko/beranda_page.dart';
import 'package:okgreen/presentation/page/detail_toko/edukasi_page.dart';
import 'package:okgreen/presentation/widget/bottom_navbar.dart';
import 'package:okgreen/presentation/widget/top_wave.dart';

class JualBarangPage extends StatefulWidget {
  const JualBarangPage({super.key});

  @override
  State<JualBarangPage> createState() => _JualBarangPageState();
}

class _JualBarangPageState extends State<JualBarangPage> {
  int currentIndex = 1; // Jual Barang tab
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  
  String selectedCategory = 'Electronics';
  String selectedCondition = 'Good';
  
  final List<String> categories = ['Electronics', 'Fashion', 'Books', 'Sports', 'Furniture', 'Others'];
  final List<String> conditions = ['Like New', 'Good', 'Fair', 'Poor'];

  void _onTabTapped(int index) {
    setState(() {
      currentIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BerandaPage()));
        break;
      case 1:
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BeliBarangPage()));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EdukasiPage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          ClipPath(
            clipper: TopWaveClipper(),
            child: Container(
              height: 280,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Jual Barang',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Jual barang bekas dengan mudah',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(child: _buildSellForm()),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  Widget _buildSellForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo upload
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.camera_alt, color: AppColors.primary, size: 40),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tambah Foto Barang',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                Text('Tap untuk menambah foto', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildFormField(label: 'Nama Barang', controller: _titleController, hint: 'Masukkan nama barang'),
          const SizedBox(height: 16),
          _buildFormField(label: 'Deskripsi', controller: _descriptionController, hint: 'Deskripsikan barang', maxLines: 4),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Kategori',
                  value: selectedCategory,
                  items: categories,
                  onChanged: (value) => setState(() => selectedCategory = value!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownField(
                  label: 'Jenis Sampah',
                  value: selectedCondition,
                  items: conditions,
                  onChanged: (value) => setState(() => selectedCondition = value!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFormField(label: 'Harga (Rp)', controller: _priceController, hint: '0', keyboardType: TextInputType.number),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFormField(label: 'Lokasi', controller: _locationController, hint: 'Kota/Kabupaten'),
              ),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              child: const Text('Jual Barang', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: Container(),
            onChanged: onChanged,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
