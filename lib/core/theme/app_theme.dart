import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      surface: AppColors.surface,
      background: AppColors.background,
    );

    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(
            color: AppColors.border,
            width: 1.5,
          ),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 56,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          letterSpacing: -1.0,
        ),
        displayMedium: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.background,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
