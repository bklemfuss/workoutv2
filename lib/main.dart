import 'package:flutter/material.dart';
import 'src/dashboard.dart';
import 'src/history_screen.dart';
import 'src/statistics_screen.dart';
import 'src/account_screen.dart';
import 'src/login_screen.dart';
import 'src/options_screen.dart';
import 'src/widgets/colors.dart';

void main() {
  runApp(const WorkoutApp());
}

class WorkoutApp extends StatelessWidget {
  const WorkoutApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout App',
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 16, color: AppColors.textPrimary),
          bodyMedium: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => Dashboard(),
        '/history': (context) => const HistoryScreen(),
        '/statistics': (context) => const StatisticsScreen(),
        '/options': (context) => const OptionsScreen(),
        '/profile': (context) => const AccountScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}