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
  );

  static const price = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.grey800,
  );
}
