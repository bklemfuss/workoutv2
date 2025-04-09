import 'package:flutter/material.dart';
import 'widgets/app_toolbar.dart';
import 'widgets/bottom_nav_bar.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppToolbar(title: 'Dashboard'),
      body: Center(
        child: Text(
          'Welcome to the Workout App!',
          style: Theme.of(context).textTheme.bodyLarge, // Use the shared body text style
        ),
      ),
      bottomNavigationBar: const BottomNavBar(
        currentIndex: 0, // Index for Dashboard
      ),
    );
  }
}