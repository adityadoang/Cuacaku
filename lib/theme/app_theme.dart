// File: lib/theme/app_theme.dart
// Fungsi: Mendefinisikan palet warna, tipografi, dan tema Material Design 3
// yang digunakan secara konsisten di seluruh tampilan aplikasi.

import 'package:flutter/material.dart';

/// Konfigurasi Theme Material Design 3 yang konsisten untuk seluruh aplikasi.
class AppTheme {
  const AppTheme._();

  static const Color primarySky = Color(0xFF5B9DF8);
  static const Color deepIndigo = Color(0xFF4749B8);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color softBackground = Color(0xFFF3F6FC);
  static const Color cardBorder = Color(0xFFE4EAF5);
  static const Color textPrimary = Color(0xFF1A2138);
  static const Color textSecondary = Color(0xFF7B859B);
  static const Color accentAmber = Color(0xFFFFC107);
  static const Color accentRain = Color(0xFF4FA3F7);
  static const Color accentCoral = Color(0xFFFF6B6B);

  /// Mengembalikan konfigurasi [ThemeData] mode terang untuk aplikasi.
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primarySky,
      primary: primarySky,
      secondary: deepIndigo,
      surface: surfaceWhite,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: softBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 96,
          fontWeight: FontWeight.w200,
          letterSpacing: -4.0,
          color: Colors.white,
          height: 1.0,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          color: textSecondary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        hintStyle: const TextStyle(
          color: textSecondary,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE2E8F4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: primarySky, width: 1.6),
        ),
      ),
    );
  }
}
