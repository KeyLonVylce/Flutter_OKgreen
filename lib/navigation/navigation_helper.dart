// lib/core/navigation/navigation_helper.dart
import 'package:flutter/material.dart';

class NavigationHelper {
  static void navigateToPage(BuildContext context, int index) {
    String routeName;
    
    switch (index) {
      case 0:
        routeName = '/home';
        break;
      case 1:
        routeName = '/jual-barang';
        break;
      case 2:
        routeName = '/beli-barang';
        break;
      case 3:
        routeName = '/edukasi';
        break;
      default:
        routeName = '/home';
    }
    
    // Cek apakah route saat ini sama dengan route yang akan dituju
    // Jika sama, tidak perlu navigasi
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute == routeName) {
      return;
    }
    
    // Gunakan pushReplacementNamed untuk menghindari stack build up
    Navigator.pushReplacementNamed(context, routeName);
  }
  
  // Helper untuk mendapatkan current index berdasarkan route name
  static int getCurrentIndex(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    
    switch (currentRoute) {
      case '/home':
        return 0;
      case '/jual-barang':
        return 1;
      case '/beli-barang':
        return 2;
      case '/edukasi':
        return 3;
      default:
        return 0;
    }
  }
}