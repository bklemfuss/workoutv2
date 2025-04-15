import 'package:flutter/material.dart';

class ExerciseListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> exercises;

  const ExerciseListWidget({super.key, required this.exercises});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Access the current theme
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        return Card(
          margin: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.01,
          ),
          elevation: 4,
          color: theme.cardColor, // Use the theme's card color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Exercise Name
                Text(
                  exercise['exercise_name'] ?? exercise['name'] ?? 'Unknown Exercise', // Use exercise_name
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ), // Use the theme's text style
                ),
                SizedBox(height: screenHeight * 0.01),
                // Display Sets, Reps, and Weight
                Text(
                  'Sets: ${exercise['sets']}',
                  style: theme.textTheme.bodyMedium, // Use the theme's text style
                ),
                Text(
                  'Reps: ${exercise['reps']}',
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  'Weight: ${exercise['weight']} kg',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}