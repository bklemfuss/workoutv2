import 'dart:io';
import 'package:flutter/material.dart';
import 'src/dashboard.dart';
import 'src/history_screen.dart';
import 'src/statistics_screen.dart';
import 'src/account_screen.dart';
import 'src/login_screen.dart';
import 'src/options_screen.dart';
import 'src/start_workout_screen.dart';
import 'src/theme/app_theme.dart'; // Import the theme file

void main() {
  runApp(const WorkoutApp());
}

class WorkoutApp extends StatelessWidget {
  const WorkoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout App',
      theme: Platform.isIOS ? iosTheme : androidTheme, // Apply theme based on OS
      initialRoute: '/',
      routes: {
        '/': (context) => Dashboard(),
        '/history': (context) => const HistoryScreen(),
        '/statistics': (context) => const StatisticsScreen(),
        '/options': (context) => const OptionsScreen(),
        '/profile': (context) => const AccountScreen(),
        '/login': (context) => const LoginScreen(),
        '/start_workout': (context) => const StartWorkoutScreen(),
      },
    );
  }
}