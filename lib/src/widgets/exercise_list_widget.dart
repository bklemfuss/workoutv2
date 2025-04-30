import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/unit_provider.dart'; // Import UnitProvider

class ExerciseListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> exercises; // List of workoutExercise records for a specific workout

  const ExerciseListWidget({super.key, required this.exercises});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unitProvider = Provider.of<UnitProvider>(context);
    final isMetric = unitProvider.unitSystem == 'Metric';

    // Group exercises by name to display them under a common header
    final Map<String, List<Map<String, dynamic>>> groupedExercises = {};
    for (var exercise in exercises) {
      final name = exercise['exercise_name'] as String? ?? 'Unknown Exercise';
      (groupedExercises[name] ??= []).add(exercise);
    }

    final exerciseNames = groupedExercises.keys.toList();

    // Use ListView.builder to create a list of cards, one for each exercise name
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0), // Add overall padding
      itemCount: exerciseNames.length,
      itemBuilder: (context, index) {
        final exerciseName = exerciseNames[index];
        // Get all workoutExercise entries for this specific exercise name within the current workout
        final exerciseEntries = groupedExercises[exerciseName]!;
        final weightUnit = isMetric ? 'kg' : 'lbs';

        // Each exercise gets its own Card
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0), // Vertical spacing between cards
          elevation: 2,
          color: theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Padding inside the card
            child: Column( // Column allows vertical arrangement and auto-sizing height
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Exercise Name Header for the card
                Text(
                  exerciseName,
                  style: theme.textTheme.titleMedium?.copyWith( // Use titleMedium for exercise name
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12), // Space below header
                // List each weight/rep entry vertically
                ...exerciseEntries.map((entry) {
                  // Safely access weight and reps, providing defaults
                  final weight = entry['weight'] ?? 0;
                  final reps = entry['reps'] ?? 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0), // Spacing between entries
                    child: Text(
                      '${weight} $weightUnit x $reps reps', // Display weight, unit, and reps
                      style: theme.textTheme.bodyMedium, // Use bodyMedium for entries
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }
}