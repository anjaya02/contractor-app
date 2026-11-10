import 'package:flutter/material.dart';

abstract final class AppColors {
  static const navy = Color(0xFF132C40);
  static const teal = Color(0xFF087E83);
  static const ink = Color(0xFF182B3A);
  static const muted = Color(0xFF586875);
  static const background = Color(0xFFF4F7F8);
  static const border = Color(0xFFDCE3E7);
  static const error = Color(0xFFB3261E);
  static const errorSurface = Color(0xFFFFF1EF);
}

abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const section = 48.0;
}

abstract final class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      primary: AppColors.navy,
      secondary: AppColors.teal,
      surface: Colors.white,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 34,
          height: 1.15,
          fontWeight: FontWeight.w700,
          letterSpacing: -1,
          color: AppColors.ink,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          height: 1.2,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
          color: AppColors.ink,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
        bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: AppColors.muted),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.5,
          color: AppColors.muted,
        ),
        bodySmall: TextStyle(fontSize: 12, height: 1.5, color: AppColors.muted),
        labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFB),
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        hintStyle: const TextStyle(color: AppColors.muted, fontSize: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.teal, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
