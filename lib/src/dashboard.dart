import 'package:flutter/material.dart';
import 'widgets/app_toolbar.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/floating_start_new_workout_button.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppToolbar(title: 'Dashboard'),
      body: Center(
        child: Text(
          'Welcome to the Workout App!',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      bottomNavigationBar: const BottomNavBar(
        currentIndex: 0,
      ),
      floatingActionButton: const FloatingStartNewWorkoutButton(),
    );
  }
}