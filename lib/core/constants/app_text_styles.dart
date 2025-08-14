import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const greeting = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.grey800,
  );

  static const smallDescription = TextStyle(
    fontSize: 12,
    color: AppColors.grey600,
    height: 1.3,
  );

  static const price = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.grey800,
  );

  static const ecoDescription = TextStyle(
    fontSize: 11,
    color: AppColors.grey600,
    height: 1.4,
  );

  static const userName = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
}