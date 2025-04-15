import 'package:flutter/material.dart';
import 'services/database_helper.dart';
import 'widgets/exercise_list_widget.dart';

class WorkoutSummaryScreen extends StatelessWidget {
  final int workoutId;

  const WorkoutSummaryScreen({super.key, required this.workoutId});

  Future<Map<String, dynamic>> _fetchWorkoutSummary() async {
    final dbHelper = DatabaseHelper();

    // Fetch the workout details (template name)
    final workoutDetails = await dbHelper.getWorkoutDetails(workoutId);

    // Fetch the exercises for the workout
    final workoutExercises = await dbHelper.getWorkoutExercises(workoutId);

    return {
      'workoutDetails': workoutDetails,
      'workoutExercises': workoutExercises,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Summary'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchWorkoutSummary(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading workout summary.'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No workout summary found.'));
          } else {
            final workoutDetails = snapshot.data!['workoutDetails'] as Map<String, dynamic>;
            final workoutExercises = snapshot.data!['workoutExercises'] as List<Map<String, dynamic>>;

            return Column(
              children: [
                // Display the template name
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue[100],
                  child: Text(
                    workoutDetails['template_name'] ?? 'Unknown Template',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                // Display the list of exercises using ExerciseListWidget
                Expanded(
                  child: ExerciseListWidget(exercises: workoutExercises),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}