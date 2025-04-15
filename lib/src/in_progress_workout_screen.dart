import 'package:flutter/material.dart';
import 'services/database_helper.dart';
import 'widgets/exercise_list_widget.dart';

class InProgressWorkoutScreen extends StatelessWidget {
  final List<Map<String, dynamic>> exercises;
  final int templateId;

  const InProgressWorkoutScreen({super.key, required this.exercises, required this.templateId});

  Future<void> _finishWorkout(BuildContext context) async {
    final dbHelper = DatabaseHelper();

    // Step 1: Create a new workout
    final workoutId = await dbHelper.createWorkout(templateId, 1); // Use user_id = 1 for now

    // Step 2: Prepare exercise data
    final workoutExercises = exercises.map((exercise) {
      return {
        'exercise_id': exercise['exercise_id'],
        'sets': exercise['sets'],
        'reps': exercise['reps'],
        'weight': exercise['weight'],
      };
    }).toList();

    // Step 3: Create workout exercises
    await dbHelper.createWorkoutExercises(workoutId, workoutExercises);

    // Step 4: Navigate back to the dashboard
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
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
                const Text(
                  'Timer Placeholder',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Finish Workout'),
                          content: const Text('Are you sure you want to finish the workout?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Confirm'),
                            ),
                          ],
                        );
                      },
                    );
                    if (confirm == true) {
                      await _finishWorkout(context);
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
            child: ExerciseListWidget(exercises: exercises),
          ),
        ],
      ),
    );
  }
}