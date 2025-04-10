import 'package:flutter/material.dart';
import 'widgets/app_toolbar.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/floating_start_new_workout_button.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppToolbar(title: 'Statistics'),
      body: const Center(
        child: Text(
          'This is the Statistics Screen',
          style: TextStyle(fontSize: 18),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(
        currentIndex: 2,
      ),
      floatingActionButton: const FloatingStartNewWorkoutButton(),
    );
  }
}