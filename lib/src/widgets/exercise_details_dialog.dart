import 'package:flutter/material.dart';

class ExerciseDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> exercise;

  const ExerciseDetailsDialog({Key? key, required this.exercise}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: theme.cardColor, // Use the card color from the theme
      elevation: 8, // Add elevation for a solid appearance
      child: Container(
        height: screenHeight * 0.6, // 60% of the screen height
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          children: [
            // Top 40% for the image
            Container(
              height: screenHeight * 0.24, // 40% of the dialog height
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(exercise['image_url'] ?? ''),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02), // Spacing

            // Exercise name
            Text(
              exercise['name'] ?? 'Unknown Exercise',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color, // Use theme text color
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.01), // Spacing

            // Exercise description
            Text(
              exercise['Description'] ?? 'No description available.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color, // Use theme text color
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.02), // Spacing

            // Scrollable instructions
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  exercise['instructions'] ?? 'No instructions available.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color, // Use theme text color
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}