import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  // Define ColorSchemes
  static const lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.textPrimaryLight, // Color for text/icons on primary
    secondary: AppColors.secondary,
    onSecondary: AppColors.textPrimaryLight, // Color for text/icons on secondary
    error: Colors.redAccent, // Standard error color
    onError: Colors.white, // Color for text/icons on error
    background: AppColors.backgroundLight,
    onBackground: AppColors.textPrimaryLight, // Color for text/icons on background
    surface: AppColors.backgroundLight, // Often similar to background in light theme
    onSurface: AppColors.textPrimaryLight, // Color for text/icons on surface
    // Add other colors if needed, or use defaults
  );

  static const darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primary,
    onPrimary: AppColors.textPrimaryDark, // Color for text/icons on primary
    secondary: AppColors.secondary,
    onSecondary: AppColors.textPrimaryDark, // Color for text/icons on secondary
    error: Colors.redAccent, // Standard error color
    onError: Colors.black, // Color for text/icons on error
    background: AppColors.background,
    onBackground: AppColors.textPrimaryDark, // Color for text/icons on background
    surface: AppColors.secondary, // Use secondary as surface color in dark theme
    onSurface: AppColors.textPrimaryDark, // Color for text/icons on surface
    // Add other colors if needed, or use defaults
  );

  static ThemeData lightTheme(double fontSize) {
    final baseTextTheme = ThemeData.light().textTheme; // Get base theme for defaults
    final colorScheme = lightColorScheme; // Use defined light scheme

    return ThemeData(
      colorScheme: colorScheme, // Use ColorScheme
      scaffoldBackgroundColor: colorScheme.background,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: colorScheme.onPrimary,
        ),
        iconTheme: IconThemeData(color: colorScheme.onPrimary), // Ensure icons match
      ),
      cardTheme: CardTheme(
        color: colorScheme.surface, // Use surface color for cards
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: AppColors.inputFieldBackground, // Keep specific input background
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none, // Remove border if filled
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Adjusted padding
        hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.secondary, // Use secondary color
        backgroundColor: colorScheme.surface, // Use surface color
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: fontSize * 0.8),
        unselectedLabelStyle: TextStyle(fontSize: fontSize * 0.8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          textStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: TextStyle(fontSize: fontSize),
        ),
      ),
      iconTheme: IconThemeData( // Default icon theme
        color: colorScheme.onBackground,
        size: 24.0,
      ),
      dialogTheme: DialogTheme(
         backgroundColor: colorScheme.background,
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
         titleTextStyle: baseTextTheme.titleLarge?.copyWith(color: colorScheme.onBackground, fontSize: fontSize + 2),
         contentTextStyle: baseTextTheme.bodyMedium?.copyWith(color: colorScheme.onBackground, fontSize: fontSize),
      ),
      textTheme: TextTheme(
        // Define various text styles using the fontSize and colorScheme
        displayLarge: baseTextTheme.displayLarge?.copyWith(fontSize: fontSize + 10, color: colorScheme.onBackground),
        displayMedium: baseTextTheme.displayMedium?.copyWith(fontSize: fontSize + 8, color: colorScheme.onBackground),
        displaySmall: baseTextTheme.displaySmall?.copyWith(fontSize: fontSize + 6, color: colorScheme.onBackground),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(fontSize: fontSize + 4, color: colorScheme.onBackground, fontWeight: FontWeight.bold),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(fontSize: fontSize + 2, color: colorScheme.onBackground, fontWeight: FontWeight.bold),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(fontSize: fontSize + 1, color: colorScheme.onBackground, fontWeight: FontWeight.bold),
        titleLarge: baseTextTheme.titleLarge?.copyWith(fontSize: fontSize + 2, color: colorScheme.onBackground),
        titleMedium: baseTextTheme.titleMedium?.copyWith(fontSize: fontSize, color: colorScheme.onBackground),
        titleSmall: baseTextTheme.titleSmall?.copyWith(fontSize: fontSize - 1, color: colorScheme.onBackground),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(fontSize: fontSize, color: colorScheme.onBackground),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(fontSize: fontSize - 2, color: AppColors.textSecondaryLight), // Use specific secondary text color
        bodySmall: baseTextTheme.bodySmall?.copyWith(fontSize: fontSize - 4, color: AppColors.textSecondaryLight),
        labelLarge: baseTextTheme.labelLarge?.copyWith(fontSize: fontSize, color: colorScheme.onPrimary, fontWeight: FontWeight.bold), // Often used in buttons
        labelMedium: baseTextTheme.labelMedium?.copyWith(fontSize: fontSize - 1, color: colorScheme.onBackground),
        labelSmall: baseTextTheme.labelSmall?.copyWith(fontSize: fontSize - 2, color: colorScheme.onBackground),
      ).apply( // Apply base colors if needed, though ColorScheme handles most
        bodyColor: colorScheme.onBackground,
        displayColor: colorScheme.onBackground,
      ),
      // Keep primaryColor for potential direct access, though ColorScheme is preferred
      primaryColor: colorScheme.primary,
    );
  }

  static ThemeData darkTheme(double fontSize) {
    final baseTextTheme = ThemeData.dark().textTheme; // Get base theme for defaults
    final colorScheme = darkColorScheme; // Use defined dark scheme

    return ThemeData(
      colorScheme: colorScheme, // Use ColorScheme
      scaffoldBackgroundColor: colorScheme.background,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: colorScheme.onPrimary,
        ),
        iconTheme: IconThemeData(color: colorScheme.onPrimary), // Ensure icons match
      ),
       cardTheme: CardTheme(
        color: colorScheme.surface, // Use surface color for cards
        elevation: 4, // Slightly more elevation in dark mode can look good
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: AppColors.inputFieldBackground, // Keep specific input background
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
           borderSide: BorderSide.none, // Remove border if filled
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Adjusted padding
        hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.secondary, // Use secondary color
        backgroundColor: colorScheme.surface, // Use surface color
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: fontSize * 0.8),
        unselectedLabelStyle: TextStyle(fontSize: fontSize * 0.8),
      ),
       elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          textStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: TextStyle(fontSize: fontSize),
        ),
      ),
      iconTheme: IconThemeData( // Default icon theme
        color: colorScheme.onBackground,
        size: 24.0,
      ),
      dialogTheme: DialogTheme(
         backgroundColor: colorScheme.background,
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
         titleTextStyle: baseTextTheme.titleLarge?.copyWith(color: colorScheme.onBackground, fontSize: fontSize + 2),
         contentTextStyle: baseTextTheme.bodyMedium?.copyWith(color: colorScheme.onBackground, fontSize: fontSize),
      ),
      textTheme: TextTheme(
        // Define various text styles using the fontSize and colorScheme
        displayLarge: baseTextTheme.displayLarge?.copyWith(fontSize: fontSize + 10, color: colorScheme.onBackground),
        displayMedium: baseTextTheme.displayMedium?.copyWith(fontSize: fontSize + 8, color: colorScheme.onBackground),
        displaySmall: baseTextTheme.displaySmall?.copyWith(fontSize: fontSize + 6, color: colorScheme.onBackground),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(fontSize: fontSize + 4, color: colorScheme.onBackground, fontWeight: FontWeight.bold),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(fontSize: fontSize + 2, color: colorScheme.onBackground, fontWeight: FontWeight.bold),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(fontSize: fontSize + 1, color: colorScheme.onBackground, fontWeight: FontWeight.bold),
        titleLarge: baseTextTheme.titleLarge?.copyWith(fontSize: fontSize + 2, color: colorScheme.onBackground),
        titleMedium: baseTextTheme.titleMedium?.copyWith(fontSize: fontSize, color: colorScheme.onBackground),
        titleSmall: baseTextTheme.titleSmall?.copyWith(fontSize: fontSize - 1, color: colorScheme.onBackground),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(fontSize: fontSize, color: colorScheme.onBackground),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(fontSize: fontSize - 2, color: AppColors.textSecondaryDark), // Use specific secondary text color
        bodySmall: baseTextTheme.bodySmall?.copyWith(fontSize: fontSize - 4, color: AppColors.textSecondaryDark),
        labelLarge: baseTextTheme.labelLarge?.copyWith(fontSize: fontSize, color: colorScheme.onPrimary, fontWeight: FontWeight.bold), // Often used in buttons
        labelMedium: baseTextTheme.labelMedium?.copyWith(fontSize: fontSize - 1, color: colorScheme.onBackground),
        labelSmall: baseTextTheme.labelSmall?.copyWith(fontSize: fontSize - 2, color: colorScheme.onBackground),
      ).apply( // Apply base colors if needed, though ColorScheme handles most
        bodyColor: colorScheme.onBackground,
        displayColor: colorScheme.onBackground,
      ),
       // Keep primaryColor for potential direct access, though ColorScheme is preferred
      primaryColor: colorScheme.primary,
    );
  }
}