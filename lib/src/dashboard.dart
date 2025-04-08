import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout App'),
        centerTitle: true,
      ),
      body: Center(
        child: const Text(
          'Welcome to the Workout App!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}