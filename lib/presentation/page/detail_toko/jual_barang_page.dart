import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:okgreen/core/constants/app_colors.dart';
import 'package:okgreen/presentation/page/detail_toko/beli_barang_page.dart';
import 'package:okgreen/presentation/page/detail_toko/beranda_page.dart';
import 'package:okgreen/presentation/widget/bottom_navbar.dart';
import 'package:okgreen/presentation/widget/top_wave.dart';
import 'package:okgreen/service/api_client.dart'; // Import ApiClient yang sudah ada

class JualBarangPage extends StatefulWidget {
  const JualBarangPage({super.key});

  @override
  State<JualBarangPage> createState() => _JualBarangPageState();
}

class _JualBarangPageState extends State<JualBarangPage> {
  int currentIndex = 1;
  
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  String? selectedCategoryId;
  String? selectedSellTypeId;
  String selectedSellMethod = 'drop_point';
  
  List<WasteCategory> categories = [];
  List<SellWasteType> sellTypes = [];
  
  final List<String> sellMethods = ['drop_point', 'pickup'];
  final Map<String, String> sellMethodLabels = {
    'drop_point': 'Drop Point',
    'pickup': 'Pickup Service'
  };
  
  // UBAH DARI List<String> KE List<File>
  List<File> selectedPhotos = [];
  final ImagePicker _picker = ImagePicker();
  bool isSubmitting = false;

  // GUNAKAN ApiClient yang sudah ada
  final ApiClient _apiClient = ApiClient();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  // Load categories DENGAN ApiClient existing
  void _loadCategories() async {
    try {
      final response = await _apiClient.getWasteCategories();
      setState(() {
        categories = response.map((e) => WasteCategory.fromJson(e)).toList();
      });
    } catch (e) {
      // Fallback ke mock data
      setState(() {
        categories = [
          WasteCategory(id: '1', categoryName: 'Plastik'),
          WasteCategory(id: '2', categoryName: 'Kertas'),
          WasteCategory(id: '3', categoryName: 'Logam'),
        ];
      });
    }
  }

  // Load sell types DENGAN ApiClient existing
  void _loadSellTypes(String categoryId) async {
    try {
      final response = await _apiClient.getSellWasteTypes(categoryId);
      setState(() {
        sellTypes = response.map((e) => SellWasteType.fromJson(e)).toList();
        selectedSellTypeId = null;
      });
    } catch (e) {
      setState(() {
        sellTypes = [
          SellWasteType(id: '1', typeName: 'Botol Plastik', pointsPerKg: 2000),
        ];
        selectedSellTypeId = null;
      });
    }
  }

  // UPLOAD FOTO - implementasi sederhana
  Future<void> _pickPhoto() async {
    if (selectedPhotos.length >= 5) {
      _showError('Maksimal 5 foto');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pilih Foto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _getPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _getPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getPhoto(ImageSource source) async {
    final XFile? photo = await _picker.pickImage(source: source);
    if (photo != null) {
      setState(() {
        selectedPhotos.add(File(photo.path));
      });
    }
  }

  void _removePhoto(int index) {
    setState(() {
      selectedPhotos.removeAt(index);
    });
  }

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

  // SUBMIT dengan ApiClient existing
  void _submitSellRequest() async {
    // Validasi
    if (selectedPhotos.isEmpty) {
      _showError('Minimal 1 foto harus diupload');
      return;
    }
    if (selectedCategoryId == null || selectedSellTypeId == null || _weightController.text.isEmpty) {
      _showError('Lengkapi semua field');
      return;
    }
    
    double? weight = double.tryParse(_weightController.text);
    if (weight == null || weight <= 0) {
      _showError('Berat harus lebih dari 0');
      return;
    }

    setState(() => isSubmitting = true);

    try {
      await _apiClient.submitSellRequest(
        wasteCategoryId: selectedCategoryId!,
        sellWasteTypeId: selectedSellTypeId!,
        sellMethod: selectedSellMethod,
        weight: weight,
        description: _descriptionController.text,
        photos: selectedPhotos,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Berhasil mengirim permintaan jual sampah'), backgroundColor: Colors.green),
      );
      
      _resetForm();
    } catch (e) {
      _showError('Gagal mengirim: $e');
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
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
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Jual Sampah', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                          Text('Jual sampah dan dapatkan poin', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.recycling, color: Colors.white, size: 24),
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
      bottomNavigationBar: BottomNavbar(currentIndex: currentIndex, onTap: _onTabTapped),
    );
  }

  Widget _buildSellForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FOTO UPLOAD SEDERHANA
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: selectedPhotos.isEmpty 
              ? InkWell(
                  onTap: _pickPhoto,
                  child: Container(
                    height: 200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, color: AppColors.primary, size: 40),
                        SizedBox(height: 16),
                        Text('Tap untuk tambah foto', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Foto (${selectedPhotos.length}/5)', style: TextStyle(fontWeight: FontWeight.w600)),
                          TextButton(onPressed: selectedPhotos.length < 5 ? _pickPhoto : null, child: Text('Tambah')),
                        ],
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
                        itemCount: selectedPhotos.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(selectedPhotos[index], fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _removePhoto(index),
                                  child: Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                    child: Icon(Icons.close, color: Colors.white, size: 16),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
          ),
          
          SizedBox(height: 20),
          
          // CATEGORY DROPDOWN
          _buildDropdown(
            'Kategori Sampah *',
            selectedCategoryId,
            categories.map((e) => DropdownMenuItem(value: e.id, child: Text(e.categoryName))).toList(),
            (value) {
              setState(() {
                selectedCategoryId = value;
                selectedSellTypeId = null;
                sellTypes = [];
              });
              if (value != null) _loadSellTypes(value);
            },
          ),
          
          SizedBox(height: 16),
          
          // SELL TYPE DROPDOWN
          _buildDropdown(
            'Jenis Sampah *',
            selectedSellTypeId,
            sellTypes.map((e) => DropdownMenuItem(value: e.id, child: Text(e.typeName))).toList(),
            (value) => setState(() => selectedSellTypeId = value),
            enabled: selectedCategoryId != null,
          ),
          
          SizedBox(height: 16),
          
          // WEIGHT & METHOD
          Row(
            children: [
              Expanded(child: _buildTextField('Berat (Kg)', _weightController, '0.0', TextInputType.numberWithOptions(decimal: true))),
              SizedBox(width: 16),
              Expanded(
                child: _buildDropdown(
                  'Metode',
                  selectedSellMethod,
                  sellMethods.map((e) => DropdownMenuItem(value: e, child: Text(sellMethodLabels[e]!))).toList(),
                  (value) => setState(() => selectedSellMethod = value!),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          // DESCRIPTION
          _buildTextField('Deskripsi', _descriptionController, 'Opsional', null, maxLines: 3),
          
          SizedBox(height: 30),
          
          // SUBMIT BUTTON
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : _submitSellRequest,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
              child: isSubmitting 
                ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white)), SizedBox(width: 8), Text('Mengirim...', style: TextStyle(color: Colors.white))])
                : Text('Kirim Permintaan Jual', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<DropdownMenuItem<String>> items, ValueChanged<String?> onChanged, {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: enabled ? Colors.white : Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
          child: DropdownButton<String>(value: value, isExpanded: true, underline: Container(), hint: Text('Pilih $label'), onChanged: enabled ? onChanged : null, items: items),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, TextInputType? keyboardType, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
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
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}

// MODEL CLASSES
class WasteCategory {
  final String id;
  final String categoryName;
  WasteCategory({required this.id, required this.categoryName});
  factory WasteCategory.fromJson(Map<String, dynamic> json) => WasteCategory(id: json['id'].toString(), categoryName: json['category_name']);
}

class SellWasteType {
  final String id;
  final String typeName;
  final double pointsPerKg;
  SellWasteType({required this.id, required this.typeName, required this.pointsPerKg});
  factory SellWasteType.fromJson(Map<String, dynamic> json) => SellWasteType(id: json['id'].toString(), typeName: json['type_name'], pointsPerKg: (json['points_per_kg'] ?? 0).toDouble());
}