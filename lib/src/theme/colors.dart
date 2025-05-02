import 'package:flutter/material.dart';

class AppColors {
  // Existing dark mode colors
  static const primary = Color.fromARGB(255, 245, 133, 81);
  static const secondary = Color.fromARGB(255, 248, 104, 37);
  static const background = Color.fromARGB(255, 29, 43, 59);

  // Improved text colors for dark mode
  static const textPrimaryDark = Color.fromARGB(255, 220, 220, 220); // A slightly softer white
  static const textSecondaryDark = Color.fromARGB(255, 248, 247, 247); // A light gray for less emphasis

  // Light mode colors
  static const backgroundLight = Color.fromARGB(255, 231, 231, 231); // A light gray background
  static const textPrimaryLight = Color.fromARGB(255, 30, 30, 30);   // A dark gray for good contrast
  static const textSecondaryLight = Color.fromARGB(255, 90, 90, 90);  // A medium gray for less emphasis

  // Input field background color
  static const inputFieldBackground = Color.fromARGB(255, 248, 142, 93); 

  // Add new colors here
  static const Color success = Colors.green; // Define success color
  static const Color onSuccess = Colors.white; // Define text/icon color on success background
}