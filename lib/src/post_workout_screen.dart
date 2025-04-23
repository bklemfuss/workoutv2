import 'package:flutter/material.dart';
import 'services/database_helper.dart';

class PostWorkoutScreen extends StatelessWidget {
  const PostWorkoutScreen({Key? key}) : super(key: key);

  Future<Map<String, dynamic>> _fetchWorkoutDetails(BuildContext context) async {
    final workoutId = ModalRoute.of(context)!.settings.arguments as int;
    final dbHelper = DatabaseHelper();
    final workoutDetails = await dbHelper.getWorkoutDetails(workoutId);
    final workoutExercises = await dbHelper.getWorkoutExercises(workoutId);
    final totalWorkouts = (await dbHelper.getWorkouts()).length;

    return {
      'workoutDetails': workoutDetails,
      'workoutExercises': workoutExercises,
      'totalWorkouts': totalWorkouts,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Summary')),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _fetchWorkoutDetails(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text('No data available.'));
                }

                final workoutDetails = snapshot.data!['workoutDetails'];
                final workoutExercises = snapshot.data!['workoutExercises'];
                final totalWorkouts = snapshot.data!['totalWorkouts'];

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'You finished your $totalWorkouts workout!',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Workout: ${workoutDetails['template_name']}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: workoutExercises.length,
                          itemBuilder: (context, index) {
                            final exercise = workoutExercises[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title: Text(exercise['exercise_name']),
                                subtitle: Text(
                                    'Sets: ${exercise['sets']}, Reps: ${exercise['reps']}, Weight: ${exercise['weight']}'),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Add Done button at the bottom
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/dashboard',
                    (route) => false,
                  );
                },
                child: const Text('Done'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}