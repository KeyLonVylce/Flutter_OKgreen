import 'package:flutter/material.dart';
import 'package:okgreen/service/user_service.dart';

class ProfilPage extends StatefulWidget {
  final int userId;
  final Map<String, dynamic>? userData;

  const ProfilPage({
    Key? key, 
    required this.userId,
    this.userData,
  }) : super(key: key);

  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();
 
  // Controllers untuk form fields
  late TextEditingController _namaController;
  late TextEditingController _emailController;
  late TextEditingController _nomorTeleponController;
  late TextEditingController _tanggalLahirController;
  late TextEditingController _alamatController;
  
  String? _selectedGender;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }
  
  void _initializeControllers() {
    // Initialize controllers with existing data if available
    final userData = widget.userData ?? {};
    
    _namaController = TextEditingController(text: userData['name'] ?? '');
    _emailController = TextEditingController(text: userData['email'] ?? '');
    _nomorTeleponController = TextEditingController(text: userData['phone_number'] ?? '');
    _tanggalLahirController = TextEditingController(
      text: userData['date_of_birth'] ?? ''
    );
    _alamatController = TextEditingController(text: userData['address'] ?? '');
    _selectedGender = userData['gender'];
  }
  
  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _nomorTeleponController.dispose();
    _tanggalLahirController.dispose();
    _alamatController.dispose();
    super.dispose();
  }
  
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _tanggalLahirController.text = 
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }
  
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final response = await _userService.updateProfile(
        userId: widget.userId,
        name: _namaController.text.trim().isNotEmpty ? _namaController.text.trim() : null,
        email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
        phone: _nomorTeleponController.text.trim().isNotEmpty ? _nomorTeleponController.text.trim() : null,
        address: _alamatController.text.trim().isNotEmpty ? _alamatController.text.trim() : null,
        dateOfBirth: _tanggalLahirController.text.trim().isNotEmpty ? _tanggalLahirController.text.trim() : null,
        gender: _selectedGender,
      );
      
      if (response.success) {
        // Update userData dengan data baru
        final updatedUserData = <String, dynamic>{
          ...widget.userData ?? {},
          'name': _namaController.text.trim().isNotEmpty ? _namaController.text.trim() : widget.userData?['name'],
          'email': _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : widget.userData?['email'],
          'phone_number': _nomorTeleponController.text.trim().isNotEmpty ? _nomorTeleponController.text.trim() : widget.userData?['phone_number'],
          'address': _alamatController.text.trim().isNotEmpty ? _alamatController.text.trim() : widget.userData?['address'],
          'date_of_birth': _tanggalLahirController.text.trim().isNotEmpty ? _tanggalLahirController.text.trim() : widget.userData?['date_of_birth'],
          'gender': _selectedGender ?? widget.userData?['gender'],
        };

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Profil berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Return updated data to previous page
        Navigator.pop(context, updatedUserData);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Gagal memperbarui profil'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Informasi Pribadi',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Profile Picture Section
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      widget.userData?['name'] ?? 'Pengguna',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Tetapkan Foto',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 24),
                    
                    // Form Fields
                    _buildTextField(
                      controller: _namaController,
                      label: 'Nama',
                      validator: (value) {
                        if (value?.trim().isEmpty ?? true) {
                          return 'Nama tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      validator: (value) {
                        if (value?.trim().isEmpty ?? true) {
                          return 'Email tidak boleh kosong';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _nomorTeleponController,
                      label: 'Nomor Telepon',
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 16),

                    _buildTextField(
                      controller: _alamatController,
                      label: 'Alamat',
                    ),
                    SizedBox(height: 16),
                    
                    _buildDateField(),
                    SizedBox(height: 16),
                    
                    _buildGenderDropdown(),
                    SizedBox(height: 32),
                    
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Submit',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.green),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
  
  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tanggal Lahir',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _tanggalLahirController,
          readOnly: true,
          onTap: _selectDate,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.green),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffixIcon: Icon(Icons.calendar_today, color: Colors.grey[600], size: 20),
          ),
        ),
      ],
    );
  }
  
  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jenis Kelamin',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedGender,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.green),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: [
            DropdownMenuItem<String>(
              value: 'laki-laki',
              child: Text('Laki-laki'),
            ),
            DropdownMenuItem<String>(
              value: 'perempuan',
              child: Text('Perempuan'),
            ),
          ],
          onChanged: (String? newValue) {
            setState(() {
              _selectedGender = newValue;
            });
          },
        ),
      ],
    );
  }
}