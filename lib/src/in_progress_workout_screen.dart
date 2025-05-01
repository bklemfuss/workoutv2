import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/unit_provider.dart';
import 'services/database_helper.dart'; // Import DatabaseHelper
import 'widgets/exercise_input_card.dart';

class InProgressWorkoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> exercises;
  final int templateId;

  const InProgressWorkoutScreen({Key? key, required this.exercises, required this.templateId})
      : super(key: key);

  @override
  State<InProgressWorkoutScreen> createState() => _InProgressWorkoutScreenState();
}

class _InProgressWorkoutScreenState extends State<InProgressWorkoutScreen> {
  late Timer _timer;
  int _elapsedSeconds = 0;
  //  Use a Map to store the exercise data, keyed by exercise_id.
  final Map<int, List<Map<String, dynamic>>> _exercisesData = {};

  @override
  void initState() {
    super.initState();
    // Ensure proper initialization of controllers or focus nodes if used
    for (var exercise in widget.exercises) {
      _exercisesData[exercise['exercise_id']] = [
        {'reps': 0, 'weight': 0.0}
      ]; // Initialize with one default set
    }
    _startTimer();
  }

  @override
  void dispose() {
    // Ensure proper disposal of controllers or focus nodes if used
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

    void _handleSetsChanged(int exerciseId, List<Map<String, dynamic>> sets) {
    setState(() {
      _exercisesData[exerciseId] = sets;
    });
  }

  Future<void> _finishWorkout(BuildContext context) async {
  final dbHelper = DatabaseHelper();
  final db = await dbHelper.database; // Await the database getter

  try {
    // Step 1: Create a new workout
    final workoutId =
        await dbHelper.createWorkout(widget.templateId, 1); // Use user_id = 1 for now

    // **Use a transaction to ensure data consistency.**
    await db.transaction((txn) async {
      // Step 2: Create workout exercises
      for (var exerciseId in _exercisesData.keys) {
        final sets = _exercisesData[exerciseId]!; // Get sets for this exercise
        for (var set in sets) {
          await dbHelper.createWorkoutExercise(
            txn, // Pass the transaction
            workoutId,
            exerciseId,
            set['reps'] ?? 0,
            set['weight'] ?? 0.0,
          );
        }
      }
    });

    // Step 3: Save the workout timer in the database
    await dbHelper.updateWorkoutTimer(workoutId, _elapsedSeconds);

    // Step 4: Navigate to the PostWorkoutScreen using named route
    Navigator.pushReplacementNamed(
      context,
      '/workout_summary',
      arguments: workoutId,
    );
  } catch (e, stackTrace) {
    //  Show error to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to save workout: $e'), backgroundColor: Colors.red),
    );
  }
}

  Future<void> _discardWorkout(BuildContext context) async {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get the theme
    final colorScheme = theme.colorScheme; // Get the color scheme
    final textTheme = theme.textTheme; // Get the text theme

    // Ensure no parent widget intercepts touch events
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard on tap outside
      child: Scaffold(
        appBar: AppBar(title: const Text('In Progress Workout')), // Uses AppBarTheme
        body: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.05,
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
              // Use a theme color, maybe secondary or a custom one if needed
              color: colorScheme.secondaryContainer, // Example: Using secondaryContainer
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatTime(_elapsedSeconds),
                    // Use a text theme style
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final confirm = await showDialog<int>(
                        context: context,
                        builder: (context) {
                          // AlertDialog will use DialogTheme from AppTheme
                          return AlertDialog(
                            title: const Text('Finish Workout'),
                            content: const Text('What would you like to do with this workout?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, 0);
                                },
                                // TextButton uses TextButtonTheme
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, 1);
                                },
                                child: const Text('Finish and Save'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, 2);
                                },
                                // Consider a different style for destructive actions if needed
                                child: Text(
                                  'Finish and Discard',
                                  style: TextStyle(color: colorScheme.error), // Use error color for discard
                                ),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm == 1) {
                        await _finishWorkout(context);
                      } else if (confirm == 2) {
                        await _discardWorkout(context);
                      } else {
                        debugPrint('No action taken.');
                      }
                    },
                    // Use ElevatedButtonTheme, potentially override specific properties if needed
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Keep specific color for this button? Or use theme.colorScheme.primary?
                      foregroundColor: Colors.white, // Ensure contrast with green
                      padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.height * 0.01,
                        horizontal: MediaQuery.of(context).size.width * 0.05,
                      ),
                      // Use text style from theme if possible, or define explicitly if needed
                      textStyle: textTheme.labelLarge?.copyWith(fontSize: 14), // Example using labelLarge
                    ),
                    child: const Text(
                      'Finish Workout',
                      // Style is now mostly handled by ElevatedButton.styleFrom
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.exercises.length,
                itemBuilder: (context, index) {
                  final exercise = widget.exercises[index];
                  return ExerciseInputCard(
                    exercise: exercise,
                    onSetsChanged: _handleSetsChanged,
                  );
                },
              ),
            ),
            Padding( // Add some padding
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Weight: ${Provider.of<UnitProvider>(context).unitSystem == 'Metric' ? 'kg' : 'lbs'}',
                  // Use a text theme style
                  style: textTheme.bodyLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
