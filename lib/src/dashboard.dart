import 'package:flutter/material.dart';
import 'widgets/app_toolbar.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppToolbar(title: 'Dashboard'),
      body: const Center(
        child: Text(
          'Welcome to the Workout App!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}