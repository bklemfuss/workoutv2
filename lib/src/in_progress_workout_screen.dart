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

    // Step 1: Create a new workout
    final workoutId = await dbHelper.createWorkout(widget.templateId, 1); // Use user_id = 1 for now

    // Step 2: Prepare exercise data
    final workoutExercises = widget.exercises.map((exercise) {
      return {
        'exercise_id': exercise['exercise_id'],
        'sets': exercise['sets'],
        'reps': exercise['reps'],
        'weight': exercise['weight'],
      };
    }).toList();

    // Step 3: Create workout exercises
    await dbHelper.createWorkoutExercises(workoutId, workoutExercises);

    // Step 4: Save the workout timer in the database
    await dbHelper.updateWorkoutTimer(workoutId, _elapsedSeconds);

    // Step 5: Navigate back to the dashboard
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
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
                    final confirm = await showDialog<int>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Finish Workout'),
                          content: const Text(
                              'What would you like to do with this workout?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, 0),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, 1),
                              child: const Text('Finish and Save'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, 2),
                              child: const Text('Finish and Discard'),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirm == 1) {
                      // Finish and save the workout
                      await _finishWorkout(context);
                    } else if (confirm == 2) {
                      // Finish and discard the workout
                      await _discardWorkout(context);
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
                return ExerciseInputCard(
                  exercise: exercise,
                  onChanged: (updatedExercise) {
                    // Update the exercise in the list
                    widget.exercises[index] = updatedExercise;
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