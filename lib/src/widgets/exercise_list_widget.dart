import 'package:flutter/material.dart';

class ExerciseListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> exercises;

  const ExerciseListWidget({super.key, required this.exercises});

  @override
  Widget build(BuildContext context) {
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
                  style: TextStyle(
                    fontSize: screenHeight * 0.02,
                    fontWeight: FontWeight.bold,
                  ),
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
                    ),
                    _buildInputField(
                      context,
                      label: 'Sets',
                      initialValue: exercise['sets']?.toString() ?? '',
                    ),
                    _buildInputField(
                      context,
                      label: 'Reps',
                      initialValue: exercise['reps']?.toString() ?? '',
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

  Widget _buildInputField(BuildContext context,
      {required String label, required String initialValue}) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: screenHeight * 0.015),
        ),
        SizedBox(
          width: screenWidth * 0.15,
          child: TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              border: OutlineInputBorder(),
            ),
            controller: TextEditingController(text: initialValue),
          ),
        ),
      ],
    );
  }
}