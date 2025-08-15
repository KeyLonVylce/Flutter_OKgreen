import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';

class AppDecorations {
  // Gradient Decoration
  static const BoxDecoration waveGradient = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.primary,
        AppColors.primaryDark,
      ],
    ),
  );

  // Form Container Decoration
  static BoxDecoration formContainer = BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(AppDimensions.shadowOpacity),
        blurRadius: AppDimensions.shadowBlur,
        offset: AppDimensions.shadowOffset,
      ),
    ],
  );
}

class AppInputDecorations {
  // Base Input Decoration
  static InputDecoration baseInputDecoration({
    required String labelText,
    required String hintText,
    required Widget prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),
    );
  }
}

class AppButtonStyles {
  // Primary Button Style
  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
    ),
  );
}