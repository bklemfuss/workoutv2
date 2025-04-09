import 'package:flutter/material.dart';

class StartWorkoutScreen extends StatelessWidget {
  const StartWorkoutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Workout'),
      ),
      body: const Center(
        child: Text(
          'This is the Start Workout Screen',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}