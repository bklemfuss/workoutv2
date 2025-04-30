import 'dart:async';
import 'package:flutter/material.dart';
import 'services/database_helper.dart';
import 'widgets/exercise_input_card.dart';
import 'package:provider/provider.dart';
import 'providers/unit_provider.dart';

class InProgressWorkoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> exercises;
  final int templateId;

  const InProgressWorkoutScreen({
    Key? key,
    required this.exercises,
    required this.templateId,
  }) : super(key: key);

  @override
  State<InProgressWorkoutScreen> createState() => _InProgressWorkoutScreenState();
}

class _InProgressWorkoutScreenState extends State<InProgressWorkoutScreen> {
  late Timer _timer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
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

  Future<void> _finishWorkout(BuildContext context) async {
    final dbHelper = DatabaseHelper();

    try {
      debugPrint('Starting _finishWorkout...');

      // Step 1: Create a new workout
      debugPrint('Creating a new workout...');
      final workoutId = await dbHelper.createWorkout(widget.templateId, 1); // Use user_id = 1 for now
      debugPrint('Workout created with ID: $workoutId');

      // Step 2: Prepare workout exercises data
      debugPrint('Preparing workout exercises data...');
      final workoutExercises = <Map<String, dynamic>>[];

      for (final exercise in widget.exercises) {
        debugPrint('Processing exercise: $exercise');
        for (final row in exercise['rows'] ?? []) {
          debugPrint('Processing row: $row');
          workoutExercises.add({
            'exercise_id': exercise['exercise_id'],
            'reps': row['reps'] ?? 0, // Default to 0 if null
            'weight': row['weight'] ?? 0.0, // Default to 0.0 if null
          });
        }
      }

      debugPrint('Workout exercises prepared: $workoutExercises');

      // Step 3: Create workout exercises
      debugPrint('Creating workout exercises...');
      await dbHelper.createWorkoutExercises(workoutId, workoutExercises);
      debugPrint('Workout exercises created.');

      // Step 4: Save the workout timer in the database
      debugPrint('Saving workout timer...');
      await dbHelper.updateWorkoutTimer(workoutId, _elapsedSeconds);
      debugPrint('Workout timer saved.');

      // Step 5: Navigate to the PostWorkoutScreen using named route
      debugPrint('Navigating to PostWorkoutScreen...');
      Navigator.pushReplacementNamed(
        context,
        '/workout_summary',
        arguments: workoutId,
      );
      debugPrint('Navigation complete.');
    } catch (e, stackTrace) {
      debugPrint('Error in _finishWorkout: $e');
      debugPrint('StackTrace: $stackTrace');
    }
  }

  Future<void> _discardWorkout(BuildContext context) async {
    // Simply navigate back to the dashboard without saving anything
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final unitProvider = Provider.of<UnitProvider>(context);
    final isMetric = unitProvider.unitSystem == 'Metric';
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text('In Progress Workout')),
      body: Column(
        children: [
          // Top Section (5% of the screen height)
          Container(
            height: screenHeight * 0.05,
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            color: Colors.blue[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatTime(_elapsedSeconds), // Display the timer
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () async {
                    debugPrint('Finish Workout button pressed.');
                    final confirm = await showDialog<int>(
                      context: context,
                      builder: (context) {
                        debugPrint('Showing confirmation dialog...');
                        return AlertDialog(
                          title: const Text('Finish Workout'),
                          content: const Text(
                              'What would you like to do with this workout?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                debugPrint('Cancel selected.');
                                Navigator.pop(context, 0);
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                debugPrint('Finish and Save selected.');
                                Navigator.pop(context, 1);
                              },
                              child: const Text('Finish and Save'),
                            ),
                            TextButton(
                              onPressed: () {
                                debugPrint('Finish and Discard selected.');
                                Navigator.pop(context, 2);
                              },
                              child: const Text('Finish and Discard'),
                            ),
                          ],
                        );
                      },
                    );

                    debugPrint('Dialog result: $confirm');
                    if (confirm == 1) {
                      // Finish and save the workout
                      debugPrint('Calling _finishWorkout...');
                      await _finishWorkout(context);
                    } else if (confirm == 2) {
                      // Finish and discard the workout
                      debugPrint('Calling _discardWorkout...');
                      await _discardWorkout(context);
                    } else {
                      debugPrint('No action taken.');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.01,
                      horizontal: screenWidth * 0.05,
                    ),
                  ),
                  child: const Text(
                    'Finish Workout',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          // Scrollable List of Exercises (95% of the screen height)
          Expanded(
            child: ListView.builder(
              itemCount: widget.exercises.length,
              itemBuilder: (context, index) {
                final exercise = widget.exercises[index];
                debugPrint('Building ExerciseInputCard for exercise: $exercise');
                return ExerciseInputCard(
                  exercise: exercise,
                  onChanged: (updatedExercise) {
                    setState(() {
                      debugPrint('Updating exercise at index $index with: $updatedExercise');
                      widget.exercises[index] = updatedExercise; // Update the exercise in the list
                    });
                  },
                );
              },
            ),
          ),
          Center(
            child: Text(
              'Weight: ${isMetric ? 'kg' : 'lbs'}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}