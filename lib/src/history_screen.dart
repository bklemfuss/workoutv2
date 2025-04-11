import 'package:flutter/material.dart';
import 'services/database_helper.dart';
import 'widgets/app_toolbar.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/floating_start_new_workout_button.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  Future<List<Map<String, dynamic>>> _fetchWorkouts() async {
    return await DatabaseHelper().getWorkoutsWithDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppToolbar(title: 'History'),
      body: Column(
        children: [
          // Top Section (10% of the screen height)
          Container(
            height: MediaQuery.of(context).size.height * 0.1,
            color: Colors.blue[100], // Placeholder color
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.calendar_today, size: 28),
                  onPressed: () {
                    // Add functionality for calendar icon if needed
                  },
                ),
              ],
            ),
          ),
          // Remaining Section (90% of the screen height)
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchWorkouts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error loading workouts.'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No workouts found.'));
                } else {
                  final workouts = snapshot.data!;
                  return ListView.builder(
                    itemCount: workouts.length,
                    itemBuilder: (context, index) {
                      final workout = workouts[index];
                      return ListTile(
                        title: Text(workout['template_name'] ?? 'Unknown Template'),
                        subtitle: Text(
                          'Date: ${workout['date']}\nUser: ${workout['user_name'] ?? 'Unknown User'}',
                        ),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () {
                          // Navigate to workout summary screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WorkoutSummaryScreen(
                                workoutId: workout['workout_id'],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: const FloatingStartNewWorkoutButton(), // Use the custom FAB widget
      bottomNavigationBar: const BottomNavBar(
        currentIndex: 1,
      ),
    );
  }
}

class WorkoutSummaryScreen extends StatelessWidget {
  final int workoutId;

  const WorkoutSummaryScreen({super.key, required this.workoutId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Workout Summary (ID: $workoutId)'),
      ),
      body: Center(
        child: Text(
          'Details for Workout ID: $workoutId',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}