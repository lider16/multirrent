import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const TextStyle headlineSmall = TextStyle(
    color: AppColors.onBackground,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle titleLarge = TextStyle(
    color: AppColors.onSurface,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleMedium = TextStyle(
    color: AppColors.onSurface,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle bodyLarge = TextStyle(
    color: AppColors.onSurface,
    fontSize: 16,
  );

  static const TextStyle bodyMedium = TextStyle(
    color: AppColors.onSurface,
    fontSize: 14,
  );
}
