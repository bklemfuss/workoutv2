import 'package:flutter/material.dart';
import 'widgets/app_toolbar.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/floating_start_new_workout_button.dart';

class OptionsScreen extends StatelessWidget {
  const OptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppToolbar(title: 'Options'),
      body: const Center(
        child: Text(
          'This is the Options Screen',
          style: TextStyle(fontSize: 18),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(
        currentIndex: 3, // Index for Options
      ),
      floatingActionButton: const FloatingStartNewWorkoutButton(),
    );
  }
}