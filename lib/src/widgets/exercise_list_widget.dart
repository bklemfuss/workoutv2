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
                  exercise['name'] ?? 'Unknown Exercise',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ), // Use the theme's text style
                ),
                SizedBox(height: screenHeight * 0.01),
                // Input Fields for Weight, Sets, Reps
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInputField(
                      context,
                      label: 'Weight',
                      initialValue: exercise['weight']?.toString() ?? '',
                      theme: theme,
                    ),
                    _buildInputField(
                      context,
                      label: 'Sets',
                      initialValue: exercise['sets']?.toString() ?? '',
                      theme: theme,
                    ),
                    _buildInputField(
                      context,
                      label: 'Reps',
                      initialValue: exercise['reps']?.toString() ?? '',
                      theme: theme,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputField(
    BuildContext context, {
    required String label,
    required String initialValue,
    required ThemeData theme,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium, // Use the theme's text style
        ),
        SizedBox(
          width: screenWidth * 0.15,
          child: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: theme.inputDecorationTheme.fillColor, // Use theme's input field color
            ),
            style: theme.textTheme.bodyMedium, // Use the theme's text style
            controller: TextEditingController(text: initialValue),
          ),
        ),
      ],
    );
  }
}