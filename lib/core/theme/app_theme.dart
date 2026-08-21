import 'package:flutter/material.dart';

abstract final class AppColors {
  static const navy950 = Color(0xFF07111F);
  static const navy900 = Color(0xFF0B1B2B);
  static const navy800 = Color(0xFF12304A);
  static const navy700 = Color(0xFF1B4565);
  static const gold500 = Color(0xFFD7A928);
  static const gold300 = Color(0xFFF0CE63);
  static const paper = Color(0xFFF7F9FC);
  static const ink = Color(0xFF17212B);
  static const muted = Color(0xFF64748B);
  static const success = Color(0xFF1F9D68);
  static const warning = Color(0xFFD97706);
  static const danger = Color(0xFFC43D3D);
}

abstract final class AppSpacing {
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 40.0;
}

abstract final class AppRadii {
  static const sm = 10.0;
  static const md = 16.0;
  static const lg = 22.0;
}

class AppTheme {
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.navy800,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.navy800,
      onPrimary: Colors.white,
      secondary: AppColors.gold500,
      onSecondary: AppColors.navy950,
      surface: Colors.white,
      onSurface: AppColors.ink,
      surfaceContainerHighest: const Color(0xFFE9EEF5),
      error: AppColors.danger,
    );

    final baseText = Typography.material2021().black;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.paper,
      fontFamily: 'Roboto',
      textTheme: baseText.copyWith(
        headlineLarge: baseText.headlineLarge?.copyWith(
          color: AppColors.navy950,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.0,
        ),
        headlineSmall: baseText.headlineSmall?.copyWith(
          color: AppColors.navy950,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: baseText.titleLarge?.copyWith(
          color: AppColors.navy950,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: baseText.titleMedium?.copyWith(
          color: AppColors.ink,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: baseText.bodyLarge?.copyWith(
          color: AppColors.ink,
          height: 1.45,
        ),
        bodyMedium: baseText.bodyMedium?.copyWith(
          color: AppColors.muted,
          height: 1.4,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.navy900,
        foregroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: Color(0xFFD8E0EA)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: Color(0xFFD8E0EA)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.gold500, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.muted),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.navy800,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navy800,
          minimumSize: const Size.fromHeight(48),
          side: const BorderSide(color: AppColors.navy700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFFE2E8F0), thickness: 1),
    );
  }
}
