import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class FloatingStartNewWorkoutButton extends StatelessWidget {
  const FloatingStartNewWorkoutButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      material: (_, __) => FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/start_workout'); // Navigate to start_workout_screen
        },
        backgroundColor: Colors.blue, // Customize the button color
        child: const Icon(Icons.add, size: 28, color: Colors.white), // Plus icon
      ),
      cupertino: (_, __) => CupertinoButton(
        onPressed: () {
          Navigator.pushNamed(context, '/start_workout'); // Navigate to start_workout_screen
        },
        color: CupertinoColors.activeBlue, // Customize the button color
        padding: const EdgeInsets.all(16),
        child: const Icon(CupertinoIcons.add, size: 28, color: CupertinoColors.white),
      ),
    );
  }
}