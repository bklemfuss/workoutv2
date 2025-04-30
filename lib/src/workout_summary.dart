import 'package:flutter/material.dart';
import 'services/database_helper.dart';
import 'widgets/exercise_list_widget.dart';

class WorkoutSummaryScreen extends StatelessWidget {
  final int workoutId;

  const WorkoutSummaryScreen({super.key, required this.workoutId});

  Future<void> _deleteWorkout(BuildContext context) async {
    final dbHelper = DatabaseHelper();

    try {
      // Delete the workout and associated workout exercises
      await dbHelper.deleteWorkout(workoutId);

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Workout deleted successfully!'),
          backgroundColor: Theme.of(context).colorScheme.primary, // Use theme color
        ),
      );

      // Close the modal and return `true` to indicate deletion
      Navigator.pop(context, true);
    } catch (e) {
      // Show an error message if deletion fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete workout: $e'),
          backgroundColor: Theme.of(context).colorScheme.error, // Use theme error color
        ),
      );
    }
  }

  Future<Map<String, dynamic>> _fetchWorkoutSummary() async {
    final dbHelper = DatabaseHelper();

    // Fetch the workout details (template name and workout timer)
    final workoutDetails = await dbHelper.getWorkoutDetails(workoutId);

    // Fetch the exercises for the workout
    final workoutExercises = await dbHelper.getWorkoutExercises(workoutId);

    return {
      'workoutDetails': workoutDetails,
      'workoutExercises': workoutExercises,
    };
  }

  String _formatWorkoutTime(int workoutTimer) {
    final hours = workoutTimer ~/ 3600;
    final minutes = (workoutTimer % 3600) ~/ 60;

    if (hours > 0) {
      return '$hours hours $minutes minutes';
    } else {
      return '$minutes minutes';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Access the current theme

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Summary'),
        backgroundColor: theme.appBarTheme.backgroundColor, // Use theme app bar color
        foregroundColor: theme.appBarTheme.foregroundColor, // Use theme app bar text color
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Delete Workout'),
                    content: const Text('Are you sure you want to delete this workout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false), // Cancel
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true), // Confirm
                        child: const Text('Delete'),
                      ),
                    ],
                  );
                },
              );

              if (confirm == true) {
                await _deleteWorkout(context);
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchWorkoutSummary(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading workout summary.',
                style: theme.textTheme.bodyLarge, // Use theme text style
              ),
            );
          } else if (!snapshot.hasData) {
            return Center(
              child: Text(
                'No workout summary found.',
                style: theme.textTheme.bodyLarge, // Use theme text style
              ),
            );
          } else {
            final workoutDetails = snapshot.data!['workoutDetails'] as Map<String, dynamic>;
            final workoutExercises = snapshot.data!['workoutExercises'] as List<Map<String, dynamic>>;

            final workoutTimer = workoutDetails['workout_timer'] as int? ?? 0; // Default to 0 if null
            final formattedTime = _formatWorkoutTime(workoutTimer);

            return Column(
              children: [
                // Display the template name and workout time
                Container(
                  padding: const EdgeInsets.all(16),
                  color: theme.cardColor, // Use theme card color
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workoutDetails['template_name'] ?? 'Unknown Template',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ), // Use theme text style
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formattedTime,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                        ), // Use theme text style
                      ),
                    ],
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