import 'package:flutter/material.dart';
import 'package:okgreen/core/constants/app_colors.dart';
import 'package:okgreen/presentation/page/detail_toko/jelajahi_barang.dart';
import 'package:okgreen/presentation/page/detail_toko/beranda_page.dart';
import 'package:okgreen/presentation/widget/bottom_navbar.dart';
import 'package:okgreen/presentation/widget/top_wave.dart';
import 'riwayat.dart';

class JualBarangPage extends StatefulWidget {
  const JualBarangPage({super.key});

  @override
  State<JualBarangPage> createState() => _JualBarangPageState();
}

class _JualBarangPageState extends State<JualBarangPage> {
  int currentIndex = 1; // Jual Barang tab
  
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  // Backend fields
  String? selectedCategoryId;
  String? selectedSellTypeId;
  String selectedSellMethod = 'drop_point';
  
  // Data untuk dropdown
  List<WasteCategory> categories = [];
  List<SellWasteType> sellTypes = [];
  
  final List<String> sellMethods = ['drop_point', 'pickup'];
  final Map<String, String> sellMethodLabels = {
    'drop_point': 'Drop Point',
    'pickup': 'Pickup Service'
  };
  
  // Untuk foto
  List<String> selectedPhotos = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  // Load waste categories from backend
  void _loadCategories() async {
    // TODO: Implement API call to get categories
    // Example implementation:
    try {
      // final response = await ApiService.getWasteCategories();
      // setState(() {
      //   categories = response.data;
      // });
      
      // Mock data for now - replace with actual API call
      setState(() {
        categories = [
          WasteCategory(id: '1', categoryName: 'Plastik'),
          WasteCategory(id: '2', categoryName: 'Kertas'),
          WasteCategory(id: '3', categoryName: 'Logam'),
          WasteCategory(id: '4', categoryName: 'Kaca'),
          WasteCategory(id: '5', categoryName: 'Organik'),
        ];
      });
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat kategori: $e')),
      );
    }
  }

  // Load sell waste types based on category
  void _loadSellTypes(String categoryId) async {
    // TODO: Implement API call to get sell types by category
    try {
      // final response = await ApiService.getSellTypes(categoryId);
      // setState(() {
      //   sellTypes = response.data;
      //   selectedSellTypeId = null;
      // });
      
      // Mock data for now - replace with actual API call
      setState(() {
        sellTypes = [
          SellWasteType(id: '1', typeName: 'Botol Plastik', pointsPerKg: 2000),
          SellWasteType(id: '2', typeName: 'Kantong Plastik', pointsPerKg: 1500),
          SellWasteType(id: '3', typeName: 'Kemasan Makanan', pointsPerKg: 1800),
        ];
        selectedSellTypeId = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat jenis sampah: $e')),
      );
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      currentIndex = index;
    });
    
    switch (index) {
      case 0: // Beranda
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const BerandaPage())
        );
        break;
      case 1: // Jual Barang (current page)
        break;
      case 2: // Jelajahi Produk
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const JelajahiProdukPage())
        );
        break;
      case 3: // Riwayat
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const RiwayatPage())
        );
        break;
    }
  }

  void _submitSellRequest() async {
    // Validation
    if (selectedCategoryId == null) {
      _showError('Pilih kategori sampah');
      return;
    }
    if (selectedSellTypeId == null) {
      _showError('Pilih jenis sampah');
      return;
    }
    if (_weightController.text.isEmpty) {
      _showError('Masukkan berat sampah');
      return;
    }
    
    double? weight = double.tryParse(_weightController.text);
    if (weight == null || weight <= 0) {
      _showError('Berat sampah harus lebih dari 0');
      return;
    }

    // TODO: Implement API call to submit sell request
    try {
      // final request = SellWasteRequest(
      //   wasteCategoryId: selectedCategoryId!,
      //   sellWasteTypeId: selectedSellTypeId!,
      //   sellMethod: selectedSellMethod,
      //   weight: weight,
      //   description: _descriptionController.text,
      //   photos: selectedPhotos,
      // );
      // 
      // final response = await ApiService.submitSellRequest(request);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permintaan jual sampah berhasil dikirim (pending verifikasi)'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Reset form
      _resetForm();
      
    } catch (e) {
      _showError('Gagal mengirim permintaan jual sampah: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _resetForm() {
    setState(() {
      selectedCategoryId = null;
      selectedSellTypeId = null;
      selectedSellMethod = 'drop_point';
      sellTypes = [];
      selectedPhotos = [];
    });
    _weightController.clear();
    _descriptionController.clear();
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
                          ),
                          Text(
                            'Jual sampah dan dapatkan poin',
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
                        child: const Icon(
                          Icons.recycling,
                          color: Colors.white,
                          size: 24,
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
          _buildPhotoUpload(),
          const SizedBox(height: 20),
          
          // Category dropdown
          _buildCategoryDropdown(),
          const SizedBox(height: 16),
          
          // Sell type dropdown (enabled only when category selected)
          _buildSellTypeDropdown(),
          const SizedBox(height: 16),
          
          // Weight and sell method
          Row(
            children: [
              Expanded(
                child: _buildFormField(
                  label: 'Berat (Kg)', 
                  controller: _weightController, 
                  hint: '0.0', 
                  keyboardType: const TextInputType.numberWithOptions(decimal: true)
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSellMethodDropdown(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Description
          _buildFormField(
            label: 'Deskripsi (Opsional)', 
            controller: _descriptionController, 
            hint: 'Deskripsikan kondisi sampah', 
            maxLines: 4
          ),
          const SizedBox(height: 16),
          
          // Price estimation
          if (selectedSellTypeId != null && _weightController.text.isNotEmpty)
            _buildPriceEstimation(),
          
          const SizedBox(height: 30),
          
          // Submit button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _submitSellRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              child: const Text(
                'Kirim Permintaan Jual', 
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPhotoUpload() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: selectedPhotos.isEmpty
          ? InkWell(
              onTap: () {
                // TODO: Implement photo selection
                // _selectPhotos();
              },
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
                    'Tambah Foto Sampah',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Text('Tap untuk menambah foto', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: selectedPhotos.length + 1,
              itemBuilder: (context, index) {
                if (index == selectedPhotos.length) {
                  return InkWell(
                    onTap: () {
                      // TODO: Add more photos
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: const Icon(Icons.add, color: Colors.grey),
                    ),
                  );
                }
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[300],
                  ),
                  // TODO: Display actual image
                  child: const Icon(Icons.image, color: Colors.grey),
                );
              },
            ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategori Sampah *', 
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)
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
            value: selectedCategoryId,
            isExpanded: true,
            underline: Container(),
            hint: const Text('Pilih kategori sampah'),
            onChanged: (value) {
              setState(() {
                selectedCategoryId = value;
                selectedSellTypeId = null;
                sellTypes = [];
              });
              if (value != null) {
                _loadSellTypes(value);
              }
            },
            items: categories.map((WasteCategory category) {
              return DropdownMenuItem<String>(
                value: category.id,
                child: Text(category.categoryName),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSellTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jenis Sampah *', 
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: selectedCategoryId == null ? Colors.grey[100] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButton<String>(
            value: selectedSellTypeId,
            isExpanded: true,
            underline: Container(),
            hint: Text(
              selectedCategoryId == null ? 'Pilih kategori terlebih dahulu' : 'Pilih jenis sampah',
              style: TextStyle(color: selectedCategoryId == null ? Colors.grey : null),
            ),
            onChanged: selectedCategoryId == null ? null : (value) {
              setState(() {
                selectedSellTypeId = value;
              });
            },
            items: sellTypes.map((SellWasteType type) {
              return DropdownMenuItem<String>(
                value: type.id,
                child: Row(
                  children: [
                    Expanded(child: Text(type.typeName)),
                    Text(
                      '${type.pointsPerKg} poin/kg',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSellMethodDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Metode Penjualan', 
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)
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
            value: selectedSellMethod,
            isExpanded: true,
            underline: Container(),
            onChanged: (value) {
              setState(() {
                selectedSellMethod = value!;
              });
            },
            items: sellMethods.map((String method) {
              return DropdownMenuItem<String>(
                value: method,
                child: Text(sellMethodLabels[method]!),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceEstimation() {
    final selectedType = sellTypes.firstWhere(
      (type) => type.id == selectedSellTypeId,
      orElse: () => SellWasteType(id: '', typeName: '', pointsPerKg: 0),
    );
    
    final weight = double.tryParse(_weightController.text) ?? 0;
    final totalPoints = selectedType.pointsPerKg * weight;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estimasi Poin',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${weight.toStringAsFixed(1)} kg × ${selectedType.pointsPerKg} poin/kg = ${totalPoints.toStringAsFixed(0)} poin',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
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
          onChanged: (value) {
            if (label.contains('Berat') && selectedSellTypeId != null) {
              setState(() {}); // Refresh untuk update estimasi harga
            }
          },
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
}

// Model classes to match backend
class WasteCategory {
  final String id;
  final String categoryName;

  WasteCategory({required this.id, required this.categoryName});

  factory WasteCategory.fromJson(Map<String, dynamic> json) {
    return WasteCategory(
      id: json['id'].toString(),
      categoryName: json['category_name'],
    );
  }
}

class SellWasteType {
  final String id;
  final String typeName;
  final double pointsPerKg;

  SellWasteType({required this.id, required this.typeName, required this.pointsPerKg});

  factory SellWasteType.fromJson(Map<String, dynamic> json) {
    return SellWasteType(
      id: json['id'].toString(),
      typeName: json['type_name'],
      pointsPerKg: (json['points_per_kg'] ?? 0).toDouble(),
    );
  }
}

// Request model untuk API
class SellWasteRequest {
  final String wasteCategoryId;
  final String sellWasteTypeId;
  final String sellMethod;
  final double weight;
  final String? description;
  final List<String> photos;

  SellWasteRequest({
    required this.wasteCategoryId,
    required this.sellWasteTypeId,
    required this.sellMethod,
    required this.weight,
    this.description,
    required this.photos,
  });

  Map<String, dynamic> toJson() {
    return {
      'waste_category_id': wasteCategoryId,
      'sell_waste_type_id': sellWasteTypeId,
      'sell_method': sellMethod,
      'weight': weight,
      'description': description,
      'photo': photos,
    };
  }
}