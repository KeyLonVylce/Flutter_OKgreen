import 'package:flutter/material.dart';
import 'package:okgreen/core/constants/app_colors.dart';
import 'package:okgreen/presentation/page/detail_toko/beli_barang_page.dart';
import 'package:okgreen/presentation/page/detail_toko/beranda_page.dart';
import 'package:okgreen/presentation/widget/bottom_navbar.dart';
import 'package:okgreen/presentation/widget/top_wave.dart';

class JualBarangPage extends StatefulWidget {
  const JualBarangPage({super.key});

  @override
  State<JualBarangPage> createState() => _JualBarangPageState();
}

class _JualBarangPageState extends State<JualBarangPage> {
  int currentIndex = 1; // Jual Barang tab
  
  final TextEditingController _beratController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  String selectedCategory = 'Pilih Kategori Sampah';
  String selectedJenis = 'Pilih Jenis Sampah';
  String selectedUnit = 'Kg';
  
  // Data kategori sampah
  final List<String> categories = [
    'Pilih Kategori Sampah',
    'Sampah Organik',
    'Sampah Anorganik',
    'Sampah B3',
    'Sampah Elektronik'
  ];
  
  // Data jenis sampah
  final List<String> jenisSampah = [
    'Pilih Jenis Sampah',
    'Plastik Botol',
    'Plastik Kemasan',
    'Kertas',
    'Kardus',
    'Kaleng',
    'Besi',
    'Kaca',
    'Aluminium'
  ];
  
  final List<String> units = ['Kg', 'Gram', 'Ton'];

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
                            'Jual Sampah',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
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

          // Kategori
          _buildDropdownField(
            label: 'Kategori',
            value: selectedCategory,
            items: categories,
            onChanged: (value) => setState(() => selectedCategory = value!),
          ),
          const SizedBox(height: 20),

          // Jenis
          _buildDropdownField(
            label: 'Jenis',
            value: selectedJenis,
            items: jenisSampah,
            onChanged: (value) => setState(() => selectedJenis = value!),
          ),
          const SizedBox(height: 20),

          // Berat
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Berat',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _beratController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Masukkan berat',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButton<String>(
                        value: selectedUnit,
                        isExpanded: true,
                        underline: Container(),
                        onChanged: (value) => setState(() => selectedUnit = value!),
                        items: units.map((String item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Deskripsi
          _buildFormField(
            label: 'Deskripsi',
            controller: _descriptionController,
            hint: 'Masukan Deskripsi (Opsional)',
            maxLines: 4,
          ),
          const SizedBox(height: 20),

          // Foto upload
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Foto',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  // Handle photo upload
                },
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey[300]!,
                      style: BorderStyle.solid,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.grey[600],
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Upload foto',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _validateAndSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Jual Sampah',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary),
            ),
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
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
                child: Text(
                  item,
                  style: TextStyle(
                    color: item.contains('Pilih') ? Colors.grey[600] : Colors.black87,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _validateAndSubmit() {
    // Validasi form
    if (selectedCategory == 'Pilih Kategori Sampah') {
      _showErrorDialog('Pilih kategori sampah terlebih dahulu');
      return;
    }
    
    if (selectedJenis == 'Pilih Jenis Sampah') {
      _showErrorDialog('Pilih jenis sampah terlebih dahulu');
      return;
    }
    
    if (_beratController.text.isEmpty) {
      _showErrorDialog('Masukkan berat sampah');
      return;
    }
    
    // TODO: Implement API call untuk submit data
    _showSuccessDialog();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('Berhasil'),
          content: const Text('Data sampah berhasil disubmit'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetForm();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _resetForm() {
    setState(() {
      selectedCategory = 'Pilih Kategori Sampah';
      selectedJenis = 'Pilih Jenis Sampah';
      selectedUnit = 'Kg';
      _beratController.clear();
      _descriptionController.clear();
    });
  }

  @override
  void dispose() {
    _beratController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}