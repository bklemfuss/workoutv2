import 'package:flutter/material.dart';
import 'services/database_helper.dart';

class StartWorkoutScreen extends StatelessWidget {
  final int templateId;

  const StartWorkoutScreen({Key? key, required this.templateId}) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchExercises() async {
    return await DatabaseHelper().getExercisesByTemplateId(templateId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Workout'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchExercises(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading exercises.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No exercises found.'));
          } else {
            final exercises = snapshot.data!;
            return ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                return ListTile(
                  title: Text(exercise['name'] ?? 'Unknown Exercise'),
                  subtitle: Text(exercise['Description'] ?? 'No description available'),
                  onTap: () {
                    // Add functionality for tapping an exercise if needed
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}