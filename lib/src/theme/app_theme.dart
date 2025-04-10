import 'package:flutter/material.dart';
import 'colors.dart'; // Import your colors

final ThemeData androidTheme = ThemeData(
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
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
    selectedItemColor: AppColors.secondary,
    unselectedItemColor: AppColors.textSecondary,
    backgroundColor: AppColors.background,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(fontSize: 16, color: AppColors.textPrimary),
    bodyMedium: TextStyle(fontSize: 14, color: AppColors.textSecondary),
  ),
);

final ThemeData iosTheme = ThemeData(
  primaryColor: AppColors.secondary,
  scaffoldBackgroundColor: AppColors.background,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.secondary,
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
    unselectedItemColor: AppColors.textSecondary,
    backgroundColor: AppColors.background,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(fontSize: 16, color: AppColors.textPrimary),
    bodyMedium: TextStyle(fontSize: 14, color: AppColors.textSecondary),
  ),
);