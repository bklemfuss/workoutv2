import 'package:flutter/material.dart';
import 'colors.dart'; // Import your colors

class AppTheme {
  static ThemeData lightTheme(double fontSize) {
    return ThemeData(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      cardColor: AppColors.primary,
      inputDecorationTheme: const InputDecorationTheme(
        fillColor: AppColors.background,
        filled: true,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.secondary,
        backgroundColor: AppColors.background,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(fontSize: fontSize, color: AppColors.textPrimary),
        bodyMedium: TextStyle(fontSize: fontSize - 2, color: AppColors.textSecondary),
      ),
    );
  }

  static ThemeData darkTheme(double fontSize) {
    return ThemeData(
      primaryColor: AppColors.secondary,
      scaffoldBackgroundColor: Colors.black,
      cardColor: Colors.grey[800],
      inputDecorationTheme: const InputDecorationTheme(
        fillColor: Colors.black,
        filled: true,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(fontSize: fontSize, color: Colors.white),
        bodyMedium: TextStyle(fontSize: fontSize - 2, color: Colors.grey),
      ),
    );
  }
}