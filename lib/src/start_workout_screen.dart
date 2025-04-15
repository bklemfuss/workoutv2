import 'package:flutter/material.dart';
import 'services/database_helper.dart';
import 'widgets/bottom_nav_bar.dart';

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
      body: Column(
        children: [
          // Scrollable list of exercises (90% of the screen height)
          Expanded(
            flex: 9,
            child: FutureBuilder<List<Map<String, dynamic>>>(
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
          ),
          // Bottom section with "Start Workout" button (10% of the screen height)
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.blue[100], // Optional background color
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Ensure exercises are fetched and passed correctly
                    _fetchExercises().then((exercises) {
                      Navigator.pushNamed(
                        context,
                        '/in_progress_workout',
                        arguments: {
                          'template_id': templateId, // Pass the template_id
                          'exercises': exercises,    // Pass the exercises list
                        },
                      );
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Start Workout',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(
        currentIndex: 0, // Set the appropriate index for this screen
      ),
    );
  }
}