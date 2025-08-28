import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Existing styles
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

  // Login/Register Screen Styles
  static const pageTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.grey800,
  );

  static const pageSubtitle = TextStyle(
    fontSize: 16,
    color: AppColors.white,
  );

  static const inputLabel = TextStyle(
    color: AppColors.grey800,
  );

  static const inputHint = TextStyle(
    color: AppColors.grey600,
  );

  static const rememberMeText = TextStyle(
    fontSize: 14,
    color: AppColors.grey600,
  );

  static const forgotPasswordText = TextStyle(
    fontSize: 14,
    color: AppColors.primary,
    fontWeight: FontWeight.w600,
  );

  static const buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const dividerText = TextStyle(
    color: AppColors.grey600,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static const linkPromptText = TextStyle(
    color: AppColors.grey600,
    fontSize: 14,
  );

  static const linkText = TextStyle(
    color: AppColors.primary,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
}