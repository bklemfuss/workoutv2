import 'package:flutter/material.dart';

class ExerciseInputCard extends StatefulWidget {
  final Map<String, dynamic> exercise;
  final Function(Map<String, dynamic>) onChanged;

  const ExerciseInputCard({super.key, required this.exercise, required this.onChanged});

  @override
  State<ExerciseInputCard> createState() => _ExerciseInputCardState();
}

class _ExerciseInputCardState extends State<ExerciseInputCard> {
  late TextEditingController setsController;
  late TextEditingController repsController;
  late TextEditingController weightController;

  @override
  void initState() {
    super.initState();
    setsController = TextEditingController(text: widget.exercise['sets']?.toString() ?? '');
    repsController = TextEditingController(text: widget.exercise['reps']?.toString() ?? '');
    weightController = TextEditingController(text: widget.exercise['weight']?.toString() ?? '');
  }

  void _onFieldChanged() {
    widget.onChanged({
      'exercise_id': widget.exercise['exercise_id'],
      'sets': int.tryParse(setsController.text) ?? 0,
      'reps': int.tryParse(repsController.text) ?? 0,
      'weight': double.tryParse(weightController.text) ?? 0.0,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Access the current theme
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

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
              widget.exercise['exercise_name'] ?? widget.exercise['name'] ?? 'Unknown Exercise',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ), // Use the theme's text style
            ),
            SizedBox(height: screenHeight * 0.01),
            // Input Fields for Sets, Reps, and Weight
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInputField(
                  label: 'Sets',
                  controller: setsController,
                  onChanged: _onFieldChanged,
                ),
                _buildInputField(
                  label: 'Reps',
                  controller: repsController,
                  onChanged: _onFieldChanged,
                ),
                _buildInputField(
                  label: 'Weight',
                  controller: weightController,
                  onChanged: _onFieldChanged,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onChanged,
  }) {
    final theme = Theme.of(context);
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
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            ),
            style: theme.textTheme.bodyMedium, // Use the theme's text style
            onChanged: (value) => onChanged(),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    setsController.dispose();
    repsController.dispose();
    weightController.dispose();
    super.dispose();
  }
}