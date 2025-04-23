import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData lightTheme(double fontSize) {
    return ThemeData(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      cardColor: AppColors.primary,
      inputDecorationTheme: InputDecorationTheme(
        fillColor: AppColors.inputFieldBackground, // Use the new light grey color
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), // Rounded corners
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10), // Adjust padding
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimaryLight,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.secondary,
        backgroundColor: AppColors.backgroundLight,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(fontSize: fontSize, color: AppColors.textPrimaryLight),
        bodyMedium: TextStyle(fontSize: fontSize - 2, color: const Color.fromARGB(255, 59, 59, 59)),
      ),
    );
  }

  static ThemeData darkTheme(double fontSize) {
    return ThemeData(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      cardColor: AppColors.secondary,
      inputDecorationTheme: InputDecorationTheme(
        fillColor: AppColors.inputFieldBackground, // Use the same light grey color for consistency
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), // Rounded corners
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10), // Adjust padding
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimaryDark,
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
        bodyLarge: TextStyle(fontSize: fontSize, color: AppColors.textPrimaryDark),
        bodyMedium: TextStyle(fontSize: fontSize - 2, color: AppColors.textSecondaryDark),
      ),
    );
  }
}