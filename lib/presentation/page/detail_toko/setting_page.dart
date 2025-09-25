import 'package:flutter/material.dart';
import 'package:okgreen/core/constants/app_icons.dart';
import 'package:okgreen/presentation/page/auth/login.dart';
import 'package:okgreen/presentation/page/detail_toko/hubungi_kami.dart';
import 'package:okgreen/presentation/page/detail_toko/profil.dart';
import 'package:okgreen/service/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _userName = 'Pengguna';
  String _userEmail = '';
  Map<String, dynamic>? _userData; // Store complete user data
  int? _userId; // Store user ID
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      
      if (userDataString != null) {
        final userData = json.decode(userDataString);
        setState(() {
          _userData = userData; // Store complete data
          _userId = userData['id'] ?? userData['user']?['id']; // Get user ID
          _userName = userData['name'] ?? userData['user']?['name'] ?? 'Pengguna';
          _userEmail = userData['email'] ?? userData['user']?['email'] ?? '';
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _userName = 'Pengguna';
        _userEmail = '';
        _userData = null;
        _userId = null;
      });
    }
  }

  // Save updated user data to SharedPreferences
  Future<void> _saveUserData(Map<String, dynamic> updatedData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Merge dengan data yang sudah ada
      final existingData = _userData ?? {};
      final mergedData = {...existingData, ...updatedData};
      
      await prefs.setString('user_data', json.encode(mergedData));
      
      // Update state dengan data baru
      setState(() {
        _userData = mergedData;
        _userName = mergedData['name'] ?? 'Pengguna';
        _userEmail = mergedData['email'] ?? '';
      });
      
      print('User data saved successfully: ${mergedData['name']}');
    } catch (e) {
      print('Error saving user data: $e');
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Pengaturan',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Profile Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
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
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey,
                    child: Text(
                      _userName.isNotEmpty ? _userName[0].toUpperCase() : 'P',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_userEmail.isNotEmpty)
                          Text(
                            _userEmail,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Menu Items
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
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
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: SettingIcons.privacy,
                    title: 'Informasi Pribadi',
                    onTap: () async {
                      if (_userId != null) {
                        // Navigate to ProfilPage
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfilPage(
                              userId: _userId!,
                              userData: _userData,
                            ),
                          ),
                        );
                        
                        // Jika data dikembalikan dari ProfilPage, update data
                        if (result is Map<String, dynamic>) {
                          await _saveUserData(result); // Save to SharedPreferences dan update state
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Data profil berhasil diperbarui'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } else {
                        // Show error if user ID is not available
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Data pengguna tidak tersedia. Silakan login ulang.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: SettingIcons.points,
                    title: 'Tukarkan Point',
                    onTap: () {
                      // Handle tap
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: SettingIcons.contact,
                    title: 'Hubungi Kami',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HubungiKamiPage(),
                        ),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: SettingIcons.history,
                    title: 'Riwayat',
                    onTap: () {
                      // Handle tap
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: SettingIcons.logout,
                    title: 'Log out',
                    onTap: () {
                      _showLogoutDialog(context);
                    },
                    isDestructive: true,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            AppIcon(
              icon: icon,
              size: 20,
              color: isDestructive ? Colors.red : Colors.grey[600],
              backgroundColor: isDestructive 
                  ? Colors.red.withOpacity(0.1)
                  : Colors.grey[100],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? Colors.red : Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[100],
      indent: 56,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Batal',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                
                try {
                  // Perform logout
                  final result = await _authService.logout();
                  
                  if (result.success) {
                    // Clear user data from SharedPreferences
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('user_data');
                    
                    // Navigate to login page
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => WaveLoginScreen()),
                      (route) => false,
                    );
                  } else {
                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result.message ?? 'Logout gagal'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  // Handle error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Terjadi kesalahan: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text(
                'Keluar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}