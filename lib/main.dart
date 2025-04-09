import 'package:flutter/material.dart';
import 'src/dashboard.dart';
import 'src/history_screen.dart';
import 'src/statistics_screen.dart';
import 'src/account_screen.dart';
import 'src/login_screen.dart';
import 'src/widgets/bottom_nav_bar.dart';

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
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => Dashboard(),
        '/history': (context) => const HistoryScreen(),
        '/statistics': (context) => const StatisticsScreen(),
        '/profile': (context) => const AccountScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}