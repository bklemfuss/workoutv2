import 'package:flutter/material.dart';

class FloatingStartNewWorkoutButton extends StatelessWidget {
  const FloatingStartNewWorkoutButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.pushNamed(context, '/start_workout'); // Navigate to start_workout_screen
      },
      backgroundColor: Colors.blue, // Customize the button color
      child: const Icon(Icons.add, size: 28, color: Colors.white), // Plus icon
    );
  }
}