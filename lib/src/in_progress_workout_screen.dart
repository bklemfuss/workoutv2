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
     // Initialize _exercisesData
    for (var exercise in widget.exercises) {
      _exercisesData[exercise['exercise_id']] = [
        {'reps': 0, 'weight': 0.0}
      ]; // Initialize with one default set
    }
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
    final unitProvider = Provider.of<UnitProvider>(context);
    final isMetric = unitProvider.unitSystem == 'Metric';
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text('In Progress Workout')),
      body: Column(
        children: [
          Container(
            height: screenHeight * 0.05,
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            color: Colors.blue[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatTime(_elapsedSeconds),
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
                          content: const Text('What would you like to do with this workout?'),
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
                      debugPrint('Calling _finishWorkout...');
                      await _finishWorkout(context);
                    } else if (confirm == 2) {
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
