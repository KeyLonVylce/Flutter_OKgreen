// lib/main.dart
import 'package:flutter/material.dart';
import 'presentation/page/detail_toko/beranda_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Test BerandaPage',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
      ),
      home: BerandaPage(), // Langsung ke BerandaPage
    );
  }
}