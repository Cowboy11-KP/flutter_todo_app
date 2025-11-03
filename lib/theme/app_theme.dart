import 'package:flutter/material.dart';
import 'package:frontend/theme/app_color.dart';


class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    fontFamily: 'Poppins',

    textTheme: const TextTheme(
      headlineLarge: TextStyle( // Tiêu đề lớn
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      headlineMedium: TextStyle( // Tiêu đề trung bình
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      bodyLarge: TextStyle( // Tiêu đề task
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Color(0xDEFFFFFF),
      ),
      bodyMedium: TextStyle( // Mô tả task
        fontSize: 14,
        color: Color(0xFF9A9A9A),
      ),
      bodySmall: TextStyle( // Placeholder
        fontSize: 14,
        color: Color(0xFFB0B0B0),
      ),
      labelLarge: TextStyle( // Text button
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      labelMedium: TextStyle( // Placeholder
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Color(0xDEFFFFFF),
      ),
      labelSmall: TextStyle( // Text phụ nhỏ
        fontSize: 12,
        color: Color(0xFF888888),
      ),
    ),


    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: AppColors.textSecondary),
    ),
  );
}
